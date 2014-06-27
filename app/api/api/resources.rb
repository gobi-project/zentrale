##
# REST-API for resources

module API
  ##
  # GET     /resources       => List of all resources
  # GET     /resources/:id   => Get data from resource
  # PATCH	 /resources/:id   => Change resource
  # DELETE  /resources/:id   => Delete resource
  class Resources < Grape::API
    # FIXME: Cannot mount module multiple times
    # https://github.com/intridea/grape/issues/570
    eval(IO.read("#{Rails.root}/app/api/api/resources.nested"))
  end
end
