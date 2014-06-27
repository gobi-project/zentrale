require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @path = "#{@api_prefix}/states"
  end
  before(:each) do
    @resource = FactoryGirl.create(:resource)
    @state_str = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id},
                            \"value\":10}]},\"name\":\"state1\"}"
    @state = RuleParser.parse_state(@state_str)
  end

  describe 'GET /states' do
    describe 'list of all states' do
      it do
        get @path, nil, @header
        last_response.status.should eq 200
        JSON(last_response.body).size.should eq TorfState.count
      end
    end
  end

  describe 'POST /states' do
    describe 'parameters:' do
      context 'name' do
        it do
          post @path, '{ "name":"night" }', @header
          last_response.status.should eq 400
        end
      end
      context 'conditions' do
        it do
          post @path, "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":10}]}}", @header
          last_response.status.should eq 400
        end
      end
      context 'name and conditions' do
        it do
          param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id},
                            \"value\":20}]},\"name\":\"state2\"}"
          post @path, param, @header
          last_response.status.should eq 201
          s = JSON(last_response.body)
          s.size.should eq 3
          s['name'].should eq 'state2'
          s['conditions'].size.should eq 1
          s['conditions']['equal'].size.should eq 1
          s['conditions']['equal'].first['id'].should eq @resource.id
          s['conditions']['equal'].first['device_id'].should eq @resource.device_id
          s['conditions']['equal'].first['name'].should eq @resource.name
          s['conditions']['equal'].first['resource_type'].should eq @resource.resource_type
          s['conditions']['equal'].first['interface_type'].should eq @resource.interface_type
          s['conditions']['equal'].first['unit'].should eq @resource.unit
          s['conditions']['equal'].first['value'].should eq 20
        end
      end
    end
  end

  describe 'GET /states/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should eq 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@state.id}", nil, @header
        last_response.status.should eq 200
        s = JSON(last_response.body)
        s.size.should eq 3
        s['name'].should eq 'state1'
        s['conditions'].size.should eq 1
        s['conditions']['equal'].size.should eq 1
        s['conditions']['equal'].first['id'].should eq @resource.id
        s['conditions']['equal'].first['device_id'].should eq @resource.device_id
        s['conditions']['equal'].first['name'].should eq @resource.name
        s['conditions']['equal'].first['resource_type'].should eq @resource.resource_type
        s['conditions']['equal'].first['interface_type'].should eq @resource.interface_type
        s['conditions']['equal'].first['unit'].should eq @resource.unit
        s['conditions']['equal'].first['value'].should eq 10
      end
    end
  end

  describe 'DELETE /states/:id' do
    context 'invalid id' do
      it do
        delete "#{@path}/1337", nil, @header
        last_response.status.should eq 204
      end
    end
    context 'valid id' do
      it do
        delete "#{@path}/#{@state.id}", nil, @header
        last_response.status.should eq 204
        TorfState.find_by_id(@state.id).should eq nil
      end
    end
  end

  describe 'PATCH /states/:id' do
    context 'name' do
      it do
        patch "#{@path}/#{@state.id}", '{ "name":"night" }', @header
        last_response.status.should eq 204
        TorfState.find_by_id(@state.id).name.should eq 'night'
      end
    end
    context 'conditions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":11},
                                            {\"id\":#{@resource.id}, \"value\":12}]}}"
        patch "#{@path}/#{@state.id}", param, @header
        last_response.status.should eq 204
        state = TorfState.find_by_id(@state.id)
        state.name.should eq 'state1'
        state.torf_simple_matchers.size.should eq 2
      end
    end
    context 'name and conditions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":11},
                        {\"id\":#{@resource.id}, \"value\":12}]},\"name\":\"night\"}"
        patch "#{@path}/#{@state.id}", param, @header
        last_response.status.should eq 204
        state = TorfState.find_by_id(@state.id)
        state.name.should eq 'night'
        state.torf_simple_matchers.size.should eq 2
      end
    end
  end
end
