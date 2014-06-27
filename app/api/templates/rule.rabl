object @rule

attributes :id, :name, :enabled

extends('rules/conditions')

node('actions') do |rule|
  sql = "SELECT
          resources.id,
          resources.device_id,
          resources.name,
          resources.resource_type,
          resources.interface_type,
          resources.unit,
          value
        FROM
          resources,
          torf_actions
        WHERE
          torf_rule_id = #{rule.id}
        AND
          resources.id = torf_resource_id"
  resources = ActiveRecord::Base.connection.execute(sql, :skip_logging).map!{|a| a.reject!{|k| k.class == Fixnum}}
  resources.map!{|r| OpenStruct.new r}

  partial('rules/resources', object: resources)
end
