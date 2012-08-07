class DayzGps.Collections.MapMarkers extends Backbone.Collection

  #backend: 'messages'

  model: DayzGps.Models.MapMarker

  initialize: () ->
    #@.bindBackend()

    @.bind "backend:create", (model) ->
      console.log model
      @.add model

    @.bind "backend:update", (model) ->
      console.log model
      @.get(model.id).set model

    @.bind "backend:delete", (model) ->
      console.log model
      @.remove model.id
