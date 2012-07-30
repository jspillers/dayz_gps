window.DayzGps =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: ->
    console.log 'Hello from Backbone!'
    map_marker = new DayzGps.Models.MapMarker()
    console.log map_marker

$(document).ready ->
  DayzGps.init()
