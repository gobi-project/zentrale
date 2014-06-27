require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @path = "#{@api_prefix}/devices"
  end
  before(:each) do
    @device = FactoryGirl.create(:device)
    10.times do
      FactoryGirl.create(:resource, device_id: @device.id)
    end
  end

  describe 'GET /devices' do
    describe 'list of all devices' do
      before :all do
        50.times do
          FactoryGirl.create(:device)
        end
      end
      context 'without limit' do
        it do
          get @path, nil, @header
          last_response.status.should be 200
          JSON(last_response.body).size.should eq Device.count
        end
      end
      context 'limit 10' do
        it do
          get "#{@path}?limit=10", nil, @header
          last_response.status.should be 200
          res = JSON(last_response.body)
          res.size.should eq 10
          res[0]['id'] = Device.first.id
        end
      end
      context 'limit 10, offset 10' do
        it do
          get "#{@path}?limit=10,10", nil, @header
          last_response.status.should be 200
          res = JSON(last_response.body)
          res.size.should eq 10
          res[0]['id'] = Device.offset(10).limit(10).first.id
        end
      end
      context 'limit 10, offset 1337' do
        it do
          get "#{@path}?limit=1337,10", nil, @header
          last_response.status.should be 200
          JSON(last_response.body).size.should eq 0
        end
      end
      context 'invalid limit' do
        it do
          get "#{@path}?limit=10,,10", nil, @header
          last_response.status.should be 400
        end
      end
    end
  end

  describe 'GET /devices/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should be 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@device.id}", nil, @header
        last_response.status.should be 200
        d = JSON(last_response.body)
        d.size.should eq 5
        d['name'].should eq @device.name
        d['id'].should eq @device.id
        d['address'].should eq @device.address
        d['resources'].size.should eq @device.resources.size
        d['status'].should eq @device.status.to_s
      end
    end
  end

  describe 'PATCH /devices/:id' do
    context 'invalid id' do
      it do
        patch "#{@path}/1337", '{"name": "foo"}', @header
        last_response.status.should be 404
      end
    end
    describe 'parameters:' do
      context 'none' do
        it do
          patch "#{@path}/#{@device.id}", '{}', @header
          last_response.status.should eq 204
          d = Device.find_by_id(@device.id)
          d.name.should eq @device.name
          d.status.should eq @device.status
          d.resources.size.should eq @device.resources.size
        end
      end
      context 'name' do
        it do
          patch "#{@path}/#{@device.id}", '{"name":"fancy device"}', @header
          last_response.status.should eq 204
          d = Device.find_by_id(@device.id)
          d.name.should eq 'fancy device'
          d.status.should eq @device.status
          d.resources.size.should eq @device.resources.size
        end
      end
      context 'status' do
        it do
          patch "#{@path}/#{@device.id}", '{"status": "inactive"}', @header
          last_response.status.should eq 204
          d = Device.find_by_id(@device.id)
          d.name.should eq @device.name
          d.status.should eq :inactive
          d.resources.size.should eq @device.resources.size
        end
      end
      context 'name and status' do
        it do
          patch "#{@path}/#{@device.id}", '{"name":"fancy device", "status": "inactive"}', @header
          last_response.status.should eq 204
          d = Device.find_by_id(@device.id)
          d.name.should eq 'fancy device'
          d.status.should eq :inactive
          d.resources.size.should eq @device.resources.size
        end
      end
    end
  end

  describe 'DELETE /devices/:id' do
    context 'invalid id' do
      it do
        delete "#{@path}/1337", nil, @header
        last_response.status.should eq 204
      end
    end
    context 'valid id' do
      it do
        id = @device.resources.pluck(:id)
        delete "#{@path}/#{@device.id}", nil, @header
        last_response.status.should eq 204
        Device.find_by_id(@device.id).should eq nil
        Resource.where(id: id).size.should eq 0
      end
    end
  end

  describe 'GET /devices/:id/resources' do
    context 'invalid id' do
      it do
        get "#{@path}/1337/resources", nil, @header
        last_response.status.should eq 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@device.id}/resources", nil, @header
        last_response.status.should eq 200
        d = JSON(last_response.body)
        d.size.should eq @device.resources.size
      end
    end
  end
end
