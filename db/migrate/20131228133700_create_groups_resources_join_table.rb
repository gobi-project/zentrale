class CreateGroupsResourcesJoinTable < ActiveRecord::Migration
  def change
    create_table :groups_resources, id: false do |t|
      t.integer :resource_id
      t.integer :group_id
    end
  end
end