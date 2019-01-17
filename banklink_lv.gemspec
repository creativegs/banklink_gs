# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "banklink/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.3.8"
  s.name = "banklink_gs"
  s.version = Banklink::VERSION
  s.author = "Creative.gs"
  s.email = ["girts@creative.gs"]
  s.homepage = "https://github.com/CreativeGS/banklink_gs"
  s.platform = Gem::Platform::RUBY
  s.summary = "Banklink integration in your website without active merchant (Latvia)"
  s.require_path = "lib"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'pry'
  s.add_development_dependency "simplecov"
end
