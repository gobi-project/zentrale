class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.string :resource_type
      t.string :interface_type
      t.string :unit
      t.string :path
      t.references :device, index: true

      t.timestamps
    end
  end
end
