# frozen_string_literal: true

class Scanner
  KEYWORDS = {
    'and' => :and,
    'class' => :class,
    'else' => :else,
    'false' => :false,
    'for' => :for,
    'fun' => :fun,
    'if' => :if,
    'nil' => :nil,
    'or' => :or,
    'print' => :print,
    'return' => :return,
    'super' => :super,
    'this' => :this,
    'true' => :true,
    'var' => :var,
    'while' => :while
  }.freeze

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      @start = @current
      scan_token
    end

    @tokens << Token.new(:eof, '', nil, @line)
    @tokens
  end

  private

  def advance
    ret = @source[@current]
    @current += 1
    ret
  end

  def add_token(type, literal = nil)
    text = @source[@start...@current]
    @tokens << Token.new(type, text, literal, @line)
  end

  def match(expected)
    return false if at_end?
    return false if @source[@current] != expected

    @current += 1
    true
  end

  def peek
    return "\0" if at_end?

    @source[@current]
  end

  def peek_next
    return "\0" if @current + 1 >= @source.length

    @source[@current + 1]
  end

  def digit?(c)
    c =~ /[[:digit:]]/
  end

  def alpha?(c)
    c =~ /[[:alpha:]]/ || c == '_'
  end

  def alphanum?(c)
    (digit? c) || (alpha? c)
  end

  def string
    until peek == '"' || at_end?
      @line += 1 if peek == '\n'
      advance
    end

    if at_end?
      Lox.lex_error @line, 'unterminated string.'
      return
    end

    advance

    value = @source[@start + 1...@current - 1]
    add_token :string, value
  end

  def number
    advance while digit? peek

    if peek == '.' && (digit? peek_next)
      advance

      advance while digit? peek
    end

    add_token :number, @source[@start...@current].to_f
  end

  def identifier
    advance while alpha? peek

    @source[@start...@current]

    text = @source[@start...@current]
    type = KEYWORDS[text]
    type = :identifier if type.nil?
    add_token type
  end

  def scan_token
    c = advance
    case c
    when '(' then add_token :left_paren
    when ')' then add_token :right_paren
    when '{' then add_token :left_brace
    when '}' then add_token :right_brace
    when ',' then add_token :comma
    when '.' then add_token :dot
    when '-' then add_token :minus
    when '+' then add_token :plus
    when ';' then add_token :semicolon
    when '*' then add_token :star
    when '!' then add_token match('=') ? :bang_equal : :bang
    when '=' then add_token match('=') ? :equal_equal : :equal
    when '<' then add_token match('=') ? :less_equal : :less
    when '>' then add_token match('=') ? :greater_equal : :greater
    when '/'
      if match '/'
        advance until peek == '\n' || at_end?
      else
        add_token :slash
      end
    when ' ', "\r", "\t" then nil
    when "\n" then @line += 1
    when '"' then string
    else
      if digit? c
        number
      elsif alpha? c
        identifier
      else
        Lox.lex_error(@line, 'unexpected character.')
      end
    end
  end

  def at_end?
    @current >= @source.length
  end
end

class Token
  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  attr_reader :lexeme, :literal, :line, :type

  def to_s
    "#{@type} #{@lexeme} #{@literal}"
  end
end
