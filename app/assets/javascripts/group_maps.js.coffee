$ ->
  window.initialize = ->
    map_options =
      minZoom: 2
      maxZoom: 6
      inPng: not 0
      mapTypeControl: not 1
      center: new google.maps.LatLng(7.5, 7)
      streetViewControl: not 1
      draggableCursor: "default"
      zoom: 3
      mapTypeControlOptions:
        mapTypeIds: [ "custom", google.maps.MapTypeId.ROADMAP ]
        style: google.maps.MapTypeControlStyle.DROPDOWN_MENU

    window.map = new google.maps.Map(document.getElementById("map_canvas"), map_options)
    window.map.mapTypes.set "chernarus", window.dayz_image_map
    window.map.setMapTypeId "chernarus"

    # initialize obj to track player position markers
    window.player_markers = {}

    # poll for updated positions every sec
    window.poll_player_positions()

    # update the players position on click
    google.maps.event.addListener window.map, "click", (event) ->
      window.put_player_position(event.latLng)

  window.dayz_image_map = new google.maps.ImageMapType(
    getTileUrl: (a, b) ->
      (if 0 > a.x or 0 > a.y or a.x > mapTileCounts[b].x or a.y > mapTileCounts[b].y then null else "/assets/tiles/" + b + "/" + a.x + "_" + a.y + ".png")
    tileSize: new google.maps.Size(256, 256)
    minZoom: 2
    maxZoom: 6
    name: "Chernarus"
  )

  window.put_player_position = (latLng) ->
    data =
      group_map:
        player_positions: {}
    data.group_map.player_positions[window.current_user_id] = { lat: latLng.lat(), lng: latLng.lng() }
    window.create_or_update_marker(window.current_user_id, latLng.lat(), latLng.lng())
    $.ajax
      url: '/group_maps/' + window.group_map_id
      type: 'PUT'
      dataType: "json"
      data: data
      success: (data) ->

  window.poll_player_positions = ->
    setInterval (->
      $.ajax
        url: '/group_maps/' + window.group_map_id
        dataType: "json"
        success: (data) ->
          window.create_or_update_markers(data)
    ), 1000

  window.create_or_update_markers = (locations) ->
    users = _.keys(locations)
    for user in users
      window.create_or_update_marker(user, locations[user].lat, locations[user].lng)

  window.create_or_update_marker = (user, lat, lng) ->
    if window.player_markers[user]?
      window.player_markers[user].setPosition(
        new google.maps.LatLng(lat, lng)
      )
    else
      window.player_markers[user] = new google.maps.Marker(
        position: new google.maps.LatLng(lat, lng)
        icon:
          path: google.maps.SymbolPath.CIRCLE
          scale: 3
          fillColor: 'blue'
          strokeColor: 'blue'
        draggable: false
        map: window.map
      )

  window.mapTileCounts =
    2:
      x: 3
      y: 3
    3:
      x: 7
      y: 6
    4:
      x: 15
      y: 13
    5:
      x: 31
      y: 26
    6:
      x: 63
      y: 53

  window.getNormalizedCoord = (coord, zoom) ->
    y = coord.y
    x = coord.x
    tileRange = 1 << zoom
    return null  if y < 0 or y >= tileRange
    return null  if x < 0 or x >= tileRange
    x: x
    y: y

