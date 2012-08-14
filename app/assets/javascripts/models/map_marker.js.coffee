class DayzGps.Models.MapMarker extends Backbone.Model

  initialize: (opts) ->
    @google = DayzGps.google
    @map = DayzGps.google_map
    @info_window_views = DayzGps.info_window_views

    @.render()
    @.setup_event_listeners()

  render: ->
    opts =
      position: @.get_lat_lng()
      icon: @.icon()
      draggable: true
      map: @map
    if @marker?
      @marker.setOptions(opts)
    else
      @marker = new @google.maps.Marker(opts)

  setup_event_listeners: ->
    @google.maps.event.addListener @marker, 'click', @.handle_click
    @google.maps.event.addListener @marker, 'dblclick', @.handle_dbl_click
    @google.maps.event.addListener @marker, 'dragend', @.handle_drag_end
    @.on('change', @.update_marker, @)

  get_lat_lng: ->
    new @google.maps.LatLng(@.get('lat'), @.get('lng'))

  handle_click: =>
    _.each @info_window_views, (win_view) -> win_view.close()

    @info_window_view = if !@info_window_views[@cid]?
      inf_win_view = new DayzGps.Views.InfoWindowView(map_marker: @)
      @info_window_views[@cid] = inf_win_view
      inf_win_view
    else
      @info_window_views[@cid]

    @info_window_view.render()

  delete: ->
    @.nullify()
    @.destroy()

  nullify: ->
    @marker.setMap()
    @marker = null
    delete @info_window_views[@cid]
    @info_window_view = null

  handle_dbl_click: ->
    console.log 'handle double click'

  update_marker: =>
    @marker.setPosition(@.get_lat_lng())

  handle_drag_end: (event) =>
    @.set('lat', event.latLng.lat())
    @.set('lng', event.latLng.lng())
    @.save()

  icon: ->
    if @.get('type') == 'camp'
      '/assets/tent-icon.gif'
    else
      path: @google.maps.SymbolPath.CIRCLE
      scale: 3
      fillColor: 'blue'
      strokeColor: 'blue'
