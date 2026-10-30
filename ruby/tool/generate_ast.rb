#!/usr/bin/env ruby

# frozen_string_literal: true

def define_acceptor(fh)
  fh.write "module Acceptor\n"
  fh.write "  def accept(o)\n"
  fh.write "    raise NotImplementedError\n"
  fh.write "  end\n"
  fh.write "end\n\n"
end

def define_ast(fh, base_name, types)
  fh.write "module #{base_name}\n"

  types.each do |t|
    class_name = t.split(':')[0].strip
    fields = t.split(':')[1].strip
    define_type fh, base_name, class_name, fields, '  '
  end

  define_visitor fh, base_name, types, '  '

  fh.write "end\n"
end

def define_visitor(fh, base_name, types, indent = '')
  fh.write "#{indent}module Visitor\n"
  types.each do |t|
    t_name = t.split(':')[0].strip.downcase
    fh.write "#{indent}  def visit_#{t_name}_#{base_name.downcase}(o)\n"
    fh.write "#{indent}    raise NotImplementedError\n"
    fh.write "#{indent}  end\n"
  end
  fh.write "#{indent}end\n"
end

def define_type(fh, base_name, class_name, fields, indent = '')
  fh.write "#{indent}class #{class_name}\n"
  fh.write "#{indent}  include Acceptor\n"
  fh.write "#{indent}  def accept(visitor)\n"
  fh.write "#{indent}    visitor.visit_#{class_name.downcase}_#{base_name.downcase} self\n"
  fh.write "#{indent}  end\n"
  fh.write "#{indent}  def initialize(#{fields})\n"
  fields.split(', ').each do |field_name|
    fh.write "#{indent}    @#{field_name} = #{field_name}\n"
  end
  fh.write "#{indent}  end\n"
  fields.split(', ').each do |field_name|
    fh.write "#{indent}  attr_reader :#{field_name}\n"
  end
  fh.write "#{indent}end\n\n"
end

unless ARGV.length == 1
  puts 'usage: generate_ast <output directory>'
  exit 64
end

output_dir = ARGV[0]

path = "#{output_dir}/ast.rb"
File.open(path, 'w') do |f|
  define_acceptor f

  define_ast f, 'Expr', [
    'Assign   : name, value',
    'Binary   : left, operator, right',
    'Call     : callee, paren, arguments',
    'Grouping : expression',
    'Literal  : value',
    'Logical  : left, operator, right',
    'Unary    : operator, right',
    'Variable : name'
  ]

  define_ast f, 'Stmt', [
    'Block      : statements',
    'Expression : expression',
    'Function   : name, params, body',
    'If         : condition, then_branch, else_branch',
    'Print      : expression',
    'While      : condition, body',
    'Var        : name, initializer'
  ]
end
