##
# REST-API for users

module API
  ##
  # GET     /users      => List of all users
  # POST    /user       => Create new user
  # GET     /user/:id   => Get data from user
  # PATCH   /user/:id   => Change data from user
  # DELETE  /user:id    => Delete user
  class Users < Grape::API
    namespace :users do
      get '', rabl: 'users.rabl' do
        authenticate!
        @users = User.all
      end

      params do
        requires :username, type: String
        requires :password, type: String
        requires :email, type: String
      end
      post '', rabl: 'user.rabl' do
        @user = User.create(
                  username: params[:username],
                  password: params[:password],
                  email: params[:email]
             )
        error({ error: @user.errors.messages }, 400) unless @user.valid?
      end

      route_param :user_id, requirements: /[0-9]+/ do
        before do
          authenticate!
          @user = User.find_by_id(params[:user_id])
          error('Not Found', 404) unless options[:method].include?('DELETE') if @user.nil?
        end

        get '', rabl: 'user.rabl' do
          @user
        end

        params do
          optional :username, type: String
          optional :password, type: String
          optional :email, type: String
        end
        patch do
          if @user.update(permitted_params)
            status(204)
          else
            error({ error: @user.errors.messages }, 400)
          end
        end

        delete do
          @user.destroy unless @user.nil?
          status(204)
        end
      end
    end
  end
end
