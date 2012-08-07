window.DayzGps =

  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Socket: {}

  init: ->
    Backbone.io.connect('http://localhost:3000');

    @current_user_id = window.current_user_id
    @asset_host      = window.asset_host
    @group_map_id    = window.group_map_id
    @google          = window.google
    @google_map_view = new DayzGps.GoogleMap()
    @google_map      = @google_map_view.map
    @map_markers     = new DayzGps.Collections.MapMarkers()

    models = [
      {
        lat: 0
        lng: 0
        type: 'player'
        label: 'Bob'
        owner_id: @current_user_id
      }
    ]

    @map_markers.reset(models)

    @socket          = new DayzGps.SocketIo(collection: @map_markers)
    @map_view        = new DayzGps.Views.MapView(collection: @map_markers)

$(document).ready ->
  $.getScript("http://localhost:3000/socket.io/socket.io.js").done (script, textStatus) ->
    $.getScript("http://localhost:3000/socket.io/backbone.io.js").done (script, textStatus) ->
      DayzGps.init()
