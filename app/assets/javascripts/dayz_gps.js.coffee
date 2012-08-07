window.DayzGps =

  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Socket: {}

  init: (opts) ->

    @current_user_id = opts.current_user_id
    @asset_host      = opts.asset_host
    @group_map_id    = opts.group_map_id
    @google          = opts.google

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
