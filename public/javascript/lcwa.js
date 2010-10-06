(function() {
  var Lcwa;
  Lcwa = function() {
    var that;
    that = this;
    $('#output').append("<p>hello from coffee-script</p>");
    this.get_sample_json();
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
  $(function() {
    var lcwa;
    lcwa = new Lcwa();
    return (window.the_app = lcwa);
  });
}).call(this);
