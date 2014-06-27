require 'spec_helper'
require 'json'
require 'codtls'
describe 'GobiAPI' do
  include AuthHelper
  include Rack::Test::Methods
  before(:all) do
    @path = "#{@api_prefix}/psk"
  end
  before(:each) do
    @param = {}
    @param['uuid'] = 'ef9621e3-68cf-456d-86cc-452179acda96'
    @param['psk'] = 'ABCDEFGHIJKLMNOP'
    @param['desc'] = 'Toller Key'
  end
  describe 'POST /psk' do
    describe 'parameters' do
      context 'uuid only' do
        it do
          @param.delete('psk')
          @param.delete('desc')
          post @path, @param.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'psk only' do
        it do
          @param.delete('uuid')
          @param.delete('desc')
          post @path, @param.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'desc only' do
        it do
          @param.delete('uuid')
          @param.delete('psk')
          post @path, @param.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'uuid and desc' do
        it do
          @param.delete('psk')
          post @path, @param.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'psk and desc' do
        it do
          @param.delete('uuid')
          post @path, @param.to_json, @header
          last_response.status.should eq 400
        end
      end
      context 'uuid and psk' do
        it do
          @param.delete('desc')
          post @path, @param.to_json, @header
          last_response.status.should eq 204
        end
      end
      context 'uuid, psk and desc' do
        it do
          post @path, @param.to_json, @header
          last_response.status.should eq 204
        end
      end
    end
    describe 'content' do
      describe 'invalid uuid, valid psk' do
        context 'uuid to long' do
          it do
            @param['uuid'] = 'ef9621e368cf456d86cc452179aasdasdasdsdsdcda96'
            post @path, @param.to_json, @header
            last_response.status.should eq 400
          end
        end
        context 'uui to short' do
          it do
            @param['uuid'] = 'ef962-e368cf452179acda96'
            post @path, @param.to_json, @header
            last_response.status.should eq 400
          end
        end
      end
      describe 'valid uuid, invalid psk' do
        context 'psk to long' do
          it do
            @param['psk'] = 'ABCDEFGHIJKLMNOPQ'
            post @path, @param.to_json, @header
            last_response.status.should eq 400
          end
        end
        context 'psk to short' do
          it do
            @param['psk'] = 'ABCDEFGHIJKLMNO'
            post @path, @param.to_json, @header
            last_response.status.should eq 400
          end
        end
      end
      describe 'valid uuid and psk' do
        context 'with desc' do
          it do
            post @path, @param.to_json, @header
            last_response.status.should eq 204
            psk = CODTLSDevice.where(uuid: ['ef9621e368cf456d86cc452179acda96'].pack('H*'), psk: 'ABCDEFGHIJKLMNOP', desc: 'Toller Key')
            psk.should_not be nil
          end
        end
        context 'without desc' do
          it do
            @param.delete('desc')
            post @path, @param.to_json, @header
            last_response.status.should eq 204
            psk = CODTLSDevice.where(uuid: ['ef9621e368cf456d86cc452179acda96'].pack('H*'), psk: 'ABCDEFGHIJKLMNOP', desc: nil)
            psk.should_not be nil
          end
        end
      end
    end
  end
  describe 'GET /psk' do
    context 'no keys' do
      it do
        get @path, nil, @header
        last_response.status.should eq 200
      end
    end
    context 'multiple keys' do
      it do
        PreSharedKey.new(
                          uuid: @param['uuid'],
                          psk: @param['psk'],
                          desc: @param['desc']
                        ).save
        get @path, nil, @header
        last_response.status.should eq 200
        response = JSON(last_response.body)
        response.size.should eq 1
        response[0]['uuid'].should eq @param['uuid']
        response[0]['psk'].should eq @param['psk']
        response[0]['desc'].should eq @param['desc']
      end
    end
  end
end
