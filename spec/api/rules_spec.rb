require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @path = "#{@api_prefix}/rules"
  end
  before(:each) do
    @resource = FactoryGirl.create(:resource)
    @rule_str = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id},\"value\":10}]},
                                                  \"name\":\"rule1\",
                                                  \"actions\":[{\"value\":13,\"id\":#{@resource.id}}]}"
    @rule = RuleParser.parse_rule(@rule_str)
  end

  describe 'GET /rules' do
    describe 'list of all rules' do
      it do
        get @path, nil, @header
        last_response.status.should eq 200
        JSON(last_response.body).size.should eq TorfRule.count
      end
    end
  end

  describe 'POST /rules' do
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
      context 'actions' do
        it do
          post @path, "{\"actions\":[{\"value\":13,\"id\":#{@resource.id}}]}", @header
          last_response.status.should eq 400
        end
      end
      context 'name and actions' do
        it do
          post @path, "{\"name\":\"rule1\", \"actions\":[{\"value\":13,\"id\":#{@resource.id}}]}", @header
          last_response.status.should eq 400
        end
      end
      context 'name and and conditions' do
        it do
          post @path, "{\"name\":\"rule1\", \"conditions\":{\"equal\":[{\"id\":#{@resource.id},\"value\":10}]}}", @header
          last_response.status.should eq 400
        end
      end
      context 'actions and conditions' do
        it do
          post @path, "{\"actions\":[{\"value\":13,\"id\":#{@resource.id}}],
                      \"conditions\":{\"equal\":[{\"id\":#{@resource.id},\"value\":10}]}}", @header
          last_response.status.should eq 400
        end
      end
      context 'name, conditions and actions' do
        it do
          param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id},
                            \"value\":29}]},\"name\":\"state2\",
                            \"actions\":[{\"value\":55,\"id\":#{@resource.id}}]}"
          post @path, param, @header
          last_response.status.should eq 201
          r = JSON(last_response.body)
          r.size.should eq 4
          r['name'].should eq 'state2'
          r['conditions'].size.should eq 1
          r['conditions']['equal'].size.should eq 1
          r['conditions']['equal'].first['id'].should eq @resource.id
          r['conditions']['equal'].first['device_id'].should eq @resource.device_id
          r['conditions']['equal'].first['name'].should eq @resource.name
          r['conditions']['equal'].first['resource_type'].should eq @resource.resource_type
          r['conditions']['equal'].first['interface_type'].should eq @resource.interface_type
          r['conditions']['equal'].first['unit'].should eq @resource.unit
          r['conditions']['equal'].first['value'].should eq 29
          r['actions'].size.should eq 1
          r['actions'].first['id'].should eq @resource.id
          r['actions'].first['value'].should eq 55
        end
      end
    end
  end

  describe 'GET /rules/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should eq 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@rule.id}", nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r.size.should eq 4
        r['name'].should eq 'rule1'
        r['conditions'].size.should eq 1
        r['conditions']['equal'].size.should eq 1
        r['conditions']['equal'].first['id'].should eq @resource.id
        r['conditions']['equal'].first['device_id'].should eq @resource.device_id
        r['conditions']['equal'].first['name'].should eq @resource.name
        r['conditions']['equal'].first['resource_type'].should eq @resource.resource_type
        r['conditions']['equal'].first['interface_type'].should eq @resource.interface_type
        r['conditions']['equal'].first['unit'].should eq @resource.unit
        r['conditions']['equal'].first['value'].should eq 10
        r['actions'].size.should eq 1
        r['actions'].first['id'].should eq @resource.id
        r['actions'].first['value'].should eq 13
      end
    end
  end

  describe 'DELETE /rules/:id' do
    context 'invalid id' do
      it do
        delete "#{@path}/1337", nil, @header
        last_response.status.should eq 204
      end
    end
    context 'valid id' do
      it do
        delete "#{@path}/#{@rule.id}", nil, @header
        last_response.status.should eq 204
        TorfRule.find_by_id(@rule.id).should eq nil
      end
    end
  end

  describe 'PATCH /rules/:id' do
    context 'name' do
      it do
        patch "#{@path}/#{@rule.id}", '{ "name":"rulor" }', @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rulor'
        r.torf_simple_matchers.size.should eq 1
        r.torf_actions.size.should eq 1
      end
    end
    context 'conditions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":10},
                                            {\"id\":#{@resource.id}, \"value\":12}]}}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rule1'
        r.torf_simple_matchers.size.should eq 2
        r.torf_actions.size.should eq 1
      end
    end
    context 'actions' do
      it do
        param = "{\"actions\":[{\"value\":13,\"id\":#{@resource.id}}, {\"value\":13,\"id\":#{@resource.id}}]}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rule1'
        r.torf_simple_matchers.size.should eq 1
        r.torf_actions.size.should eq 2
      end
    end
    context 'name and conditions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":10},
                        {\"id\":#{@resource.id}, \"value\":12}]},\"name\":\"rulor\"}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rulor'
        r.torf_simple_matchers.size.should eq 2
        r.torf_actions.size.should eq 1
      end
    end
    context 'name and actions' do
      it do
        param = "{\"actions\":[{\"value\":13,\"id\":#{@resource.id}},
                          {\"value\":13,\"id\":#{@resource.id}}], \"name\":\"rulor\"}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rulor'
        r.torf_simple_matchers.size.should eq 1
        r.torf_actions.size.should eq 2
      end
    end
    context 'conditions and actions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":10},
                        {\"id\":#{@resource.id}, \"value\":12}]},
                        \"actions\":[{\"value\":13,\"id\":#{@resource.id}}, {\"value\":13,\"id\":#{@resource.id}}]}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rule1'
        r.torf_simple_matchers.size.should eq 2
        r.torf_actions.size.should eq 2
      end
    end
    context 'name, conditions and actions' do
      it do
        param = "{\"conditions\":{\"equal\":[{\"id\":#{@resource.id}, \"value\":10},
                        {\"id\":#{@resource.id}, \"value\":12}]}, \"name\":\"rulor\",
                        \"actions\":[{\"value\":13,\"id\":#{@resource.id}}, {\"value\":13,\"id\":#{@resource.id}}]}"
        patch "#{@path}/#{@rule.id}", param, @header
        last_response.status.should eq 204
        r = TorfRule.find_by_id(@rule.id)
        r.name.should eq 'rulor'
        r.torf_simple_matchers.size.should eq 2
        r.torf_actions.size.should eq 2
      end
    end
  end
end
