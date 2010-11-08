class Lcwa
  constructor: ->
    @widgets = null
    @widget_details = {}
    @outputElement = '#output'
    # icons using raphael - see http://raphaeljs.com/icons/
    @icons =
      cog: "M26.974,16.514l3.765-1.991c-0.074-0.738-0.217-1.454-0.396-2.157l-4.182-0.579c-0.362-0.872-0.84-1.681-1.402-2.423l1.594-3.921c-0.524-0.511-1.09-0.977-1.686-1.406l-3.551,2.229c-0.833-0.438-1.73-0.77-2.672-0.984l-1.283-3.976c-0.364-0.027-0.728-0.056-1.099-0.056s-0.734,0.028-1.099,0.056l-1.271,3.941c-0.967,0.207-1.884,0.543-2.738,0.986L7.458,4.037C6.863,4.466,6.297,4.932,5.773,5.443l1.55,3.812c-0.604,0.775-1.11,1.629-1.49,2.55l-4.05,0.56c-0.178,0.703-0.322,1.418-0.395,2.157l3.635,1.923c0.041,1.013,0.209,1.994,0.506,2.918l-2.742,3.032c0.319,0.661,0.674,1.303,1.085,1.905l4.037-0.867c0.662,0.72,1.416,1.351,2.248,1.873l-0.153,4.131c0.663,0.299,1.352,0.549,2.062,0.749l2.554-3.283C15.073,26.961,15.532,27,16,27c0.507,0,1.003-0.046,1.491-0.113l2.567,3.301c0.711-0.2,1.399-0.45,2.062-0.749l-0.156-4.205c0.793-0.513,1.512-1.127,2.146-1.821l4.142,0.889c0.411-0.602,0.766-1.243,1.085-1.905l-2.831-3.131C26.778,18.391,26.93,17.467,26.974,16.514zM20.717,21.297l-1.785,1.162l-1.098-1.687c-0.571,0.22-1.186,0.353-1.834,0.353c-2.831,0-5.125-2.295-5.125-5.125c0-2.831,2.294-5.125,5.125-5.125c2.83,0,5.125,2.294,5.125,5.125c0,1.414-0.573,2.693-1.499,3.621L20.717,21.297z"
      progress: "M15.999,4.308c1.229,0.001,2.403,0.214,3.515,0.57L18.634,6.4h6.247l-1.562-2.706L21.758,0.99l-0.822,1.425c-1.54-0.563-3.2-0.878-4.936-0.878c-7.991,0-14.468,6.477-14.468,14.468c0,3.317,1.128,6.364,3.005,8.805l2.2-1.689c-1.518-1.973-2.431-4.435-2.436-7.115C4.312,9.545,9.539,4.318,15.999,4.308zM27.463,7.203l-2.2,1.69c1.518,1.972,2.431,4.433,2.435,7.114c-0.011,6.46-5.238,11.687-11.698,11.698c-1.145-0.002-2.24-0.188-3.284-0.499l0.828-1.432H7.297l1.561,2.704l1.562,2.707l0.871-1.511c1.477,0.514,3.058,0.801,4.709,0.802c7.992-0.002,14.468-6.479,14.47-14.47C30.468,12.689,29.339,9.643,27.463,7.203z"
    @setup_ajax_indicator()
    $.ajaxSetup timeout: 10000 # don't let ajax calls run forever - global default

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

  setup_ajax_indicator: ->
    that = this
    $("#ajax-status").ajaxStart( -> that.show_working_icon(this) ).ajaxStop( -> that.hide_working_icon(this) )

  show_icon: (paper, name, width) ->
    scale = width/32
    paper.path(@icons[name]).scale(scale,scale,0,0)

  show_working_icon: (element) ->
    domElement = $(element).show()[0]
    width = 50
    paper = Raphael(domElement, width, width)
    @show_icon(paper, "progress", width).attr({fill: "#eee", stroke: "none"}).animate({rotation:"360"},10000)

  hide_working_icon: (element) ->
    $(element).empty().hide()

$( ->
  # expose a namespace for external use
  window.LCWA =
    App: Lcwa
    the_app: new Lcwa  # create (and kick off) the application instance
)
