class GroupMembership < ActiveRecord::Base
  attr_accessible :group_map_id, :user_id

  belongs_to :user
  belongs_to :group_map

end
