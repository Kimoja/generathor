# frozen_string_literal: true

require_relative "lib/generathor/version"

Gem::Specification.new do |spec|
  spec.name        = "generathor"
  spec.version     = Generathor::VERSION
  spec.summary     = ""
  spec.description = "generathor"
  spec.authors     = ["Joakim Carrilho"]
  spec.email       = "joakim.carrilho@yahoo.fr"
  spec.files       = ["lib/generathor.rb"]
  spec.homepage    = ""
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.1.1"

  spec.add_dependency "thor"
  spec.add_dependency "thor-zsh_completion"
end
