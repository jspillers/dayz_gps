class DayzGps.Views.MapView extends Backbone.View

  initialize: (opts) ->
    @current_user_id = DayzGps.current_user_id
    @group_map_id    = DayzGps.group_map_id
    @google          = DayzGps.google
    @asset_host      = DayzGps.asset_host
    @map             = DayzGps.google_map

    @google.maps.event.addListener @map, 'rightclick', @.handle_right_click

    # poll for updated positions every sec
    #@.poll_map_markers()

    # update the players position on click
    #@google.maps.event.addListener @map, "click", (event) =>
    #  @.put_player_position(event.latLng)

  handle_right_click: () ->
    console.log 'right click'

  put_player_position: (latLng) ->
    data =
      group_map:
        map_markers: {}
    data.group_map.map_markers[@current_user_id] = { lat: latLng.lat(), lng: latLng.lng() }
    @.create_or_update_marker(@current_user_id, latLng.lat(), latLng.lng())
    $.ajax
      url: '/group_maps/' + @group_map_id
      type: 'PUT'
      dataType: "json"
      data: data
      success: (data) ->

  poll_map_markers: ->
    $.ajax
      url: '/group_maps/' + @group_map_id
      dataType: "json"
      success: (data) =>
        @.create_or_update_markers(data)

  create_or_update_markers: (locations) ->
    users = _.keys(locations)
    for user in users
      @.create_or_update_marker(user, locations[user].lat, locations[user].lng)

  create_or_update_marker: (user, lat, lng) ->
    if @player_markers[user]?
      @player_markers[user].setPosition(
        new @google.maps.LatLng(lat, lng)
      )
    else
      @player_markers[user] = new @google.maps.Marker(
        position: new @google.maps.LatLng(lat, lng)
        icon:
          path: @google.maps.SymbolPath.CIRCLE
          scale: 3
          fillColor: 'blue'
          strokeColor: 'blue'
        draggable: false
        map: @map
      )

