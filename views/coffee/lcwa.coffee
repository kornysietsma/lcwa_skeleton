class Lcwa
  constructor: ->
    @items = {}
    @load_contexts()
    @load_items()

  load_items: ->
    lcwa = this
    $.getJSON("/items.json",
                null,
                (items) ->
                    lcwa.update_items(items)
    )

  update_items: (items) ->
    @items = items
    @contexts.items.refresh()

  load_contexts: ->
    lcwa = this
    @contexts =
        items:
            $.sammy( ->
                @use Sammy.Mustache
                @element_selector = '#items'
                @get '#/', (context) ->
                    lcwa.show_all(context)
            )

    for name, context of @contexts
      context.run()

  show_all: (context) ->
    context.partial($("#all-view"),@items)

$( ->
     lcwa =  new Lcwa()
     window.the_app = lcwa # really just to aid debugging
)
