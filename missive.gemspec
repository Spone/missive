# frozen_string_literal: true

require_relative "lib/missive/version"

Gem::Specification.new do |spec|
  spec.name = "missive"
  spec.version = Missive::VERSION
  spec.authors = ["Hans Lemuet"]
  spec.email = ["hans@etamin.studio"]

  spec.summary = "Toolbox for managing newsletters in Rails, sending them with Postmark."
  spec.description = "Missive provides primitives to build your own custom newsletter: lists, subscribers, content editor, tracking."
  spec.homepage = "https://github.com/Spone/missive"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 8.0.0"
  spec.add_dependency "postmark-rails", ">= 0.22.1"
  spec.add_dependency "time_for_a_boolean", ">= 0.2.1"
  spec.add_dependency "rails-pattern_matching", ">= 0.3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
