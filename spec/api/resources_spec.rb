require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @path = "#{@api_prefix}/resources"
  end
  before(:each) do
    @resource = FactoryGirl.create(:resource)
  end

  describe 'GET /resources' do
    describe 'list of all resources' do
      it do
        get @path, nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r.size.should eq Resource.count
      end
    end
  end

  describe 'GET /resources/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should eq 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@resource.id}", nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r['id'].should eq @resource.id
        r['device_id'].should eq @resource.device_id
        r['name'].should eq @resource.name
        r['resource_type'].should eq @resource.resource_type
        r['interface_type'].should eq @resource.interface_type
        r['unit'].should eq @resource.unit
        r['value'].should eq @resource.current_value
      end
    end
  end

  describe 'GET /resources/:id/measurements' do
    context 'invalid id' do
      it do
        get "#{@path}/1337/measurements", nil, @header
        last_response.status.should eq 404
      end
    end
    describe 'parameter:' do
      context 'from' do
        it do
          get "#{@path}/#{@resource.id}/measurements?from=1396300095", nil, @header
          last_response.status.should eq 400
        end
      end
      context 'to' do
        it do
          get "#{@path}/#{@resource.id}/measurements?to=1396300095", nil, @header
          last_response.status.should eq 400
        end
      end
      context 'granularity' do
        it do
          get "#{@path}/#{@resource.id}/measurements?granularity=60", nil, @header
          last_response.status.should eq 400
        end
      end
      context 'from and granularity' do
        it do
          get "#{@path}/#{@resource.id}/measurements?from=1396300095&granularity=60", nil, @header
          last_response.status.should eq 400
        end
      end
      context 'to and granularity' do
        it do
          get "#{@path}/#{@resource.id}/measurements?from=1396300095&granularity=60", nil, @header
          last_response.status.should eq 400
        end
      end
      context 'from and to' do
        it do
          get "#{@path}/#{@resource.id}/measurements?from=1396300095&to=1396300095", nil, @header
          last_response.status.should eq 200
          m = JSON(last_response.body)
          m.size.should eq 1
          m[0]['datetime'].should eq 139_630_009_5
          m[0]['value'].should eq 1337
        end
      end
      context 'from, to and granularity' do
        it do
          get "#{@path}/#{@resource.id}/measurements?from=1396300095&to=1396300095&granularity=60", nil, @header
          last_response.status.should eq 200
          m = JSON(last_response.body)
          m.size.should eq 1
          m[0]['datetime'].should eq 139_630_009_5
          m[0]['value'].should eq 1337
        end
      end
    end
    context 'from > to' do
      it do
        get "#{@path}/#{@resource.id}/measurements?from=1396300096&to=1396300095", nil, @header
        last_response.status.should eq 200
        JSON(last_response.body).should be_empty
      end
    end
  end

  describe 'PATCH /resources/:id' do
    context 'invalid id' do
      it do
        patch "#{@path}/1337", '{ "name": "fancy resource"}', @header
        last_response.status.should eq 404
      end
    end
    context 'valid id' do
      describe 'name' do
        it do
          patch "#{@path}/#{@resource.id}", '{ "name": "fancy resource"}', @header
          last_response.status.should eq 204
          Resource.find(@resource.id).name.should eq 'fancy resource'
        end
      end
      describe 'value' do
        it do
          patch "#{@path}/#{@resource.id}", '{ "value": 1337}', @header
          last_response.status.should eq 204
          Resource.find(@resource.id).current_value.should eq 1337
        end
      end
      describe 'name and value' do
        it do
          patch "#{@path}/#{@resource.id}", '{ "name": "fancy resource", "value": 1337}', @header
          last_response.status.should eq 204
          Resource.find(@resource.id).name.should eq 'fancy resource'
          Resource.find(@resource.id).current_value.should eq 1337
        end
      end
    end
  end
end
