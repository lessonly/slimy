$:.push File.expand_path("../lib", __FILE__)
require "slimy/version"

Gem::Specification.new do |s|
  s.name        = "slimy"
  s.version     = Slimy::VERSION
  s.date        = "2020-12-01"
  s.summary     = "SLI metrics middleware"
  s.description = "Provide a simple and consistent library for recording SLI" \
                  + "type metrics for Rack, Sidekiq, and maybe more."
  s.authors     = ["Tyler Henrichs", "Stephen Gregory"]
  s.email       = "devops+slimy@lessonly.com"
  s.homepage    = "https://rubygems.org/gems/slimy"
  s.license     = "MIT"
  s.files       = `git ls-files`.split("\n")

  s.require_paths = ["lib"]

  s.add_runtime_dependency "rack", "~> 2.0"

  s.add_development_dependency "bump"
  s.add_development_dependency "bundler", ">= 1.0", "< 3"
  s.add_development_dependency "minitest", "~> 5.14"
  s.add_development_dependency "minitest-reporters", "~> 1.4"
  s.add_development_dependency "rake", "~> 10.4", ">= 10.4.2"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "timecop", "~> 0.9"
end