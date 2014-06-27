ENV['RACK_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'

  config.before(:all) do
    @user = FactoryGirl.create(:user)
    @token = @user.session_token.create[:token]
    @header = generate_header @token
    @api_prefix = '/api/v1'
  end
  config.before(:each) do
    Resource.any_instance.stub(:current_value).and_return(1337)
    Resource.any_instance.stub(:value).and_return(1337)
    Observer.any_instance.stub(:add).and_return(true)
    Resource.any_instance.stub(:measurements) do |res, param|
      if param[:start_point] <= param[:end_point]
        Measurement.new(1, 1337, Time.at(param[:start_point]))
      end
    end
  end
end

def app
  API::Root
end
