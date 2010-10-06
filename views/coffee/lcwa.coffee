class Lcwa
  constructor: () ->
    that = this  # not a big fan of the fat arrow
    $('#output').append("<p>hello from coffee-script</p>")

    @get_sample_json()

  get_sample_json: ->
    $.getJSON("/sample.json",
                null,
                (response) ->
                   for line in response.data
                     $('#output').append "<p>#{line}</p>"
    )

$( ->
     lcwa =  new Lcwa()
     window.the_app = lcwa # really just to aid debugging
)
