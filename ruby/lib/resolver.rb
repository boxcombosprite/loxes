# frozen_string_literal: true

require_relative 'ast'
require_relative 'lox'

class Resolver
  include Stmt::Visitor
  include Expr::Visitor

  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
    @current_function_type = :ft_none
  end

  def visit_block_stmt(stmt)
    begin_scope
    resolve stmt.statements
    end_scope
    nil
  end

  def visit_expression_stmt(stmt)
    resolve stmt.expression
    nil
  end

  def visit_function_stmt(stmt)
    declare stmt.name
    define stmt.name
    resolve_function stmt, :ft_function
    nil
  end

  def visit_if_stmt(stmt)
    resolve stmt.condition
    resolve stmt.then_branch
    resolve stmt.else_branch unless stmt.else_branch.nil?
    nil
  end

  def visit_print_stmt(stmt)
    resolve stmt.expression
    nil
  end

  def visit_return_stmt(stmt)
    Lox.parse_error stmt.keyword, "can't return from top-level code." if @current_function_type == :ft_none
    resolve stmt.value unless stmt.value.nil?
    nil
  end

  def visit_var_stmt(stmt)
    declare stmt.name
    resolve stmt.initializer unless stmt.initializer.nil?
    define stmt.name
    nil
  end

  def visit_while_stmt(stmt)
    resolve stmt.condition
    resolve stmt.body
    nil
  end

  def visit_variable_expr(expr)
    if !@scopes.empty? && @scopes.last[expr.name.lexeme] == false
      Lox.parse_error expr.name, "can't read local variable in its own initializer."
    end

    resolve_local expr, expr.name
    nil
  end

  def visit_assign_expr(expr)
    resolve expr.value
    resolve_local expr, expr.name
    nil
  end

  def visit_binary_expr(expr)
    resolve expr.left
    resolve expr.right
    nil
  end

  def visit_call_expr(expr)
    resolve expr.callee

    expr.arguments.each { |a| resolve a }

    nil
  end

  def visit_grouping_expr(expr)
    resolve expr.expression
    nil
  end

  def visit_literal_expr(_expr)
    nil
  end

  def visit_logical_expr(expr)
    resolve expr.left
    resolve expr.right
    nil
  end

  def visit_unary_expr(expr)
    resolve expr.right
    nil
  end

  def resolve(x)
    if x.is_a? Array
      x.each { |t| resolve t }
    else
      x.accept self
    end
  end

  private

  def resolve_function(function, type)
    enclosing_function_type = @current_function_type
    @current_function_type = type

    begin_scope
    function.params.each do |p|
      declare p
      define p
    end
    resolve function.body
    end_scope
    @current_function_type = enclosing_function_type
  end

  def begin_scope
    @scopes.push({})
  end

  def end_scope
    @scopes.pop
  end

  def declare(name)
    return if @scopes.empty?

    scope = @scopes.last

    Lox.parse_error name, 'already a variable with this name in this scope.' if scope.key?(name.lexeme)

    scope[name.lexeme] = false
  end

  def define(name)
    return if @scopes.empty?

    @scopes.last[name.lexeme] = true
  end

  def resolve_local(expr, name)
    @scopes.to_enum.with_index.reverse_each do |s, i|
      if s.key? name.lexeme
        @interpreter.resolve expr, @scopes.length - 1 - i
        break
      end
    end
  end
end
