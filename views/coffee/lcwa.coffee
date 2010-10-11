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
                    lcwa.update_items(data.items)
    )

  update_items: (items) ->
    @items = items
    for ix in [0...items.length]
      items[ix].index = ix
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

    @context.run()

  show_all: (context) ->
    context.partial($("#all-view"),{items:@items})

  show_item: (index, context) ->
    item = @items[index]
    context.partial($("#item-view"),item)

$( ->
     lcwa =  new Lcwa()
     window.LCWA = lcwa # really just to aid debugging
)
