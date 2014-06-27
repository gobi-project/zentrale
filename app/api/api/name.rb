##
# REST-API for name

module API
  ##
  # GET    /name    => Get server name
  class Name < Grape::API
    get :name do
      { name: App.name }
    end
  end
end
