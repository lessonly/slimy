# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slimy/version"

Gem::Specification.new do |s|
  s.name        = 'slimy'
  s.version     = Slimy::VERSION
  s.date        = '2020-12-01'
  s.summary     = "SLI metrics middleware"
  s.description = "Provide a simple and consistent library for recording SLI type metrics for Rack, Sidekiq, and maybe more."
  s.authors     = ["Stephen Gregory", "Tyler Henrichs"]
  s.email       = 'devops+slimy@lessonly.com'
  s.homepage    = 'https://rubygems.org/gems/slimy'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end