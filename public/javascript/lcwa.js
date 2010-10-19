(function() {
  var Lcwa;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  }, __hasProp = Object.prototype.hasOwnProperty;
  Lcwa = function() {
    this.widgets = null;
    this.widget_details = {};
    this.outputElement = '#output';
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
  $(function() {
    return (window.LCWA = {
      App: Lcwa,
      the_app: new Lcwa()
    });
  });
}).call(this);
