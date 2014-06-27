TITS.on_write do |dto|
  ActiveRecord::Base.connection_pool.with_connection do
    App.log.debug "Update Torf for resource #{dto.resource_id}"
    begin
      changes = Torf.update_sensor(resource_id: dto.resource_id, value: dto.value)
      App.log.debug "Torf has #{changes.size} changes"
      changes.each do |a|
        r = Resource.find_by_id(a.id)
        if r.nil?
          App.log.debug "TITS -> TORF no resource found for id #{a.id}"
        else
          r.update_resource(value: a.value)
        end
      end
    rescue => e
      App.log.err e.backtrace
    end
  end
end
