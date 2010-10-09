class Lcwa
  constructor: () ->
    @model = {}
    @views = @load_views()
    @controller = @load_controller()
    @load_data( => @controller.run('#/') )

  load_data: (next_action) ->
    lcwa = this
    $.getJSON("/data.json",
                null,
                (response) ->
                    if response.status == "ok"
                        lcwa.update_model(response.data)
                    else
                        lcwa.show_errors(response)
                    next_action()
    )

  load_controller: ->
    lcwa = this
    $.sammy( ->
      @use Sammy.Template
      @element_selector = '#output'
      @next_engine = 'template'
      @get '#/', (context) ->
        lcwa.show_main(context)
    )

  load_views: ->
    results = {}
    $("#views section").each (index, element) ->
        $el = $(element)
        name = $el.attr("class")  # we know there is only a single class, so this is safe
        results[name] = element
    return results

  update_model: (data) ->
    @model = data

  show_errors: (response) ->
    alert "errors occurred - see log"
    @controller.log "Error: #{response}"

  show_main: (context) ->
    context.partial($("#test"),@model[0])

$( ->
     lcwa =  new Lcwa()
     window.the_app = lcwa # really just to aid debugging
)
