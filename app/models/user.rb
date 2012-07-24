class User < ActiveRecord::Base
  attr_accessible :email, :name, :provider, :uid

  has_many :owned_group_maps, class_name: 'GroupMap', foreign_key: 'owner_id'

  has_many :group_maps, through: :group_memberships
  has_many :group_memberships

  def is_a_member_of?(group_map)
    group_map.users.include?(self)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

end
