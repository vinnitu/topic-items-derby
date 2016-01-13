app = require "./index"

app.get "/topics/:id?", (page, model, {id}, next) ->
  model.query("topics", {}).subscribe ->
    return page.render "topics" if not id

    model.set "_page.id", id

    ids = "topics.#{id}.ids"
    items = model.query "items", ids
    model.subscribe items, ->
      model.refList "_page.items", "items", ids
      page.render "topics"


app.component "topics", class Topics
  init: ->
    @id = @model.scope("_page.id").get()
    @topics = @model.scope "topics"
    @model.ref "topics", @topics.filter()

  addTopic: ->
    id = @topics.add ids: [], =>
      @page.redirect "/topics/#{id}"

  delTopic: ->
    @topics.del @id, =>
      @page.redirect "/topics"

  addItem: ->
    id = @model.scope("items").add {}, =>
      @model.scope("topics.#{@id}.ids").push id

  delItem: ({id}, i) ->
    @model.scope("topics.#{@id}.ids").remove i, (error) =>
      @model.scope("items.#{id}").fetch =>
        @model.scope("items").del id, (error) =>

  upItem: (i) ->
    @model.scope("topics.#{@id}.ids").move i, i-1 if i

  downItem: (i) ->
    @model.scope("topics.#{@id}.ids").move i, i+1
