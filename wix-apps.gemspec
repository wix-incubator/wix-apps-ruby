# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wix-apps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Gregory Man']
  gem.email         = ['man.gregory@gmail.com']
  gem.description   = %q{ Rack middleware for WixApps }
  gem.summary       = %q{ Rack middleware for WixApps parameters parsing and validation }
  gem.homepage      = 'https://github.com/wix/wix-apps-ruby'

  gem.add_dependency 'multi_json'
  gem.add_dependency 'rack'
  gem.add_dependency 'jruby-openssl' if RUBY_PLATFORM == 'java'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack-test'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'wix-apps'
  gem.require_paths = ['lib']
  gem.version       = Wix::Apps::VERSION
end
