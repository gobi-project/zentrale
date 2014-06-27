##
# REST-API for psk

module API
  ##
  # GET     /psk      => List of all PSKs
  # POST    /psk      => Create new PSK
  # DELETE  /psk/:id  => Delete PSK
  class Psk < Grape::API
    namespace :psk do
      params do
        requires :uuid, type: String, regexp: /^\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}$/
        requires :psk, type: String, regexp: /^\w{16}$/
        optional :desc, type: String
      end
      post do
        psk = PreSharedKey.new(
                uuid: params[:uuid],
                psk: params[:psk],
                desc: params[:desc]
            )
        if psk.save
          status(204)
          DeviceInitializer.run
        else
          error('Bad Request', 400)
        end
      end

      get do
        PreSharedKey.all
      end

      route_param :uuid_id, requirements: /[0-9]+/ do
        delete do
          PreSharedKey.delete(params[:uuid_id])
          status(204)
        end
      end
    end
  end
end
