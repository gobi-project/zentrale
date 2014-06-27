require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods
  before(:all) do
    @path = "#{@api_prefix}/name"
  end
  describe 'GET /name' do
    describe 'get name' do
      it do
        get @path, nil, @header
        last_response.status.should eq 200
        body = JSON(last_response.body)
        expect(body['name']).to eq App.name
      end
    end
  end
end
