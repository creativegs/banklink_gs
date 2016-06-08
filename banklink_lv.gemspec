# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "banklink/version"

Gem::Specification.new do |s|
  s.name = "banklink_sac"
  s.version = Banklink::VERSION
  s.author = "Arturs Braucs, Girts Kesteris"
  s.email = ["girts@creative.gs"]
  s.homepage = "https://github.com/Sacristan/banklink"
  s.platform = Gem::Platform::RUBY
  s.summary = "Banklink integration in your website without active merchant (Latvia)"
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.rdoc"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.add_dependency "activesupport"
end
