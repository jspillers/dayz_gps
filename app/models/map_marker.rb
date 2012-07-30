class MapMarker < ActiveRecord::Base
  attr_accessible :group_map_id, :kind, :label, :lat, :lng, :user_id

  belongs_to :group_map
  belongs_to :user

  KINDS = [
    :player,
    :enemy_player,
    :squad,
    :vehicle,
    :camp,
    :waypoint,
    :objective,
    :sniper,
    :enemy_sniper
  ]
end
