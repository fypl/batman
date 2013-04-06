(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Batman.extend(Batman.DOM, {
    querySelectorAll: function(node, selector) {
      return jQuery(selector, node);
    },
    querySelector: function(node, selector) {
      return jQuery(selector, node)[0];
    },
    setInnerHTML: function(node, html) {
      var child, childNodes, result, _i, _j, _len, _len2;
      childNodes = (function() {
        var _i, _len, _ref, _results;
        _ref = node.childNodes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child);
        }
        return _results;
      })();
      for (_i = 0, _len = childNodes.length; _i < _len; _i++) {
        child = childNodes[_i];
        Batman.DOM.willRemoveNode(child);
      }
      result = jQuery(node).html(html);
      for (_j = 0, _len2 = childNodes.length; _j < _len2; _j++) {
        child = childNodes[_j];
        Batman.DOM.didRemoveNode(child);
      }
      return result;
    },
    removeNode: function(node) {
      var _ref;
      Batman.DOM.willRemoveNode(node);
      if ((_ref = node.parentNode) != null) {
        _ref.removeChild(node);
      }
      return Batman.DOM.didRemoveNode(node);
    },
    destroyNode: function(node) {
      Batman.DOM.willDestroyNode(node);
      Batman.DOM.willRemoveNode(node);
      jQuery(node).remove();
      Batman.DOM.didRemoveNode(node);
      return Batman.DOM.didDestroyNode(node);
    },
    appendChild: function(parent, child) {
      Batman.DOM.willInsertNode(child);
      jQuery(parent).append(child);
      return Batman.DOM.didInsertNode(child);
    },
    textContent: function(node) {
      return jQuery(node).text();
    }
  });
  Batman.Request.prototype._parseResponseHeaders = function(xhr) {
    var headers;
    return headers = xhr.getAllResponseHeaders().split('\n').reduce(function(acc, header) {
      var key, matches, value;
      if (matches = header.match(/([^:]*):\s*(.*)/)) {
        key = matches[1];
        value = matches[2];
        acc[key] = value;
      }
      return acc;
    }, {});
  };
  Batman.Request.prototype._prepareOptions = function(data) {
    var options, _ref;
    options = {
      url: this.get('url'),
      type: this.get('method'),
      dataType: this.get('type'),
      data: data || this.get('data'),
      username: this.get('username'),
      password: this.get('password'),
      headers: this.get('headers'),
      beforeSend: __bind(function() {
        return this.fire('loading');
      }, this),
      success: __bind(function(response, textStatus, xhr) {
        this.mixin({
          xhr: xhr,
          status: xhr.status,
          response: response,
          responseHeaders: this._parseResponseHeaders(xhr)
        });
        return this.fire('success', response);
      }, this),
      error: __bind(function(xhr, status, error) {
        this.mixin({
          xhr: xhr,
          status: xhr.status,
          response: xhr.responseText,
          responseHeaders: this._parseResponseHeaders(xhr)
        });
        xhr.request = this;
        return this.fire('error', xhr);
      }, this),
      complete: __bind(function() {
        return this.fire('loaded');
      }, this)
    };
    if ((_ref = this.get('method')) === 'PUT' || _ref === 'POST') {
      if (!this.hasFileUploads()) {
        options.contentType = this.get('contentType');
        if (typeof options.data === 'object') {
          options.processData = false;
          options.data = Batman.URI.queryFromParams(options.data);
        }
      } else {
        options.contentType = false;
        options.processData = false;
        options.data = this.constructor.objectToFormData(options.data);
      }
    }
    return options;
  };
  Batman.Request.prototype.send = function(data) {
    return jQuery.ajax(this._prepareOptions(data));
  };
  Batman.mixins.animation = {
    show: function(addToParent) {
      var jq, show, _ref, _ref2;
      jq = $(this);
      show = function() {
        return jq.show(600);
      };
      if (addToParent) {
        if ((_ref = addToParent.append) != null) {
          _ref.appendChild(this);
        }
        if ((_ref2 = addToParent.before) != null) {
          _ref2.parentNode.insertBefore(this, addToParent.before);
        }
        jq.hide();
        setTimeout(show, 0);
      } else {
        show();
      }
      return this;
    },
    hide: function(removeFromParent) {
      $(this).hide(600, __bind(function() {
        var _ref;
        if (removeFromParent) {
          if ((_ref = this.parentNode) != null) {
            _ref.removeChild(this);
          }
        }
        return Batman.DOM.didRemoveNode(this);
      }, this));
      return this;
    }
  };
}).call(this);
