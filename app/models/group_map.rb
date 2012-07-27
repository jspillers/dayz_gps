class GroupMap < ActiveRecord::Base
  attr_accessible :description, :name, :player_positions
  attr_protected :owner_id

  belongs_to :owner, class_name: 'User'
  has_many :users, through: :group_memberships
  has_many :group_memberships

  serialize :player_positions

  def player_positions=(new_positions)
    old_positions = player_positions
    self[:player_positions] = old_positions.merge(new_positions)
  end

  def player_positions
    self[:player_positions].blank? ? {} : self[:player_positions]
  end

  def user_ids=(ids)
    ids_array = ids.split(',')
    self[:users] = User.find(ids_array)
  end

  def user_ids
    users.map(&:id).join(',')
  end
end
