module Acceptor
  def accept(o)
    raise NotImplementedError
  end
end

module Expr
  class Assign
    include Acceptor
    def accept(visitor)
      visitor.visit_assign_expr self
    end
    def initialize(name, value)
      @name = name
      @value = value
    end
    attr_reader :name
    attr_reader :value
  end

  class Binary
    include Acceptor
    def accept(visitor)
      visitor.visit_binary_expr self
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

  class Call
    include Acceptor
    def accept(visitor)
      visitor.visit_call_expr self
    end
    def initialize(callee, paren, arguments)
      @callee = callee
      @paren = paren
      @arguments = arguments
    end
    attr_reader :callee
    attr_reader :paren
    attr_reader :arguments
  end

  class Grouping
    include Acceptor
    def accept(visitor)
      visitor.visit_grouping_expr self
    end
    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  class Literal
    include Acceptor
    def accept(visitor)
      visitor.visit_literal_expr self
    end
    def initialize(value)
      @value = value
    end
    attr_reader :value
  end

  class Logical
    include Acceptor
    def accept(visitor)
      visitor.visit_logical_expr self
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

  class Unary
    include Acceptor
    def accept(visitor)
      visitor.visit_unary_expr self
    end
    def initialize(operator, right)
      @operator = operator
      @right = right
    end
    attr_reader :operator
    attr_reader :right
  end

  class Variable
    include Acceptor
    def accept(visitor)
      visitor.visit_variable_expr self
    end
    def initialize(name)
      @name = name
    end
    attr_reader :name
  end

  module Visitor
    def visit_assign_expr(o)
      raise NotImplementedError
    end
    def visit_binary_expr(o)
      raise NotImplementedError
    end
    def visit_call_expr(o)
      raise NotImplementedError
    end
    def visit_grouping_expr(o)
      raise NotImplementedError
    end
    def visit_literal_expr(o)
      raise NotImplementedError
    end
    def visit_logical_expr(o)
      raise NotImplementedError
    end
    def visit_unary_expr(o)
      raise NotImplementedError
    end
    def visit_variable_expr(o)
      raise NotImplementedError
    end
  end
end
module Stmt
  class Block
    include Acceptor
    def accept(visitor)
      visitor.visit_block_stmt self
    end
    def initialize(statements)
      @statements = statements
    end
    attr_reader :statements
  end

  class Expression
    include Acceptor
    def accept(visitor)
      visitor.visit_expression_stmt self
    end
    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  class Function
    include Acceptor
    def accept(visitor)
      visitor.visit_function_stmt self
    end
    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end
    attr_reader :name
    attr_reader :params
    attr_reader :body
  end

  class If
    include Acceptor
    def accept(visitor)
      visitor.visit_if_stmt self
    end
    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end
    attr_reader :condition
    attr_reader :then_branch
    attr_reader :else_branch
  end

  class Print
    include Acceptor
    def accept(visitor)
      visitor.visit_print_stmt self
    end
    def initialize(expression)
      @expression = expression
    end
    attr_reader :expression
  end

  class While
    include Acceptor
    def accept(visitor)
      visitor.visit_while_stmt self
    end
    def initialize(condition, body)
      @condition = condition
      @body = body
    end
    attr_reader :condition
    attr_reader :body
  end

  class Var
    include Acceptor
    def accept(visitor)
      visitor.visit_var_stmt self
    end
    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end
    attr_reader :name
    attr_reader :initializer
  end

  module Visitor
    def visit_block_stmt(o)
      raise NotImplementedError
    end
    def visit_expression_stmt(o)
      raise NotImplementedError
    end
    def visit_function_stmt(o)
      raise NotImplementedError
    end
    def visit_if_stmt(o)
      raise NotImplementedError
    end
    def visit_print_stmt(o)
      raise NotImplementedError
    end
    def visit_while_stmt(o)
      raise NotImplementedError
    end
    def visit_var_stmt(o)
      raise NotImplementedError
    end
  end
end
