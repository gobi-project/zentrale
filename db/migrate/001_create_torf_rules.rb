class CreateTorfRules < ActiveRecord::Migration
  def change
    create_table :torf_rules do |t|
      t.string :name, null: false
      t.integer :priority
      t.boolean :enabled, default: true
      t.boolean :is_active, default: false
      t.timestamps
    end
  end
end
