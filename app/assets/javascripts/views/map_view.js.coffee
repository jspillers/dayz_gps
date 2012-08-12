class DayzGps.Views.MapView extends Backbone.View

  initialize: (opts) ->
    @current_user_id   = DayzGps.current_user_id
    @group_map_id      = DayzGps.group_map_id
    @google            = DayzGps.google
    @asset_host        = DayzGps.asset_host
    @map               = DayzGps.google_map
    @info_window_views = DayzGps.info_window_views

    @google.maps.event.addListener @map, 'click', @.handle_click
    @google.maps.event.addListener @map, 'rightclick', @.handle_right_click

  handle_click: (event) =>
    console.log @info_window_views
    # hide any open info windows
    _.each @info_window_views, (win_view) -> win_view.close()

  handle_right_click: (event) =>
    @.create_marker(event)

  create_marker: (event) ->
    DayzGps.map_markers.create
      lat: event.latLng.lat()
      lng: event.latLng.lng()
      type: 'player'
      label: 'Bob'
      description: 'some stuff about this marker goes here'
      owner_id: @current_user_id
