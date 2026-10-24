#!/usr/bin/env ruby

# frozen_string_literal: true

def define_ast(output_dir, base_name, types)
  path = "#{output_dir}/ast.rb"
  File.open(path, 'a+') do |f|
    f.write "module #{base_name}\n"
    f.write "  def accept(o)\n"
    f.write "    raise NotImplementedError\n"
    f.write "  end\n"
    f.write "end\n\n"

    types.each do |t|
      class_name = t.split(':')[0].strip
      fields = t.split(':')[1].strip
      define_type f, base_name, class_name, fields
    end

    define_visitor f, types
  end
end

def define_visitor(fh, types)
  fh.write "module Visitor\n"
  types.each do |t|
    t_name = t.split(':')[0].strip.downcase
    fh.write "  def visit_#{t_name}(o)\n"
    fh.write "    raise NotImplementedError\n"
    fh.write "  end\n"
  end
  fh.write "end\n"
end

def define_type(fh, base_name, class_name, fields)
  fh.write "class #{class_name}\n"
  fh.write "  include #{base_name}\n"
  fh.write "  def accept(visitor)\n"
  fh.write "    visitor.visit_#{class_name.downcase} self\n"
  fh.write "  end\n"
  fh.write "  def initialize(#{fields})\n"
  fields.split(', ').each do |field_name|
    fh.write "    @#{field_name} = #{field_name}\n"
  end
  fh.write "  end\n"
  fields.split(', ').each do |field_name|
    fh.write "  attr_reader :#{field_name}\n"
  end
  fh.write "end\n\n"
end

unless ARGV.length == 1
  puts 'usage: generate_ast <output directory>'
  exit 64
end

output_dir = ARGV[0]

define_ast output_dir, 'Expr', [
  'Binary   : left, operator, right',
  'Grouping : expression',
  'Literal  : value',
  'Unary    : operator, right'
]
