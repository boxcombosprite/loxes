# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'rlox'
  spec.version = '0.0.0'
  spec.summary = 'ruby lox'
  spec.authors = ['boxcombosprite']
  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir['lib/**/*.rb', 'bin/*']
  spec.bindir = 'bin'
  spec.executables = ['rlox']
  spec.require_paths = ['lib']
end
