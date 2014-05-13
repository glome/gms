# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures/gms", __FILE__)
ActiveSupport::TestCase.set_fixture_class :accounts => Gms::Account

class ActiveSupport::TestCase
  fixtures :all
end
#fixes other problems with controller tests (url helpers)
class ActionController::TestCase
  setup do
    @routes = Gms::Engine.routes
  end
end
