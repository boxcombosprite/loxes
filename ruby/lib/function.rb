# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'

class Function
  include Callable

  def initialize(declaration)
    @declaration = declaration
  end

  def _call(interpreter, arguments)
    environment = Environment.new interpreter.globals
    @declaration.params.zip(arguments).each do |p, a|
      environment.define p.lexeme, a
    end

    interpreter.execute_block @declaration.body, environment
    nil
  end

  def arity
    @declaration.params.length
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
