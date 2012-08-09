# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wix-apps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gregory Man"]
  gem.email         = ["man.gregory@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.add_dependency 'multi_json'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency 'rake'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wix-apps"
  gem.require_paths = ["lib"]
  gem.version       = Wix::Apps::VERSION
end
