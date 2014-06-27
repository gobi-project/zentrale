class CreateTorfStates < ActiveRecord::Migration
  def change
    create_table :torf_states do |t|
      t.string :name, null: false
      t.belongs_to :torf_rule
      t.boolean :is_fulfilled, default: false
      t.timestamps
    end

    create_table :torf_rules_states do |t|
      t.belongs_to :torf_rule
      t.belongs_to :torf_state
    end

    create_table :state_child_associations do |t|
      t.integer :torf_state_id
      t.integer :parent_state_id
    end

    create_table :state_parent_associations do |t|
      t.integer :torf_state_id
      t.integer :child_state_id
    end
  end
end