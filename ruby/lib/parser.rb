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
    expression
  rescue ParseError
    nil
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
    equality
  end

  def equality
    expr = comparison
    while match :bang_equal, :equal_equal
      operator = previous
      right = comparison
      expr = Binary.new expr, operator, right
    end

    expr
  end

  def comparison
    expr = term

    while match :greater, :greater_equal, :less, :less_equal
      operator = previous
      right = term
      expr = Binary.new expr, operator, right
    end

    expr
  end

  def term
    expr = factor

    while match :minus, :plus
      operator = previous
      right = factor
      expr = Binary.new expr, operator, right
    end

    expr
  end

  def factor
    expr = unary

    while match :slash, :star
      operator = previous
      right = unary
      expr = Binary.new expr, operator, right
    end

    expr
  end

  def unary
    if match :bang, :minus
      operator = previous
      right = unary
      return Unary.new operator, right
    end

    primary
  end

  def primary
    return Literal.new(false) if match :false
    return Literal.new(true) if match :true
    return Literal.new(nil) if match :nil

    return Literal.new(previous.literal) if match :number, :string

    if match :left_paren
      expr = expression
      consume :right_paren, "expect ')' after expression."
      return Grouping.new expr
    end

    raise error peek, 'expect expression.'
  end
end
