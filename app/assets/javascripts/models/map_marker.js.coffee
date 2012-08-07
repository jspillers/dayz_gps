class DayzGps.Models.MapMarker extends Backbone.Model

  initialize: (opts) ->
    @google = DayzGps.google
    @map = DayzGps.google_map
    @marker = new @google.maps.Marker
      position: new @google.maps.LatLng(@.get('lat'), @.get('lng'))
      icon: @.icon()
      draggable: true
      map: @map
    @.setup_event_listeners()

  setup_event_listeners: ->
    @google.maps.event.addListener @marker, 'dblclick', @.handle_dbl_click
    @google.maps.event.addListener @marker, 'click', @.handle_click
    @google.maps.event.addListener @marker, 'dragend', @.handle_drag_end

  handle_click: ->
    console.log 'handle click'

  handle_dbl_click: ->
    console.log 'handle double click'

  handle_drag_end: (event) =>
    @.set('lat', event.latLng.lat())
    @.set('lng', event.latLng.lng())
    @.save()

  icon: ->
    path: @google.maps.SymbolPath.CIRCLE
    scale: 3
    fillColor: 'blue'
    strokeColor: 'blue'
