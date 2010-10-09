class Lcwa
  constructor: () ->
    $('#output').append("<p>hello from coffee-script</p>")
    @get_sample_json()
    app = @link_sammy()
    app.run '#/'

  get_sample_json: ->
    $.getJSON("/sample.json",
                null,
                (response) ->
                   for line in response.data
                     $('#output').append "<p>#{line}</p>"
    )

  link_sammy: ->
    $.sammy( ->
      @element_selector = '#output'
      @get '#/', (context) ->
        context.log "in sammy-land!"
        $('#output').append "<p>sammy was here</p>"
    )

$( ->
     lcwa =  new Lcwa()
     window.the_app = lcwa # really just to aid debugging
)
