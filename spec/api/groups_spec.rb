require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @path = "#{@api_prefix}/groups"
  end
  before(:each) do
    10.times do
      FactoryGirl.create(:resource)
    end
    @resources = Resource.all
    i = 0
    10.times do
      RuleParser.parse_rule("{\"conditions\":{\"equal\":[{\"id\":#{@resources[0].id},
                            \"value\":10}]},\"name\":\"rule#{i}\",
                            \"actions\":[{\"value\":13,\"id\":#{@resources[0].id}}]}")
      i += 1
    end
    @rules = TorfRule.all
    @group = Group.build(name: 'group1', resources: @resources.pluck(:id), rules: @rules.pluck(:id))
  end

  describe 'GET /groups' do
    describe 'list of all groups' do
      before :all do
        50.times do
          FactoryGirl.create(:group)
        end
      end
      context 'without limit' do
        it do
          get @path, nil, @header
          last_response.status.should be 200
          JSON(last_response.body).size.should eq Group.count
        end
      end
      context 'limit 10' do
        it do
          get "#{@path}?limit=10", nil, @header
          last_response.status.should be 200
          res = JSON(last_response.body)
          res.size.should eq 10
          res[0]['id'] = Group.first.id
        end
      end
      context 'limit 10, offset 10' do
        it do
          get "#{@path}?limit=10,10", nil, @header
          last_response.status.should be 200
          res = JSON(last_response.body)
          res.size.should eq 10
          res[0]['id'] = Group.offset(10).limit(10).first.id
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

  describe 'POST /groups' do
    describe 'parameters:' do
      context 'rules' do
        it do
          post @path, '{"rules":[1,2]}', @header
          last_response.status.should be 400
        end
      end
      context 'resources' do
        it do
          post @path, '{"resources":[1,2]}', @header
          last_response.status.should be 400
        end
      end
      context 'rules and resources' do
        it do
          post @path, '{"rules":[1,2], resources":[1,2]}', @header
          last_response.status.should be 400
        end
      end
      context 'name' do
        it do
          post @path, '{ "name":"fancy group" }', @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
        end
      end
      context 'name and resources' do
        it do
          post @path, "{ \"name\":\"fancy group\", \"resources\":#{@resources.pluck(:id)} }", @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g.size.should eq 4
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
          g['rules'].size.should eq 0
          g['resources'].size.should eq @resources.size
        end
      end
      context 'name and rules' do
        it do
          post @path, "{ \"name\":\"fancy group\", \"rules\":#{@rules.pluck(:id)} }", @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g.size.should eq 4
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
          g['resources'].size.should eq 0
          g['rules'].size.should eq @rules.size
        end
      end
      context 'name, resources and rules' do
        it do
          post @path, "{ \"name\":\"fancy group\", \"rules\":#{@rules.pluck(:id)}, \"resources\":#{@resources.pluck(:id)} }", @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g.size.should eq 4
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
          g['resources'].size.should eq @resources.size
          g['rules'].size.should eq @rules.size
        end
      end
    end
    describe 'content:' do
      context 'name to short' do
        it do
          post @path, '{"name":""}', @header
          last_response.status.should be 400
        end
      end
      context 'invalid resources' do
        it do
          post @path, '{ "name":"fancy group", "resources":[1337] }', @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g.size.should eq 4
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
          g['resources'].size.should eq 0
          g['rules'].size.should eq 0
        end
      end
      context 'invalid rules' do
        it do
          post @path, '{ "name":"fancy group", "rules":[1337] }', @header
          last_response.status.should eq 201
          g = JSON(last_response.body)
          group = Group.find_by_name('fancy group')
          g.size.should eq 4
          g['id'].should eq group.id
          g['name'].should eq 'fancy group'
          g['resources'].size.should eq 0
          g['rules'].size.should eq 0
        end
      end
    end
  end

  describe 'GET /groups/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should be 404
      end
    end
    context 'valid id' do
      it do
        get "#{@path}/#{@group.id}", nil, @header
        last_response.status.should be 200
        g = JSON(last_response.body)
        g.size.should eq 4
        g['name'].should eq @group.name
        g['id'].should eq @group.id
        g['rules'].size.should eq @group.rules.size
        g['resources'].size.should eq @group.resources.size
      end
    end
  end

  describe 'PATCH /groups/:id' do
    context 'invalid id' do
      it do
        patch "#{@path}/1337", '{}', @header
        last_response.status.should eq 404
      end
    end
    describe 'parameters:' do
      context 'none' do
        it do
          patch "#{@path}/#{@group.id}", '{}', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq @group.name
          g.resources.size.should eq @group.resources.size
          g.rules.size.should eq @group.rules.size
        end
      end
      context 'name' do
        it do
          patch "#{@path}/#{@group.id}", '{ "name":"RenamedGroup"}', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq 'RenamedGroup'
          g.resources.size.should eq @group.resources.size
          g.rules.size.should eq @group.rules.size
        end
      end
      context 'resources' do
        it do
          res = @resources.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"resources\":#{res}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq @group.name
          g.resources.size.should eq 5
          g.rules.size.should eq @group.rules.size
        end
      end
      context 'rules' do
        it do
          rul = @rules.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"rules\":#{rul}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq @group.name
          g.resources.size.should eq @group.resources.size
          g.rules.size.should eq 5
        end
      end
      context 'name and resources' do
        it do
          res = @resources.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"name\":\"RenamedGroup\", \"resources\":#{res}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq 'RenamedGroup'
          g.resources.size.should eq 5
          g.rules.size.should eq @group.rules.size
        end
      end
      context 'name and rules' do
        it do
          rul = @rules.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"name\":\"RenamedGroup\", \"rules\":#{rul}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq 'RenamedGroup'
          g.resources.size.should eq @group.resources.size
          g.rules.size.should eq 5
        end
      end
      context 'resources and rules' do
        it do
          rul = @rules.pluck(:id)[0..4]
          res = @resources.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"resources\":#{res}, \"rules\":#{rul}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq @group.name
          g.resources.size.should eq 5
          g.rules.size.should eq 5
        end
      end
      context 'name, resources and rules' do
        it do
          rul = @rules.pluck(:id)[0..4]
          res = @resources.pluck(:id)[0..4]
          patch "#{@path}/#{@group.id}", "{ \"name\":\"RenamedGroup\", \"resources\":#{res}, \"rules\":#{rul}}", @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.name.should eq 'RenamedGroup'
          g.resources.size.should eq 5
          g.rules.size.should eq 5
        end
      end
    end
    describe 'content:' do
      context 'name to short' do
        it do
          patch "#{@path}/#{@group.id}", '{ "name":"" }', @header
          last_response.status.should eq 400
        end
      end
      context 'invalid resources' do
        it do
          patch "#{@path}/#{@group.id}", '{ "resources":[1337] }', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.resources.size.should eq 0
        end
      end
      context 'invalid rules' do
        it do
          patch "#{@path}/#{@group.id}", '{ "rules":[1337] }', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.rules.size.should eq 0
        end
      end
      describe 'rules still exist' do
        it do
          patch "#{@path}/#{@group.id}", '{ "rules":[] }', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.rules.size.should eq 0
          @group.rules.each do |r|
            TorfRule.find_by_id(r.id).should_not be nil
          end
        end
      end
      describe 'resources still exist' do
        it do
          patch "#{@path}/#{@group.id}", '{ "resources":[] }', @header
          last_response.status.should eq 204
          g = Group.find_by_id(@group.id)
          g.resources.size.should eq 0
          @group.resources.each do |r|
            Resource.find_by_id(r.id).should_not be nil
          end
        end
      end
    end
  end

  describe 'DELETE /groups/:id' do
    context 'valid id' do
      it do
        g = FactoryGirl.create(:group)
        delete "#{@path}/#{g.id}", nil, @header
        last_response.status.should eq 204
        Group.find_by_id(g.id).should be nil
      end
    end
    context 'invalid id' do
      it do
        delete "#{@path}/1337", nil, @header
        last_response.status.should eq 204
      end
    end
  end

  describe 'GET /groups/:id/resources' do
    context 'valid group id' do
      it do
        get "#{@path}/#{@group.id}/resources/", nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r.size.should eq @resources.size
      end
    end
    context 'invalid group id' do
      it do
        get "#{@path}/1337/resources/", nil, @header
        last_response.status.should eq 404
      end
    end
  end

  describe 'GET /groups/:id/rules' do
    context 'valid group id' do
      it do
        get "#{@path}/#{@group.id}/rules/", nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r.size.should eq @rules.size
      end
    end
    context 'invalid group id' do
      it do
        get "#{@path}/1337/rules/", nil, @header
        last_response.status.should eq 404
      end
    end
  end

  describe 'GET /groups/:id/rules/:id' do
    context 'valid rule id' do
      it do
        get "#{@path}/#{@group.id}/rules/#{@rules[0].id}", nil, @header
        last_response.status.should eq 200
        r = JSON(last_response.body)
        r['id'].should eq @rules[0].id
      end
    end
    context 'invalid rule id' do
      it do
        get "#{@path}/#{@group.id}/rules/1337", nil, @header
        last_response.status.should eq 404
      end
    end
  end
end
