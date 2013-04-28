(function() {
// Copyright 2011 Google Inc. All Rights Reserved.
/**
 * @fileoverview Defines the namespace for easyrp.
 * @author guibinkong@google.com (Guibin Kong)
 * @nocompile
 */

/**
 * Defines the name space for Google Connect Tools.
 */

// Safety net in case we're used outside google.load()
if (!('google' in window)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google = {};
}
if (!('identitytoolkit' in window.google)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google.identitytoolkit = {};
}

/**
 * @namespace Name space for Easy Relying Parties.
 */
window.google.identitytoolkit.easyrp =
    window.google.identitytoolkit.easyrp || {};
// Copyright 2010 Google Inc. All Rights Reserved.

/**
 * @fileoverview Stores all the labels and messages of the widget. This file
 *               should be translated to support I18N.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespace Stores all the images used in the widget.
 */
window.google.identitytoolkit.easyrp.images = {
  bulb: 'https://www.google.com/uds/modules/identitytoolkit/image/bulb.gif',
  close: 'https://www.google.com/uds/modules/identitytoolkit/image/close.gif',
  gmail: 'https://www.google.com/uds/modules/identitytoolkit/image/' +
      'gmail-caw.png',
  yahoo: 'https://www.google.com/uds/modules/identitytoolkit/image/' +
      'yahoo-caw.png',
  aol: 'https://www.google.com/uds/modules/identitytoolkit/image/aol-caw.png',
  hotmail: 'https://www.google.com/uds/modules/identitytoolkit/image/' +
      'hotmail-caw.png'
};

/**
 * @namespace Stores all the labels of the widget.
 */
window.google.identitytoolkit.easyrp.labels = {
  idps: {
    Gmail: 'Gmail',
    Yahoo: 'Yahoo! Mail',
    AOL: 'AOL Mail',
    Hotmail: 'Hotmail'
  },

  /** The tooltip for the button.*/
  title: 'Import profile information',

  /** The HTML code to show when calling createAuthUrl. */
  loading: '<h2>Connect to Server...</h2>',

  /** The HTML code to show when calling verifying assertion. */
  verifying: '<h2>Verifying the result....</h2>',

  useOtherEmail: 'Use a different email',

  selectorSubtitle: 'Use an email address you already have'
};

/**
 * @namespace Stores all the messages of the widget.
 */
window.google.identitytoolkit.easyrp.messages = {
  /** Error Message for the empty email address. */
  emptyEmail: 'Email cannot be empty!',

  /** Error Message for the format of email address is invalid. */
  emailFormatError: 'Invalid email format!',

  /** Error Message for failed to start AJAX request. */
  ajaxFailed: 'Failed to get result from server!',

  /** Error Message for failed AJAX request. */
  ajaxError: 'AJAX Error',

  /** Error Message for failed to redirect to IDP. */
  redirectFailed: '<h2>Failed to redirect to email provider for ' +
      '"%%identifier%%": %%reason%%.</h2>',

  /** Error Message for the email provider is not an IDP. */
  unsupportedDomain: 'unsupported email domain',

  /** Error Message for incorrect assertion information. */
  verifyFailed: '<h2>Failed to verify the response: %%reason%%.<h2>',

  /** Error Message for empty information in the assertion. */
  emptyAssertion: 'empty assertion returned'
};

// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the namespace for easyrp.
 * @author guibinkong@google.com (Guibin Kong)
 * @nocompile
 */

/**
 * Defines the name space for Google Connect Tools.
 */

// Safety net in case we're used outside google.load()
if (!('google' in window)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google = {};
}
if (!('identitytoolkit' in window.google)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google.identitytoolkit = {};
}

/**
 * @namespace Name space for Easy Relying Parties.
 */
window.google.identitytoolkit.easyrp =
    window.google.identitytoolkit.easyrp || {};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Configuration parameters for the login widget.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespace Configuration parameters.
 */
window.google.identitytoolkit.easyrp.config =
    window.google.identitytoolkit.easyrp.config || {};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Configuration parameters for the popup window.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespace The configuration parameters for the popup window.
 */
window.google.identitytoolkit.easyrp.config.popup = {};

/**
 * The width of the popup window.
 */
window.google.identitytoolkit.easyrp.config.popup.width = 520;

/**
 * The height of the popup window.
 */
window.google.identitytoolkit.easyrp.config.popup.height = 550;

// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Configuration parameters to connect to EasyRP API server.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * The EasyRP API Server. Default is http://www.googleapis.com/.
 */
window.google.identitytoolkit.easyrp.config.apiServer = '';

/**
 * The version of the EasyRP API.
 */
window.google.identitytoolkit.easyrp.config.apiVersion = 'v1';

/**
 * The callback URL when returned from an IDP.
 */
window.google.identitytoolkit.easyrp.config.continueUrl = '';

// Changes the end-point of EasyRP API.
if (window.google.identitytoolkit.easyrp.config.apiServer) {
  window['__GOOGLEAPIS'] = {
    'googleapis': {
      'proxy': window.google.identitytoolkit.easyrp.config.apiServer +
          '/static/proxy.html'
    }
  };
}

// Changes the version of the EasyRP API.
googleapis.setVersions({
  'identitytoolkit': window.google.identitytoolkit.easyrp.config.apiVersion
});
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Configuration parameters for the IDP selector popin.
 * @author liujin@google.com (Jin Liu)
 */

/**
 * The configuration parameters for the IDP selector popin.
 */
window.google.identitytoolkit.easyrp.config.idpSelector = {};

/**
 * The width of the popin.
 */
window.google.identitytoolkit.easyrp.config.idpSelector.width = 300;

/**
 * The height of the popin.
 */
window.google.identitytoolkit.easyrp.config.idpSelector.height = 500;

/**
 * The displayed IDP list.
 */
window.google.identitytoolkit.easyrp.config.idpSelector.idps =
    ['Gmail', 'Yahoo', 'AOL', 'Hotmail'];


// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview The configuration parameters for the Identifier Providers.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * The name space for IDP configuration parameters.
 */
window.google.identitytoolkit.easyrp.config.idps = {};

/**
 * @namespace The configuration parameters for Gmail.
 */
window.google.identitytoolkit.easyrp.config.idps.Gmail =
    /** @lends window.google.identitytoolkit.easyrp.config.idps.Gmail */ {
  /**
   * The display name for the IDP.
   */
  label: window.google.identitytoolkit.easyrp.labels.idps.Gmail,

  /**
   * The URL of the icon for the IDP.
   */
  image: window.google.identitytoolkit.easyrp.images.gmail,

  /**
   * The email domain for the IDP.
   */
  domain: 'gmail.com'
};

/**
 * @namespace The configuration parameters for Yahoo.
 */
window.google.identitytoolkit.easyrp.config.idps.Yahoo =
    /** @lends window.google.identitytoolkit.easyrp.config.idps.Yahoo */ {
  /**
   * The display name for the IDP.
   */
  label: window.google.identitytoolkit.easyrp.labels.idps.Yahoo,

  /**
   * The URL of the icon for the IDP.
   */
  image: window.google.identitytoolkit.easyrp.images.yahoo,

  /**
   * The email domain for the IDP.
   */
  domain: 'yahoo.com'
};

/**
 * @namespace The configuration parameters for AOL.
 */
window.google.identitytoolkit.easyrp.config.idps.AOL =
    /** @lends window.google.identitytoolkit.easyrp.config.idps.AOL */ {
  /**
   * The display name for the IDP.
   */
  label: window.google.identitytoolkit.easyrp.labels.idps.AOL,

  /**
   * The URL of the icon for the IDP.
   */
  image: window.google.identitytoolkit.easyrp.images.aol,

  /**
   * The email domain for the IDP.
   */
  domain: 'aol.com'
};

/**
 * @namespace The configuration parameters for Hotmail.
 */
window.google.identitytoolkit.easyrp.config.idps.Hotmail =
    /** @lends window.google.identitytoolkit.easyrp.config.idps.Hotmail */ {
  /**
   * The display name for the IDP.
   */
  label: window.google.identitytoolkit.easyrp.labels.idps.Hotmail,

  /**
   * The URL of the icon for the IDP.
   */
  image: window.google.identitytoolkit.easyrp.images.hotmail,

  /**
   * The email domain for the IDP.
   */
  domain: 'hotmail.com'
};

// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview A template to set configuration parameters. A widget should
 * overwrite some of the methods that starts with 'setWidget' to actually
 * support these configuration parameters.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * This method is the entry point to change the configuration parameters of a
 * widget.
 * <p>This method lists all supported parameter names, which are
 * case-insensitive. The default behavior when changing a config is to write a
 * log to the browser console. (With the exception 'developerKey', 'returnToUrl'
 * , and 'companyName', which will do the real work here.)
 * <p>A widget should override some of the methods that starts with 'setWidget'
 * to actually support these configuration parameters.
 * @param {object} config The configuration parameter key-value pairs.
 */
window.google.identitytoolkit.easyrp.config.setConfig = function(config) {
  if (config) {
    for (var key in config) {
      var value = config[key];
      // Use lower case for error-tolerance
      var lowerCaseKey = key.toLowerCase();
      switch (lowerCaseKey) {
        case 'developerkey': {
          window.google.identitytoolkit.easyrp.config.setDeveloperKey_(value,
              key);
          break;
        }
        case 'returntourl': {
          window.google.identitytoolkit.easyrp.config.setReturnToUrl_(value,
              key);
          break;
        }
        case 'companyname': {
          window.google.identitytoolkit.easyrp.config.setCompanyName_(value,
              key);
          break;
        }
        case 'width': {
          window.google.identitytoolkit.easyrp.config.setWidgetWidth(value,
              key);
          break;
        }
        case 'loginurl': {
          window.google.identitytoolkit.easyrp.config.setWidgetLoginUrl(value,
              key);
          break;
        }
        case 'signupurl': {
          window.google.identitytoolkit.easyrp.config.setWidgetSignupUrl(value,
              key);
          break;
        }
        case 'homeurl': {
          window.google.identitytoolkit.easyrp.config.setWidgetHomeUrl(value,
              key);
          break;
        }
        case 'forgoturl': {
          window.google.identitytoolkit.easyrp.config.setWidgetForgotUrl(value,
              key);
          break;
        }
        case 'idps': {
          window.google.identitytoolkit.easyrp.config.setWidgetIdps(value,
              key);
          break;
        }
        case 'localtabheader': {
          window.google.identitytoolkit.easyrp.config.setWidgetLocalTabHeader(
              value, key);
          break;
        }
        case 'anytabheader': {
          window.google.identitytoolkit.easyrp.config.setWidgetAnyTabHeader(
              value, key);
          break;
        }
        case 'realm': {
          window.google.identitytoolkit.easyrp.config.setOpenidRealm(value,
              key);
          break;
        }
        default: {
          window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(
              key);
          break;
        }
      }
    }
  }
};

/**
 * Writes a log to browser console for a unrecognized configuration parameter.
 * @param {string} key The name of the configuration parameter.
 * @private
 */
window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_ = function(
    key) {
  if (window.google.identitytoolkit.easyrp.util &&
      window.google.identitytoolkit.easyrp.util.log) {
    var msg = 'Unrecognized config parameter \'' + key + '\', ignored!';
    window.google.identitytoolkit.easyrp.util.log(msg);
  }
};

/**
 * Sets configuration parameter: developer key.
 * @param {string} value the parameter value.
 * @private
 */
window.google.identitytoolkit.easyrp.config.setDeveloperKey_ = function(value) {
  googleapis.setDeveloperKey(value);
};

/**
 * Sets configuration parameter: return to URL
 * @param {string} value the parameter value.
 * @private
 */
window.google.identitytoolkit.easyrp.config.setReturnToUrl_ = function(value) {
  window.google.identitytoolkit.easyrp.config.continueUrl = value;
};

/**
 * Sets configuration parameter: company name.
 * @param {string} value the parameter value.
 * @private
 */
window.google.identitytoolkit.easyrp.config.setCompanyName_ = function(value) {
  if (window.google.identitytoolkit.easyrp.labels) {
    window.google.identitytoolkit.easyrp.config.replaceCompanyName_(
        window.google.identitytoolkit.easyrp.labels, value);
  }
};

/**
 * Sets configuration parameter: OpenID realm. It's optional and used to create
 * the IDP authentication URL.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setOpenidRealm = function(value) {
  window.google.identitytoolkit.easyrp.config.openidRealm = value;
};

/**
 * Replaces all the place holder '' to company name.
 * @param {object} res The resource object.
 * @param {string} companyNameValue The value of the company name.
 * @private
 */
window.google.identitytoolkit.easyrp.config.replaceCompanyName_ = function(res,
    companyNameValue) {
  for (var key in res) {
    var value = res[key];
    if (typeof(value) == 'string') {
      res[key] = value.replace(/\%\%companyName\%\%/g, companyNameValue);
    } else if (typeof(value) == 'object') {
      window.google.identitytoolkit.easyrp.config.replaceCompanyName_(value,
          companyNameValue);
    }
  }
};

/**
 * Sets configuration parameter: widget width.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetWidth = function(value,
    key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: login URL.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetLoginUrl = function(value,
    key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: sign up URL.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetSignupUrl = function(
    value, key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: sign up URL.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetForgotUrl = function(
    value, key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: sign up URL.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetHomeUrl = function(value,
    key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: nascar IDPs.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetIdps = function(value,
    key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: any tab header.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetLocalTabHeader = function(
    value, key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};

/**
 * Sets configuration parameter: any tab header.
 * @param {string} value the parameter value.
 * @param {string} key the parameter name.
 */
window.google.identitytoolkit.easyrp.config.setWidgetAnyTabHeader = function(
    value, key) {
  window.google.identitytoolkit.easyrp.config.logUnrecognizedConfig_(key);
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the namespace for easyrp.
 * @author guibinkong@google.com (Guibin Kong)
 * @nocompile
 */

/**
 * Defines the name space for Google Connect Tools.
 */

// Safety net in case we're used outside google.load()
if (!('google' in window)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google = {};
}
if (!('identitytoolkit' in window.google)) {
  /**
   * @namespace Name space for Easy Relying Parties.
   */
  window.google.identitytoolkit = {};
}

/**
 * @namespace Name space for Easy Relying Parties.
 */
window.google.identitytoolkit.easyrp =
    window.google.identitytoolkit.easyrp || {};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines some common utility functions.
 * @supported Chrome5+, FireFox3.6+, IE8, IE7, and Safari4.0+.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespace Utility functions.
 */
window.google.identitytoolkit.easyrp.util =
    window.google.identitytoolkit.easyrp.util || {};

/**
 * Logs a message to the console of the browser for debugging.
 * @param {string} message The message to log.
 */
window.google.identitytoolkit.easyrp.util.log = function(message) {
  try {
    if (window.console && window.console.log) {
      window.console.log(message);
    }
  } catch (ex) {
    // Ignore if cannot log to console.
  }
};

/**
 * UUID allows multiple instances on the same page.
 * @type {number}
 * @private
 */
window.google.identitytoolkit.easyrp.util.uuidCounter_ = new Date().getTime();

/**
 * Computes a UUID for this widget. If a UUID is set on the options, use it.
 * Otherwise generates one.
 * @param {Object} options The options object of this widget.
 * @return {number | string} The uuid of this widget.
 */
window.google.identitytoolkit.easyrp.util.generateUuid = function(options) {
  var newUuid;
  if (options && options.uuid) {
    newUuid = options.uuid;
  } else {
    newUuid = ++window.google.identitytoolkit.easyrp.util.uuidCounter_;
  }
  return newUuid;
};

/**
 * Creates a form to submit the {@code parameters} to the {@code targetUrl}.
 * @param {string} targetUrl The URL to which the form will submit.
 * @param {{key1: value1, key2: value2, ...}} parameters The parameters in the
 *     form.
 * @param {Window} opt_win The optional window in which the form is created. If
 *     missing, current {@code window} object is used.
 * @return {Element} The created DOM element.
 * @private
 */
window.google.identitytoolkit.easyrp.util.createForm_ = function(targetUrl,
    parameters, opt_win) {
  var win = opt_win || window;
  if (!targetUrl) {
    throw 'The targetUrl cannot be null.';
  }
  var myForm = win.document.createElement('form');
  myForm.method = 'post';
  myForm.action = targetUrl;
  if (parameters) {
    for (var k in parameters) {
      var myInput = win.document.createElement('input');
      myInput.setAttribute('type', 'hidden');
      myInput.setAttribute('name', k);
      if (parameters[k] === null || parameters[k] === undefined) {
        myInput.setAttribute('value', '');
      } else {
        myInput.setAttribute('value', parameters[k]);
      }
      myForm.appendChild(myInput);
    }
  }
  win.document.body.appendChild(myForm);
  return myForm;
};

/**
 * Creates a form with {@code parameters} and submit it to {@code targetUrl}.
 * @param {string} targetUrl The URL to which the form will submit.
 * @param {{key1: value1, key2: value2, ...}} parameters The parameters in the
 *     form.
 * @param {Window} opt_win The optional window in which the form is created. If
 *     missing, current {@code window} object is used.
 */
window.google.identitytoolkit.easyrp.util.postTo = function(targetUrl,
    parameters, opt_win) {
  var win = opt_win || window;
  var myForm = window.google.identitytoolkit.easyrp.util.createForm_(targetUrl,
      parameters, win);
  myForm.submit();
  win.document.body.removeChild(myForm);
};

/**
 * Returns the URL params. e.g. To get the value of the "foo" param in the
 * URL the code can be: var foo = parseUrlParams_()['foo'];
 * @param {string} url The URL to parse.
 * @return {Object} The URL params array.
 * @private
 */
window.google.identitytoolkit.easyrp.util.parseUrlParams_ = function(url) {
  var params = [];
  var segments = url.slice(url.indexOf('?') + 1).split('&');
  for (var i = 0; i < segments.length; i++) {
    var pair = segments[i].split('=');
    if (pair.length == 2) {
      params[pair[0]] = decodeURIComponent(pair[1]);
    } else {
      params[pair[0]] = undefined;
    }
  }
  return params;
};

/**
 * Sends the request to the given URL with POST method instead of GET method.
 * A hidden form is used to post the request.
 * @param {string} targetUrl The URL to post.
 * @param {Object} parent The parent element to which the form appends.
 */
window.google.identitytoolkit.easyrp.util.formRedirect = function(targetUrl,
    parent) {
  var url = targetUrl.substring(0, targetUrl.indexOf('?'));
  var params =
      window.google.identitytoolkit.easyrp.util.parseUrlParams_(targetUrl);
  window.google.identitytoolkit.easyrp.util.postTo(url, params, parent);
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines some utility functions to handle email address.
 * @supported Chrome5+, FireFox3.6+, IE8, IE7, and Safari4.0+.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * The regular expression for a vaild email address.
 * @type {RegExp}
 * @private
 */
window.google.identitytoolkit.easyrp.util.EMAIL_REGEX_ =
    /^\w+(\.\w+)*@(\w+(\.\w+)+)$/;

/**
 * Checks if the given parameter is a valid email address format.
 * @param {string} email The input email to be checked.
 * @return {boolean} True if the email format is valid.
 */
window.google.identitytoolkit.easyrp.util.isValidEmail = function(email) {
  return email && (
      window.google.identitytoolkit.easyrp.util.EMAIL_REGEX_.exec(email) !=
      null);
};

/**
 * Returns the domain part of an email in lower case.
 * @param {string} email The email to be parsed.
 * @return {string} The domain of the email parameter.
 */
window.google.identitytoolkit.easyrp.util.getEmailDomain = function(email) {
  if (email && window.google.identitytoolkit.easyrp.util.isValidEmail(email)) {
    return jQuery.trim(email.split('@')[1]).toLowerCase();
  }
};

/**
 * Returns the user name part of an email in lower case.
 * @param {string} email The email to be parsed.
 * @return {string} The user name of the email parameter.
 */
window.google.identitytoolkit.easyrp.util.getEmailUsername = function(email) {
  if (email && window.google.identitytoolkit.easyrp.util.isValidEmail(email)) {
    return jQuery.trim(email.split('@')[0]).toLowerCase();
  }
};

/**
 * Returns the IDP name for a domain if it is in NASCAR list.
 * @param {string} domain The domain to be checked.
 * @return {string} The IDP id, or <code>undefined</code> if not found.
 */
window.google.identitytoolkit.easyrp.util.isDomainInNascar = function(domain) {
  if (domain) {
    var idps = window.google.identitytoolkit.easyrp.config.idps;
    for (var idpId in idps) {
      var idp = idps[idpId];
      if (idp && (idp.domain == domain)) {
        return idpId;
      }
    }
  }
};

/**
 * Shows a dark screen to cover the browser window.
 * @param {boolean} opt_checkedWindow If set, start a timer to wait that window
 *          close.
 */
window.google.identitytoolkit.easyrp.util.showDarkScreen = function(
    opt_checkedWindow) {
  window.google.identitytoolkit.easyrp.util.removeDarkScreen();
  var darkScreen = jQuery('<div>').addClass('dark-screen').attr('id',
      'dark-screen').appendTo(jQuery('body'));
  window.google.identitytoolkit.easyrp.util.resizeDarkScreen_();
  jQuery('body').css('overflow-x', 'hidden');

  if (opt_checkedWindow) {
    darkScreen.data('popupWindow', opt_checkedWindow);
    var popupChecker = window.setInterval(
        window.google.identitytoolkit.easyrp.util.checkPopup_, 40);
    darkScreen.data('popupChecker', popupChecker);
  }
  jQuery(window).resize(
      window.google.identitytoolkit.easyrp.util.resizeDarkScreen_);

  darkScreen.show();
};

/**
 * Removes the dark screen that covers the browser.
 */
window.google.identitytoolkit.easyrp.util.removeDarkScreen = function() {
  var darkScreen = jQuery('#dark-screen');
  if (darkScreen.length) {
    var popupChecker = darkScreen.data('popupChecker');
    if (popupChecker) {
      window.clearInterval(popupChecker);
      darkScreen.removeData('popupChecker');
    }
    var popup = darkScreen.data('popupWindow');
    if (popup) {
      darkScreen.removeData('popupWindow');
      if (!popup.closed) {
        popup.close();
      }
    }
    jQuery(window).unbind('resize',
        window.google.identitytoolkit.easyrp.util.resizeDarkScreen_);
    jQuery('body').css('overflow-x', 'auto');
    darkScreen.remove();
  }
};

/**
 * Sets the position of the dark screen.
 * @private
 */
window.google.identitytoolkit.easyrp.util.resizeDarkScreen_ = function() {
  var darkScreen = jQuery('#dark-screen');
  if (darkScreen.length) {
    var size = window.google.identitytoolkit.easyrp.util.maxScreenSize_();
    darkScreen.width(size.width).height(size.height);
  }
};

/**
 * Computes the window/document size to be covered by the dark screen. It will
 * ensure the document and window must be covered, and a height at least 1200px
 * so that Gmail's sign-up page can be shown.
 * @return {Object} The suitable width and height.
 * @private
 */
window.google.identitytoolkit.easyrp.util.maxScreenSize_ = function() {
  var height = Math.max(jQuery(window).height(), jQuery(document).height());
  var width = Math.max(jQuery(window).width(), jQuery(document).width());
  if (height < 1200) {
    // BUG FIX: Ensures the Gamil sign-up section can be shown fully.
    height = 1200;
  }

  return {
      'width': width,
      'height': height
  };
};

/**
 * Checks whether the popup window is closed. If closed, remove the dark screen
 * that covers the browser.
 * @private
 */
window.google.identitytoolkit.easyrp.util.checkPopup_ = function() {
  var darkScreen = jQuery('#dark-screen');
  if (darkScreen.length) {
    var popup = darkScreen.data('popupWindow');
    if (!popup || popup.closed) {
      window.google.identitytoolkit.easyrp.util.removeDarkScreen();
    }
  }
};

// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines utility function to open a popup window.
 * @supported Chrome5+, FireFox3.6+, IE8, IE7, and Safari4.0+.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * Opens a new window.
 * @param {number} width The width of the window.
 * @param {number} height The height of the window.
 * @param {string} opt_url The URL for the new window. If missing or set to
 *     null, 'about:blank' will be used.
 * @return {Window} the opened window object.
 */
window.google.identitytoolkit.easyrp.util.showPopup = function(width,
    height, opt_url) {
  var top = (jQuery(window).height() - height) / 2;
  var left = (jQuery(window).width() - width) / 2;
  top = top > 0 ? top : 0;
  left = left > 0 ? left : 0;
  var options = 'width=' + width + ',height=' + height + ',left=' + left +
      ',top=' + top + ',status=1,location=1,resizable=yes';
  var url = opt_url || 'about:blank';
  var popup = window.open(url, 'OpenIdPopup', options);
  if (popup) {
    if (window.google.identitytoolkit.easyrp.util.showDarkScreen) {
      window.google.identitytoolkit.easyrp.util.showDarkScreen(popup);
    }
    popup.focus();
  }
  return popup;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines utility functions to validate parameter.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespcae Parameter validators.
 */
window.google.identitytoolkit.easyrp.param = {};

/**
 * Checks a parameter value is not null or undefined.
 * @param {any} value The value of a parameter.
 * @param {string} opt_paramName An optional name of the parameter.
 */
window.google.identitytoolkit.easyrp.param.notNull = function(value,
    opt_paramName) {
  if (value === undefined || value === null) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% cannot be null.', opt_paramName);
  }
};

/**
 * Checks a parameter value is not empty. That is, the value must evaluate to
 * true.
 * @param {any} value The value of a parameter.
 * @param {string} opt_paramName An optional name of the parameter.
 */
window.google.identitytoolkit.easyrp.param.notEmpty = function(value,
    opt_paramName) {
  if (!value) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% cannot be empty.', opt_paramName);
  }
};

/**
 * Checks a parameter value must be a non-empty array.
 * @param {any} value The value of a parameter.
 * @param {string} opt_paramName An optional name of the parameter.
 */
window.google.identitytoolkit.easyrp.param.notEmptyArray = function(value,
    opt_paramName) {
  if (!value) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% cannot be empty.', opt_paramName);
  }
  if (!jQuery.isArray(value)) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% is not an array.', opt_paramName);
  }
  if (!value.length) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% cannot be an empty array.', opt_paramName);
  }
};

