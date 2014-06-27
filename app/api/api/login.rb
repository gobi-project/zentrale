##
# REST-API for login

module API
  ##
  # POST    /login    => Get session token
  # DELETE  /login    => Remove session token
  class Login < Grape::API
    params do
      requires :username, type: String
      requires :password, type: String
    end
    post :login, rabl: 'session.rabl' do
      user = User.authenticate(params[:username], params[:password])
      error('Unauthorized', 401) unless user

      @session = user.session_token.create
    end

    delete :login do
      authenticate!
      t = SessionToken.find_by_token(@current_token)
      t.destroy unless t.nil?
      status(204)
    end
  end
end
