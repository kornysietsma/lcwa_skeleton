(function() {
  var Lcwa;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Lcwa = function() {
    function Lcwa() {
      this.widgets = null;
      this.widget_details = {};
      this.errors = [];
      this.outputElement = '#output';
      this.load_views();
      this.setup_error_handler();
      this.setup_ajax_indicator();
      $.ajaxSetup({
        timeout: 10000
      });
      $(window).hashchange(__bind(function(event) {
        return this.hashchange(event);
      }, this));
      this.bindStateLinks();
      $(window).hashchange();
    }
    Lcwa.prototype.hashchange = function(event) {
      var widget;
      widget = event.getState('widget');
      if (widget) {
        debug.log("changing state based on hash - widget now " + widget);
        return this.show_widget(widget);
      } else {
        debug.log("changing state to show all widgets");
        return this.show_all();
      }
    };
    Lcwa.prototype.bindStateLinks = function() {
      return $("" + this.outputElement + " a[href^=#]").live('click', function(e) {
        var linkParam;
        linkParam = $(this).attr("data-link");
        if (linkParam == null) {
          return true;
        }
        debug.log("clicked link with linkParam " + linkParam + " - setting state");
        $.bbq.pushState(linkParam, 0);
        return false;
      });
    };
    Lcwa.prototype.with_link = function(data, linkObj) {
      return _.extend(data, {
        linkParam: $.param(linkObj)
      });
    };
    Lcwa.prototype.show_widget = function(widget) {
      var newState, that;
      that = this;
      if (!this.widget_details[widget]) {
        this.renderView("#output", "loading", {
          message: "loading widget"
        });
        return this.load_widget_and(widget, function() {
          return that.show_widget(widget);
        });
      } else {
        debug.log("showing widget");
        widget = _.clone(this.widget_details[widget]);
        widget.sprockets = _.values(widget.sprockets);
        newState = this.with_link(widget, {
          widget: ''
        });
        return this.renderView("#output", "widget", newState);
      }
    };
    Lcwa.prototype.show_all = function() {
      var that, widget_list;
      that = this;
      if (this.widgets == null) {
        debug.log("loading widgets");
        this.renderView("#output", "loading", {
          message: "loading widgets"
        });
        return this.load_widgets_and(function() {
          return that.show_all();
        });
      } else {
        debug.log("showing widgets");
        widget_list = _.map(this.widgets, function(widget) {
          return that.with_link({
            name: widget.name
          }, {
            widget: widget["_id"]
          });
        });
        return this.renderView("#output", "all", {
          widgets: widget_list
        });
      }
    };
    Lcwa.prototype.load_widgets_and = function(nextAction) {
      var successFn, that;
      that = this;
      successFn = function(data) {
        that.widgets = data;
        return nextAction();
      };
      return this.load_json("/widgets.json", successFn);
    };
    Lcwa.prototype.load_widget_and = function(widget, nextAction) {
      var successFn, that;
      that = this;
      successFn = function(data) {
        that.widget_details[widget] = data;
        return nextAction();
      };
      return this.load_json("/widget/" + widget + ".json", successFn);
    };
    Lcwa.prototype.load_views = function() {
      var that;
      that = this;
      that.views = {};
      return $(".view-template").each(function() {
        var name;
        name = $(this).attr("data-name");
        return that.views[name] = $(this).html();
      });
    };
    Lcwa.prototype.renderView = function(element, name, data) {
      var view;
      if (!this.views[name]) {
        throw new Error("no such view: " + name);
      }
      view = Mustache.to_html(this.views[name], data, this.views);
      return $(element).html(view);
    };
    Lcwa.prototype.renderModal = function(name, data) {
      var view;
      if (!this.views[name]) {
        throw new Error("no such view: " + name);
      }
      view = Mustache.to_html(this.views[name], data, this.views);
      return $.modal(view);
    };
    Lcwa.prototype.load_json = function(url, onSuccess) {
      var that;
      that = this;
      return $.ajax({
        url: url,
        dataType: 'json',
        data: null,
        success: function(data) {
          return onSuccess(data);
        }
      });
    };
    Lcwa.prototype.post_json = function(url, data, onSuccess) {
      var that;
      that = this;
      return $.ajax({
        url: url,
        type: "POST",
        dataType: 'json',
        data: data,
        success: function(data) {
          return onSuccess(data);
        }
      });
    };
    Lcwa.prototype.show_error = function(title, text) {
      var error;
      if (!(text instanceof Array)) {
        text = [text];
      }
      error = {
        timestamp: new Date(),
        title: title,
        text: text
      };
      this.errors.push(error);
      return this.renderModal("errors", {
        errors: this.errors
      });
    };
    Lcwa.prototype.setup_error_handler = function() {
      var that;
      that = this;
      return $("body").ajaxError(function(event, request, settings, exception) {
        return that.ajax_error_handler(event, request, settings, exception);
      });
    };
    Lcwa.prototype.ajax_error_handler = function(event, request, settings, exception) {
      var full_msg, info, responseText, text, title;
      title = "Error " + request.status + " occurred fetching \"" + settings.url + "\"";
      text = [];
      responseText = request.responseText;
      if (responseText[0] === "{") {
        info = JSON.parse(responseText);
        if ((info.context != null) && (info.message != null)) {
          full_msg = "Context: " + info.context + ", Error: " + info.message;
          text.push(full_msg);
          debug.log("pushed err msg: " + full_msg + " - status " + request.status + " text " + request.statusText);
        } else {
          text.push("" + request.status + ":" + request.statusText);
          text.push("(unparseable error body: " + responseText + ")");
        }
      } else {
        text.push("" + request.status + ":" + request.statusText);
      }
      if (exception != null) {
        text.push(" - exception thrown: " + exception);
      }
      return this.show_error(title, text);
    };
    Lcwa.prototype.setup_ajax_indicator = function() {
      var that;
      that = this;
      return $("#ajax-status").ajaxStart(function() {
        return $(this).html("<p>(loading...)</p>");
      }).ajaxStop(function() {
        return $(this).empty();
      });
    };
    return Lcwa;
  }();
  $(function() {
    return window.LCWA = {
      App: Lcwa,
      the_app: new Lcwa
    };
  });
}).call(this);
