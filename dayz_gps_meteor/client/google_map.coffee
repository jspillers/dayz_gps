class GoogleMap

  constructor: (opts) ->
    @google = opts.google
    @.setup_google_map()

  setup_google_map: ->
    @map = new @google.maps.Map(document.getElementById("map_canvas"), @.map_options())

    image_map = new @google.maps.ImageMapType
      getTileUrl: (a, b) =>
        (if 0 > a.x or 0 > a.y or a.x > @.mapTileCounts()[b].x or a.y > @.mapTileCounts()[b].y then null else "/images/tiles/" + b + "/" + a.x + "_" + a.y + ".png")
      tileSize: new @google.maps.Size(256, 256)
      minZoom: 2
      maxZoom: 6
      name: "Chernarus"

    @map.mapTypes.set "chernarus", image_map
    @map.setMapTypeId "chernarus"

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
