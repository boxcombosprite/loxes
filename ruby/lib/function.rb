# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'

class Function
  include Callable

  def initialize(declaration, closure)
    @declaration = declaration
    @closure = closure
  end

  def _call(interpreter, arguments)
    environment = Environment.new @closure
    @declaration.params.zip(arguments).each do |p, a|
      environment.define p.lexeme, a
    end

    begin
      interpreter.execute_block @declaration.body, environment
    rescue Return => e
      return e.value
    end
    nil
  end

  def arity
    @declaration.params.length
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
