class Lcwa
  constructor: ->
    @items = []
    @load_context()
    @load_items()

  load_items: ->
    lcwa = this
    $.getJSON("/items.json",
                null,
                (data) ->
                    lcwa.update_items(data)
    )

  update_items: (items) ->
    @items = items
    @context.refresh()

  load_context: ->
    lcwa = this
    @context =
      $.sammy( ->
         @use Sammy.Mustache
         @element_selector = '#items'
         @get '#/', (context) ->
            lcwa.show_all(context)
         @get '#/items/:index', (context) ->
            lcwa.show_item(context.params['index'],context)
      )

    @context.run('#/')

  show_all: (context) ->
    # @items is a hash, mustache wants an array:
    item_list = { index: key, title:data.title, body:data.body } for key, data of @items
    context.log item_list
    context.partial($("#all-view"),{items: item_list})

  show_item: (index, context) ->
    item = @items[index]
    context.partial($("#item-view"),item)

$( ->
     lcwa =  new Lcwa()
     window.LCWA = lcwa # really just to aid debugging
)
