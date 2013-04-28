function place_site_metrix(file) {
	if ( typeof(s) =="undefined" || (typeof(s) != "undefined" && typeof(s.server) == "undefined")) {	
		var output = '<!--Tracking code --->';
		output += '<s\cript type="text/javascript" src="'+file+'"></s\cript>';
		output += '<!--Tracking code --->';
		
		if ( typeof(echoOmniture) == "undefined") {	
			output += '<s\cript type="text/javascript" src="http://media.washingtonpost.com/wp-srv/javascript/omniture/omniture-utils.js"></s\cript>';
		}
		output += '<s\cript>try{echoOmniture()}catch(e){};</s\cript>';
		
		if (location.protocol != "file:")
			document.write(output);
	}
}
function placeSiteMetrix() {
	place_site_metrix("http://www.washingtonpost.com/rw/sites/twpweb/js/wp_omniture.js");
}
function placeTestSiteMetrix() {
	place_site_metrix("http://qaprev.digitalink.com/rw/sites/twpweb/js/wp_omniture.js");
}