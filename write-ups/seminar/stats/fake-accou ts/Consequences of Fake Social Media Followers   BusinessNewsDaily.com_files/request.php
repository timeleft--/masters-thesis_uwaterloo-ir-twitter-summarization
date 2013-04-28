
var country_code = 'CA';
var encoded_page_url = encodeURIComponent(document.location);
var encoded_sub_id = 'testsubid';var encoded_tag_path = 'tmn%2Fbnd';var app_url = 'http://api.toptenreviews.com/r/c';
var host_name = 'api.toptenreviews.com';
var browser = 'chrome';
var browser_version = '22.0.1229.94';
function createLoggableURL(destination_url) {
	var encoded_destination_url = encodeURIComponent(destination_url);

	return app_url+'/popuplog/logclick.php?link='+encoded_destination_url+'&sub_id='+encoded_sub_id+'&tag_path='+encoded_tag_path;
}

function createCookie(name,value,days) {
    var docurl=document.URL;
    if(docurl.indexOf(".toptenreviews.com")>0){
        var dmn = "; domain=.toptenreviews.com;";
    }
    else{
        var dmn = ";";
    }

    if (days) {
	    var date = new Date();
	    date.setTime(date.getTime()+(days*24*60*60*1000));
	    var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/"+dmn;
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
	    var c = ca[i];
	    while (c.charAt(0)==' ') c = c.substring(1,c.length);
	    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return "";
}

//Graybox stuff
document.write('<div id="reactor-gbox" style="position: absolute; left:0; top:0; opacity: 0.4; filter: alpha(opacity=40); background-color: black; z-index: 500;" onclick="reactorSmokeScreen(false);"></div>');

function popReactorGBox(display_gbox, display_ad){
    var boxname = 'popup-div';

    contbox=document.getElementById(boxname);
    var width = parseInt(contbox.style.width);
    var height = parseInt(contbox.style.height);

    if (typeof width == 'NaN')
    {
        width = 500;
    }

    if (typeof height == 'NaN')
    {
        height = 500;
    }

    leftscroll=(document.documentElement.scrollLeft) ?  document.documentElement.scrollLeft : document.body.scrollLeft;
    topscroll=(document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);

    browseheight=(window.innerHeight) ? window.innerHeight:document.documentElement.clientHeight;
    browsewidth=(window.innerWidth) ? window.innerWidth:document.documentElement.clientWidth;

    // if the browser is smaller than the window will be..
    height=(browseheight < height) ? browseheight:height;
    width=(browsewidth < width) ? browsewidth:width;

    browseheight=(browseheight < height) ? 0:browseheight;
    boxtop=(browseheight/2) + topscroll;
    boxtop=boxtop-(height/2);
    boxtop=(boxtop <=0) ? 0:boxtop;

    browsewidth=(browsewidth < width) ? 0:browsewidth;
    boxleft=(browsewidth/2) + leftscroll;
    boxleft=boxleft-(width/2);
    boxleft=(boxleft <= 0) ? 0:boxleft;

    contbox.style.top=boxtop + "px";
    contbox.style.left=boxleft + "px";
    contbox.style.height=height + "px";
    contbox.style.width=width + "px";

    if (display_ad)
    {
        var ad_box = document.getElementById('popup_object_ad');
        var ad_box_ifrm = document.getElementById('popup_object_ad_ifrm');
        if (ad_box_ifrm)
        {
            ad_box_ifrm.style.overflow = 'visible';
            ad_box_ifrm.style.border = '0';
            ad_box_ifrm.style.width = contbox.style.width;
            ad_box_ifrm.style.height = contbox.style.height;
        }

        ad_box.style.display = 'block';
    }

    if (display_gbox)
    {
        reactorSmokeScreen(true);
    }

    contbox.style.display = 'block';
}

function reactorSmokeScreen(on){
    var gbox = document.getElementById('reactor-gbox');
    var popup = document.getElementById('popup-div');
    var ad_box = document.getElementById('popup_object_ad');

    var topscroll=(document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
    if(on){
        // hide scroll bars
        windowscroll=document.getElementsByTagName('html')[0];
        windowscroll.style.overflow="hidden";
        document.documentElement.scrollTop=topscroll;

        gbox.style.width = '3000px';
        gbox.style.height = '2000px';
        gbox.style.display = 'block';

    }
    else{
        // put back the scrolls
        windowscroll=document.getElementsByTagName('html')[0];
        windowscroll.style.overflow="auto";
        // and for safari and chrome
        document.body.scrollTop += 1;
        document.body.scrollTop -= 1;
        document.documentElement.scrollTop=topscroll;

        gbox.style.display = 'none';
        popup.style.display = 'none';

        if (ad_box)
        {
            ad_box.style.display = 'none';
        }
    }
};
//End graybox functions

//Log Request
try{
    var ajaxImage = new Image();
    ajaxImage.src = app_url + '/popuplog/logrequest.php?sub_id=' + encoded_sub_id + '&path=' + encoded_tag_path + '&cb=' + (Math.random());
}
catch(e){}

//Write an invisible div to use as an access point for popups
document.write("<div id='popup-div' style='display: none; z-index: 999; position: absolute; top:0; left:0;'></div>");

//END JAVASCRIPT HEADER
//BEGIN SUBHEADER

//show popup after 3 seconds so page will have time to load
var popupDelay=setTimeout( function loadPopup(){

/*The popup_tags_array will hold a JSON object that represents each popup_tag's popup
associated with this tag request.  This is done so we can iterate through all
of the popups and choose which one to display, if any, based on cookie data (already shown? rule broken?) */
var popup_tags_array = new Array();

//Used to increment index of JavaScript array while looping through popup_tags in in ruby
var i = 0;
//The popup_tags have been sorted by priority in the controller

//END SUBHEADER
var popup_object = {};
popup_object.id = "reaction_285";
popup_object.js_code = function(){var p = document.getElementById('popup-div'); p.style.width = '640px'; p.style.height = '480px'; p.innerHTML = '<span style="width: 34px; height: 35px; position: absolute; display: inline-block; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'http://www.toptenreviews.com/i/rev/site/popup-close-button.png\', sizingMethod=\'scale\'); left:  625px; top: -15px; cursor: pointer;" onclick="reactorSmokeScreen(false);"><img style="border: 0; _display: none;" src="http://www.toptenreviews.com/i/rev/site/popup-close-button.png" /></span>'; var ad = document.getElementById('popup_object_ad'); ad.parentNode.removeChild(ad); p.appendChild(ad); p.style.border = 'solid black 2px'; p.style.backgroundColor = 'white'; p.style.zIndex = 100010;};
popup_object.display_gbox = 1;
popup_object.display_ad = true;
popup_object.cookie_expire = 30;
var rules_array = new Array();
var rules_counter = 0;
popup_object.rules = rules_array;
popup_tags_array[i] = popup_object;
i++;
//Now that we have an array containing all of this tag requests popup_tags popups, we can
//iterate through them and choose wich one to display based on cookie data and the results of
//rules that can only be determined on the client side (ie. browser version)
//NOTE: these have already been sorted by priority in the controller
var popup_tag = null;
popup_tags_loop:
for(var pt in popup_tags_array){

    //This was added because Joomlas MooTools was for some reason adding an extra null element to this
    if(popup_tags_array[pt].id == null){
        continue;
    }

    var already_shown = readCookie(popup_tags_array[pt].id);
    if(already_shown != '1'){

        //check each potential rule
        for(var pr in popup_tags_array[pt].rules){

            //This was added because Joomlas MooTools was for some reason adding an extra null element to this
            if(popup_tags_array[pt].rules[pr].rule_function == null){
                break;
            }

            //if any rules return false, move on to the next popup

            if(!popup_tags_array[pt].rules[pr].rule_function()){

                //create cookie so this wont be evaluated again
                //alert(popup_tags_array[pt].id);
                createCookie(popup_tags_array[pt].id,'1',popup_tags_array[pt].cookie_expire);

                //alert('rule broken!');
                //rule was broken, move on to the next tag

                continue popup_tags_loop;
            }
        }

        //All rules have passed and this popup has not been shown yet, so this tag will do.
        popup_tag = popup_tags_array[pt];

        //Create a cookie for this popup_tag so this tag request will not show another popup
        //on the clients machine during this session
        //alert(popup_tags_array[pt].id);
        createCookie(popup_tags_array[pt].id,'1',popup_tags_array[pt].cookie_expire);

        //We have a popup to show so exit the loop
        break;
    }
}

//If an appropriate popup was chosen based on rules, priority and cookie data, show it now
    //And send a request to the server to record this as a succefull impression
    if(popup_tag == null){
        //alert('NO popups to show');
    }
    else{
        //record this as an impression

        try{
            var ajaxImage = new Image();
            ajaxImage.src = app_url + '/popuplog/logimpression.php?sub_id=' + encoded_sub_id + '&path=' + encoded_tag_path + '&cb=' + (Math.random());
        }
        catch(e){

        }

        //Finally, show the popup
        popup_tag.js_code();

        if (popup_tag.display_gbox)
        {
            popReactorGBox(true, popup_tag.display_ad);
        }
    }

},1000);    //END OF INTERVAL
