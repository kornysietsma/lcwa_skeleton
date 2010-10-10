(function() {
  var Lcwa;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  };
  Lcwa = function() {
    this.model = {};
    this.controller = this.load_controller();
    this.load_data(__bind(function() {
      return this.controller.run('#/');
    }, this));
    return this;
  };
  Lcwa.prototype.load_data = function(next_action) {
    var lcwa;
    lcwa = this;
    return $.getJSON("/data.json", null, function(data) {
      lcwa.update_model(data);
      return next_action();
    });
  };
  Lcwa.prototype.load_controller = function() {
    var lcwa;
    lcwa = this;
    return $.sammy(function() {
      this.use(Sammy.Mustache);
      this.element_selector = '#output';
      return this.get('#/', function(context) {
        return lcwa.show_all(context);
      });
    });
  };
  Lcwa.prototype.update_model = function(data) {
    return (this.model = data);
  };
  Lcwa.prototype.show_all = function(context) {
    return context.partial($("#all-view"), this.model);
  };
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.the_app = lcwa);
  });
}).call(this);
