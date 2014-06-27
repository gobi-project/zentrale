##
# REST-API for notifications

module API
  ##
  # GET      /notifications          => Get all notifications
  # DELETE   /notifications/:id      => delete a notification
  class Notifications < Grape::API
    namespace :notifications do
      params do
        optional :read, type: Integer, default: 1
      end
      get '', rabl: 'notifications.rabl' do
        if params[:read] == 1
          @n = Notification.all
        else
          @n = Notification.where(read: false)
        end
        @notifications = @n.map(&:serializable_hash).map! { |r| OpenStruct.new r }
        @n.update_all(read: true)
        @notifications
      end

      route_param :notification_id, requirements: /[0-9]+/ do
        delete do
          n = Notification.find_by_id(params[:notification_id])
          n.destroy unless n.nil?
          status(204)
        end
      end
    end
  end
end
