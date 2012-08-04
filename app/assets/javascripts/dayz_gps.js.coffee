window.DayzGps =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Socket: {}
  init: ->
    @map = new DayzGps.Views.Map
      current_user_id: window.current_user_id
      asset_host: window.asset_host
      group_map_id: window.group_map_id
      google: window.google

$(document).ready ->
  $.getScript("http://localhost:8080/socket.io/socket.io.js").done (script, textStatus) ->
    DayzGps.init()
