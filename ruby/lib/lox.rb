# frozen_string_literal: true

require_relative 'lexer'
require_relative 'parser'
require_relative 'interpreter'
require_relative 'ast_printer'

class Lox
  @had_error = false
  @had_runtime_error = false

  @interpreter = Interpreter.new

  def self.report(line, where, msg)
    warn "[line #{line}] Error#{where} : #{msg}"
    @had_error = true
  end

  def self.lex_error(line, msg)
    report line, '', msg
  end

  def self.parse_error(token, message)
    if token.type == :eof
      report token.line, ' at end', message
    else
      report token.line, " at '#{token.lexeme}'", message
    end
  end

  def self.runtime_error(error)
    puts "#{error.message}\n[line #{error.token.line}]"
    @had_runtime_error = true
  end

  def self.run(src)
    scanner = Scanner.new src
    tokens = scanner.scan_tokens
    parser = Parser.new tokens
    expression = parser.parse

    return if @had_error

    @interpreter.interpret expression
  end

  def self.run_file(buf)
    run buf
    exit 65 if @had_error
    exit 70 if @had_runtime_error
  end

  def self.run_prompt
    loop do
      print '> '
      $stdout.flush
      begin
        run ARGF.readline
        @had_error = false
      rescue EOFError
        exit 0
      end
    end
  end
end
