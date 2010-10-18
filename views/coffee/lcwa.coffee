class Lcwa
  constructor: ->
    @items = null
    @outputElement = '#items'

    $(window).hashchange (event) => @hashchange(event)
    @bindStateLinks()
    $(window).hashchange()

  renderView: (viewSel,data) ->
    view = Mustache.to_html($(viewSel).html(),data)
    $(@outputElement).html(view)

  hashchange: (event) ->
    item = event.getState 'item'
    if item
      debug.log "changing state based on hash - item now #{item}"
      @show_item(item)
    else
      debug.log "changing state to show all items"
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

  show_item: (item) ->
    that = this
    if @items == null
      @renderView("#loading-view",{message:"loading items"})
      @load_items_and( -> that.show_item(item))
    else
      newState = @with_link(@items[item],{item:''})  # link back to top!
      @renderView("#item-view",newState)

  show_all: ->
    that = this
    if @items == null
      @renderView("#loading-view",{message:"loading items"})
      @load_items_and( -> that.show_all())
    else
      # @items is a hash, mustache wants an array - and we want to add links:
      item_list = { index: key, title:data.title, body:data.body, linkParam: $.param({item:key}) } for key, data of @items
      @renderView("#all-view",{items: item_list})

  load_items_and: (callback) ->
    that = this
    $.ajax
      url: "/items.json"
      dataType: 'json'
      data: null
      success: (data) ->
        if data.success
          that.items = data.payload
          callback()
        else
          that.renderView("#error-view",data.payload)
      error: (request, textStatus, error) ->
        that.renderView("#error-view", that.formatErrorState(textStatus,error))

  formatErrorState: (textStatus, error) ->
    { message: "#{textStatus}: #{error}" }

$( ->
  # expose a namespace for external use
  window.LCWA =
    App: Lcwa
    the_app: new Lcwa  # create (and kick off) the application instance
)
