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
      container = $("#info-window-" + @map_marker.cid)
      container.find('.marker-type option[value="' + @map_marker.get('type') + '"]').
        prop('selected','selected')
      container.find(".save-marker").click (evnt) =>
        attrs =
          label: container.find('.marker-label').val()
          type: container.find('.marker-type').val()
          description: container.find('.marker-description').val()
        @map_marker.save attrs,
          success: =>
            @map_marker.render()
            @.close()
        return false

      container.find(".delete-marker").click (evnt) =>
        @map_marker.delete()
        return false

    @info_window.open @map, @map_marker.marker

  close: ->
    @info_window.setMap()
