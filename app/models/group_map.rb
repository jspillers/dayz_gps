class GroupMap < ActiveRecord::Base
  attr_accessible :description, :name, :map_markers
  attr_protected :owner_id

  belongs_to :owner, class_name: 'User'
  has_many :users, through: :group_memberships
  has_many :group_memberships
  has_many :map_markers

  def map_markers=(positions)
    #map_markers.find_or_create_by_socket_id ??
  end
end
