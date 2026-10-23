# frozen_string_literal: true

require_relative 'lexer'

class Lox
  @had_error = false

  def self.report(line, where, msg)
    warn "[line #{line}] Error#{where} : #{msg}"
    @had_error = true
  end

  def self.error(line, msg)
    report line, '', msg
  end

  def self.run(src)
    scanner = Scanner.new src
    tokens = scanner.scan_tokens

    tokens.each do |tok|
      puts tok
    end
  end

  def self.run_file(buf)
    run buf
    exit 65 if @had_error
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
