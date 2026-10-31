# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'

class Function
  include Callable

  def initialize(declaration, closure, is_initializer)
    @declaration = declaration
    @closure = closure
    @is_initilizer = is_initializer
  end

  def bind(instance)
    environment = Environment.new @closure
    environment.define 'this', instance

    Function.new @declaration, environment, @is_initializer
  end

  def _call(interpreter, arguments)
    environment = Environment.new @closure
    @declaration.params.zip(arguments).each do |p, a|
      environment.define p.lexeme, a
    end

    begin
      interpreter.eval_block @declaration.body, environment
    rescue Return => e
      return @closure.get_at 0, 'this' if @is_initializer

      return e.value
    end

    return @closure.get_at 0, 'this' if @is_initializer

    nil
  end

  def arity
    @declaration.params.length
  end

  def to_s
    "<fn #{@declaration.name.lexeme}>"
  end
end
