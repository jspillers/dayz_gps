window.Namespace = {}

class Namespace.Message extends Backbone.Model
  initialize: ->
    @on "error", (model, res) ->
      alert res.error.message

Namespace.Messages = Backbone.Collection.extend(

  # Specify the backend with which to sync
  backend: "messages"
  model: Namespace.Message
  initialize: ->

    # Setup default backend bindings
    # (see lib/browser.js for details).
    @bindBackend()
)
Namespace.MessageView = Backbone.View.extend(
  tagName: "li"
  events:
    "click .delete": "delete"

  initialize: ->
    @template = _.template($("#message-template").html())

  render: ->
    $(@el).html @template(@model.toJSON())
    this

  delete: (e) ->
    e.preventDefault()
    @model.destroy()
)
Namespace.MessagesView = Backbone.View.extend(
  events:
    "click .send": "send"
    "keypress .message": "keypress"

  initialize: (options) ->
    @collection.on "add change remove reset", @render, this
    @template = _.template($("#messages-template").html())

  render: ->
    $(@el).html @template()
    @collection.each (message) ->
      view = new Namespace.MessageView(model: message)
      @$("ul").append view.render().el

    this

  send: ->
    @collection.create
      text: @$(".message").val()
    ,
      wait: true

    @$(".message").val ""

  keypress: (e) ->
    @send()  if e.which is 13
)
$ ->
  window.messages = new Namespace.Messages()
  window.messages.fetch()
  new Namespace.MessagesView(
    el: $("#messages")
    collection: messages
  ).render()

