class Lcwa
  constructor: ->
    @widgets = null
    @widget_details = {}
    @outputElement = '#output'

    $(window).hashchange (event) => @hashchange(event)
    @bindStateLinks()
    $(window).hashchange()

  renderView: (viewSel,data) ->
    view = Mustache.to_html($(viewSel).html(),data)
    $(@outputElement).html(view)

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

  # clones the data and adds a 'linkParam' serialised parameter object
  with_link: (data, linkObj) ->
    result = {}
    for key,val of data
      result[key] = val
    result.linkParam = $.param(linkObj)
    result

  show_widget: (widget) ->
    that = this
    if !(@widget_details[widget])
      @renderView("#loading-view",{message:"loading widget"})
      @load_widget_and(widget, -> that.show_widget(widget))
    else
      debug.log "showing widget"
      newState = @with_link(@widget_details[widget],{widget:''})  # link back to top!
      @renderView("#widget-view",newState)

  show_all: ->
    that = this
    if @widgets == null
      debug.log "loading widgets"
      @renderView("#loading-view",{message:"loading widgets"})
      @load_widgets_and( -> that.show_all())
    else
      debug.log "showing widgets"
      # build new list including link param
      widget_list = { name:widget.name, linkParam: $.param({widget:widget["id"]}) } for widget in @widgets
      @renderView("#all-view",{widgets: widget_list})

  load_json_and: (url, errorView, onSuccess, nextAction) ->
    that = this
    $.ajax
      url: url
      dataType: 'json'
      data: null
      success: (data) ->
        if data.success
          onSuccess(data)
          nextAction()
        else
          that.renderView(errorView,data.payload)
      error: (request, textStatus, error) ->
        that.renderView(errorView, that.formatErrorState(textStatus,error))

  formatErrorState: (textStatus, error) ->
    { message: "#{textStatus}: #{error}" }

  load_widgets_and: (nextAction) ->
    that = this
    successFn = (data) -> that.widgets = data.payload
    @load_json_and("/widgets.json","#error-view", successFn, nextAction)

  load_widget_and: (widget, nextAction) ->
    that = this
    successFn = (data) -> that.widget_details[widget] = data.payload
    @load_json_and("/widget/#{widget}.json","#error-view", successFn, nextAction)

$( ->
  # expose a namespace for external use
  window.LCWA =
    App: Lcwa
    the_app: new Lcwa  # create (and kick off) the application instance
)
