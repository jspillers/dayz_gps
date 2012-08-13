class DayzGps.Collections.MapMarkers extends Backbone.Collection

  backend: 'messages'

  model: DayzGps.Models.MapMarker

  initialize: () ->
    #@.bindBackend()

    @.bind "backend:create", (model) ->
      @.add model

    @.bind "backend:update", (model) ->
      @.get(model.id).set model

    @.bind "backend:delete", (model) ->
      @.get(model.id).nullify()
      @.remove model.id
