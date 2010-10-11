(function() {
  var Lcwa;
  var __hasProp = Object.prototype.hasOwnProperty;
  Lcwa = function() {
    this.items = [];
    this.load_context();
    this.load_items();
    return this;
  };
  Lcwa.prototype.load_items = function() {
    var lcwa;
    lcwa = this;
    return $.getJSON("/items.json", null, function(data) {
      return lcwa.update_items(data);
    });
  };
  Lcwa.prototype.update_items = function(items) {
    this.items = items;
    return this.context.refresh();
  };
  Lcwa.prototype.load_context = function() {
    var lcwa;
    lcwa = this;
    this.context = $.sammy(function() {
      this.use(Sammy.Mustache);
      this.element_selector = '#items';
      this.get('#/', function(context) {
        return lcwa.show_all(context);
      });
      return this.get('#/items/:index', function(context) {
        return lcwa.show_item(context.params['index'], context);
      });
    });
    return this.context.run('#/');
  };
  Lcwa.prototype.show_all = function(context) {
    var _ref, _result, data, item_list, key;
    item_list = (function() {
      _result = []; _ref = this.items;
      for (key in _ref) {
        if (!__hasProp.call(_ref, key)) continue;
        data = _ref[key];
        _result.push({
          index: key,
          title: data.title,
          body: data.body
        });
      }
      return _result;
    }).call(this);
    context.log(item_list);
    return context.partial($("#all-view"), {
      items: item_list
    });
  };
  Lcwa.prototype.show_item = function(index, context) {
    var item;
    item = this.items[index];
    return context.partial($("#item-view"), item);
  };
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.LCWA = lcwa);
  });
}).call(this);
