class GroupMap < ActiveRecord::Base
  attr_accessible :description, :name
  attr_protected :owner_id

  belongs_to :owner, class_name: 'User'
  has_many :users, through: :group_memberships
  has_many :group_memberships
end
