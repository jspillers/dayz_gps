class DayzGps.MapMarkersView extends Backbone.View

  el: $ 'body'

  initialize: ->
    _.bindAll @
    @.render()

  render: ->
    console.log 'render'
