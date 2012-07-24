class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.integer :group_map_id
      t.integer :user_id

      t.timestamps
    end
  end
end
