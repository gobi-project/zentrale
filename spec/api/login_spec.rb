require 'spec_helper'
require 'json'

describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods

  before(:all) do
    @password = 'foobert'
    @users = []
    2.times do
      @users << FactoryGirl.create(:user, password: @password)
    end
    @path = "#{@api_prefix}/login"
  end

  describe 'POST /login' do
    context 'without credentials' do
      it do
        params = '{}'
        post @path, params, generate_header
        last_response.status.should eq 400
      end
    end

    context 'wrong password' do
      it do
        param = "{ \"username\":\"#{@users[0].username}\", \"password\":\"hallo\" }"
        post @path, param, generate_header
        last_response.status.should eq 401
      end
    end

    context 'missing password' do
      it do
        param = "{ \"username\":\"#{@users[0].username}\" }"
        post @path, param, generate_header
        last_response.status.should eq 400
      end
    end

    context 'wrong username' do
      it do
        param = "{ \"username\":\"Hallo\", \"password\":\"#{@password}\" }"
        post @path, param, generate_header
        last_response.status.should eq 401
      end
    end

    context 'missing username' do
      it do
        param = "{ \"password\":\"hallo\" }"
        post @path, param, generate_header
        last_response.status.should eq 400
      end
    end

    context 'right credentials' do
      it do
        param = "{ \"username\":\"#{@users[0].username}\", \"password\":\"#{@password}\" }"
        post @path, param, generate_header
        last_response.status.should eq 201
        valid_data = "{ \"session\":\"#{@users[0].session_token.last[:token]}\" }"
        JSON(last_response.body).should eq JSON(valid_data)
      end
    end
  end

  describe 'DELETE /login' do
    context 'missing token' do
      it do
        delete @path, nil, generate_header
        last_response.status.should eq 401
      end
    end

    describe 'token via request header' do
      context 'invalid token' do
        it do
          delete @path, nil, generate_header('foobar')
          last_response.status.should eq 401
        end
      end

      context 'valid token' do
        it do
          token = @users[1].session_token.create[:token]
          delete @path, nil, generate_header(token)
          last_response.status.should eq 204
          SessionToken.find_by_token(token).should be nil
        end
      end
    end

    describe 'token via query string' do
      context 'invalid token' do
        it do
          delete "#{@path}?session=foobar", nil, generate_header
          last_response.status.should eq 401
        end
      end

      context 'valid token' do
        it do
          token = @users[1].session_token.create[:token]
          delete "#{@path}?session=#{token}", nil, generate_header
          last_response.status.should eq 204
          SessionToken.find_by_token(token).should eq nil
        end
      end
    end
  end
end
