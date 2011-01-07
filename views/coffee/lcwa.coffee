class Lcwa
  constructor: ->
    @widgets = null
    @widget_details = {}

    @errors = []  # we accumulate errors until manually cleared - don't want to lose them behind other errors
    @outputElement = '#output'

    # load view templates from index.html sections
    @load_views()
    # set up global error handler
    @setup_error_handler()

    @setup_ajax_indicator()
    $.ajaxSetup timeout: 10000 # don't let ajax calls run forever - global default

    $(window).hashchange (event) => @hashchange(event)
    @bindStateLinks()
    $(window).hashchange()

  hashchange: (event) ->
    widget = event.getState 'widget'
    if widget
      debug.log "changing state based on hash - widget now #{widget}"
      @show_widget(widget)
    else
      debug.log "changing state to show all widgets"
      @show_all()

  bindStateLinks: ->
    $("#{@outputElement} a[href^=#]").live 'click', (e) ->
      linkParam = $(this).attr("data-link")
      return true unless linkParam?
      debug.log "clicked link with linkParam #{linkParam} - setting state"
      $.bbq.pushState(linkParam, 0)  # 0 means merge with existing state, for multi-widget handling
      false

  with_link: (data, linkObj) ->
    _.extend(data, linkParam: $.param(linkObj))

  show_widget: (widget) ->
    that = this
    if !(@widget_details[widget])
      @renderView("#output", "loading", {message:"loading widget"})
      @load_widget_and(widget, -> that.show_widget(widget))
    else
      debug.log "showing widget"
      # widget.sprockets is a map, but the view wants a list - convert them:
      widget = _.clone(@widget_details[widget])
      widget.sprockets = _.values(widget.sprockets)  # should really sort them as well
      newState = @with_link(widget,{widget:''})  # link back to top!
      @renderView("#output", "widget", newState)

  show_all: ->
    that = this
    unless @widgets?
      debug.log "loading widgets"
      @renderView("#output", "loading",{message:"loading widgets"})
      @load_widgets_and( -> that.show_all())
    else
      debug.log "showing widgets"
      # build new list including link param
      widget_list = _.map(@widgets, (widget) -> that.with_link({name:widget.name} , {widget:widget["_id"]} ))
      @renderView("#output", "all",{widgets: widget_list})

  load_widgets_and: (nextAction) ->
    that = this
    successFn = (data) ->
     that.widgets = data
     nextAction()
    @load_json("/widgets.json", successFn)

  load_widget_and: (widget, nextAction) ->
    that = this
    successFn = (data) ->
      that.widget_details[widget] = data
      nextAction()
    @load_json("/widget/#{widget}.json", successFn)


  # following is more generic stuff for views, data loading etc - not widget-example-specific

  load_views: ->
    that = this
    that.views = {}
    $(".view-template").each ->
       name = $(this).attr("data-name")
       that.views[name] = $(this).html()

  renderView: (element, name, data) ->
    throw new Error("no such view: #{name}") unless @views[name]
    view = Mustache.to_html(@views[name],data,@views)  # 3rd param is partials - pass all views as potential partials
    $(element).html(view)

  renderModal: (name, data) ->
    throw new Error("no such view: #{name}") unless @views[name]
    view = Mustache.to_html(@views[name],data,@views)  # 3rd param is partials - pass all views as potential partials
    $.modal(view)

  load_json: (url, onSuccess) ->
    that = this
    $.ajax
      url: url
      dataType: 'json'
      data: null
      success: (data) ->
        onSuccess(data)

  post_json: (url, data, onSuccess) ->
    that = this
    $.ajax
      url: url
      type: "POST"
      dataType: 'json'
      data: data
      success: (data) ->
        onSuccess(data)

  # pushes an error on the error list, and pops up the modal display - note there's no way to clear errors yet!
  show_error: (title, text) ->
    unless text instanceof Array
      text = [text]
    error = {
      timestamp: new Date(),
      title: title,
      text: text
    }
    @errors.push error
    @renderModal("errors", {errors: @errors})

  setup_error_handler: ->
    that = this
    $("body").ajaxError (event, request, settings, exception) ->
      that.ajax_error_handler(event, request, settings, exception)

  ajax_error_handler: (event, request, settings, exception) ->
    title = "Error #{request.status} occurred fetching \"#{settings.url}\""
    text = []
    responseText = request.responseText
    if responseText[0] == "{"
      info = JSON.parse(responseText)
      if info.context? and info.message?
        full_msg = "Context: #{info.context}, Error: #{info.message}"
        text.push full_msg
        debug.log "pushed err msg: #{full_msg} - status #{request.status} text #{request.statusText}"
      else  # can't parse our expected info - yeurk!
        text.push "#{request.status}:#{request.statusText}"
        text.push "(unparseable error body: #{responseText})"
    else
      text.push "#{request.status}:#{request.statusText}"

    if exception?
      text.push " - exception thrown: #{exception}"
    @show_error(title, text)

  setup_ajax_indicator: ->
    that = this
    $("#ajax-status").ajaxStart( -> $(this).html("<p>(loading...)</p>") ).ajaxStop( -> $(this).empty() )

$( ->
  # expose a namespace for external use
  window.LCWA =
    App: Lcwa
    the_app: new Lcwa  # create (and kick off) the application instance
)
