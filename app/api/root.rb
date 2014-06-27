##
# Mount point for REST-API

module API
  ##
  # Root API
  class Root < Grape::API
    prefix 'api'
    version 'v1', using: :path
    format :json
    formatter :json, Grape::Formatter::Rabl
    content_type :json, 'application/json'

    helpers do

      # FIXME: Rack::Cors should handle this, grape ...
      def error(msg, code)
        error!(msg, code, 'Access-Control-Allow-Origin' => '*')
      end

      def authenticate!
        error('Unauthorized', 401) unless current_user
      end

      def current_user
        ActiveRecord::Base.connection_pool.with_connection do
          session = @request.env['Session'] || @request.headers['Session'] || params[:session]
          token = SessionToken.find_by_token(session)

          if token
            @current_token = token.token
            @current_user = token.user
          else
            false
          end
        end
      end

      def permitted_params
        declared(params, include_missing: false)
      end
    end
    before do
      header 'Access-Control-Allow-Origin', '*'
    end

    mount API::Login
    mount API::Name
    mount API::Users
    segment do
      before do
        authenticate!
      end
      mount API::Devices
      mount API::Resources
      mount API::Groups
      mount API::Psk
      mount API::Rules
      mount API::States
      mount API::Notifications
    end
    # FIXME: Options in grape 0.7.0 not working
    route :options, '*path' do
      status(204)
    end
  end
end
