class CreateMapMarkers < ActiveRecord::Migration
  def change
    create_table :map_markers do |t|
      t.integer :user_id
      t.integer :group_map_id
      t.integer :lat
      t.integer :lng
      t.string :kind
      t.string :label

      t.timestamps
    end
  end
end
