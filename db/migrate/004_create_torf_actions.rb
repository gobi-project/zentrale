class CreateTorfActions < ActiveRecord::Migration
  def change
    create_table :torf_actions do |t|
      t.belongs_to :torf_resource
      t.belongs_to :torf_rule
      t.integer :value
      t.timestamps
    end
  end
end
