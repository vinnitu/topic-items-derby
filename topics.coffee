app = require "./index"

app.get "/topics/:id?", (page, model, {id}, next) ->

  model.query("topics", {}).subscribe ->
    page.render "topics"

  if id
    model.at("topics.#{id}").subscribe ->
      items = model.query "items", "topics.#{id}.ids"
      model.subscribe items, ->
        items.ref "_page.items"
        page.render "topics"


app.component "topics", class Topics
  init: ->
    @topics = @model.scope "topics"
    @model.ref "topics", @topics.filter()

  add: ->
    @topics.add ids: []

  del: (id) ->
    @topics.del id, =>
      @page.redirect "/topics"

app.component "topics:items", class Items
  init: ->
    @ids = @model.scope "_page.ids"
    @items = @model.scope "_page.items"
    @model.ref "items", @items

  add: ->
    id = @items.add {}, =>
      @ids.push id

  del: (i, id) ->
    @ids.remove i
    @items.del id
