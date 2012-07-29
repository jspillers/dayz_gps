class MapMarker < ActiveRecord::Base
  attr_accessible :group_map_id, :kind, :label, :lat, :lng, :user_id
end
