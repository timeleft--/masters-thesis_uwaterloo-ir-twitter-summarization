/* import findPosition from /wp-srv/js/utilsStatic.js */

function article_fontSizer(size) {
	var article_body = document.getElementById('article_body');
	
	if (size == "small"){article_body.style.fontSize ="1.5em";}
	if (size == "medium"){article_body.style.fontSize ="2.0em";}
	if (size == "large"){article_body.style.fontSize ="2.5em";}
}
function saveExpando(type) {

	var wp_ie = navigator.appName.toLowerCase().indexOf("explorer") != -1;
	var saveArticle = document.getElementById('saveArticle');
	var shareExpando = document.getElementById('shareExpandBox');
	var saveSign = document.getElementById('saveSign');
	
	if(type =="show") {
		saveArticle.className = "saveDevelopBorder";
		shareExpando.className = "expand_on";
		document.saveIcon.src="http://www.washingtonpost.com/wp-srv/article/images/icon_save_grey.gif";
		saveSign.innerHTML = String.fromCharCode(187);	

		if ( wp_ie ) {
			shareExpando.style.top = "17px";
			shareExpando.style.left = "-214px";
		}		
	} else {
		saveArticle.className = "saveDevelop";
		shareExpando.className = "expand_off";
		document.saveIcon.src="http://www.washingtonpost.com/wp-srv/article/images/icon_save.gif";
		saveSign.innerHTML = "+";
	}
}
function saveExpando2(type){

	var saveArticle = document.getElementById('saveArticle');
	var shareExpando = document.getElementById('shareExpandBox');
	var saveSign = document.getElementById('saveSign');

	if(type =="show") {
		saveArticle.className = "saveDevelopBorder";
		shareExpando.className = "expand_on";
		document.saveIcon.src="http://www.washingtonpost.com/wp-srv/article/images/icon_save_grey.gif";
		saveSign.innerHTML = String.fromCharCode(187);

		shareExpando.style.position = 'absolute';
		shareExpando.style.left = findPosition('saveArticle').x+(saveArticle.offsetWidth-shareExpando.offsetWidth)+'px';
		shareExpando.style.top = findPosition('saveArticle').y+saveArticle.offsetHeight+'px';
	} else {
		saveArticle.className = "saveDevelop";
		shareExpando.className = "expand_off";
		document.saveIcon.src="http://www.washingtonpost.com/wp-srv/article/images/icon_save.gif";
		saveSign.innerHTML = "+";
	}
}
function changebg(id){
	document.getElementById(id).style.background = '#fff';
}
function resetbg(id){
	document.getElementById(id).style.background = '#EEE';
}