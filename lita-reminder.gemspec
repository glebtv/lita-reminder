Gem::Specification.new do |spec|
  spec.name          = "lita-reminder"
  spec.version       = "0.0.2"
  spec.authors       = ["glebtv"]
  spec.email         = ["glebtv@gmail.com"]
  spec.description   = %q{Reminder for Lita chat bot }
  spec.summary       = %q{Reminder for Lita chat bot }
  spec.homepage      = "https://github.com/glebtv/lita-reminder"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", "~> 2.4"
  spec.add_runtime_dependency "rufus-scheduler", "~> 2.0.24"
  spec.add_runtime_dependency "chronic", "~> 0.10.2"
  spec.add_runtime_dependency "whois", "~> 3.2.1"
  spec.add_runtime_dependency "addressable", "~> 2.3.5"
  

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.14"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
