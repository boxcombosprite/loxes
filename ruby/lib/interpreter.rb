# frozen_string_literal: true

require_relative 'ast'
require_relative 'lox'
require_relative 'environment'

class LoxRuntimeError < RuntimeError
  attr_reader :token

  def initialize(token, message)
    @token = token
    super message
  end
end

class Interpreter
  include Expr::Visitor
  include Stmt::Visitor

  def initialize
    @environment = Environment.new
  end

  def interpret(statements)
    statements.each { |s| execute s }
  rescue LoxRuntimeError => e
    Lox.runtime_error e
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate expr.expression
  end

  def visit_unary_expr(expr)
    right = evaluate expr.right

    case expr.operator.type
    when :minus
      check_number_operand expr.operator, right
      -right
    when :bang then !right # lox uses same truthiness as ruby
    end
  end

  def visit_variable_expr(expr)
    @environment.get expr.name
  end

  def visit_binary_expr(expr)
    left = evaluate expr.left
    right = evaluate expr.right

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

  def visit_assign_expr(expr)
    value = evaluate expr.value
    @environment.assign expr.name, value
    value
  end

  def visit_expression_stmt(stmt)
    evaluate stmt.expression
    nil
  end

  def visit_print_stmt(stmt)
    value = evaluate stmt.expression
    puts stringify(value)
    nil
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer.nil? ? nil : evaluate(stmt.initializer)

    @environment.define stmt.name.lexeme, value
    nil
  end

  def visit_block_stmt(stmt)
    execute_block stmt.statements, Environment.new(@environment)
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

  def evaluate(expr)
    expr.accept self
  end

  def execute(stmt)
    stmt.accept self
  end

  def execute_block(statements, environment)
    previous = @environment
    begin
      @environment = environment

      statements.each { |s| execute s }
    ensure
      @environment = previous
    end
  end
end
