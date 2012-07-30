class GroupMap < ActiveRecord::Base
  attr_accessible :description, :name, :player_positions
  attr_protected :owner_id

  belongs_to :owner, class_name: 'User'
  has_many :users, through: :group_memberships
  has_many :group_memberships
  has_many :map_markers

  accepts_nested_attributes_for :map_markers

end
