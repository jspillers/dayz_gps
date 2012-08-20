DayzGps = {}
DayzGps.info_window_views = []

MapMarkers = new Meteor.Collection('map_markers')

GroupMaps = new Meteor.Collection('group_maps')

Session.set('group_map_id', null)

DayzGpsRouter = Backbone.Router.extend
  routes:
    '':              'home'
    ':group_map_id': 'home'

  home: (group_map_id) ->
    window.google_map = new GoogleMap(google: window.google)
    new MapView
      info_window_views: DayzGps.info_window_views
      group_map_id: group_map_id
      current_user: Meteor.user()
      google: window.google
      google_map: window.google_map


  set_group_map: (group_map_id) ->
    Session.set "group_map_id", group_map_id

Router = new DayzGpsRouter

Meteor.startup ->
  Backbone.history.start { pushState: true }
