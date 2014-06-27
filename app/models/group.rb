class Group < ActiveRecord::Base
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :torf_rules

  validates :name, presence: true, length: { minimum: 1 }
  alias_attribute :rules, :torf_rules

  def self.build(options = {})
    return unless options.class == Hash
    g = Group.new(name: options[:name])
    if g.valid?
      g.save
      g.update_group(options.except!(:name))
    end
    g
  end

  def update_group(options = {})
    return unless options.class == Hash
    self.name = options[:name] if options.key?(:name)

    if self.valid?
      new_res_ids = options[:resources]
      unless new_res_ids.nil?
        new_res = Resource.where('id in (?)', new_res_ids)
        resources.replace(new_res)
      end

      new_rule_ids = options[:rules]
      unless new_rule_ids.nil?
        new_rules = TorfRule.where('id in (?)', new_rule_ids)
        rules.replace(new_rules)
      end
      save
    end
  end
end
