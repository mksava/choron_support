# frozen_string_literal: true

require_relative "lib/choron_support/version"

Gem::Specification.new do |spec|
  spec.name = "choron_support"
  spec.version = ChoronSupport::VERSION
  spec.authors = ["mksava"]
  spec.email = ["dosec.mk@gmail.com"]

  spec.summary = "By using this library, you can incorporate some useful functions into Ruby on Rails."
  spec.description = "By using this library, you can incorporate some useful functions into Ruby on Rails."
  spec.homepage = "https://github.com/mksava/choron_support"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mksava/choron_support"
  spec.metadata["changelog_uri"] = "https://github.com/mksava/choron_support/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "ridgepole"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "spring"
  spec.add_development_dependency "spring-commands-rspec"
  spec.add_development_dependency "pry-rails"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rspec-parameterized"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
