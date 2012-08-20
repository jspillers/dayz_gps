class MapView extends Backbone.View

  initialize: (opts) ->
    @current_user_id   = opts.current_user._id
    @group_map_id      = opts.group_map_id
    @google            = opts.google
    @map               = opts.google_map
    @info_window_views = opts.info_window_views

    @google.maps.event.addListener @map, 'click', @.handle_click
    @google.maps.event.addListener @map, 'dblclick', @.handle_dbl_click
    @google.maps.event.addListener @map, 'rightclick', @.handle_right_click

  handle_click: (event) =>
    # hide any open info windows
    _.each @info_window_views, (win_view) -> win_view.close()

  handle_right_click: (event) =>
    @.create_marker(event)

  handle_dbl_click: ->
    console.log 'handle double click'

  create_marker: (event) ->
    MapMarkers.insert
      lat: event.latLng.lat()
      lng: event.latLng.lng()
      type: 'player'
      label: 'Bob'
      description: ''
      group_map_id: @group_map_id
      owner_id: @current_user_id
