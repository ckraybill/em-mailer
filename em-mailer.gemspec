# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-mailer/version"

Gem::Specification.new do |s|
  s.name        = "em-mailer"
  s.version     = Em::Mailer::VERSION
  s.authors     = ["Chris Kraybill"]
  s.email       = ["ckraybill@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Asynchronous mail client and server}
  s.description = %q{Asynchronous mail client and server written in ruby,
                  eventmachine to replace synchronous mail implementation
                  in Rails 2 and 3}

  s.rubyforge_project = "em-mailer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "eventmachine"
  s.add_dependency "mail"
  s.add_dependency "yajl-ruby"
  s.add_dependency "actionmailer"

  s.add_development_dependency "rspec"
  s.add_development_dependency "em-spec"
end
