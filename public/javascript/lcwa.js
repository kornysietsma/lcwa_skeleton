(function() {
  var Lcwa;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  }, __hasProp = Object.prototype.hasOwnProperty;
  Lcwa = function() {
    this.widgets = null;
    this.widget_details = {};
    this.outputElement = '#output';
    this.icons = {
      cog: "M26.974,16.514l3.765-1.991c-0.074-0.738-0.217-1.454-0.396-2.157l-4.182-0.579c-0.362-0.872-0.84-1.681-1.402-2.423l1.594-3.921c-0.524-0.511-1.09-0.977-1.686-1.406l-3.551,2.229c-0.833-0.438-1.73-0.77-2.672-0.984l-1.283-3.976c-0.364-0.027-0.728-0.056-1.099-0.056s-0.734,0.028-1.099,0.056l-1.271,3.941c-0.967,0.207-1.884,0.543-2.738,0.986L7.458,4.037C6.863,4.466,6.297,4.932,5.773,5.443l1.55,3.812c-0.604,0.775-1.11,1.629-1.49,2.55l-4.05,0.56c-0.178,0.703-0.322,1.418-0.395,2.157l3.635,1.923c0.041,1.013,0.209,1.994,0.506,2.918l-2.742,3.032c0.319,0.661,0.674,1.303,1.085,1.905l4.037-0.867c0.662,0.72,1.416,1.351,2.248,1.873l-0.153,4.131c0.663,0.299,1.352,0.549,2.062,0.749l2.554-3.283C15.073,26.961,15.532,27,16,27c0.507,0,1.003-0.046,1.491-0.113l2.567,3.301c0.711-0.2,1.399-0.45,2.062-0.749l-0.156-4.205c0.793-0.513,1.512-1.127,2.146-1.821l4.142,0.889c0.411-0.602,0.766-1.243,1.085-1.905l-2.831-3.131C26.778,18.391,26.93,17.467,26.974,16.514zM20.717,21.297l-1.785,1.162l-1.098-1.687c-0.571,0.22-1.186,0.353-1.834,0.353c-2.831,0-5.125-2.295-5.125-5.125c0-2.831,2.294-5.125,5.125-5.125c2.83,0,5.125,2.294,5.125,5.125c0,1.414-0.573,2.693-1.499,3.621L20.717,21.297z",
      progress: "M15.999,4.308c1.229,0.001,2.403,0.214,3.515,0.57L18.634,6.4h6.247l-1.562-2.706L21.758,0.99l-0.822,1.425c-1.54-0.563-3.2-0.878-4.936-0.878c-7.991,0-14.468,6.477-14.468,14.468c0,3.317,1.128,6.364,3.005,8.805l2.2-1.689c-1.518-1.973-2.431-4.435-2.436-7.115C4.312,9.545,9.539,4.318,15.999,4.308zM27.463,7.203l-2.2,1.69c1.518,1.972,2.431,4.433,2.435,7.114c-0.011,6.46-5.238,11.687-11.698,11.698c-1.145-0.002-2.24-0.188-3.284-0.499l0.828-1.432H7.297l1.561,2.704l1.562,2.707l0.871-1.511c1.477,0.514,3.058,0.801,4.709,0.802c7.992-0.002,14.468-6.479,14.47-14.47C30.468,12.689,29.339,9.643,27.463,7.203z"
    };
    this.setup_ajax_indicator();
    $.ajaxSetup({
      timeout: 10000
    });
    $(window).hashchange(__bind(function(event) {
      return this.hashchange(event);
    }, this));
    this.bindStateLinks();
    $(window).hashchange();
    return this;
  };
  Lcwa.prototype.renderView = function(viewSel, data) {
    var view;
    view = Mustache.to_html($(viewSel).html(), data);
    return $(this.outputElement).html(view);
  };
  Lcwa.prototype.hashchange = function(event) {
    var widget;
    widget = event.getState('widget');
    if (widget) {
      debug.log("changing state based on hash - widget now " + (widget));
      return this.show_widget(widget);
    } else {
      debug.log("changing state to show all widgets");
      return this.show_all();
    }
  };
  Lcwa.prototype.bindStateLinks = function() {
    return $("" + (this.outputElement) + " a[href^=#]").live('click', function(e) {
      var linkParam;
      linkParam = $(this).attr("data-link");
      if (!(typeof linkParam !== "undefined" && linkParam !== null)) {
        return true;
      }
      debug.log("clicked link with linkParam " + (linkParam) + " - setting state");
      $.bbq.pushState(linkParam, 0);
      return false;
    });
  };
  Lcwa.prototype.with_link = function(data, linkObj) {
    var _ref, key, result, val;
    result = {};
    _ref = data;
    for (key in _ref) {
      if (!__hasProp.call(_ref, key)) continue;
      val = _ref[key];
      result[key] = val;
    }
    result.linkParam = $.param(linkObj);
    return result;
  };
  Lcwa.prototype.show_widget = function(widget) {
    var newState, that;
    that = this;
    if (!(this.widget_details[widget])) {
      this.renderView("#loading-view", {
        message: "loading widget"
      });
      return this.load_widget_and(widget, function() {
        return that.show_widget(widget);
      });
    } else {
      debug.log("showing widget");
      newState = this.with_link(this.widget_details[widget], {
        widget: ''
      });
      return this.renderView("#widget-view", newState);
    }
  };
  Lcwa.prototype.show_all = function() {
    var _i, _len, _ref, _result, that, widget, widget_list;
    that = this;
    if (this.widgets === null) {
      debug.log("loading widgets");
      this.renderView("#loading-view", {
        message: "loading widgets"
      });
      return this.load_widgets_and(function() {
        return that.show_all();
      });
    } else {
      debug.log("showing widgets");
      widget_list = (function() {
        _result = []; _ref = this.widgets;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          widget = _ref[_i];
          _result.push({
            name: widget.name,
            linkParam: $.param({
              widget: widget["id"]
            })
          });
        }
        return _result;
      }).call(this);
      return this.renderView("#all-view", {
        widgets: widget_list
      });
    }
  };
  Lcwa.prototype.load_json_and = function(url, errorView, onSuccess, nextAction) {
    var that;
    that = this;
    return $.ajax({
      url: url,
      dataType: 'json',
      data: null,
      success: function(data) {
        if (data.success) {
          onSuccess(data);
          return nextAction();
        } else {
          return that.renderView(errorView, data.payload);
        }
      },
      error: function(request, textStatus, error) {
        return that.renderView(errorView, that.formatErrorState(textStatus, error));
      }
    });
  };
  Lcwa.prototype.formatErrorState = function(textStatus, error) {
    return {
      message: ("" + (textStatus) + ": " + (error))
    };
  };
  Lcwa.prototype.load_widgets_and = function(nextAction) {
    var successFn, that;
    that = this;
    successFn = function(data) {
      return (that.widgets = data.payload);
    };
    return this.load_json_and("/widgets.json", "#error-view", successFn, nextAction);
  };
  Lcwa.prototype.load_widget_and = function(widget, nextAction) {
    var successFn, that;
    that = this;
    successFn = function(data) {
      return (that.widget_details[widget] = data.payload);
    };
    return this.load_json_and("/widget/" + (widget) + ".json", "#error-view", successFn, nextAction);
  };
  Lcwa.prototype.setup_ajax_indicator = function() {
    var that;
    that = this;
    return $("#working").ajaxStart(function() {
      return that.show_working_icon(this);
    }).ajaxStop(function() {
      return that.hide_working_icon(this);
    });
  };
  Lcwa.prototype.show_icon = function(paper, name) {
    return paper.path(this.icons[name]);
  };
  Lcwa.prototype.show_working_icon = function(element) {
    var domElement, paper, scale, width;
    domElement = $(element).show()[0];
    width = 50;
    scale = width / 32;
    paper = Raphael(domElement, width, width);
    return this.show_icon(paper, "progress").scale(scale, scale, 0, 0).attr({
      fill: "#eee",
      stroke: "none"
    }).animate({
      rotation: "360"
    }, 10000);
  };
  Lcwa.prototype.hide_working_icon = function(element) {
    return $(element).empty().hide();
  };
  $(function() {
    return (window.LCWA = {
      App: Lcwa,
      the_app: new Lcwa()
    });
  });
}).call(this);
