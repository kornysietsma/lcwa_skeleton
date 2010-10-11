(function() {
  var Lcwa;
  var __hasProp = Object.prototype.hasOwnProperty;
  Lcwa = function() {
    this.items = {};
    this.load_contexts();
    this.load_items();
    return this;
  };
  Lcwa.prototype.load_items = function() {
    var lcwa;
    lcwa = this;
    return $.getJSON("/items.json", null, function(items) {
      return lcwa.update_items(items);
    });
  };
  Lcwa.prototype.update_items = function(items) {
    this.items = items;
    return this.contexts.items.refresh();
  };
  Lcwa.prototype.load_contexts = function() {
    var _ref, _result, context, lcwa, name;
    lcwa = this;
    this.contexts = {
      items: $.sammy(function() {
        this.use(Sammy.Mustache);
        this.element_selector = '#items';
        return this.get('#/', function(context) {
          return lcwa.show_all(context);
        });
      })
    };
    _result = []; _ref = this.contexts;
    for (name in _ref) {
      if (!__hasProp.call(_ref, name)) continue;
      context = _ref[name];
      _result.push(context.run());
    }
    return _result;
  };
  Lcwa.prototype.show_all = function(context) {
    return context.partial($("#all-view"), this.items);
  };
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.the_app = lcwa);
  });
}).call(this);