/**
 * Checks a parameter value must be a non-empty array.
 * @param {any} value The value of a parameter.
 * @param {string} opt_paramName An optional name of the parameter.
 */
window.google.identitytoolkit.easyrp.param.notEmptyFunction = function(value,
    opt_paramName) {
  if (!value) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% cannot be empty.', opt_paramName);
  }
  if (!jQuery.isFunction(value)) {
    window.google.identitytoolkit.easyrp.param.throwError_(
        'Parameter %%param%% is not a function.', opt_paramName);
  }
};

/**
 * Throws an error to indicate a failed parameter validation.
 * @param {string} message The error message.
 * @param {string} opt_paramName An optional name of the parameter.
 * @private
 */
window.google.identitytoolkit.easyrp.param.throwError_ = function(message,
    opt_paramName) {
  try {
    if (console && console.trace) {
      console.trace();
    }
  } catch (e) {
  }
  var param = opt_paramName ? ' \'' + opt_paramName + '\'' : '';
  throw message.replace(/\%\%param\%\%/g, param);
};
/**
 * A class can extends parent class.
 * @param {Function} parentClass The parent class to be extended.
 */
Function.prototype.inheritsFrom = function(parentClass) {
  window.google.identitytoolkit.easyrp.param.notEmptyFunction(parentClass,
      'parentClass');

  this.prototype = new parentClass;
  this.prototype.constructor = this;
  this.prototype.parentClass = parentClass.prototype;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines common utility functions to show/hide a pop-in DIV.
 * @supported Chrome5+, FireFox3.6+, IE8, IE7, and Safari4.0+.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * Computes the position for the popin.
 * @private
 */
window.google.identitytoolkit.easyrp.util.setPopinPosition_ = function() {
  var popin = jQuery('#popin-box');
  if (popin) {
    var top = jQuery(window).scrollTop() +
        (jQuery(window).height() - popin.height()) / 2;
    var left = jQuery(window).scrollLeft() +
        (jQuery(window).width() - popin.width()) / 2;
    top = Math.max(top, 0);
    left = Math.max(left, 0);
    popin.css({
        'top': top + 'px',
        'left': left + 'px'
    });
  }
};

/**
 * Creates a DIV element for the popin.The reason why the popin is not shown in
 * the createPopIn method is we don't want user to see the moving of the popin.
 * @return {Element} The created element.
 */
window.google.identitytoolkit.easyrp.util.createPopIn = function() {
  jQuery('#popin-box').remove();
  var popin = jQuery('<div>').addClass('popin-box').css('display', 'none')
      .attr('id', 'popin-box').appendTo(jQuery('body'));
  window.google.identitytoolkit.easyrp.util.setPopinPosition_();
  return popin;
};

/**
 * Shows the popin DIV and covers the browser with a dark screen. Creates the
 * popin DIV if not already created.
 */
window.google.identitytoolkit.easyrp.util.showPopIn = function() {
  if (jQuery('#popin-box').length == 0) {
    window.google.identitytoolkit.easyrp.util.createPopIn();
  }
  window.google.identitytoolkit.easyrp.util.showDarkScreen();
  jQuery(window).resize(
      window.google.identitytoolkit.easyrp.util.setPopinPosition_);
  jQuery('#popin-box').show();
  window.google.identitytoolkit.easyrp.util.setPopinPosition_();
};

/**
 * Removes the popin DIV and the dark screen.
 */
window.google.identitytoolkit.easyrp.util.removePopIn = function() {
  jQuery(window).unbind('resize',
      window.google.identitytoolkit.easyrp.util.setPopinPosition_);
  jQuery('#popin-box').remove();
  window.google.identitytoolkit.easyrp.util.removeDarkScreen();
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Utility functions for AJAX handling.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * AJAX utility functions.
 */
window.google.identitytoolkit.easyrp.net =
    window.google.identitytoolkit.easyrp.net || {};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Utility functions to call EasyRP API.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @namespace EasyRP API utility functions.
 */
window.google.identitytoolkit.easyrp.googleapi =
    window.google.identitytoolkit.easyrp.googleapi || {};

/**
 * Sends AJAX request to EasyRP API server.
 * @param {string} method The Apiary rpcMethod name.
 * @param {object} parameters The parameters for the Apiary request.
 * @param {function(response)} callback The function to be called when response
 *     returned.
 * @private
 */
window.google.identitytoolkit.easyrp.googleapi.makeRequest_ =
    function(method, parameters, callback) {
  window.google.identitytoolkit.easyrp.util.
      log('Request to GoogleAPI: method=[' + method + '], params=[' +
      window.JSON.stringify(parameters) + '].');
  googleapis.newRequest(method, parameters).execute(function(response) {
    window.google.identitytoolkit.easyrp.util.log('GoogleAPI returns: ' +
        window.JSON.stringify(response));
    callback(response);
  });
};

/**
 * Sends an AJAX request to get the authentication URL for the identifier.
 * @param {email|domain} identifier The identifier for which to create the URL.
 * @param {string} opt_continueUrl The callback URL to which IDP return
 *     response. If missing, use
 *     {@code window.google.identitytoolkit.easyrp.config.continueUrl}.
 * @param {function(response)} callback The function to be called when response
 *     returned.
 * @param {string} opt_purpose The purpose for the federated login:
 *     'signin' or 'upgrade'. Default is 'signin'.
 * @param {email} opt_input_email The email user input. Leave empty if you don't
 *     want server check the mismatch case.
 * @param {string} opt_openidRealm The OpenID realm used to create the IDP
 *     authentication URL. The default is to use the one in the config.
 */
window.google.identitytoolkit.easyrp.googleapi.createAuthUrl = function(
    identifier, opt_continueUrl, callback, opt_purpose, opt_input_email,
    opt_openidRealm) {
  var parameters = {};
  var continueUrl = opt_continueUrl;
  if (!continueUrl) {
    continueUrl = window.google.identitytoolkit.easyrp.config.continueUrl;
  }
  if (opt_purpose) {
    continueUrl += (continueUrl.indexOf('?') >= 0 ? '&' : '?');
    continueUrl = continueUrl + 'rp_purpose=' + opt_purpose;
  }
  if (opt_input_email) {
    continueUrl += (continueUrl.indexOf('?') >= 0 ? '&' : '?');
    continueUrl = continueUrl + 'rp_input_email=' + opt_input_email;
  }
  parameters['continueUrl'] = continueUrl;
  parameters['identifier'] = identifier;
  var realm = opt_openidRealm ||
      window.google.identitytoolkit.easyrp.config.openidRealm;
  if (realm) {
    parameters['openidRealm'] = realm;
  }
  window.google.identitytoolkit.easyrp.googleapi.makeRequest_(
      'identitytoolkit.relyingparty.createAuthUrl', parameters, callback);
};

/**
 * Sends an AJAX request to get verify an assertion.
 * @param {string} requestUri The URL of the request (from IDP).
 * @param {string} postBody The post body of the request (from IDP).
 * @param {function(response)} callback The function to be called when response
 *     returned.
 */
window.google.identitytoolkit.easyrp.googleapi.verifyAssertion = function(
    requestUri, postBody, callback) {
  var parameters = {
    requestUri: requestUri,
    postBody: postBody
  };
  window.google.identitytoolkit.easyrp.googleapi.makeRequest_(
      'identitytoolkit.relyingparty.verifyAssertion', parameters, callback);
};

/**
 * Parses the raw AJAX response, and return a translated response object.
 * Below is a sample of the returned object.
 * <pre>
 * {
 *   authUri: '', // Returns when no error occurs.
 *   error: ''    // Returns when error occurs.
 * }
 * </pre>
 * @param {object} response The raw AJAX response.
 * @return {object} The parsed result.
 */
window.google.identitytoolkit.easyrp.googleapi.parseCreateAuthUrlResponse =
    function(response) {
  var resp = {};
  if (response && 'error' in response) {
    resp['error'] = response['error'];
  }
  if (response && ('authUri' in response)) {
    resp['authUri'] = response['authUri'];
  }
  return resp;
};

/**
 * Parses the raw AJAX response, and return a translated response object.
 * Below is a sample of the returned object.
 * <pre>
 * {
 *   error: '',    // Returns when error occurs.
 *   email: '',    // Returns when no error occurs.
 *   firstName: '',// Returns when no error occurs.
 *   lastName: '', // Returns when no error occurs.
 *   fullName: '', // Returns when no error occurs.
 *   nickName: '', // Returns when no error occurs.
 * }
 * </pre>
 * @param {object} response The raw AJAX response.
 * @return {object} The parsed result.
 */
window.google.identitytoolkit.easyrp.googleapi.parseVerifyAssertionResponse =
    function(response) {
  var resp = {};
  if (response && 'error' in response) {
    resp['error'] = response['error'];
  }
  // TODO: Get user profile
  resp['email'] = response['verifiedEmail'];
  resp['firstName'] = response['firstName'];
  resp['lastName'] = response['lastName'];
  resp['fullName'] = response['fullName'];
  resp['nickName'] = response['nickName'];
  return resp;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the ApiHandler interface.
 *
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class The ApiHandler interface. ApiHandler is the API of a widget.
 * A widget won't send and parse AJAX request/response directly,
 * instead it uses a RequestFactory to create a Request, then call the
 * execute(callback) method of the Request to send the request, after the AJAX
 * response is returned and parsed, the callback will be invoked.
 * <br>You can see an example below.
 * <pre>
 * var request = widget.getRequestFactory().newCreateAuthUrlRequest(email);
 * request.execute(function(response) {
 *   if ('authUri' in response) {
 *     popup.location.href = response.authUri;
 *   }
 * });
 * </pre>
 * The RequestFactory uses a wrapped {@code ApiHandler} to do the real work.
 * {@code ApiHandler} is hidden to client so that it can be configurable and
 * interchangeable.
 * <br>The ApiHanlder defines three methods:
 * <ul>
 * <li>newRequest()</li> is called when client want to new a request. ApiHanlder
 * will check the request type is allowed, and all required parameters are
 * provided.
 * <li>send()</li> is called when the Request.execute() is invoked. It will
 * send suitable AJAX request to (RP or EasyRP) server.
 * <li>parseResponse()</li> is called when the AJAX response is returned. It
 * will parse the raw AJAX response, and return the translated response object.
 * </ul>
 * @interface
 */
window.google.identitytoolkit.easyrp.net.ApiHandler = function() {
};

/**
 * Creates a Request object. The ApiHandler checks whether the request type and
 * parameters are valid. If no Request object is returned, the calling
 * RequestFactory will create it.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType} type
 *     The type of the request.
 * @param {object} parameters The parameters of the request.
 * @return {window.google.identitytoolkit.easyrp.api.net.Request}
 *     The created Request object if any.
 */
window.google.identitytoolkit.easyrp.net.ApiHandler.prototype.newRequest =
    function(type, parameters) {
};

/**
 * Sends the AJAX request to (RP or EasyRP) server.
 * @param {window.google.identitytoolkit.easyrp.api.net.Request} request
 *     The request to be send.
 * @param {Function} callback The function to be called after the response
 *     returned.
 */
window.google.identitytoolkit.easyrp.net.ApiHandler.prototype.send = function(
    request, callback) {
};

/**
 * Parses the raw AJAX response, and return a translated response.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType} requestType
 *     The type the request.
 * @param {object} response The raw AJAX response.
 * @return {object} The translated response.
 */
window.google.identitytoolkit.easyrp.net.ApiHandler.prototype.parseResponse =
    function(requestType, response) {
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the Request class.
 *
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class Enum for RequestType values. Each represents a different AJAX request.
 * @enum {string}
 */
window.google.identitytoolkit.easyrp.net.RequestType =
    /** @lends window.google.identitytoolkit.easyrp.net.RequestType */ {
  /** Login request */
  LOGIN: 'login',

  /** Federated login request */
  FEDERATED_LOGIN: 'federated',

  /** Use the verifed email after mismatch */
  USE_VERIFIED_EMAIL: 'useVerifiedEmail',

  /** Clear the IDP assertion */
  RESET_IDP_ASSERTION: 'resetIdpResponse',

  /** A request to get the authentication URL */
  CREATE_AUTH_URL: 'createAuthUrl',

  /** A request to verify the assertion from IDP */
  VERIFY_ASSERTION: 'verifyAssertion'
};

/**
 * @class Enum for RequestState values.
 * @enum {number}
 */
window.google.identitytoolkit.easyrp.net.RequestState =
    /** @lends window.google.identitytoolkit.easyrp.net.RequestState */ {
  /** The request has not been executed yet. */
  UNEXECUTED: 0,

  /** The request is sent, but the response is not returned. */
  EXECUTING: 1,

  /** The request has executed, and the response has returned. */
  EXECUTED: 2
};

/**
 * @class Defines the Request class. A widget won't send and parse AJAX
 * request/response directly, instead it uses a RequestFactory to create a
 * Request, then call the execute(callback) method of the Request to send the
 * request, after the AJAX response is returned and parsed, the callback will be
 * invoked.
 * <br>See below example.
 * <pre>
 * var request = widget.getRequestFactory().newCreateAuthUrlRequest(email);
 * request.execute(function(response) {
 *   if ('authUri' in response) {
 *     popup.location.href = response.authUri;
 *   }
 * });
 * </pre>
 * The constructor should be called only by request factory to create a new
 * Request.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType}
 *     requestType The request type.
 * @param {object} parameters The parameters of the request.
 * @constructor
 */
window.google.identitytoolkit.easyrp.net.Request = function(requestType,
    parameters) {
  this.requestType_ = requestType;
  this.parameters_ = parameters;
  this.state_ =
      window.google.identitytoolkit.easyrp.net.RequestState.UNEXECUTED;
};

/**
 * Returns the type of the request.
 * @return {window.google.identitytoolkit.easyrp.net.RequestType}
 *    The request type.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getRequestType =
    function() {
  return this.requestType_;
};

/**
 * Returns the parameters of the request.
 * @return {object} The parameters of the request.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getParameters =
    function() {
  return this.parameters_;
};

/**
 * Returns the value for the request parameter specified by 'name'.
 * @param {string} name The parameter name.
 * @return {string|number|boolean} The parameter value.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getParameter =
    function(name) {
  return this.parameters_[name];
};

/**
 * Sets the value for the request parameter specified by 'name'.
 * @param {string} name The parameter name.
 * @param {string|number|boolean} value The parameter value.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.setParameter =
    function(name, value) {
  this.parameters_[name] = value;
};

/**
 * Returns the state of the request.
 * @return {window.google.identitytoolkit.easyrp.net.RequestState}
 *     The state of the request.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getState =
    function() {
  return this.state_;
};

/**
 * Executes the request, the callback function will be called when the AJAX
 * response is returned.
 * @param {Function} callback The function to be called when request is done.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.execute =
    function(callback) {
  if (!this.apiHandler_) {
    throw 'The apiHandler of the request cannot be null.';
  }
  this.callback_ = callback;
  this.state_ = window.google.identitytoolkit.easyrp.net.RequestState.EXECUTING;
  this.apiHandler_.send(this, jQuery.proxy(this.done_, this));
};

/**
 * Intercepts the returned AJAX response, and call the callback function.
 * @param {object} response The returned AJAX response.
 * @private
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.done_ =
    function(response) {
  this.response_ = this.apiHandler_.parseResponse(this.requestType_, response);
  this.state_ = window.google.identitytoolkit.easyrp.net.RequestState.EXECUTED;
  this.callback_(this.response_);
};

/**
 * Returns the parsed response of the request.
 * @return {object} The parsed response.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getResponse =
    function() {
  if (this.state_ ==
    window.google.identitytoolkit.easyrp.net.RequestState.EXECUTED) {
    return this.response_;
  }
};

/**
 * Sets the ApiHandler of the request. Should be called by request factory only.
 * @param {window.google.identitytoolkit.easyrp.net.ApiHandler} apiHandler
 *     The ApiHandler that really handle the request.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.setApiHandler =
    function(apiHandler) {
  this.apiHandler_ = apiHandler;
};

/**
 * Returns the ApiHandler that really handle the request.
 * @return {window.google.identitytoolkit.easyrp.net.ApiHandler}
 *     The ApiHandler that really handle the request.
 */
window.google.identitytoolkit.easyrp.net.Request.prototype.getApiHandler =
    function() {
  return this.apiHandler_;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview An implementation for the {@code ApiHandler} interface.
 * @see window.google.identitytoolkit.easyrp.net.ApiHandler
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class The ApiHandler for the Attribute Importer widget.
 * @constructor
 * @implements window.google.identitytoolkit.easyrp.net.ApiHandler
 */
window.google.identitytoolkit.easyrp.net.AttributeImporterApiHandler =
    function() {
};

/**
 * Creates a Request object. The ApiHandler checks whether the request type and
 * parameters are valid. If no Request object is returned, the calling
 * RequestFactory will create it.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType} type
 *     The type of the request.
 * @param {object} parameters The parameters of the request.
 * @return {window.google.identitytoolkit.easyrp.api.net.Request}
 *     The created Request object if any.
 */
window.google.identitytoolkit.easyrp.net.AttributeImporterApiHandler.prototype.
    newRequest = function(type, parameters) {
  if (type ==
      window.google.identitytoolkit.easyrp.net.RequestType.CREATE_AUTH_URL) {
    if (!parameters['identifier']) {
      throw 'Missing required parameter \'identifier\'.';
    }
  } else if (type ==
      window.google.identitytoolkit.easyrp.net.RequestType.VERIFY_ASSERTION) {
    if (!parameters['requestUri'] && !parameters['postData']) {
      throw 'Missing required parameter \'requestUri\' or \'postData\'.';
    }
  } else {
    throw 'Unsupported request type.';
  }
};

/**
 * Sends the AJAX request to (RP or EasyRP) server.
 * @param {window.google.identitytoolkit.easyrp.api.net.Request} request
 *     The request to be send.
 * @param {Function} callback The function to be called after the response
 *     returned.
 */
window.google.identitytoolkit.easyrp.net.AttributeImporterApiHandler.prototype.
    send = function(request, callback) {
  var type = request.getRequestType();
  if (type ==
      window.google.identitytoolkit.easyrp.net.RequestType.CREATE_AUTH_URL) {
    window.google.identitytoolkit.easyrp.googleapi.
        createAuthUrl(request.getParameter('identifier'), null, callback);
  } else if (type ==
      window.google.identitytoolkit.easyrp.net.RequestType.VERIFY_ASSERTION) {
    window.google.identitytoolkit.easyrp.googleapi.
        verifyAssertion(request.getParameter('requestUri'),
        request.getParameter('postData'), callback);
  } else {
    throw 'Unsupported request type.';
  }
};

/**
 * Parses the raw AJAX response, and return a translated response.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType} requestType
 *     The type the request.
 * @param {object} response The raw AJAX response.
 * @return {object} The translated response.
 */
window.google.identitytoolkit.easyrp.net.AttributeImporterApiHandler.prototype.
    parseResponse = function(requestType, response) {
  if (requestType ==
      window.google.identitytoolkit.easyrp.net.RequestType.CREATE_AUTH_URL) {
    return window.google.identitytoolkit.easyrp.googleapi.
        parseCreateAuthUrlResponse(response);
  } else if (requestType ==
      window.google.identitytoolkit.easyrp.net.RequestType.VERIFY_ASSERTION) {
    var resp = window.google.identitytoolkit.easyrp.googleapi.
        parseVerifyAssertionResponse(response);
    if (!resp['firstName'] && response['fullName']) {
      resp['firstName'] = response['fullName'];
    }
    if (!resp['firstName'] && response['nickName']) {
      resp['firstName'] = response['nickName'];
    }
    if (!resp['lastName'] && response['fullName']) {
      resp['lastName'] = response['fullName'];
    }
    if (!resp['lastName'] && response['nickName']) {
      resp['lastName'] = response['nickName'];
    }
    return resp;
  } else {
    throw 'Unsupported request type.';
  }
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the RequestFactory class.
 *
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class Constructs a new RequestFactory. This class helps client to
 * create an AJAX request and execute it. The RequestFactory uses a wrapped
 * {@code ApiHandler} to create a {@code Request}. {@code ApiHandler} is hidden
 * to client so that it can be configurable and interchangeable.
 * <br>See below example.
 * <pre>
 * var request = widget.getRequestFactory().newCreateAuthUrlRequest(email);
 * request.execute(function(response) {
 *   ......
 * });
 * </pre>
 * See ApiHandler for more information.
 * @param {window.google.identitytoolkit.easyrp.net.ApiHandler} apiHandler
 *     The wrapped ApiHandler.
 * @constructor
 */
window.google.identitytoolkit.easyrp.net.RequestFactory = function(apiHandler) {
  this.apiHandler_ = apiHandler;
};

/**
 * Creates a new Request.
 * @param {window.google.identitytoolkit.easyrp.net.RequestType} type
 *     The request type.
 * @param {object} parameters The parameters of the request.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.newRequest =
    function(type, parameters) {
  var request;
  // Allows handler to override the method to do special check.
  if (this.apiHandler_ && this.apiHandler_.newRequest) {
    request = this.apiHandler_.newRequest(type, parameters);
  }
  if (!request) {
    request = new window.google.identitytoolkit.easyrp.net.Request(type,
        parameters);
  }
  request.setApiHandler(this.apiHandler_);
  return request;
};

/**
 * Merges tow parameters objects.<br>
 * When key is same, value in 'requiredParams' has high priority. Note when the
 * value of a key is {@code null} in 'requiredParams', the value in 'opt_params'
 * will be used. But if its value is {@code undefined}
 * @param {object} requiredParams The parameters need to be merge.
 * @param {object} opt_params The parameters need to be merge.
 * @return {object} The merged parameters object.
 * @private
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    mergeParameters_ = function(requiredParams, opt_params) {
  var params = {};
  if (opt_params) {
    jQuery.extend(params, opt_params);
  }
  jQuery.extend(params, requiredParams);
  return params;
};

/**
 * Creates a Login Request with the provided parameters.
 * @param {string} email The input email.
 * @param {string} password The input password.
 * @param {object} opt_params Other parameters if any.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newLoginRequest = function(email, password, opt_params) {
  var type = window.google.identitytoolkit.easyrp.net.RequestType.LOGIN;
  var parameters = this.mergeParameters_({
    email: email,
    password: password
  }, opt_params);
  return this.newRequest(type, parameters);
};

/**
 * Creates a Federated Login Request with the provided parameters.
 * @param {string} email The input email.
 * @param {object} opt_params Other parameters if any.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newFederatedLoginRequest = function(email, opt_params) {
  var type =
      window.google.identitytoolkit.easyrp.net.RequestType.FEDERATED_LOGIN;
  var parameters = this.mergeParameters_({
    email: email
  }, opt_params);
  return this.newRequest(type, parameters);
};

/**
 * Creates a Use Verified Email Request with the provided parameters.
 * @param {string} verifiedEmail The verified email.
 * @param {object} opt_params Other parameters if any.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newUseVerifiedEmailRequest = function(verifiedEmail, opt_params) {
  var type =
      window.google.identitytoolkit.easyrp.net.RequestType.USE_VERIFIED_EMAIL;
  var parameters = this.mergeParameters_({
    email: verifiedEmail
  }, opt_params);
  return this.newRequest(type, parameters);
};

/**
 * Creates a Use Verified Email Request with the provided parameters.
 * @param {object} opt_params Other parameters if any.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newResetIdpAssertionRequest = function(opt_params) {
  var type =
      window.google.identitytoolkit.easyrp.net.RequestType.RESET_IDP_ASSERTION;
  var parameters = this.mergeParameters_({}, opt_params);
  return this.newRequest(type, parameters);
};

/**
 * Creates a GetAuthUrl Request with the provided parameters.
 * @param {string} identifier The input identifier.
 * @param {object} opt_params Other parameters if any.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newCreateAuthUrlRequest = function(identifier, opt_params) {
  var type =
      window.google.identitytoolkit.easyrp.net.RequestType.CREATE_AUTH_URL;
  var parameters = this.mergeParameters_({
    identifier: identifier
  }, opt_params);
  return this.newRequest(type, parameters);
};

/**
 * Creates a VerifyAssertion Request with the provided parameters.
 * @param {string} requestUri The request URI when returned from IDP.
 * @param {string} postData The data posted by the IDP when returned.
 * @param {object} opt_params Other parameters.
 * @return {window.google.identitytoolkit.easyrp.net.Request}
 *     The created request object.
 */
window.google.identitytoolkit.easyrp.net.RequestFactory.prototype.
    newVerifyAssertionRequest = function(requestUri, postData, opt_params) {
  var type =
      window.google.identitytoolkit.easyrp.net.RequestType.VERIFY_ASSERTION;
  var parameters = this.mergeParameters_({
    requestUri: requestUri,
    postData: postData
  }, opt_params);
  return this.newRequest(type, parameters);
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Contains many reusable methods to create UI fragments. They can
 *               be used to create the pages on the widget.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * Name space for the UI controls.
 */
window.google.identitytoolkit.easyrp.page = {};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the Page class, which is super class for all pages.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class Defines the Page class, which is super class for all pages.
 * @constructor
 */
window.google.identitytoolkit.easyrp.Page = function() {
};

/**
 * Renders the page on the page container.
 * @param {element} container The HTML element that contains the page.
 * @param {object} resource The resource object.
 * @param {boolean} opt_showCloseIcon whether to show the close icon.
 */
window.google.identitytoolkit.easyrp.Page.prototype.render = function(container,
    resource, opt_showCloseIcon) {
  window.google.identitytoolkit.easyrp.param.notNull(container, 'container');
  window.google.identitytoolkit.easyrp.param.notNull(resource, 'resource');
  this.container_ = container;
  this.resource_ = resource;
  this.showCloseIcon_ = !!opt_showCloseIcon;
};

/**
 * Returns the parent DOM element.
 * @return {element} The parent DOM element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.getContainer = function() {
  return this.container_;
};

/**
 * Returns the resource bundle used in the Page.
 * @return {object} The resource bundle used in the Page.
 */
window.google.identitytoolkit.easyrp.Page.prototype.getResource = function() {
  return this.resource_;
};

/**
 * Whether to show the close icon.
 * @return {boolean} Whether to show the close icon.
 */
window.google.identitytoolkit.easyrp.Page.prototype.isShowCloseIcon =
    function() {
  return this.showCloseIcon_;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Contains many reusable methods to create UI fragments. They can
 *               be used to crate the pages on the widget.
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * Creates a table.
 * @param {string} opt_styleClass The optional style class name for the created
 *        table. Can set multiple classes separated by space.
 * @return {Element} the created table element wrapped by jQuery.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createTable = function(
    opt_styleClass) {
  var table = jQuery('<table>').attr('cellspacing', 0).attr('cellpadding', 0)
      .attr('border', 0);
  if (opt_styleClass) {
    table.addClass(opt_styleClass);
  }
  return table;
};

/**
 * Creates a normal button by HTML input element.
 * @param {string} caption The caption of the button.
 * @param {string} handler The handler function when the button is clicked.
 * @param {string} opt_styleClass An optional class name for the button.
 * @return {Element} The created button element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createButton = function(
    caption, handler, opt_styleClass) {
  window.google.identitytoolkit.easyrp.param.notEmpty(caption, 'caption');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var btn = jQuery('<input type=button>').val(caption).addClass(
      'widget-input-button');
  if (opt_styleClass) {
    btn.addClass(opt_styleClass);
  }
  var self = this;
  btn.click(function() {
    self[handler].call(self);
  });
  return btn;
};

/**
 * Creates a link button by HTML a element.
 * @param {string} caption The caption of the button.
 * @param {string} handler The handler function when the button is clicked.
 * @param {string} opt_styleClass An optional class name for the button.
 * @return {Element} The created button element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createLinkButton = function(
    caption, handler, opt_styleClass) {
  window.google.identitytoolkit.easyrp.param.notEmpty(caption, 'caption');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var btn = jQuery('<a>').addClass('widget-link').html(caption);
  if (opt_styleClass) {
    btn.addClass(opt_styleClass);
  }
  var self = this;
  btn.click(function() {
    self[handler].call(self);
    return false;
  });
  return btn;
};

/**
 * Creates a 3D button by background images.
 * @param {string} caption The caption of the button.
 * @param {string} handler The handler function when the button is clicked.
 * @param {string} opt_styleClass An optional class name for the button.
 * @return {Element} The created button element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createRenderedButton =
    function(caption, handler, opt_styleClass) {
  window.google.identitytoolkit.easyrp.param.notEmpty(caption, 'caption');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var link = jQuery('<a>').html(caption).addClass('widget-button-link');
  var table = this.createTable('widget-button');
  if (opt_styleClass) {
    table.addClass(opt_styleClass);
  }
  var btnLine = jQuery('<tr>').appendTo(table);
  jQuery('<td>').addClass('widget-button-left').appendTo(btnLine);
  jQuery('<td>').addClass('widget-button-middle').append(link)
      .appendTo(btnLine);
  jQuery('<td>').addClass('widget-button-right').appendTo(btnLine);
  var self = this;
  jQuery(table).click(function() {
    self[handler].call(self);
    return false;
  });
  return table;
};

/**
 * Creates a text/password input box.
 * @param {string} inputClass The class for the created input element.
 * @param {boolean} isPassword Whether the input is a password instead of a
 *        text.
 * @param {string} opt_handler The handler function when keypress on the input.
 * @return {Element} The created input box element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createTextBox = function(
    inputClass, isPassword, opt_handler) {
  window.google.identitytoolkit.easyrp.param.notEmpty(inputClass, 'inputClass');
  var type = (isPassword ? 'password' : 'text');
  var textBox = jQuery('<input type=' + type + '>');
  textBox.addClass(inputClass);
  if (opt_handler) {
    var self = this;
    textBox.keypress(function(origianlEvent) {
      self[opt_handler].call(self, origianlEvent);
    });
  }
  return textBox;
};

/**
 * Creates a checkbox element. Note returned is a DIV element holding the check
 * box, not the check box itself.
 * @param {string} labelHtml The label text of the created checkbox.
 * @param {boolean} checked Whether the checkbox is checked.
 * @param {string} opt_styleClass An optional class name for the checkbox.
 * @return {Element} The created element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createCheckbox = function(
    labelHtml, checked, opt_styleClass) {
  window.google.identitytoolkit.easyrp.param.notNull(labelHtml, 'labelHtml');
  var checkBox = jQuery('<input type=checkbox>').attr('checked', !!checked);
  var label = jQuery('<label>').addClass('widget-checkbox-text').append(
      checkBox).append(labelHtml);
  var div = jQuery('<div>').addClass('widget-checkbox').append(label);
  if (opt_styleClass) {
    div.addClass(opt_styleClass);
  }
  return div;
};

/**
 * Creates a hyper-link that can be used for choice.
 * @param {string} caption The caption of the choice link.
 * @param {string} handler The handler function when the link is clicked.
 * @return {Element} The created element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createChoiceLink = function(
    caption, handler) {
  window.google.identitytoolkit.easyrp.param.notEmpty(caption, 'caption');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var div = jQuery('<div>').addClass('widget-choice-link');
  this.createLinkButton(caption, handler).appendTo(div);
  return div;
};

/**
 * Creates a reusable HTML fragment that has a text and a link.
 * @param {string} infoHtml The HTML code for the information part.
 * @param {string} linkHtml The HTML code for the link part.
 * @param {string} handler The handler function when the button is clicked.
 * @param {string} styleClass The class name for the created DIV element.
 * @return {Element} The created DIV element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createInfoLinkSection =
    function(infoHtml, linkHtml, handler, styleClass) {
  window.google.identitytoolkit.easyrp.param.notEmpty(infoHtml, 'infoHtml');
  window.google.identitytoolkit.easyrp.param.notEmpty(linkHtml, 'linkHtml');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  window.google.identitytoolkit.easyrp.param.notEmpty(styleClass, 'styleClass');
  var link = jQuery('<a>').html(linkHtml);
  var div = jQuery('<div>').addClass(styleClass).append(infoHtml).append(link);
  var self = this;
  link.click(function() {
    self[handler].call(self);
    return false;
  });
  return div;
};

/**
 * Creates a Nascar IDP link.
 * @param {{labe: '', image: '', domain: ''}} idp The IDP configuration data.
 * @param {string} idpId The IDP id to be rendered.
 * @param {string} handler The handler function when a IDP link is clicked.
 * @return {Element} The created element.
 * @private
 */
window.google.identitytoolkit.easyrp.Page.prototype.createNascarLink_ =
    function(idp, idpId, handler) {
  window.google.identitytoolkit.easyrp.param.notEmpty(idp, 'idp');
  window.google.identitytoolkit.easyrp.param.notEmpty(idpId, 'idpId');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var idpDiv = jQuery('<div>').addClass('widget-idp');
  var idpLink = jQuery('<a>').attr('href', 'javascript: void(0)').appendTo(
      idpDiv);
  var table = this.createTable('widget-idp-link').appendTo(idpLink);
  var idpTableLine = jQuery('<tr>').appendTo(table);
  idpTableLine.append(jQuery('<td>').append(
      jQuery('<img>').attr('src', idp.image).addClass('widget-idp-icon')));
  idpTableLine.append(jQuery('<td>').append(idp.label));
  var self = this;
  idpLink.click(function() {
    self[handler].call(self, idpId);
    return false;
  });
  return idpDiv;
};

/**
 * Creates a Nascar list.
 * @param {idpId: {}, ...} idps The configuration parameters for IDPs.
 * @param {Array} nascarIdpList The list of IDP ids to be rendered.
 * @param {string} handler The handler function when a IDP link is clicked.
 * @return {Element} The created element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createNascarList = function(
    idps, nascarIdpList, handler) {
  window.google.identitytoolkit.easyrp.param.notEmpty(idps, 'idps');
  window.google.identitytoolkit.easyrp.param.notEmptyArray(nascarIdpList,
      'nascarIdpList');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var nascar = jQuery('<div>').addClass('widget-nascar-list');
  for (var i = 0; i < nascarIdpList.length; i++) {
    var idpId = nascarIdpList[i];
    this.createNascarLink_(idps[idpId], idpId, handler).appendTo(nascar);
  }
  return nascar;
};

/**
 * Creates a HTML fragment with a title and a Nascar list.
 * @param {string} label The label text for the title.
 * @param {object} idps The idps config data.
 * @param {Array} nascarIdpList The list of IDP ids to be rendered.
 * @param {string} handler The handler function when a IDP link is clicked.
 * @return {Element} The created element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createNascarSection =
    function(label, idps, nascarIdpList, handler) {
  window.google.identitytoolkit.easyrp.param.notNull(label, 'label');
  window.google.identitytoolkit.easyrp.param.notEmpty(idps, 'idps');
  window.google.identitytoolkit.easyrp.param.notEmptyArray(nascarIdpList,
      'nascarIdpList');
  window.google.identitytoolkit.easyrp.param.notEmpty(handler, 'handler');
  var nascarSection = jQuery('<p>').append(label);
  this.createNascarList(idps, nascarIdpList, handler).appendTo(nascarSection);
  return nascarSection;
};

/**
 * Creates a widget header. Note: if opt_showCloseIcon is true, must provide
 * opt_handler.
 * @param {string} title The label of the header.
 * @param {boolean} opt_showCloseIcon Whether to show the close icon.
 * @param {string} opt_closeIcon The URL for the close icon.
 * @param {string} opt_handler The handler function when a IDP link is clicked.
 * @param {string} opt_closeTitle The title for the close icon.
 * @return {Element} The created header DIV element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createHeader = function(
    title, opt_showCloseIcon, opt_closeIcon, opt_handler, opt_closeTitle) {
  window.google.identitytoolkit.easyrp.param.notNull(title, 'title');
  var headerBar = jQuery('<div>').addClass('widget-header-bar');
  this.header = jQuery('<div>').html(title).addClass('widget-header').appendTo(
      headerBar);
  if (opt_showCloseIcon) {
    window.google.identitytoolkit.easyrp.param.notEmpty(opt_closeIcon,
        'opt_closeIcon');
    window.google.identitytoolkit.easyrp.param.notEmpty(opt_handler,
        'opt_handler');
    var closeIcon = jQuery('<img>').attr('src', opt_closeIcon).addClass(
        'widget-close-icon').appendTo(headerBar);
    if (opt_closeTitle) {
      closeIcon.attr('title', opt_closeTitle);
    }
    var self = this;
    closeIcon.click(function() {
      self[opt_handler].call(self);
    });
  }
  headerBar.append(jQuery('<div>').css('clear', 'both'));
  return headerBar;
};

/**
 * Creates a fragment with a label and a text/password input box.
 * @param {Element} parent The parent element for the label and input box.
 * @param {string} label The text for the label part.
 * @param {string} inputClass The class for the created input element.
 * @param {boolean} isPassword Whether the input is a password instead of a
 *        text.
 * @param {string} opt_handler The handler function when keypress on the input.
 */
window.google.identitytoolkit.easyrp.Page.prototype.appendLabelledTextBox =
    function(parent, label, inputClass, isPassword, opt_handler) {
  window.google.identitytoolkit.easyrp.param.notNull(parent, 'parent');
  window.google.identitytoolkit.easyrp.param.notNull(label, 'label');
  window.google.identitytoolkit.easyrp.param.notEmpty(inputClass, 'inputClass');
  if (label) {
    parent.append(label).append('<br>');
  }
  parent.append(this.createTextBox(inputClass, isPassword, opt_handler));
};

/**
 * Appends a error message DIV to the parent.
 * @param {Element} parent The parent element for the created element.
 * @return {Element} The created DIV element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.appendErrorDiv = function(
    parent) {
  window.google.identitytoolkit.easyrp.param.notNull(parent, 'parent');
  var errorDiv = jQuery('<div>').addClass('widget-error').appendTo(parent);
  return errorDiv;
};

/**
 * Appends a information message DIV to the parent.
 * @param {Element} parent The parent element for the created element.
 * @return {Element} The created DIV element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.appendMessageDiv = function(
    parent) {
  window.google.identitytoolkit.easyrp.param.notNull(parent, 'parent');
  var message = jQuery('<div>').addClass('widget-message').appendTo(parent)
      .hide();
  return message;
};

/**
 * Appends a DIV with style {clear: both;} to the parent.
 * @param {Element} parent The parent element for the created element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.appendClearDiv = function(
    parent) {
  window.google.identitytoolkit.easyrp.param.notNull(parent, 'parent');
  jQuery('<div>').addClass('cl').appendTo(parent);
};

/**
 * Creates a <code>center</code> element.
 * @param {Element} opt_child If set, append the element to the created center
 *        element.
 * @param {Element} opt_parent If set, appent the created center element to the
 *        element.
 * @return {Element} The created center element.
 */
window.google.identitytoolkit.easyrp.Page.prototype.putCenter = function(
    opt_child, opt_parent) {
  var center = jQuery('<center>');
  if (opt_child) {
    center.append(opt_child);
  }
  if (opt_parent) {
    center.appendTo(opt_parent);
  }
  return center;
};

/**
 * Creates a clickable icon.
 * @param {string} icon File to be rendered.
 * @param {string} handler The handler function when the button is clicked.
 * @param {string} opt_param The parameter of the handler.
 * @param {string} opt_styleClass Style class to be applied.
 * @return {Object} Div of the created item.
 */
window.google.identitytoolkit.easyrp.Page.prototype.createIconButton =
    function(icon, handler, opt_param, opt_styleClass) {
  var buttonDiv = jQuery('<div>').addClass('wizard-idp');
  if (opt_styleClass) {
    buttonDiv.addClass(opt_styleClass);
  }
  var buttonLink = jQuery('<a>').attr('href', 'javascript: void(0)');
  buttonLink.append(jQuery('<img>').attr('src', icon));
  var self = this;
  buttonDiv.click(function() {
    self[handler].call(self, opt_param);
    return false;
  });
  buttonLink.appendTo(buttonDiv);
  return buttonDiv;
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines class of the IDP selection page.
 * @author liujin@google.com (Jin Liu)
 */

/**
 * Creates the IDP Selector page.
 * @constructor
 */
window.google.identitytoolkit.easyrp.page.IdpSelectorPage = function() {
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.inheritsFrom(
    window.google.identitytoolkit.easyrp.Page);

/**
 * Renders the page on the page container.
 * @param {element} container The HTML element that contains the page.
 * @param {string} opt_resource The resource for the page.
 */
window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.render =
    function(container, opt_resource) {
  var resource = opt_resource;
  if (!resource) {
    resource = window.google.identitytoolkit.easyrp.labels;
  }
  this.parentClass.render.call(this, container, resource, true);
  this.render_();
};

/**
 * Renders the page.
 * @private
 */
window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.render_ =
    function() {
  this.container_.addClass('create-account-page');
  this.container_.append(jQuery('<div>').addClass('wizard-selector-title')
      .text('Sign up'));
  this.container_.append(jQuery('<div>').addClass('wizard-selector-subtitle')
      .text(this.resource_.selectorSubtitle));
  var listDiv = jQuery('<div>').addClass('wizard-idp-list');
  this.createIconButton(window.google.identitytoolkit.easyrp.images.close,
      'onCloseButtonClicked', 'close', 'wizard-close').appendTo(listDiv);
  for (var i = 0; i < window.google.identitytoolkit.easyrp.config.idpSelector
      .idps.length; i++) {
    var idp = window.google.identitytoolkit.easyrp.config.idpSelector.idps[i];
    this.createIconButton(
        window.google.identitytoolkit.easyrp.config.idps[idp].image,
        'onIdpItemClicked', idp).appendTo(listDiv);
  }
  this.createOtherEmailItem('onUseOtherEmailClicked').appendTo(listDiv);
  listDiv.appendTo(this.container_);
};

/**
 * Creates a text button with borders.
 * @param {string} handler The handler for the 'use other email' item.
 * @return {Object} div of the 'use other email' item.
 */
window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    createOtherEmailItem = function(handler) {
  var otherDiv = jQuery('<div>').addClass('wizard-idp last');
  this.createLinkButton(this.resource_.useOtherEmail, handler, 'text')
      .appendTo(otherDiv);
  return otherDiv;
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    getCloseIconElement = function() {
  return jQuery('.wizard-close', this.container_);
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    getIDPListElement = function() {
  return jQuery('.wizard-idp-list', this.container_);
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    getIDPItemElement = function() {
  return jQuery('.wizard-idp', this.container_).not('.wizard-close')
      .not('.last');
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    getOtherEmailButton = function() {
  return jQuery('.text', this.container_);
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    onCloseButtonClicked = function() {
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    onIdpItemClicked = function() {
};

window.google.identitytoolkit.easyrp.page.IdpSelectorPage.prototype.
    onUseOtherEmailClicked = function() {
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines the Widget interface.
 *
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * @class The Widget interface. Normally Widget is an
 * implementation of the jquery-ui widget, which combined with a UI element to
 * trigger customized/system Events. If a widget do not need to trigger events,
 * a normal JavaScript class is allowed. In both implementations, the functions
 * in this file must be provided.
 * @interface
 */
window.google.identitytoolkit.easyrp.Widget = function() {
};

/**
 * Returns the underline ApiHandler.
 * @return {window.google.identitytoolkit.easyrp.net.ApiHandler}
 *     The ApiHandler used.
 */
window.google.identitytoolkit.easyrp.Widget.prototype.getApiHandler =
    function() {
};

/**
 * Returns the RequestFactory.
 * @return {window.google.identitytoolkit.easyrp.net.RequestFactory}
 *     The RequestFactory used.
 */
window.google.identitytoolkit.easyrp.Widget.prototype.getRequestFactory =
    function() {
};

/**
 * Handles the notification send by the popup window. This is a generic way for
 * the communication between the widget and the pop-up window.
 * @param {string} type The type of the notification.
 * @param {object} params The parameters with the notification.
 */
window.google.identitytoolkit.easyrp.Widget.prototype.handleNotification =
    function(type, params) {
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Defines AttributeImporter class which implements Widget
 * interface. AttributeImporter is not a jquery-ui widget,since it doesn't need
 * a UI element to trigger events.
 * @see window.google.identitytoolkit.easyrp.Widget
 * @author guibinkong@google.com (Guibin Kong)
 */

/**
 * Name space of the Attribute importer widget.
 */
window.google.identitytoolkit.easyrp.importer = {};

/**
 * @class The Attribute Importer class. This class implements Widget interface.
 * AttributeImporter is not a jquery-ui widget,since it doesn't need a UI
 * element to trigger events.
 * @constructor
 * @implements window.google.identitytoolkit.easyrp.Widget
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter = function() {
  this.apiHandler_ = new window.google.identitytoolkit.easyrp.net.
      AttributeImporterApiHandler();
  this.requestFactory_ = new window.google.identitytoolkit.easyrp.net.
      RequestFactory(this.apiHandler_);
};

/**
 * Returns the RequestFactory.
 * @return {window.google.identitytoolkit.easyrp.net.RequestFactory}
 *     The RequestFactory used.
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    getRequestFactory = function() {
  return this.requestFactory_;
};

/**
 * Returns the underline ApiHandler.
 * @return {window.google.identitytoolkit.easyrp.net.ApiHandler}
 *     The ApiHandler used.
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    getApiHandler = function() {
  return this.apiHandler_;
};

/**
 * Starts the federated login process.
 * @param {string} email The email user input.
 * @param {Function} callback The callback function when federated login
 *     succeed.
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    start = function(email, callback) {
  if (!callback) {
    alert('Please provide a callback method.');
    return;
  }
  this.callback_ = callback;
  if (!email) {
    this.showIdpSelector_();
  } else {
    this.startFederatedLogin_(email);
  }
};

/**
 * Displays the IDP nascar list for selection.
 * @private
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    showIdpSelector_ = function() {
  this.page_ = new window.google.identitytoolkit.easyrp.page.IdpSelectorPage();
  var self = this;
  this.page_.onIdpItemClicked = function(idpId) {
    window.google.identitytoolkit.easyrp.util.removePopIn();
    var idp = window.google.identitytoolkit.easyrp.config.idps[idpId];
    if (idp) {
      self.startFederatedLogin_(idp.domain);
    }
  };
  this.page_.onCloseButtonClicked = function() {
    window.google.identitytoolkit.easyrp.util.removePopIn();
  };
  this.page_.onUseOtherEmailClicked = function() {
    window.google.identitytoolkit.easyrp.util.removePopIn();
  };
  var popin = window.google.identitytoolkit.easyrp.util.createPopIn();
  this.page_.render(popin);
  window.google.identitytoolkit.easyrp.util.showPopIn(
      window.google.identitytoolkit.easyrp.config.idpSelector.width,
      window.google.identitytoolkit.easyrp.config.idpSelector.height);
};

/**
 * Start the openId dance.
 * @param {Object} email the IDP domain.
 * @private
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    startFederatedLogin_ = function(email) {
  var popup = window.google.identitytoolkit.easyrp.util.showPopup(
      window.google.identitytoolkit.easyrp.config.popup.width,
      window.google.identitytoolkit.easyrp.config.popup.height);
  popup.document.write(window.google.identitytoolkit.easyrp.labels.loading);
  var self = this;
  var request = this.getRequestFactory().newCreateAuthUrlRequest(email);
  request.execute(function(response) {
    if ('error' in response) {
      var msg = window.google.identitytoolkit.easyrp.messages.ajaxFailed;
      popup.document.write(msg);
    } else if ('authUri' in response) {
      if (response.authUri.length < 2048) {
        popup.location.href = response.authUri;
      } else {
        window.google.identitytoolkit.easyrp.util.formRedirect(response.authUri,
            popup);
      }
    } else {
      var msg = window.google.identitytoolkit.easyrp.messages.unsupportedDomain;
      msg = msg.replace(/\%\%identifier\%\%/g, email);
      popup.document.write(msg);
    }
  });
};

/**
 * Handles the notification send by the popup window. This is a generic way for
 * the communication between the widget and the pop-up window.
 * @param {string} type The type of the notification.
 * @param {object} params The parameters with the notification.
 */
window.google.identitytoolkit.easyrp.importer.AttributeImporter.prototype.
    handleNotification = function(type, params) {
  if (type == 'verifyAssertionSuccess') {
    var response = this.apiHandler_.parseResponse(
        window.google.identitytoolkit.easyrp.net.RequestType.VERIFY_ASSERTION,
        params);
    this.callback_(response);
  }
};

/**
 * The shortcut to use the AttributeImporter. Note the start() method cannot
 * be called simultaneously.
 * <br>AttributeImporter cannot works together with other login widgets. See
 * the comments of below function.
 */
window.google.identitytoolkit.easyrp.AttributeImporter =
    new window.google.identitytoolkit.easyrp.importer.AttributeImporter();

/**
 * Forwards the callback from popup window to the attribute importer. Make sure
 * this method won't be overwirte by the default widget registry.
 * <br>As a result, window.google.identitytoolkit.easyrp.AttributeImporter
 * cannot works together with other login widgets.
 * @param {string} type The type of the notification.
 * @param {object} params The parameters with the notification.
 * @ignore
 */
window.google.identitytoolkit.easyrp.util.notifyWidget = function(type,
    params) {
  window.google.identitytoolkit.easyrp.AttributeImporter.
      handleNotification(type, params);
};
// Copyright 2011 Google Inc. All Rights Reserved.

/**
 * @fileoverview Changes Importer config.
 * @author liujin@google.com (Jin Liu)
 */

/**
 * Sets configuration parameter: nascar IDPs.
 * @param {string} value the parameter value.
 */
window.google.identitytoolkit.easyrp.config.setWidgetIdps = function(value) {
  window.google.identitytoolkit.easyrp.config.idpSelector.idps = value;
  window.google.identitytoolkit.easyrp.config.idpSelector.height =
      value.length * 50 + 220;
};

google.loader.loaded({"module":"identitytoolkit","version":"1.0","components":["importer"]});
google.loader.eval.identitytoolkit = function() {eval(arguments[0]);};if (google.loader.eval.scripts && google.loader.eval.scripts['identitytoolkit']) {(function() {var scripts = google.loader.eval.scripts['identitytoolkit'];for (var i = 0; i < scripts.length; i++) {google.loader.eval.identitytoolkit(scripts[i]);}})();google.loader.eval.scripts['identitytoolkit'] = null;}})();

// Specific for ITWorld
googleapis.setDeveloperKey(Drupal.settings.itw_gconnect.devkey);
var myIdps = Drupal.settings.itw_gconnect.idps;
window.google.identitytoolkit.easyrp.config.continueUrl = Drupal.settings.itw_gconnect.baseUrl+"/?q=git/callback";
window.google.identitytoolkit.easyrp.config.setConfig({
  idps: myIdps
});
