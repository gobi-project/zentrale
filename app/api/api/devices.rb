##
# REST-API for devices

module API
  ##
  # GET     /devices         => List of all devices
  # GET     /devices/:id     => Data from device
  # PATCH   /devices/:id     => Change device
  # DELETE  /devices/:id    => Delete device
  #
  # Plus all from /resources
  class Devices < Grape::API
    namespace :devices do
      params do
        optional :limit, type: String
      end
      get '', rabl: 'devices.rabl' do
        if params[:limit].nil?
          @devices = Device.all
        else
          limits = params[:limit].split(',')
          limits.each do |limit|
            error('Bad Request', 400) unless limit.match(/^[0-9]+$/)
          end

          if limits.size == 1
            @devices = Device.all.limit(limits[0])
          elsif limits.size == 2
            @devices = Device
                      .offset(limits[0])
                      .limit(limits[1])
          else
            error('Bad Request', 400)
          end
        end
      end

      route_param :device_id, requirements: /[0-9]+/ do
        before do
          @device = Device.find_by_id(params[:device_id])
          error('Device not found', 404) unless options[:method].include?('DELETE') if @device.nil?
        end

        get '', rabl: 'device.rabl' do
          @device
        end

        params do
          optional :name, type: String
          optional :status, type: String
        end
        patch do
          if @device.update(permitted_params)
            status(204)
          else
            error({ error: @device.errors.messages }, 400)
          end
        end

        delete do
          @device.destroy unless @device.nil?
          status(204)
        end

        # FIXME: Cannot mount module multiple times
        # https://github.com/intridea/grape/issues/570
        # mount API::Resources
        eval(IO.read("#{Rails.root}/app/api/api/resources.nested"))
      end
    end
  end
end
