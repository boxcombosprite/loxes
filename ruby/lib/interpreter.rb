# frozen_string_literal: true

require_relative 'ast'
require_relative 'lox'

class LoxRuntimeError < RuntimeError
  attr_reader :token

  def initialize(token, message)
    @token = token
    super message
  end
end

class Interpreter
  include Visitor

  def interpret(expression)
    value = evaluate expression
    puts stringify(value)
  rescue LoxRuntimeError => e
    Lox.runtime_error e
  end

  def visit_literal(expr)
    expr.value
  end

  def visit_grouping(expr)
    evaluate expr.expression
  end

  def visit_unary(expr)
    right = evaluate expr.right

    case expr.operator.type
    when :minus
      check_number_operand expr.operator, right
      -right
    when :bang then !right # lox uses same truthiness as ruby
    end
  end

  def visit_binary(expr)
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
end
