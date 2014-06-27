class CreateTorfResources < ActiveRecord::Migration
  def change
    create_table :torf_resources do |t|
      t.string :name
      t.integer :default_value, default: 0
      t.integer :value
      t.integer :through_rule, default: nil
      t.boolean :toggled_by_user, default: false
      t.timestamps
    end

    create_table :torf_resources_rules do |t|
      t.belongs_to :torf_resource
      t.belongs_to :torf_rule
    end

    create_table :torf_resources_states do |t|
      t.belongs_to :torf_resource
      t.belongs_to :torf_state
    end
  end
end