class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string   :text,    null: false
      t.boolean  :read,    null: false,  default: false

      t.timestamps
    end
  end
end
