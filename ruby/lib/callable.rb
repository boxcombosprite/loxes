# frozen_string_literal: true

module Callable
  def _call(interpreter, arguments)
    raise NotImplementedError
  end

  def arity
    raise NotImplementedError
  end
end
