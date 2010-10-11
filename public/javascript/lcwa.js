(function() {
  var Lcwa;
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
      return lcwa.update_items(data.items);
    });
  };
  Lcwa.prototype.update_items = function(items) {
    var _ref, ix;
    this.items = items;
    _ref = items.length;
    for (ix = 0; (0 <= _ref ? ix < _ref : ix > _ref); (0 <= _ref ? ix += 1 : ix -= 1)) {
      items[ix].index = ix;
    }
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
    return this.context.run();
  };
  Lcwa.prototype.show_all = function(context) {
    return context.partial($("#all-view"), {
      items: this.items
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
