# 'AIzaSyCK9DOLqMbvXzjArxcr5xp4LEGPpga_jm8'

$ ->
  window.initialize = ->
    myLatlng = new google.maps.LatLng(0, 0)
    mapOptions =
      center: myLatlng
      zoom: 1
      streetViewControl: false
      mapTypeControlOptions:
        mapTypeIds: [ "moon" ]

    console.log google
    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)
    map.mapTypes.set "moon", window.moonMapType
    map.setMapTypeId "moon"

  window.getNormalizedCoord = (coord, zoom) ->
    y = coord.y
    x = coord.x
    tileRange = 1 << zoom
    return null  if y < 0 or y >= tileRange
    return null  if x < 0 or x >= tileRange
    x: x
    y: y
  window.moonTypeOptions =
    getTileUrl: (coord, zoom) ->
      normalizedCoord = getNormalizedCoord(coord, zoom)
      return null  unless normalizedCoord
      bound = Math.pow(2, zoom)
      url = "http://mw1.google.com/mw-planetary/lunar/lunarmaps_v1/clem_bw" + "/" + zoom + "/" + normalizedCoord.x + "/" + (bound - normalizedCoord.y - 1) + ".jpg"
      console.log url
      url

    tileSize: new google.maps.Size(256, 256)
    maxZoom: 9
    minZoom: 0
    radius: 1738000
    name: "Moon"

  window.moonMapType = new google.maps.ImageMapType(moonTypeOptions)
