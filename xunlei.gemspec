# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xunlei/version"

Gem::Specification.new do |s|
  s.name        = "xunlei"
  s.version     = Xunlei::VERSION
  s.authors     = ["Forrest Ye"]
  s.email       = ["afu@forresty.com"]
  s.homepage    = ""
  s.summary     = %q{A browser script to access lixian.vip.xunlei.com tasks automatically}
  s.description = %q{A browser script to access lixian.vip.xunlei.com tasks automatically}

  s.rubyforge_project = "xunlei"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"

  s.add_runtime_dependency "watir-webdriver"
  s.add_runtime_dependency "commander"
  s.add_runtime_dependency "nokogiri"
end
