# frozen_string_literal: true

require_relative 'ast'
require_relative 'lox'
require_relative 'callable'
require_relative 'function'
require_relative 'environment'

class LoxRuntimeError < RuntimeError
  attr_reader :token

  def initialize(token, message)
    @token = token
    super message
  end
end

class Return < RuntimeError
  attr_reader :value

  def initialize(value)
    @value = value
    super
  end
end

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  attr_reader :globals

  def initialize
    @globals = Environment.new
    @globals.define 'clock', Class.new do
      include Callable
      def arity
        0
      end

      def _call(_interpreter, _arguments)
        Time.now.to_f
      end

      def to_s
        '<native fn>'
      end
    end.new

    @environment = globals
    @locals = {}
  end

  def interpret(statements)
    statements.each { |s| eval_ s }
  rescue LoxRuntimeError => e
    Lox.runtime_error e
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_logical_expr(expr)
    left = eval_ expr.left

    if expr.operator.type == :or
      return left if left
    else
      return left unless left
    end

    eval_ expr.right
  end

  def visit_grouping_expr(expr)
    eval_ expr.expression
  end

  def visit_unary_expr(expr)
    right = eval_ expr.right

    case expr.operator.type
    when :minus
      check_number_operand expr.operator, right
      -right
    when :bang then !right # lox uses same truthiness as ruby
    end
  end

  def visit_variable_expr(expr)
    lookup_variable expr.name, expr
  end

  def lookup_variable(name, expr)
    distance = @locals[expr]
    if !distance.nil?
      @environment.get_at distance, name.lexeme
    else
      @globals.get name
    end
  end

  def visit_binary_expr(expr)
    left = eval_ expr.left
    right = eval_ expr.right

    case expr.operator.type
    when :greater
      check_number_operands expr.operator, left, right
      left > right
    when :greater_equal
      check_number_operands expr.operator, left, right
      left >= right
    when :less
      check_number_operands expr.operator, left, right
      left < right
    when :less_equal
      check_number_operands expr.operator, left, right
      left <= right
    when :bang_equal
      check_number_operands expr.operator, left, right
      !(left == right) # use the same equalness as ruby as well
    when :equal_equal
      check_number_operands expr.operator, left, right
      left == right
    when :minus
      check_number_operands expr.operator, left, right
      left - right
    when :plus
      return left + right if (left.is_a? Float) && (right.is_a? Float)
      return left + right if (left.is_a? String) && (right.is_a? String)

      raise LoxRuntimeError.new expr.operator, 'operands must be two numbers or two strings'
    when :slash
      check_number_operands expr.operator, left, right
      left / right
    when :star
      check_number_operands expr.operator, left, right
      left * right
    end
  end

  def visit_call_expr(expr)
    function = eval_ expr.callee

    arguments = []
    expr.arguments.each { |a| arguments << eval_(a) }

    unless function.class.method_defined? :_call
      raise LoxRuntimeError.new expr.paren, 'can only call functions and classes.'
    end

    unless arguments.length == function.arity
      raise LoxRuntimeError.new expr.paren, "expected #{function.arity} args but got #{arguments.length}."
    end

    function._call self, arguments
  end

  def visit_assign_expr(expr)
    value = eval_ expr.value

    distance = @locals[expr]
    if !distance.nil?
      @environment.assign_at distance, expr.name, value
    else
      @globals.assign expr.name, value
    end

    value
  end

  def visit_expression_stmt(stmt)
    eval_ stmt.expression
    nil
  end

  def visit_function_stmt(stmt)
    function = Function.new stmt, @environment
    @environment.define stmt.name.lexeme, function
    nil
  end

  def visit_if_stmt(stmt)
    if eval_ stmt.condition
      eval_ stmt.then_branch
    elsif !stmt.else_branch.nil?
      eval_ stmt.else_branch
    end
    nil
  end

  def visit_print_stmt(stmt)
    value = eval_ stmt.expression
    puts stringify(value)
    nil
  end

  def visit_return_stmt(stmt)
    value = stmt.value.nil? ? nil : eval_(stmt.value)

    raise Return.new value
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer.nil? ? nil : eval_(stmt.initializer)

    @environment.define stmt.name.lexeme, value
    nil
  end

  def visit_while_stmt(stmt)
    eval_ stmt.body while eval_ stmt.condition
    nil
  end

  def visit_block_stmt(stmt)
    eval_block stmt.statements, Environment.new(@environment)
  end

  def eval_block(statements, environment)
    previous = @environment
    begin
      @environment = environment

      statements.each { |s| eval_ s }
    ensure
      @environment = previous
    end
  end

  private

  def stringify(o)
    return 'nil' if o.nil?

    if o.is_a? Float
      text = o.to_s
      text = text[0, text.length - 2] if text.end_with? '.0'
      return text
    end

    o.to_s
  end

  def check_number_operand(operator, operand)
    return if operand.is_a? Float

    raise LoxRuntimeError.new operator, 'operand must be a number.'
  end

  def check_number_operands(operator, left, right)
    return if (left.is_a? Float) && (right.is_a? Float)

    raise LoxRuntimeError.new operator, 'operands must be numbers.'
  end

  def eval_(node)
    node.accept self
  end

  def resolve(expr, depth)
    @locals[expr] = depth
  end
end
