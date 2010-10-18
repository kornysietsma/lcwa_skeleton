(function() {
  var Lcwa;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  }, __hasProp = Object.prototype.hasOwnProperty;
  Lcwa = function() {
    this.items = null;
    this.outputElement = '#items';
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
    var item;
    item = event.getState('item');
    if (item) {
      debug.log("changing state based on hash - item now " + (item));
      return this.show_item(item);
    } else {
      debug.log("changing state to show all items");
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
  Lcwa.prototype.show_item = function(item) {
    var newState, that;
    that = this;
    if (this.items === null) {
      this.renderView("#loading-view", {
        message: "loading items"
      });
      return this.load_items_and(function() {
        return that.show_item(item);
      });
    } else {
      newState = this.with_link(this.items[item], {
        item: ''
      });
      return this.renderView("#item-view", newState);
    }
  };
  Lcwa.prototype.show_all = function() {
    var _ref, _result, data, item_list, key, that;
    that = this;
    if (this.items === null) {
      this.renderView("#loading-view", {
        message: "loading items"
      });
      return this.load_items_and(function() {
        return that.show_all();
      });
    } else {
      item_list = (function() {
        _result = []; _ref = this.items;
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          data = _ref[key];
          _result.push({
            index: key,
            title: data.title,
            body: data.body,
            linkParam: $.param({
              item: key
            })
          });
        }
        return _result;
      }).call(this);
      return this.renderView("#all-view", {
        items: item_list
      });
    }
  };
  Lcwa.prototype.load_items_and = function(callback) {
    var that;
    that = this;
    return $.ajax({
      url: "/items.json",
      dataType: 'json',
      data: null,
      success: function(data) {
        if (data.success) {
          that.items = data.payload;
          return callback();
        } else {
          return that.renderView("#error-view", data.payload);
        }
      },
      error: function(request, textStatus, error) {
        return that.renderView("#error-view", that.formatErrorState(textStatus, error));
      }
    });
  };
  Lcwa.prototype.formatErrorState = function(textStatus, error) {
    return {
      message: ("" + (textStatus) + ": " + (error))
    };
  };
  $(function() {
    return (window.LCWA = {
      App: Lcwa,
      the_app: new Lcwa()
    });
  });
}).call(this);
