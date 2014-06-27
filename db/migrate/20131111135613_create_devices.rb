class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :address
      t.integer :status, default: 4

      t.timestamps
    end
  end
end
