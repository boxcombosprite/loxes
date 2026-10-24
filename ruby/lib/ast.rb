module Expr
  def accept(o)
    raise NotImplementedError
  end
end

class Binary
  include Expr
  def accept(visitor)
    visitor.visit_binary self
  end
  def initialize(left, operator, right)
    @left = left
    @operator = operator
    @right = right
  end
  attr_reader :left
  attr_reader :operator
  attr_reader :right
end

class Grouping
  include Expr
  def accept(visitor)
    visitor.visit_grouping self
  end
  def initialize(expression)
    @expression = expression
  end
  attr_reader :expression
end

class Literal
  include Expr
  def accept(visitor)
    visitor.visit_literal self
  end
  def initialize(value)
    @value = value
  end
  attr_reader :value
end

class Unary
  include Expr
  def accept(visitor)
    visitor.visit_unary self
  end
  def initialize(operator, right)
    @operator = operator
    @right = right
  end
  attr_reader :operator
  attr_reader :right
end

module Visitor
  def visit_binary(o)
    raise NotImplementedError
  end
  def visit_grouping(o)
    raise NotImplementedError
  end
  def visit_literal(o)
    raise NotImplementedError
  end
  def visit_unary(o)
    raise NotImplementedError
  end
end
