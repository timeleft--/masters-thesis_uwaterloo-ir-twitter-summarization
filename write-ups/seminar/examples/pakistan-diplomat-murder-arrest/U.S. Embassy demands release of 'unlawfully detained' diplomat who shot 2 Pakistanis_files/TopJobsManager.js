if (commercialNode && commercialNode !== '') { 
	if (!commercialNode.match('education') && !commercialNode.match('sports')) {
		/* Replaced with wapo labs platform
		document.write('<s\cript type="text/javascript" src="http://media.washingtonpost.com/wp-adv/topjobs2/top_jobs_v2.1.js"></s\cript>');
		*/
		document.write('<div id="wapoLabsPromoBox2"></div>');
	}
	if (commercialNode.match('education')) {
		document.write('<s\cript type="text/javascript" src="http://media.washingtonpost.com/wp-adv/topjobs2/top_edu_jobs.js"></s\cript>');
	} else if (commercialNode.match('sports')) {
		document.write('<div id="wapoLabsPromoBox3" style="margin-top:4px"></div>');	
	}
	/*if (commercialNode=='health' && (typeof urlCheck=='function' && urlCheck('/wp-dyn/content/health/')) && estNowWithYear<='201005092359'){
		placeAd('ARTICLE',commercialNode,43,'',true);
	}*/
}
