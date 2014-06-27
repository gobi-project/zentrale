require 'json'
require 'torf'

class RuleParseError < StandardError
end

##
# Parser for:
# JSON -> TorfRule
# JSON -> TorfState
class RuleParser
  def self.parse_rule(obj)
    json_object = parse_json_string(obj)
    parse_rule_json(json_object)
  end

  def self.parse_state(obj)
    json_object = parse_json_string(obj)
    parse_state_json(json_object)
  end

  def self.parse_actions(actions_object)
    actions = []
    actions_object.each do |action|
      fail RuleParseError, 'Invalid actions format' unless subset?(action, %w(id value))
      actions << { resource_id: action['id'], value: action['value'] }
    end
    actions
  end

  def self.parse_conditions(conditions_object)
    conditions = []
    conditions_object.each do |key, value|
      case key.downcase
      when 'any'
        conditions += parse_any(value)
      when 'none'
        conditions += parse_none(value)
      when 'greater'
        conditions += parse_greater(value)
      when 'less'
        conditions += parse_less(value)
      when 'equal'
        conditions += parse_equal(value)
      when 'unequal'
        conditions += parse_unequal(value)
      when 'states'
        conditions += parse_states(value)
      end
    end
    conditions
  end

  private

  def self.parse_json_string(json_string)
    begin
      json_object = JSON.parse(json_string)
    rescue
      raise RuleParseError, 'Unable to parse JSON'
    end
    json_object
  end

  def self.parse_rule_json(rule_object)
    fail RuleParseError, 'Invalid format' unless subset?(rule_object, %w(conditions actions name))
    Torf.create_rule(
                      name: rule_object['name'],
                      conditions: parse_conditions(rule_object['conditions']),
                      actions: parse_actions(rule_object['actions'])
                    )
  end

  def self.parse_state_json(rule_object)
    fail RuleParseError, 'Invalid format' unless subset?(rule_object, %w(conditions name))
    Torf.create_state(
                      name: rule_object['name'],
                      conditions: parse_conditions(rule_object['conditions'])
                    )
  end

  def self.parse_any(any_object)
    return if any_object.nil? || any_object.empty?
    any = []
    any_object.each do |a|
      fail RuleParseError, 'Invalid format for any object' unless subset?(a, %w(conditions))
      any << Any.new(*parse_conditions(a['conditions']))
    end
    any
  end

  def self.parse_none(none_object)
    return if none_object.nil? || none_object.empty?
    none = []
    none_object.each do |n|
      fail RuleParseError, 'Invalid format for none object' unless subset?(n, %w(conditions))
      none << None.new(*parse_conditions(n['conditions']))
    end
    none
  end

  def self.parse_greater(greater_object)
    return if greater_object.nil? || greater_object.empty?
    greater = []
    greater_object.each do |g|
      fail RuleParseError, 'Invalid format for conditions' unless subset?(g, %w(id value))
      greater << Greater.new(resource_id: g['id'], value: g['value'])
    end
    greater
  end

  def self.parse_less(less_object)
    return if less_object.nil? || less_object.empty?
    less = []
    less_object.each do |l|
      fail RuleParseError, 'Invalid format for conditions' unless subset?(l, %w(id value))
      less << Less.new(resource_id: l['id'], value: l['value'])
    end
    less
  end

  def self.parse_equal(equal_object)
    return if equal_object.nil? || equal_object.empty?
    equal = []
    equal_object.each do |e|
      fail RuleParseError, 'Invalid format for conditions' unless subset?(e, %w(id value))
      equal << Equal.new(resource_id: e['id'], value: e['value'])
    end
    equal
  end

  def self.parse_unequal(unequal_object)
    return if unequal_object.nil? || unequal_object.empty?
    unequal = []
    unequal_object.each do |u|
      fail RuleParseError, 'Invalid format for conditions' unless subset?(u, %w(id value))
      unequal << UnEqual.new(resource_id: u['id'], value: u['value'])
    end
    unequal
  end

  def self.parse_states(states_object)
    return if states_object.nil? || states_object.empty?
    states = []
    states_object.each do |s|
      fail RuleParseError, 'Invalid format for conditions' unless s.class == Fixnum
      states << { torf_state_id: s }
    end
    states
  end

  def self.subset?(array, values)
    values.all? { |k| array.key? k }
  end
end
