(function() {
  var Lcwa;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  };
  Lcwa = function() {
    this.model = {};
    this.views = this.load_views();
    this.controller = this.load_controller();
    this.load_data(__bind(function() {
      return this.controller.run('#/');
    }, this));
    return this;
  };
  Lcwa.prototype.load_data = function(next_action) {
    var lcwa;
    lcwa = this;
    return $.getJSON("/data.json", null, function(response) {
      if (response.status === "ok") {
        lcwa.update_model(response.data);
      } else {
        lcwa.show_errors(response);
      }
      return next_action();
    });
  };
  Lcwa.prototype.load_controller = function() {
    var lcwa;
    lcwa = this;
    return $.sammy(function() {
      this.use(Sammy.Template);
      this.element_selector = '#output';
      this.next_engine = 'template';
      return this.get('#/', function(context) {
        return lcwa.show_main(context);
      });
    });
  };
  Lcwa.prototype.load_views = function() {
    var results;
    results = {};
    $("#views section").each(function(index, element) {
      var $el, name;
      $el = $(element);
      name = $el.attr("class");
      return (results[name] = element);
    });
    return results;
  };
  Lcwa.prototype.update_model = function(data) {
    return (this.model = data);
  };
  Lcwa.prototype.show_errors = function(response) {
    alert("errors occurred - see log");
    return this.controller.log("Error: " + (response));
  };
  Lcwa.prototype.show_main = function(context) {
    return context.partial($("#test"), this.model[0]);
  };
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.the_app = lcwa);
  });
}).call(this);
