# frozen_string_literal: true

class Environment
  def initialize(enclosing = nil)
    @enclosing = enclosing
    @values = {}
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name.lexeme] if @values.key? name.lexeme

    return @enclosing.get name unless @enclosing.nil?

    raise LoxRuntimeError.new name, "undefined variable #{name.lexeme}."
  end

  def assign(name, value)
    if @values.key? name.lexeme
      @values[name.lexeme] = value
      return
    end

    unless @enclosing.nil?
      @enclosing.assign name, value
      return
    end

    raise LoxRuntimeError.new name, "undefined variable #{name.lexeme}."
  end
end
