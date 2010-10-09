(function() {
  var Lcwa;
  Lcwa = function() {
    var app;
    $('#output').append("<p>hello from coffee-script</p>");
    this.get_sample_json();
    app = this.link_sammy();
    app.run('#/');
    return this;
  };
  Lcwa.prototype.get_sample_json = function() {
    return $.getJSON("/sample.json", null, function(response) {
      var _i, _len, _ref, _result, line;
      _result = []; _ref = response.data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        _result.push($('#output').append("<p>" + (line) + "</p>"));
      }
      return _result;
    });
  };
  Lcwa.prototype.link_sammy = function() {
    return $.sammy(function() {
      this.element_selector = '#output';
      return this.get('#/', function(context) {
        context.log("in sammy-land!");
        return $('#output').append("<p>sammy was here</p>");
      });
    });
  };
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.the_app = lcwa);
  });
}).call(this);
