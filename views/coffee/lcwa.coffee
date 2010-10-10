class Lcwa
  constructor: () ->
    @model = {}
    @controller = @load_controller()
    @load_data( => @controller.run('#/') )

  load_data: (next_action) ->
    lcwa = this
    $.getJSON("/data.json",
                null,
                (data) ->
                    lcwa.update_model(data)
                    next_action()
    )

  load_controller: ->
    lcwa = this
    $.sammy( ->
      @use Sammy.Mustache
      @element_selector = '#output'
      @get '#/', (context) ->
        lcwa.show_all(context)
    )

  update_model: (data) ->
    @model = data

  show_all: (context) ->
    context.partial($("#all-view"),@model)

$( ->
     lcwa =  new Lcwa()
     window.the_app = lcwa # really just to aid debugging
)
