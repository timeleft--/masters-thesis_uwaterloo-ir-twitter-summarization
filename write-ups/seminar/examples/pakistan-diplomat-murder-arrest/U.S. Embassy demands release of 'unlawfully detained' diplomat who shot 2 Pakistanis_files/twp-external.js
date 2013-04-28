/*
* @version 1.0
* @author Stephanie Clark <clarks@washpost.com>
* $Changes: 2012-04 Initial version.  Writes appropriate css, js based on "isinternal" flag.
   
/*

/*** Set up environment variables */

TWP = window.TWP || {};
TWP.jsCacheBuster = "20121103231800";
TWP.cssCacheBuster = "20121103231800";

var TWPExt = window.TWPExt || {};

TWPExt.version = "v4";
TWPExt.url = window.location.href;
TWPExt.protocol = window.location.protocol;
TWPExt.server = TWPExt.server || window.location.href.match(/^.*?:\/\/.*?\//)[0];
TWPExt.debug = window.location.href.match("twpDebug=true") ? true : TWPExt.debug;
//set defaults
TWPExt.contextServer = 'http://js.washingtonpost.com';
TWPExt.contextServerSSL = 'https://ssl.washingtonpost.com';
TWPExt.contextServerCss = 'http://css.wpdigital.net'; //default for css
TWPExt.contextServerEidos = 'http://www.washingtonpost.com'; //default for Eidos files
TWPExt.contextServerOverrides = TWPExt.contextServerOverrides || {
    "http://localhost/":"http://localhost:8080",
    "sslprod":TWPExt.contextServerSSL,
    "digitalink.com":"http://glasstest.digitalink.com",
    "washpost.com":"http://glasstest.digitalink.com"
};
//reset based on current environment
TWPExt.contextServer = TWPExt.server.match("digitalink.com") ? TWPExt.contextServerOverrides["digitalink.com"]: TWPExt.contextServer;
TWPExt.contextServer = TWPExt.server.match("washpost.com") ? TWPExt.contextServerOverrides["washpost.com"]: TWPExt.contextServer;
TWPExt.contextServer = TWPExt.contextServerOverrides[TWPExt.server] ? TWPExt.contextServerOverrides[TWPExt.server] : TWPExt.contextServer;
if (TWPExt.protocol.toLowerCase() == "https:") {
    if (TWPExt.server.match("digitalink.com") ) {
            TWPExt.contextServer =  TWPExt.contextServer.toLowerCase().replace("http:","https:");
    } else {
            TWPExt.contextServer = TWPExt.contextServerOverrides["sslprod"];
    }        
}      
TWPExt.contextServer = window.location.href.match("twpContextServer=") ?  window.location.href.match(/twpContextServer=([^&]+)/)[1] : TWPExt.contextServer;


if(TWPExt.server.match("glassdev") || TWPExt.server.match("localhost")) {
	TWPExt.contextServerEidos = "http://devprev.digitalink.com";
} else if (TWPExt.server.match("glasstest")) {	
	TWPExt.contextServerEidos = "http://qaprev.digitalink.com";
} else if (TWPExt.server.match("glassstage")) {	
	TWPExt.contextServerEidos = "http://prodprev.digitalink.com";
} 		
TWPExt.eidosBase = (typeof TWP != 'undefined') && (typeof TWP.eidosBase != 'undefined') ? TWP.eidosBase : (window.eidosBase?window.eidosBase:TWPExt.contextServerEidos); //make sure eidosBase set
TWPExt.base = ((typeof TWP == 'undefined') || (typeof TWP.base == 'undefined') || TWP.base == '') ? TWPExt.contextServer:TWP.base;

//set ssl
TWPExt.base = (TWPExt.protocol.toLowerCase() == "https:")?TWPExt.contextServer:TWPExt.base;


TWPExt.loadjscssfile = function(filename, filetype){
 if (filetype=="js"){ //if filename is a external JavaScript file
  var fileref=document.createElement('script')
  fileref.setAttribute("type","text/javascript")
  fileref.setAttribute("src", filename)
 } else if (filetype=="css"){ //if filename is an external CSS file
  var fileref=document.createElement("link")
  fileref.setAttribute("rel", "stylesheet")
  fileref.setAttribute("type", "text/css")
  fileref.setAttribute("href", filename)
 }
 if (typeof fileref!="undefined")
  document.getElementsByTagName("head")[0].appendChild(fileref)
}



/***** Set up File list */
var cssFiles= {
	"v3": new Array(),
	"v4": new Array()
};

//v3
cssFiles.v3[0] = TWPExt.base  + "/wpost/css/combo?context=eidos&c=true&m=true&r=/external/twp-external-header.css&r=/external/twp-external-footer.css"
				+ "&token=" + TWP.cssCacheBuster;

//v4

cssFiles.v4[0] = TWPExt.base + "/wpost/css/combo?context=eidos&c=true&m=true&r=/2.0.0/external-header-base.css&r=/2.0.0/fonts.css&r=/2.0.0/header.css&r=/2.0.0/footer.css&r=/2.0.0/ads.css"
				+ "&token=" + TWP.cssCacheBuster;
				
var jsFiles= {
	"v3": new Array(),
	"v4": new Array() 
}


	//v3
	//NOTE: v3 uses the file below until production migration
	//jsFiles.v3[0] = (TWPExt.protocol.toLowerCase() == "https:"?TWPExt.contextServerSSL:"http://js.washingtonpost.com") + "/wpost/js/combo?context=wpost&m=true&c=false&r=/yui-base/3.3.0/build/yui/yui-min.js&r=/yui-base/3.3.0/build/loader/loader-min.js&r=/yui-base/eidos-modules/external-header.js&r=/yui-base/eidos-modules/external-footer.js&r=/yui-base/twp-yui/twp-yui.js&r=/yui-base/global/global-external-modules.js" 
	//			+ "&token=" + TWP.jsCacheBuster;
	
	//NOTE: v3 uses the file below AFTER production migration			
	jsFiles.v3[0] = TWPExt.base + "/wpost/js/combo?context=wpost&m=true&c=false&r=/yui-base/3.3.0/build/yui/yui-min.js&r=/yui-base/3.3.0/build/loader/loader-min.js&r=/yui-base/eidos-modules/external-header.js&r=/yui-base/eidos-modules/external-footer.js&r=/yui-base/twp-yui.js&r=/yui-base/global/global-external-modules-v3.js" 
				+ "&token=" + TWP.jsCacheBuster;
	
	if (typeof jQuery == "undefined"){
		jsFiles.v3[1] = TWPExt.base + "/wpost/js/combo?context=eidos&m=true&c=true&r=/jquery-1.4.noconflict.js"
					+ "&token=" + TWP.jsCacheBuster;			
	}
	
	//v4
	jsFiles.v4[0] = TWPExt.base + "/wpost/js/combo?context=wpost&m=true&c=false&r=/yui-base/3.3.0/build/yui/yui-min.js&r=/yui-base/3.3.0/build/loader/loader-min.js&r=/yui-base/eidos-modules/external-header-v4.js&r=/yui-base/eidos-modules/external-footer-v4.js&r=/yui-base/twp-yui/twp-yui.js&r=/yui-base/global/global-external-modules.js" 
				+ "&token=" + TWP.jsCacheBuster;		
	if (typeof jQuery == "undefined"){
		jsFiles.v4[1] = TWPExt.base + "/wpost/js/combo?context=eidos&m=true&c=true&r=/jquery-1.4.noconflict.js"
					+ "&token=" + TWP.jsCacheBuster;	
	}
	


/******End Set up*********/

//load inline files
for(key in cssFiles){
	  if (key == TWPExt.version) {
	  		for (i=0;i<cssFiles[key].length;i++) {
				TWPExt.loadjscssfile(cssFiles[TWPExt.version][i], "css");
			}	
	  }	
}
 

//load remaining files after doc ready	
if (document.addEventListener) {
	document.addEventListener("DOMContentLoaded", function(){
		for(key in jsFiles){
		  if (key == TWPExt.version) {
		  		for (i=0;i<jsFiles[key].length;i++) {
					TWPExt.loadjscssfile(jsFiles[TWPExt.version][i], "js");
				}	
		  }	
		}
	});	
} else { // older browser support. 
	/*removed check for document.onreadystatechange, as it was being overriden by LinkedIn.  Sigh.
	
	document.onreadystatechange= function(){
		if (document.readyState == "complete"){
			for(key in jsFiles){
			  if (key == TWPExt.version) {
			  		for (i=0;i<jsFiles[key].length;i++) {
						TWPExt.loadjscssfile(jsFiles[TWPExt.version][i], "js");
					}	
			  }	
			}
		}
	};
	*/
	for(key in jsFiles){
	  if (key == TWPExt.version) {
	  		for (i=0;i<jsFiles[key].length;i++) {
				document.write('<script type="text/javascript" src="' + jsFiles[TWPExt.version][i] + '"></script>');
			}	
	  }	
	}

}