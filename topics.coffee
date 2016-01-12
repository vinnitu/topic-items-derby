app = require "./index"

app.get "/topics/:id?", (page, model, {id}, next) ->

  model.query("topics", {}).subscribe ->
    if id
      model.set "_page.id", id

      topic = model.at("topics.#{id}").subscribe ->
        items = model.query "items", "topics.#{id}.ids"
        model.subscribe items, ->
          items.ref "_page.items"
          page.render "topics"
    else
      page.render "topics"

app.component "topics", class Topics
  init: ->
    @id = @model.scope("_page.id").get()

    @topics = @model.scope "topics"
    @model.ref "topics", @topics.filter()

  addTopic: ->
    id = @topics.add ids: []
    @page.redirect "/topics/#{id}"

  delTopic: ->
    @topics.del @id
    @page.redirect "/topics"

  addItem: ->
    id = @model.scope("items").add {}
    @model.scope("topics.#{@id}.ids").push id

  delItem: ({id}, i) ->
    @model.scope("topics.#{@id}.ids").remove i
    @model.scope("items").del id
