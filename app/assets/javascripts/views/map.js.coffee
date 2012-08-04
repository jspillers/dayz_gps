class DayzGps.Views.Map extends Backbone.View

  initialize: (opts) ->
    @current_user_id = opts.current_user_id
    @group_map_id = opts.group_map_id
    @google = opts.google
    @asset_host = opts.asset_host

    @.setup_socket_io()
    @.setup_google_map()

    # initialize obj to track player position markers
    @player_markers = {}

    # poll for updated positions every sec
    @.poll_map_markers()

    # update the players position on click
    @google.maps.event.addListener @map, "click", (event) =>
      @.put_player_position(event.latLng)

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

  setup_socket_io: ->
    @socket = io.connect("http://localhost:8080")
    # React to a received message
    @socket.on "ping", (data) ->
      # Modify the DOM to show the message
      document.getElementById("msg").innerHTML = data.msg
      # Send a message back to the server
      @socket.emit "pong",
        msg: "The web browser also knows socket.io."

  setup_google_map: ->
    @map = new @google.maps.Map(document.getElementById("map_canvas"), @.map_options())

    image_map = new @google.maps.ImageMapType
      getTileUrl: (a, b) =>
        (if 0 > a.x or 0 > a.y or a.x > @.mapTileCounts()[b].x or a.y > @.mapTileCounts()[b].y then null else @asset_host + "/assets/tiles/" + b + "/" + a.x + "_" + a.y + ".png")
      tileSize: new @google.maps.Size(256, 256)
      minZoom: 2
      maxZoom: 6
      name: "Chernarus"

    @map.mapTypes.set "chernarus", image_map
    @map.setMapTypeId "chernarus"

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

  mapTileCounts: ->
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

  getNormalizedCoord: (coord, zoom) ->
    y = coord.y
    x = coord.x
    tileRange = 1 << zoom
    return null  if y < 0 or y >= tileRange
    return null  if x < 0 or x >= tileRange
    x: x
    y: y

  map_options: ->
    minZoom: 2
    maxZoom: 6
    inPng: not 0
    mapTypeControl: not 1
    center: new @google.maps.LatLng(7.5, 7)
    streetViewControl: not 1
    draggableCursor: "default"
    zoom: 3
    mapTypeControlOptions:
      mapTypeIds: [ "custom", @google.maps.MapTypeId.ROADMAP ]
      style: @google.maps.MapTypeControlStyle.DROPDOWN_MENU
