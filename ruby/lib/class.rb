# frozen_string_literal: true

require_relative 'callable'

class LoxClass
  include Callable

  attr_reader :name, :superclass

  def initialize(name, superclass, methods)
    @name = name
    @superclass = superclass
    @methods = methods
  end

  def find_method(name)
    return @methods[name] if @methods.key? name

    return superclass.find_method(name) unless superclass.nil?

    nil
  end

  def to_s
    @name
  end

  def _call(interpreter, arguments)
    instance = LoxInstance.new self
    initializer = find_method 'init'
    initializer&.bind(instance)&._call interpreter, arguments

    instance
  end

  def arity
    initializer = find_method 'init'
    return 0 if initializer.nil?

    initializer.arity
  end
end

class LoxInstance
  def initialize(klass)
    @klass = klass
    @fields = {}
  end

  def get(name)
    return @fields[name.lexeme] if @fields.key? name.lexeme

    method = @klass.find_method name.lexeme
    return method.bind self unless method.nil?

    raise LoxRuntimeError.new name, "undefined property '#{name.lexeme}'."
  end

  def set(name, value)
    @fields[name.lexeme] = value
  end

  def to_s
    "#{@klass.name} instance"
  end
end
