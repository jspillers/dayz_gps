class CreateGroupMaps < ActiveRecord::Migration
  def change
    create_table :group_maps do |t|
      t.string :name
      t.text :description
      t.integer :owner_id

      t.timestamps
    end
  end
end
