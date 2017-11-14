lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sawyer/version'

Gem::Specification.new do |gem|
  gem.name          = 'sawyer'
  gem.version       = Sawyer::VERSION
  gem.license       = 'Apache-2.0'
  gem.authors       = ['Ryan Frantz']
  gem.email         = ['rfrantz1@bloomberg.net']
  gem.description   = 'A tool for parsing logs and emitting metrics.'
  gem.homepage      = 'https://bbgithub.dev.bloomberg.com/SystemsCoreEngineering/sawyer'
  gem.summary       = gem.description

  gem.required_ruby_version = '>= 2.3'

  gem.files         = Dir['{bin,lib,spec,support,test}/**/*', 'README*', 'CHANGELOG*']
  gem.test_files    = gem.files.grep(%r{^(test|spec)/})
  gem.require_paths = ['lib']
  gem.executables << 'sawyer'
end
