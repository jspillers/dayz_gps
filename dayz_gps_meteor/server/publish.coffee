# MapMarker -- {name: String}
MapMarkers = new Meteor.Collection('map_markers')

# Publish complete set of lists to all clients.
Meteor.publish 'map_markers', ->
  MapMarkers.find()

GroupMaps = new Meteor.Collection('group_maps')

Meteor.publish 'group_maps', ->
  MapMarkers.find()

#SetMemberships = new Meteor.Collection("set_memberships");
#
#// Publish visible items for requested list_id.
#Meteor.publish('marker', function (list_id) {
#  return Todos.find({
#    list_id: list_id,
#    privateTo: {
#      $in: [null, this.userId()]
#    }
#  });
#});

