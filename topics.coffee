app = require "./index"

app.get "/topics/:id?", (page, model, {id}, next) ->

  model.query("topics", {}).subscribe ->
    page.render "topics"

  if id
    model.set "_page.id", id

    topic = model.at("topics.#{id}").subscribe ->
      items = model.query "items", "topics.#{id}.ids"
      model.subscribe items, ->
        items.ref "_page.items"
        page.render "topics"


app.component "topics", class Topics
  init: ->
    @topics = @model.scope "topics"
    @model.ref "topics", @topics.filter()

  add: ->
    id = @topics.add ids: [], =>
      @page.redirect "/topics/#{id}"

  del: (id) ->
    @topics.del id, =>
      @page.redirect "/topics"


app.component "topics:items", class Items
  init: ->
    @items = @model.scope "_page.items"
    @model.ref "items", @items

  add: ->
    id = @model.root.at("items").add {}, (error) =>
    # id = @items.add {}, (error) =>
      console.log "add item", {error, id}

  # del: (i, id) ->
  #   # @ids.remove i
  #   @items.del id
