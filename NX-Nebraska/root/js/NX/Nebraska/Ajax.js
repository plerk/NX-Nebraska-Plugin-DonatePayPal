/*
 * Ajax interface for Project Nebraska
 * borrowed most of this from 
 * http://openjsan.org/doc/i/in/ingy/Ajax/0.11/lib/Ajax.html
 * LGPL license 
 * http://www.gnu.org/copyleft/lesser.txt
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Ajax === undefined) NX.Nebraska.Ajax = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  var Ajax = NX.Nebraska.Ajax;
  
  // The simple user interface function to GET/PUT/POST. If no callback is
  // used, the function is synchronous.

  Ajax.get = function(url, callback, params) {
    if (! params) params = {};
    params.url = url;
    params.onComplete = callback;
    return (new Ajax.Req()).get(params);
  }

  Ajax.put = function(url, data, callback, params) {
    if (! params) params = {};
    params.url = url;
    params.data = data;
    params.onComplete = callback;
    return (new Ajax.Req()).put(params);
  }

  Ajax.post = function(url, data, callback, params) {
    if (! params) params = {};
    params.url = url;
    params.data = data;
    params.onComplete = callback;
    if (! params.contentType)
        params.contentType = 'application/x-www-form-urlencoded';
    return (new Ajax.Req()).post(params);
  }
  
  Ajax.Req = function () {};
  var proto = Ajax.Req.prototype;
  
  // Allows one to override with something more drastic.
  // Can even be done "on the fly" using a bookmarklet.
  // As an example, the test suite overrides this to test error conditions.
  proto.die = function(e) { throw(e) };
  
  // Object interface
  proto.get = function(params) {
    return this._send(params, 'GET', 'Accept');
  }

  proto.put = function(params) {
    return this._send(params, 'PUT', 'Content-Type');
  }

  proto.post = function(params) {
    return this._send(params, 'POST', 'Content-Type');
  }

  // Set up the Ajax object with a working XHR object.
  proto._init_object = function(params) {
    for (key in params) {
      if (! key.match(/^url|data|onComplete|contentType|userid|passwd$/))
        throw("Invalid Ajax parameter: " + key);
      this[key] = params[key];
    }

    if (! this.contentType)
      this.contentType = 'application/json';

    if (! this.url)
      throw("'url' required for Ajax get/post method");

    if (this.request)
      throw("Don't yet support multiple requests on the same Ajax object");

    this.request = new XMLHttpRequest();

    if (! this.request)
      return this.die("Your browser doesn't do Ajax");
    if (this.request.readyState != 0)
      return this.die("Ajax readyState should be 0");

    return this;
  }

  proto._send = function(params, request_type, header) {
    this._init_object(params);
    this.request.open(request_type, this.url, Boolean(this.onComplete));
    this.request.setRequestHeader(header, this.contentType);

    // Basic Auth
    if (this.userid) {
      if (! this.passwd)
        throw("You must specify a passwd with the userid for Ajax Basic Auth request");

      if (! window.Base64)
        throw("Ajax Basic Auth requires Base64.js. Get it here: http://www.webtoolkit.info/javascript-base64.html");

      this.request.setRequestHeader(
        'Authorization',
        Base64.encode(this.userid + ':' + this.passwd)
      );
    }

    var self = this;
    if (this.onComplete) {
      this.request.onreadystatechange = function() {
        self._check_asynchronous();
      };
    }
    this.request.send(this.data);
    return Boolean(this.onComplete)
        ? this
        : this._check_synchronous();
  }

  // TODO Allow handlers for various readyStates and statusCodes.
  // Make these be the default handlers.
  proto._check_status = function() {
    var status = String(this.request.status);
    if (!status.match('^20[0-9]')) {
      return this.die(
        'Ajax request for "' + this.url +
        '" failed with status: ' + status
      );
    }
  }

  proto._check_synchronous = function() {
    this._check_status();
    return this.request.responseText;
  }

  proto._check_asynchronous = function() {
    if (this.request.readyState != 4) return;
    this._check_status();
    this.onComplete(this.request.responseText);
  }

  // IE support
  if (window.ActiveXObject && !window.XMLHttpRequest) {
    window.XMLHttpRequest = function() {
      var name = (navigator.userAgent.toLowerCase().indexOf('msie 5') != -1)
        ? 'Microsoft.XMLHTTP' : 'Msxml2.XMLHTTP';
      return new ActiveXObject(name);
    }
  }

  
  /*
   * ====================================================================
   */

})();