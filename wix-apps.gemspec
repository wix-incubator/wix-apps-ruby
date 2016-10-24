# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wix-apps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Gregory Man', 'Niklas Bichinger']
  gem.email         = %w(man.gregory@gmail.com niklas@bichinger.de)
  gem.description   = %q{ Rack middleware for WixApps }
  gem.summary       = %q{ Rack middleware for WixApps parameters parsing and validation }
  gem.homepage      = 'https://github.com/wix/wix-apps-ruby'

  gem.add_dependency 'multi_json', '~> 1.0'
  gem.add_dependency 'rack', '< 2'
  gem.add_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'ruby_dep', '1.3.1'
  gem.add_development_dependency 'listen', '< 3.1.0'
  gem.add_development_dependency 'rake', '>= 10', '~> 11'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rack-test', '~> 0.6.2'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'wix-apps'
  gem.require_paths = ['lib']
  gem.version       = Wix::Apps::VERSION
  gem.license       = 'MIT'
end
