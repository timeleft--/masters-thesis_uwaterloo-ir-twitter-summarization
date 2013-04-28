if(typeof wpAds != 'undefined' && typeof wpAds.textlinks != 'undefined' && wpAds.textlinks.article_check()){
if(!render_google_ads){
	wpAds.textlinks.init('article','bottom',commercialNode);
}
else if(render_google_ads && typeof googleAds != 'undefined'){
	googleAds.execute(commercialNode,3,false);
}
}