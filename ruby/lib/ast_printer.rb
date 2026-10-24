# frozen_string_literal: true

require_relative 'ast'
require_relative 'lexer'

class AstPrinter
  include Visitor

  def print(expr)
    expr.accept self
  end

  def visit_binary(expr)
    parenthesize expr.operator.lexeme, expr.left, expr.right
  end

  def visit_grouping(expr)
    parenthesize 'group', expr.expression
  end

  def visit_literal(expr)
    return 'nil' if expr.value.nil?

    expr.value.to_s
  end

  def visit_unary(expr)
    parenthesize expr.operator.lexeme, expr.right
  end

  def parenthesize(name, *exprs)
    s = "(#{name}"

    exprs.each do |e|
      s += ' '
      s += e.accept self
    end

    s += ')'
  end
end

# expression = Binary.new(
#   Unary.new(
#     Token.new(:minus, '-', nil, 1),
#     Literal.new(123)
#   ),
#   Token.new(:star, '*', nil, 1),
#   Grouping.new(
#     Literal.new(45.67)
#   )
# )
#
# puts AstPrinter.new.print(expression)
