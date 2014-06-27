class CreateGroupsTorfRulesJoinTable < ActiveRecord::Migration
  def change
    create_table :groups_torf_rules, id: false do |t|
      t.integer :group_id
      t.integer :torf_rule_id
    end
  end
end
