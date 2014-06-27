object @notification

attributes :id, :text

node(:datetime) { |mes| mes.created_at.to_i }
