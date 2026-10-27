module Acceptor
  def accept(o)
    raise NotImplementedError
  end
end

module Expr
  class Binary
    include Acceptor
    def accept(visitor)
      visitor.visit_binary self
    end

    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end
    attr_reader :left, :operator, :right
  end

  class Grouping
    include Acceptor
    def accept(visitor)
      visitor.visit_grouping self
    end

    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  class Literal
    include Acceptor
    def accept(visitor)
      visitor.visit_literal self
    end

    def initialize(value)
      @value = value
    end
    attr_reader :value
  end

  class Unary
    include Acceptor
    def accept(visitor)
      visitor.visit_unary self
    end

    def initialize(operator, right)
      @operator = operator
      @right = right
    end
    attr_reader :operator, :right
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
end

module Stmt
  class Expression
    include Acceptor
    def accept(visitor)
      visitor.visit_expression self
    end

    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  class Print
    include Acceptor
    def accept(visitor)
      visitor.visit_print self
    end

    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  module Visitor
    def visit_expression(o)
      raise NotImplementedError
    end

    def visit_print(o)
      raise NotImplementedError
    end
  end
end
