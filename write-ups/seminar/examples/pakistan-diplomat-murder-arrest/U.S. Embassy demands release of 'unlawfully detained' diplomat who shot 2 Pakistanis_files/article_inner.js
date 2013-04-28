
if(!render_google_ads && typeof wpAds != 'undefined' && typeof wpAds.textlinks != 'undefined' && !location.href.match('no_ads') && document.getElementById('ad_links_inner')){
	wpAds.textlinks.init('article','inner',commercialNode);
	window.onload=checkForQuigoSizes;
}
else if(render_google_ads && typeof googleAds != 'undefined'){
	document.write('<link rel="stylesheet" type="text/css" href="http://www.washingtonpost.com/wp-adv/advertisers/google/textlinks/googleAds_styles.css"/>');
	googleAds.execute(commercialNode,2,false);
	window.onload=checkForQuigoSizes;
}