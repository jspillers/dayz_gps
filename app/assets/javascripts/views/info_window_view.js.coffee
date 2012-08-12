class DayzGps.Views.InfoWindowView extends Backbone.View

  initialize: (opts) ->
    @template = _.template($("#info-window-template").html())
    @google = DayzGps.google
    @map = DayzGps.google_map
    @info_windows = DayzGps.info_windows
    @map_marker = opts.map_marker
    @info_window = new google.maps.InfoWindow

  render: ->
    @map_marker.set('marker_cid', @map_marker.cid)
    content = @template(@map_marker.toJSON())
    @info_window.setContent content

    google.maps.event.addListener @info_window, 'domready', () =>
      $("#info-window-delete-" + @map_marker.cid).submit (evnt) =>
        @map_marker.delete()
        return false

    @info_window.open @map, @map_marker.marker

  close: -> @info_window.setMap()

  delete_marker: ->
    console.log 'delete marker: ' + @marker.cid
