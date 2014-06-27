code('conditions') do
  @result = {}
  @result[:equal] = []
  @result[:unequal] = []
  @result[:less] = []
  @result[:greater] = []

  sql = "SELECT
          resources.id,
          resources.device_id,
          resources.name,
          resources.resource_type,
          resources.interface_type,
          resources.unit,
          value,
          type
        FROM
          resources,
          torf_simple_matchers
        WHERE
          #{root_object.instance_of?(TorfRule) ? 'torf_rule_id' : 'torf_state_id'} = #{root_object.id}
        AND
          resources.id = torf_resource_id"
  matcher = ActiveRecord::Base.connection.execute(sql, :skip_logging).map!{|a| a.reject!{|k| k.class == Fixnum}}

  matcher.each do |m|
    case m['type']
    when 'Equal'
      @result[:equal] << OpenStruct.new(m.except('type'))
    when 'UnEqual'
      @result[:unequal] << OpenStruct.new(m.except('type'))
    when 'Less'
      @result[:less] << OpenStruct.new(m.except('type'))
    when 'Greater'
      @result[:greater] << OpenStruct.new(m.except('type'))
    end
  end

  @result.each do |k,v|
    if v.empty?
      @result.delete k
    else
     v = partial('rules/resources', object: v)
   end
  end

  if root_object.instance_of?(TorfRule) or root_object.instance_of?(TorfState)
    @any = root_object.torf_complex_matchers.where(type: 'Any')
    @none = root_object.torf_complex_matchers.where(type: 'None')
  else
    @any = root_object.child_complex_matchers.where(type: 'Any')
    @none = root_object.child_complex_matchers.where(type: 'None')
  end

  @states = []
  if root_object.respond_to?(:child_states)
    @states = root_object.child_states
  elsif root_object.respond_to?(:torf_states)
    @states = root_object.torf_states
  end

  @result[:states] = partial('states', object: @states) unless @states.empty?

  @result[:any] = [] unless @any.empty?
  @any.map do |a|
    @result[:any] << partial('rules/conditions', :object => a)
  end

  @result[:none] = [] unless @none.empty?
  @none.map do |n|
    @result[:none] << partial('rules/conditions', :object => n)
  end

  @result
end
