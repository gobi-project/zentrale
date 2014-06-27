require 'spec_helper'
require 'json'
describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods
  before(:all) do
    @path = "#{@api_prefix}/users"
  end
  before :each do
    @new_user = {}
    @new_user['username'] = 'validuser'
    @new_user['password'] = 'validpass'
    @new_user['email'] = 'user@valid.de'
  end
  describe 'GET /users' do
    describe 'list of all users' do
      it do
        @users = []
        10.times do
          @users << FactoryGirl.create(:user)
        end
        get @path, nil, @header
        last_response.status.should eq 200
        body = JSON(last_response.body)
        body.size.should eq User.all.count
      end
    end
  end
  describe 'POST /users' do
    describe 'parameters:' do
      context 'missing all' do
        it do
          post @path, '{}', @header
          last_response.status.should eq 400
        end
      end
      context 'only username' do
        it do
          @new_user.delete('password')
          @new_user.delete('email')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'only password' do
        it do
          @new_user.delete('email')
          @new_user.delete('username')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'only email' do
        it do
          @new_user.delete('password')
          @new_user.delete('username')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'only username and password' do
        it do
          @new_user.delete('email')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'only username and email' do
        it do
          @new_user.delete('password')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'only password and email' do
        it do
          @new_user.delete('username')
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'username, password and email' do
        it do
          post @path, @new_user.to_json, @header
          last_response.status.should eq 201
        end
      end
    end
    describe 'content:' do
      context 'used username' do
        it do
          post @path, @new_user.to_json, @header
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'username to short' do
        it do
          @new_user['username'] = 'ab'
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'username to long' do
        it do
          @new_user['username'] = 'a' * 50
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'invalid email' do
        it do
          @new_user['email'] = 'aasd'
          post @path, @new_user.to_json, @header
          last_response.status.should eq 400
        end
      end
    end
    describe 'authorization' do
      context 'without session token' do
        it do
          post @path, @new_user.to_json, generate_header
          last_response.status.should eq 201
          user = JSON(last_response.body)
          user['username'].should eq @new_user['username']
          user['email'].should eq @new_user['email']
          user.key?('id').should be true
        end
      end
    end
  end
  describe 'GET /users/:id' do
    context 'invalid id' do
      it do
        get "#{@path}/1337", nil, @header
        last_response.status.should eq 404
      end
    end
    context 'valid' do
      it do
        user = FactoryGirl.create(:user)
        get "#{@path}/#{user.id}", nil, @header
        last_response.status.should eq 200
        response = JSON(last_response.body)
        response.size.should eq 3
        response['username'].should eq user.username
        response['email'].should eq user.email
        response['id'].should eq user.id
      end
    end
  end
  describe 'PATCH /users/:id' do
    before :each do
      @password = 'foobar'
      @changed_user = FactoryGirl.create(:user, password: @password)
    end
    context 'invalid id' do
      it do
        patch "#{@path}/1337", nil, @header
        last_response.status.should eq 404
      end
    end
    describe 'parameters' do
      context 'none' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{}', @header
          last_response.status.should eq 204
          user = User.authenticate(@changed_user.username, @password)
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq @changed_user.username
          user.email.should eq @changed_user.email
        end
      end
      context 'id' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"id":20"}', @header
          last_response.status.should eq 400
          user = User.authenticate(@changed_user.username, @password)
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq @changed_user.username
          user.email.should eq @changed_user.email
        end
      end
      context 'email' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"email":"foo@bar.de"}', @header
          last_response.status.should eq 204
          user = User.authenticate(@changed_user.username, @password)
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq @changed_user.username
          user.email.should eq 'foo@bar.de'
        end
      end
      context 'username' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"username":"foobar"}', @header
          last_response.status.should eq 204
          user = User.authenticate('foobar', @password)
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq 'foobar'
          user.email.should eq @changed_user.email
        end
      end
      context 'password' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"password":"muchsecure"}', @header
          last_response.status.should eq 204
          user = User.authenticate(@changed_user.username, 'muchsecure')
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq @changed_user.username
          user.email.should eq @changed_user.email
        end
      end
      context 'email and username' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"email":"foo@bar.de", "username":"foobar"}', @header
          last_response.status.should eq 204
          user = User.authenticate('foobar', @password)
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq 'foobar'
          user.email.should eq 'foo@bar.de'
        end
      end
      context 'email and password' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"email":"foo@bar.de", "password":"muchsecure"}', @header
          last_response.status.should eq 204
          user = User.authenticate(@changed_user.username, 'muchsecure')
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq @changed_user.username
          user.email.should eq 'foo@bar.de'
        end
      end
      context 'username and password' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"username":"foobar", "password":"muchsecure"}', @header
          last_response.status.should eq 204
          user = User.authenticate('foobar', 'muchsecure')
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq 'foobar'
          user.email.should eq @changed_user.email
        end
      end
      context 'username, email and password' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"username":"foobar", "email":"foo@bar.de", "password":"muchsecure"}', @header
          last_response.status.should eq 204
          user = User.authenticate('foobar', 'muchsecure')
          user.should_not eq false
          user.id.should eq @changed_user.id
          user.username.should eq 'foobar'
          user.email.should eq 'foo@bar.de'
        end
      end
    end
    describe 'content' do
      context 'invalid email' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"email":"foo.de"}', @header
          last_response.status.should eq 400
        end
      end
      context 'username to short' do
        it do
          patch "#{@path}/#{@changed_user.id}", '{"username":"f"}', @header
          last_response.status.should eq 400
        end
      end
      context 'username to long' do
        it do
          patch "#{@path}/#{@changed_user.id}", "{\"username\":\"#{'a' * 30}\"}", @header
          last_response.status.should eq 400
        end
      end
      context 'username used' do
        it do
          user = FactoryGirl.create(:user)
          patch "#{@path}/#{@changed_user.id}", "{\"username\":\"#{user.username}\"}", @header
          last_response.status.should eq 400
        end
      end
    end
  end
  describe 'DELETE /users/:id' do
    context 'valid id' do
      it do
        u = FactoryGirl.create(:user)
        delete "#{@path}/#{u.id}", nil, @header
        last_response.status.should eq 204
        User.find_by_id(u.id).should be nil
      end
    end
    context 'invalid id' do
      it do
        delete "#{@path}/1337", nil, @header
        last_response.status.should eq 204
      end
    end
  end
end
