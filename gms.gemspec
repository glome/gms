$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gms/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gms"
  s.version     = Gms::VERSION
  s.authors     = ["Ferenc Szekely"]
  s.email       = ["ferenc@glome.me"]
  s.homepage    = "http://glome.me"
  s.summary     = "GMS stands for Glome Messaging Service."
  s.description = "GMS provides XMPP messaging to Glome users."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.3"
  s.add_dependency "mysql2"
  s.add_dependency "sidekiq"
  s.add_dependency "xmpp4r"
  s.add_dependency "protected_attributes"

  s.add_development_dependency "sqlite3"
end
