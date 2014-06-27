object @measurement

attributes :value
node(:datetime) { |mes| mes.time.to_i }
