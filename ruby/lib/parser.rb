# frozen_string_literal: true

require_relative 'ast'
require_relative 'lox'

class Parser
  class ParseError < RuntimeError
  end

  def initialize(tokens)
    @current = 0
    @tokens = tokens
  end

  def parse
    statements = []
    statements << declaration until at_end?

    statements
  end

  private

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error(token, message)
    Lox.parse_error token, message

    ParseError.new
  end

  def synchronize
    advance
    until at_end?
      return if previous.type == :semicolon

      case peek.type
      when :class, :for, :fun, :if, :print, :return, :var, :while then return
      end

      advance
    end
  end

  def at_end?
    peek.type == :eof
  end

  def advance
    @current += 1 unless at_end?

    previous
  end

  def check(type)
    return false if at_end?

    peek.type == type
  end

  def match(*types)
    types.each do |t|
      if check t
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if check type

    raise error peek, message
  end

  def expression
    assignment
  end

  def declaration
    return var_declaration if match :var

    statement
  rescue ParseError
    synchronize
    nil
  end

  def statement
    return print_statement if match :print
    return Stmt::Block.new block if match :left_brace

    expression_statement
  end

  def print_statement
    value = expression
    consume :semicolon, "expect ';' after value."
    Stmt::Print.new value
  end

  def var_declaration
    name = consume :identifier, 'expect variable name.'

    initializer = match(:equal) ? expression : nil

    consume :semicolon, "expect ';' after variable declaration."
    Stmt::Var.new name, initializer
  end

  def expression_statement
    expr = expression
    consume :semicolon, "expect ';' after value."
    Stmt::Expression.new expr
  end

  def block
    statements = []

    statements << declaration until check(:right_brace) || at_end?

    consume :right_brace, "expect '}' after block."
    statements
  end

  def assignment
    expr = equality

    if match :equal
      equals = previous
      value = assignment

      if expr.is_a? Expr::Variable
        name = expr.name
        return Expr::Assign.new name, value
      end

      error equals, 'invalid assignment target.'
    end

    expr
  end

  def equality
    expr = comparison
    while match :bang_equal, :equal_equal
      operator = previous
      right = comparison
      expr = Expr::Binary.new expr, operator, right
    end

    expr
  end

  def comparison
    expr = term

    while match :greater, :greater_equal, :less, :less_equal
      operator = previous
      right = term
      expr = Expr::Binary.new expr, operator, right
    end

    expr
  end

  def term
    expr = factor

    while match :minus, :plus
      operator = previous
      right = factor
      expr = Expr::Binary.new expr, operator, right
    end

    expr
  end

  def factor
    expr = unary

    while match :slash, :star
      operator = previous
      right = unary
      expr = Expr::Binary.new expr, operator, right
    end

    expr
  end

  def unary
    if match :bang, :minus
      operator = previous
      right = unary
      return Expr::Unary.new operator, right
    end

    primary
  end

  def primary
    return Expr::Literal.new(false) if match :false
    return Expr::Literal.new(true) if match :true
    return Expr::Literal.new(nil) if match :nil
    return Expr::Literal.new(previous.literal) if match :number, :string
    return Expr::Variable.new(previous) if match :identifier

    if match :left_paren
      expr = expression
      consume :right_paren, "expect ')' after expression."
      return Expr::Grouping.new expr
    end

    raise error peek, 'expect expression.'
  end
end
