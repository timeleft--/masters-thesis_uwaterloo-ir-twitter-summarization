// BEGIN import rev. science segments
//if (document.domain != '')
//{	
	//document.write('<s\cript type="text/javascript" src="http://js.revsci.net/gateway/gw.js?csid=J05531"></s\cript>');
//}
// END import rev. science segments



function dateToString(date) {
var yyyy = date.getYear();
var mm = date.getMonth() + 1;
var dd = date.getDate();
var hour = date.getHours();
var min = date.getMinutes();

if (mm < 10) mm = "0"+mm;
if (dd < 10) dd = "0"+dd;
if (hour < 10) hour = "0"+hour;
if (min < 10) min = "0"+min;
return ''+mm+dd+hour+min;
}


function estOffset(dateObj){
	var mo = dateObj.getMonth()+1;
	if (mo < 3 || mo > 11) return 300;
	if (mo > 3 && mo < 11) return 240;
	
	var today = dateObj.getDate();
	var firstSunday = (today-dateObj.getDay())%7;
	if(firstSunday <= 0){
		firstSunday = firstSunday+7;
	}
	//firstSunday = the date of the first sunday in the current month

	if(mo==3){
		var secondSunday = firstSunday+7;
		return (today > secondSunday || (today == secondSunday && dateObj.getHours() >= 2))?240:300;
	}
	else{
		return (today > firstSunday || (today == firstSunday && dateObj.getHours() >= 2))?300:240;
	}
}

if(typeof estNow == 'undefined' || typeof estNowWithYear == 'undefined')
{
	var estNow = new Date();
	var estNowInMillis = estNow.getTime();
	var millisFromEST = (estNow.getTimezoneOffset() - estOffset(estNow)) * 60000;
	var estNow = new Date( estNowInMillis + millisFromEST )
	var estNowWithYear = estNow.getYear();
	var estNowWithYear = (estNowWithYear < 1900 )?estNowWithYear + 1900:estNowWithYear;
	estNowWithYear = estNowWithYear.toString() + dateToString(estNow).toString() ;
}

window.cNodeExists=function(){return typeof commercialNode!=="undefined" && commercialNode !== '' && commercialNode?commercialNode:false;}

//11092-MB-218518324,218518336,218518343
//12149-MB-order-id-4184799
//13138-MB-order-id-4407725
time_space = ((estNowWithYear <= '201012312359') || location.href.indexOf('all_ads') != -1)?true:false;


//hack for ie6 apple issue on leftcol
/*if(estNowWithYear < '200903042359' && navigator.userAgent.toLowerCase().match('msie 6'))
{
	document.write('<st' + 'yle>#container #top .lftcol {position:relative;top:-128px;left:-12px;}#container #Ttab-display {position:static}</st' + 'yle>')	
}*/

wpAds=(typeof wpAds!='undefined')?wpAds:{};

wpniSite = 'wpni';
wpniDomain = 'washingtonpost.com';

function trimAll(sString,toTrim) 
		{
			if(typeof sString == 'undefined' || !sString) return '';
			
			while (sString.substring(0,1) == toTrim)
			{
				sString = sString.substring(1, sString.length);
			}
			while (sString.substring(sString.length-1, sString.length) == toTrim)
			{
				sString = sString.substring(0,sString.length-1);
			}
			return sString;
		}
		
function pageId()
		{
			var pageIdStringRoot = (typeof pageIdRoot != 'undefined')?pageIdRoot:wpniSite;
			if(typeof this.returnValue=='undefined')
			{
				this.pIdReturnValue = location.href.split('?')[0];
				this.pIdReturnValue = this.pIdReturnValue.split(';')[0];
				
				if(this.pIdReturnValue.lastIndexOf('.') > this.pIdReturnValue.lastIndexOf('/'))
				{
					this.pIdReturnValue = this.pIdReturnValue.substring(0,this.pIdReturnValue.lastIndexOf('.'))
				}
				if(this.pIdReturnValue.lastIndexOf('index') > this.pIdReturnValue.lastIndexOf('/') || this.pIdReturnValue.lastIndexOf('default') > this.pIdReturnValue.lastIndexOf('/'))
				{
					this.pIdReturnValue = this.pIdReturnValue.substring(0,this.pIdReturnValue.lastIndexOf('/'))
				}
				//take off domain name and protocol declaration
				this.pIdReturnValue = this.pIdReturnValue.split(document.domain)[1]
				//trim slashes from start and end
				this.pIdReturnValue=trimAll(this.pIdReturnValue,'/')
				this.pIdReturnValue=this.pIdReturnValue.replace(/[\/\.]/gi,'-')

				//strip out any hash or plus characters
				this.pIdReturnValue=this.pIdReturnValue.replace(/#|\+/gi,'')
				
				if(this.pIdReturnValue=='')
				{
					this.pIdReturnValue = pageIdStringRoot
				}
			}
			return 'pageId=' + pageIdStringRoot + '-' + this.pIdReturnValue + ';'
		}
		
function getCookie(name) {
	var cookie = " " + document.cookie;
	var search = " " + name + "=";
	var setStr = null;
	var offset = 0;
	var end = 0;
	if (cookie.length > 0) {
		offset = cookie.indexOf(search);
		if (offset != -1) {
			offset += search.length;
			end = cookie.indexOf(";", offset)
			if (end == -1) {
				end = cookie.length;
			}
			setStr = unescape(cookie.substring(offset, end));
		}
	}
	return(setStr);
}

var adOpsLocalFlag = (getCookie('WPATC') && getCookie('WPATC').match('C=1:'))?true:false;


function aptco()
{
	/*var a = getQSValue('aptco');
	var b = getQSValue('metro');*/
	var a = urlCheck('aptco',{'type':'variable'});
	var b = urlCheck('metro',{'type':'variable'});
	if(a && b)
	{
		return 'aptco=' + a + ';metro=' + b + ';';
	} 
	return '';
}

wpAds.metaCheck = function(arg,kv){
	if(document.getElementsByTagName('meta')){
		var a = document.getElementsByTagName('meta'),i=a.length,b;
		while(i--){
			if(a[i].name && (a[i].name == 'description' || a[i].name == 'keywords') && a[i].getAttribute('content')){
				b = a[i].getAttribute('content').toLowerCase();
				var c=arg.length;
				while(c--){
					if(b.match(arg[c])){
					return '!c='+kv+';';
					}
				}
			}
		}
	}
	return '';
}
wpAds.disaster_kv = wpAds.metaCheck(['plane crash','air travel','explosion','oil','war','hostage','terror','bomb','blast','mining','miner','coal','china','palin','wikileaks'],'disaster');

function mediaPage()
{
	
	if( (  typeof thisNode != 'undefined' && thisNode.match(/media|photo|video/) || typeof commercialNode != 'undefined' && commercialNode.match(/media|photo|video/) ) || location.href.match(/video|gallery|scene-in|mobile/) )
	{
		
		return '!c=media;'
	}
	return '';
}

function print_kv()
{
	return (urlCheck('_pf.htm'))?'print=y;':'';
}

function adopsDebugToggle()
{
	var toggleButton = document.getElementById('adopsDebugToggle');
	var adopsDebugDiv = document.getElementById('adopsDebugDiv');
	adopsDebugDiv.style.display = (toggleButton.innerHTML == 'Show Data')?'block':'none';
	toggleButton.innerHTML = (toggleButton.innerHTML == 'Show Data')?'Hide Data':'Show Data';
	
}

function beta_kv()
{
	return(typeof commercialNode != 'undefined' && commercialNode=='washingtonpost.com')?'beta=n;':'';	
}

function adopsDebug(_str)
{
	if(!location.href.match('debugAdCode') && !location.href.match('adopsDebug') && !location.href.match('allAds')) return;
						   
	if(!document.getElementById('adopsDebugDiv'))
	{
		debugDiv = document.createElement('DIV');
		debugDiv.style.fontSize = '9px';
		debugDiv.style.textAlign = 'left';
		debugDiv.style.fontFamily = 'verdana,arial,helvetica';
		debugDiv.style.padding = "10px";
		debugDiv.style.marginBottom = "10px";
		debugDiv.style.borderBottom = "1px solid #a8a1a1";
		debugDiv.style.backgroundColor= "#e1e1e8";
		debugDiv.innerHTML = "<p style='margin:0px 0px 5px 0px;padding:0px;font-size:14px;color:#272127'>WPNI AdOps Debug Info&nbsp;<a href='javascript:adopsDebugToggle()' style='font-weight:bold;font-size:10px' id='adopsDebugToggle'>Show Data</a></p>"
		debugDivContent = document.createElement('DIV');
		debugDivContent.setAttribute('id','adopsDebugDiv');
		debugDivContent.style.display = "none";
		debugDiv.appendChild(debugDivContent);
		document.body.insertBefore(debugDiv, document.body.firstChild);
	}
	document.getElementById('adopsDebugDiv').innerHTML += _str;
}


function urlCheck( arg )
{
	
	var loc = '';
	
	try{
		loc = parent.window.location.href;
	}catch(e){
		loc = document.referrer
	}
	
	if(arguments[1] && typeof arguments[1]=='object')
	{
		var obj = arguments[1];
		var regex = (obj.type=='variable') ? new RegExp( "[\\?&;]"+arg+"=([^&#?]*)" ) : new RegExp( arg ) ;
	}
	else
	{
		var regex = new RegExp(arg);
	}
	var results = regex.exec( loc ) ;
	return (results==null)?null:results[results.length-1];

}

function socialMediaSite(){
	var dReferrer=(document.referrer!='')?document.referrer:false;
	var smSites=['facebook.com','digg.com','reddit.com','myspace.com','newstrust.net','twitter.com','delicious.com','stumbleupon.com'];
	var smCount=smSites.length;
	if(dReferrer){
		for(var a=0;a<smCount;a++){
			if(dReferrer.match(smSites[a])){
				return 'social=y;'
			}
		}
	}
	return ''
}

function debugIframeAds()
{

	if(document.getElementsByTagName('iframe'))
	{
		var iframe = document.getElementsByTagName('iframe');
		var num_of_iframes = document.getElementsByTagName('iframe').length;
		for(var i=0;i<num_of_iframes;i++)
		{
			if(iframe[i].src.match('http://ad.doubleclick.net/adi/wpni') && !iframe[i].src.match('inlinead'))
			{
				var b = document.createElement('DIV');
				var c = document.createElement('DIV');
				c.style.margin = '5px' ;
				c.innerHTML = iframe[i].src + '&nbsp;<a href="'+iframe[i].src+'" target="_blank">[&#187;]</a>';
				b.appendChild(c);
				
				var bStyleArray = { overflow : 'scroll', backgroundColor : '#FFAA00', color : '#770000', width : '300px' };
				
				for(j in bStyleArray)
				{
					b.style[j] = bStyleArray[j];
				}

				iframe[i].parentNode.insertBefore(b,iframe[i]);
			}
		}
	}

}

if(document.location.href.match('debugAdCode'))
{
	addLoadEvent(debugIframeAds)
}


//start of demo ad code
if( urlCheck('demoAds',{'type':'variable'}) )
{	
	demo_ads_qs_val = urlCheck('demoAds',{'type':'variable'});
	
	commercialNode = 'test';
	
	adTemplate = 0;
	var demoAdTypes = ['banner_flex_top','banner_flex_bottom','sky_left','sky_right','bigbox_flex','big_flex_right','ad_links_right','ad_links_bottom','textlinks','vm','sponsorship','tile_left','tile_right','tile_right_top','tile_right_top2','top_jobs','google_links','tile_right','tile_bottom','traffic_tile','big_box']
	var demoQS = demo_ads_qs_val.toLowerCase().split(';')
	
	for(var a = 0; demoQS[a]; a++)
	{
		for(var b = 0; demoAdTypes[b]; b++)
		{
			if(demoQS[a] == demoAdTypes[b])
			{		
				adTemplate += 1 << b;	
			}
		}
	}
}
//end of demo ad code


function dcNodeOverride()
{
	if(urlCheck('dcnode='))
	{
		var theUrl = urlCheck('dcnode',{'type':'variable'});
	}
	return (typeof theUrl != 'undefined' && theUrl!='')?theUrl:'test';
}



function getQSValue( name )
{
	  var locString=(arguments[1])?arguments[1]:window.location.href;
//first test to see if the qs variable at all. if not, return null.
  var regex = new RegExp( "[\\?&;]"+name );
  var results = regex.exec( locString );
  if(!results) return null;
//ok, it's there. get the value.

  var regex = new RegExp( "[\\?&;]"+name+"=([^&#]*)" );
  var results = regex.exec( locString );
  return (results==null)?"":results[1]
}




function doubleClickTestCode()
{
	if(typeof this.dctCodeValue == 'undefined')
	{
		this.dctCodeValue = '';
		//var queryResult = getQSValue('test_ads');
		var queryResult = urlCheck('test_ads',{'type':'variable'});
	
		if(queryResult != null)
		{
			this.dctCodeValue = 'kw=test_' + ((queryResult!='')?queryResult:'ads') + ';';	
		}
	}
	return this.dctCodeValue
}

//hack for JF ads
	
	if (location.href.indexOf('politicalads') != -1) {thisNode = 'politics'; commercialNode='politics'}
	
function getQueryVariable(variable)
{ 
	
	var query = location.href.split('?')[1]; 
	if(!query)
	{
		return null
	}
	var vars = query.split("&");
	for (var i=0;i<vars.length;i++)
	{ 
		var pair = vars[i].split("="); 
		if (pair[0] == variable)
		{ 
			
			return pair[1]; 
		} 
	}
	return null
} 



var contComments = "";

if(location.href.match('content/article') && location.href.match('_comments.html'))
{
	contComments = "category!=comments";
}

if(location.href.match('AR2008053003121'))
{
	contComments = "!category=northrop;";
}

if(location.href.match('jobs/home'))
{
	commercialNode = 'jobs/front';
}


function realEstateAreaId()
    {
    	if(typeof this.returnREAIValue == 'undefined')
    	{
    		this.returnREAIValue = '';
	   		if(getQueryVariable('areaId'))
    		{
    			this.returnREAIValue = 'areaId=' + getQueryVariable('areaId') + ";"
    		}
    		if(typeof hs != 'undefined' && typeof hs.geo_area_id != 'undefined')
    		{
    			geo_area_id_array = hs.geo_area_id.split(';');
    			for(var x =0; x < geo_area_id_array.length; x++)
    			{
    				if(typeof geo_area_id_array[x] == 'string')
					{
						this.returnREAIValue += 'areaId=' + geo_area_id_array[x] + ';'
					}
    			}
    		}
    	}
    	return this.returnREAIValue
    }

function popUnders()
{
	//these two variables control everything	
	maxPer24 = 5;
	minutesBetween = 2;
	//end
	minuteInMillis = 60000;
	dayInMillis = 86400000;
	rightNow = new Date();
	rightNowNum = parseInt(rightNow.getTime());
	rightNowPlusDay = rightNowNum + dayInMillis;
	rightNowPlusMonth = rightNowNum + (dayInMillis * 28);
	//rightNowPlusYear = rightNowNum + (dayInMillis * 365);
	rightNowPlusDayString = new Date(rightNowPlusDay);
	rightNowPlusMonthString = new Date(rightNowPlusMonth);
	//rightNowPlusYearString = new Date(rightNowPlusYear);

	popUnderRetValue = ''
		
	if (getCookie('popUnderAds'))
	{	
		cookieString=getCookie('popUnderAds');
		
		cookieArray=cookieString.split('/');

		newCookieArray = new Array();
		newCookieArrayIndex = 0;	
		
		for(var x=1;x<cookieArray.length+1;x++)
		{	var z = parseInt(rightNowNum) - parseInt(cookieArray[x]);
			if(z < dayInMillis)
			{	
				newCookieArray[newCookieArrayIndex] = cookieArray[x];
				newCookieArrayIndex++;
				testOutputDate = new Date(parseInt(cookieArray[x]));
			}
		}
		
		
		var underDailyLimit = newCookieArray.length < maxPer24;
		var enufTimeSinceLast = rightNowNum - parseInt(newCookieArray[newCookieArray.length-1]) > (minutesBetween * minuteInMillis);
		var noPopOnLastPage=cookieString.match('popOnLast=false/');
		newCookieString = "popOnLast=false/";
		
		if((underDailyLimit && noPopOnLastPage && enufTimeSinceLast) || newCookieArray.length == 0)
		{
			popUnderRetValue = 'ad=pop;';
			newCookieArray.push(rightNowNum);
			newCookieString = "popOnLast=true/";
		}
		else
		{
			
		}
	
		
		for(var x=0;x<newCookieArray.length;x++)
		{
			newCookieString += newCookieArray[x] + '/';
		}
		
		newCookieString = newCookieString.substring(0,newCookieString.length-1);
		setCookie('popUnderAds',''+newCookieString+'',''+rightNowPlusMonthString.toString()+'','/','.washingtonpost.com','');

	}
	else
	{	
		//make sure you can write a cookie at all
		setCookie('popUnderAds','*',''+rightNowPlusMonthString.toString()+'','/','.washingtonpost.com','');
		if(!getCookie('popUnderAds'))
		{
			return '';
		}
		//if so, proceed
		
		setCookie('popUnderAds','popOnLast=true/'+rightNowNum+'',''+rightNowPlusMonthString.toString()+'','/','.washingtonpost.com','');
		popUnderRetValue='ad=pop;'
	}
	return popUnderRetValue;
}

function isAnyOfTheseInTheUrl()
{
	var returnValue = false;
		for(var x=0;x<arguments.length;x++)
		{
			if(location.href.match(arguments[x]))
			{
				returnValue = true;
			}
		}
	return returnValue;
}

(function () {
	var a = 'wp_pageview', b = getCookie(a), c = true, d = new Date(parseInt(new Date().getTime()) + 432E5).toString();
	if (b && b !== '') {
		c = (Number(b)/3).toString().match(/\./) ? false:true;
		setCookie(a, Number(b) + 1, d, '/', 'washingtonpost.com');
	} else {
		setCookie(a, '1', d, '/', 'washingtonpost.com');
	}
	window['canHaveInterstitial'] = c;
}())

function new_interstitial(dir) {
	if(!document.cookie || document.cookie===''){
		return '';	
	}
	var a = location.href.match('force_interstitials'), b = !isAnyOfTheseInTheUrl('no_interstitials', 'reload=true'), c = canHaveInterstitial, d = cNodeExists() === 'admin/errorpage', e = typeof this.returnVal === 'undefined';
	if(e){this.returnVal=true};
	return (a || b) && c && !d && e ? "ad=interstitial;":'';
}

function interstitials(dir){
	if (!(dir.execute && dir.dfp_server === 'adj')) return '';
	if (cNodeExists() === 'admin/errorpage') return '';
	if (urlCheck("force_interstitials") || (typeof wpniAds.noIntrusive==="undefined" && typeof this.intReturnValue === "undefined" && !isAnyOfTheseInTheUrl("no_interstitials","g=0"))) {
		popUnderVal = (!isAnyOfTheseInTheUrl('g=1','g=0','o=','sid=','reload=true')) ? popUnders():'';
		this.intReturnValue = "dcopt=ist;" + popUnderVal;
	} else {
		this.intReturnValue = '';
	}
	return this.intReturnValue;
}

function wp_page_kv(node){
	var page = '', ary = [];
	if ( node.indexOf("/") != -1 )
		ary = node.split("/") ;
	else
		ary[0] = node ;
	
	for(var i=0; i<ary.length; i++)
	{
		if ( i == 0 &&
			ary[i].indexOf("article") != -1 &&
			ary[i].indexOf("article") == ary[i].length - "article".length &&
			ary[i] != "article" )
		{
			ary[i] = ary[i].substring(0,ary[i].indexOf("article")) ;
			page = "page=article;" ;
		}
	}
	return page;
}



function getCookie(name) {
	var cookie = " " + document.cookie;
	var search = " " + name + "=";
	var setStr = null;
	var offset = 0;
	var end = 0;
	if (cookie.length > 0) {
		offset = cookie.indexOf(search);
		if (offset != -1) {
			offset += search.length;
			end = cookie.indexOf(";", offset)
			if (end == -1) {
				end = cookie.length;
			}
			setStr = unescape(cookie.substring(offset, end));
		}
	}
	return(setStr);
}

function setCookie (name, value, expires, path, domain, secure) {
      document.cookie = name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

var debugAdCode = false;
var show_doubleclick_ad = true ;
if (document.domain == 'www.shoplocal.com') thisNode = 'shoplocal';
if (location.href.indexOf("debugAdCode")+1) debugAdCode = true ;
show_doubleclick_ad = (location.href.match('no_ads'))?false:true
if (typeof thisNode == 'undefined') thisNode = (typeof adNode != 'undefined')?adNode:'technology';
if (typeof commercialNode == 'undefined' || commercialNode == 'one') commercialNode = (typeof thisNode != 'undefined' && thisNode != 'one')?thisNode:'technology';

//hack to disable acura ads from moveabletype preview window
function parentFrame()
{
try
  {
  	if(window.parent.location.href.match('http://voices.washingtonpost.com/cgi-bin/mt/mt.cgi') && estNowWithYear <= "200901112359")
	{
		show_doubleclick_ad = false;
	}
  }
catch(err){}
}
parentFrame();



var _rs  = ''; // revenue science data
var _poe = ''; // point of entry
var _tc = 'tile'; // tiling category
var _cn = ''; // commercial node
var _an = false; // ad node
var _t = '';
var urlLoc = new String(document.location.href);



(typeof thisNode != 'undefined')?_tn = thisNode:null;


blu = (typeof blu_name != 'undefined')?true:false;


if (typeof commercialNode != 'undefined' && commercialNode != '') {

_cn = 'cn=yes;pnode='+thisNode.split("/")[0]+';';
_an = true;


}
var static_wpatc = getWPATCookie();

// changed on first call to placeAd
var firstTimeCalled = true ;
var firstTimeCalledNew = true ;
var adUniqueNumber = (typeof spec_ord != 'undefined')?spec_ord:Math.floor(Math.random() * 1000000000000000000);


var newsAncestorAsString = new String("") ;

// changed on first call to placeAd or when assertive is true
var adAncestor = new String() ;
var adNode = new String() ;
var adSite = new String() ;
var adZone = new String() ;
var adSiteZone = new String() ;
var adDir = new String() ;
var adArgs = 0 ;

function tileNum()
{
	this.tnReturnValue = (typeof this.tnReturnValue != 'undefined')?this.tnReturnValue+1:1;
	return this.tnReturnValue
}

var wp_quantcast = {
    exec : function (j) {
        document.write('<scr' + 'ipt src="http://pixel.quantserve.com/seg/' + j + '.js" type="text/javascript"></scr'+'ipt>');
        wp_quantcast._quantsegs();
    },
    _quantgc:function(n){
        var c=document.cookie;if(!c)return '';
        var i = c.indexOf(n + "="); if(-1 == i) return '';
        var len = i + n.length + 1;
        var end = c.indexOf(";",len);
        return c.substring(len, end < 0 ? c.length:end);
    },
    _quantsegs:function(){
        quantSegs = "";
        var _qsegs = wp_quantcast._quantgc('__qseg').split('|');
        for(var i=0;i<_qsegs.length;i++){
        var qArr=_qsegs[i].split("_")
        if (qArr.length>1) { quantSegs += ("qcseg=" + qArr[1] + ";"); }
        }
    },
    init : function () {
        return (typeof quantSegs != 'undefined' && quantSegs !== '') ? quantSegs:'';
    }
}
//12780-JB
wp_quantcast.exec('p-5cYn7dCzvaeyA');


function revSci()
{
	if ( typeof getCookie == 'undefined' || !getCookie('rsi_segs') || getCookie('rsi_segs') == '' ) return '';
	var rs_arr = getCookie('rsi_segs').split('|');
	var rs = '';
	for(var i=0;i<rs_arr.length;i++)
	{
		rs += "rs="+rs_arr[i].replace("J05531_","j")+";"
	}
	return rs;
}

function spotCanceller(tileNum)
{
 return (location.href.match('no_spot'+tileNum))?true:false;
}


		function locExpSponsor(){
			if (typeof countyName != 'undefined' && typeof stateName != 'undefined')
			{
				var invalidKW = ['?','=','/','\\',':',';',',','*','(',')','&','$','%','@','!','^','+',' ','[',']','{','}','.'];
				for (var i=0;i<invalidKW.length;i++)
				{
					csRE = new RegExp('(\\' + invalidKW[i] + ')', 'g');
					countyName = countyName.replace(csRE,"").toLowerCase();
					stateName = stateName.replace(csRE,"").toLowerCase();
				}
				locExpKV = "lexp_spon=" + countyName + "-" + stateName + ";";
			}
			else 
			{
				locExpKV = '';
			}
			return locExpKV
		}


function charToCodeAt(str)
{
	var new_str = '';
	var str_length = str.length;
	for(var j=0;j<str_length;j++)
	{	
		new_str += (str.charAt(j).match(/[^a-zA-Z0-9]/gi)) ? '_' + str.charCodeAt(j).toString(16) : str.charAt(j) ;
	}

	return new_str
}

//10327-RZ
function user_id_kv()
{
		var ovalue = ( getCookie('s_vi') ) ? 'o*' + getCookie('s_vi') : '' ;
		return ( getCookie('s_vi') )? 'u=' + charToCodeAt( ovalue ) + ';' : '' ;
}

function orbitFlag()
{
	if (document.location.href.match('/wp-dyn/'))
	{
		return 'orbit=y;'
	}
	return '';
}


function innovations_kv()
{
	var a = urlCheck('ad',{'type':'variable'});
	if(a && a=='inw'){
		return 'inw=y;';
	}
	if(a && a=='ins'){
		return 'ins=y;';
	}
	return '';
}


function placeAd(layer,node,kw,pos,dir,w,h,tile)
{
	
	if (location.href.match('no_ads')){ return }
	
	if(location.href.match('demoAds')){ node = dcNodeOverride() }
	
	if(spotCanceller(arguments[2])) return;
								
	if (typeof node == 'undefined' || node == 'one') node = (typeof thisNode != 'undefined' && thisNode != 'one')?thisNode:'technology';
	
	// 'Date Lab' & 'Making It' article hacks
	if (typeof wp_headline != 'undefined' && wp_headline == 'Making It'){ node = 'smallbiz/makingit' }
	if (typeof wp_headline != 'undefined' && wp_headline.match('Date Lab')){ node = 'artsandliving/datelab' }

	// 'The Fix' politics blog
	if (document.location.href.match('thefix') && node == 'politics/fedpage') { node = 'politics/fedpage/thefix' }

	// 'Government Inc' business blog
	if (document.location.href.match('government-inc') && node == 'business') { node = 'business/govinc' }
	
	//11503-MB-order_id-3935012
	if(urlCheck('/house-divided/')){ node = 'metro/blog/housedivided'; }
	
	// 'Opinions Leaders' blog
	var opLead = new Array('benchconference','capitol-briefing','sleuth');
	var opNode = new Array('opinion/columns/blogs','politics/fedpage')
	
	for(var op=0;op<opLead.length;op++){
		for(var opN = 0; opN < opNode.length; opN++)
		if (document.location.href.match(opLead[op]) && node == opNode[opN]) { node = opNode[opN]+'/opleaders' }
	}
	
	// Fed Diary blog
	if (thisNode.match('feddiary/fedpage')) { node += '/feddiary' }
	
	// 4253-JM-DC Sports blog
	if (thisNode.match('sports') && location.href.match('dcsportsbog')) { node += '/dcsportsbog' }
	
	// 4253-LY-194532589
	if (thisNode.match('artsandliving/travel') && location.href.match('travellog')) { node += '/travellog' }
	
	// 4398-MW-blog.washingtonpost.com/the-talk/
	if (node.match('politics/fedpage') && location.href.match('the-talk')) { node += '/thetalk' }
	

    //node+=(node=='washingtonpost.com')? ( '/hp' + ( ( location.href.match('reload=true') )? 'refresh' : '') ) :'';
	//Homepage commercialNode refresh zone
	node+=(((node=='washingtonpost.com/hpflex' || node=='washingtonpost.com/bb') && location.href.match('reload=true') )? 'refresh' : '');

		
	if (show_doubleclick_ad)
	{
	
		if (thisNode == 'opinion/columns/politics/feddiary') {node = 'opinion/politics/feddiary'}
	


		heavy="heavy=n;"

		if (typeof document.referrer != "undefined")
		{
			if (document.referrer == '') 
			{	
				heavy="heavy=y;"
				setCookie('heavy','y',''+wpniPOE.toString()+'','/','.washingtonpost.com','')
			}
		else
			{
				heavy="heavy=y;"
				setCookie('heavy','y',''+wpniPOE.toString()+'','/','.washingtonpost.com','')
			}
		}

		// This is a temporary hack for Fantasy Jobs ( Chris Stith: added 7/20/2006 ) 
		agent = navigator.userAgent.toLowerCase();
		if ((agent.indexOf('firefox') != -1 || agent.indexOf('safari') != -1) && node == 'sports/fantasyjob' && kw == 4)
		{ document.write('<div style="position:absolute;top:353;padding-left:45;">')}


			
  		if (node.indexOf("/") == -1) node += "/" ;
		var na = [arguments[0],arguments[1],arguments[2],arguments[3],arguments[4]] ;
    	adArgs = 5 ;
    	platform = na[0] ;
    	//if (_an) {node = cleanNode(commercialNode)}
		//else node = cleanNode(na[1]) ;
		node = cleanNode(na[1]) ;
	
		if (location.href.indexOf('http://www.uclick.com/client/wpc/wpdoc/') != -1)
		{
			node = 'artsandliving/crosswords/sudoku'
		}


		if (node.indexOf("media") == 0 || node.indexOf("gallery") >= 0) node = 'photo';

		//temp fix for email-friend problem
		if (node == '') node = 'technology';
		//temp fix for contentconversion
		if (node == 'contentconversion') node = 'nation';
		//temp fix for uncategorized
		if (node == 'uncategorized') node = 'technology';
		if (node == 'high schools') node = 'technology';
		if (node == 'wizards') node = 'technology';
		if (node == 'search/newssearch' && location.href.match("adv")) node = 'search/newsadvanced';

		tile = na[2].toString() ;
		kw = na[3];
		flexdisplay = na[4] ;
		
		pos = setPosition(tile);
		
		//turned off for multiple size switch 6/18/07
		//w = setWidth(tile); h = setHeight(tile); f = setFlexvalue(tile);

		// Fantasy Football one-off for Nissan
		oo_url = document.location.href;
		if (oo_url.indexOf("LI2005042101450") != -1) kw= 'kw=cruise;'; 
		if (oo_url.indexOf("DI2005083101900") != -1) kw= 'kw=redskins;'; 
		if (oo_url.indexOf("test_ads") != -1) kw += 'kw=wpni_test;';
		if (oo_url.indexOf("smallbusiness101") != -1) kw = 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005100501552") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005100500899") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005110101296") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005102001378") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005103101365") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005102602804") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("DI2005101100729") != -1) kw= 'kw=smallbus101;';
		if (oo_url.indexOf("welcome_to_post.html") != -1) kw = 'kw=remix;';
		if (oo_url.indexOf("GA2006021301885_metaRefresher.htm") != -1) kw = 'kw=olympics;'
		if (oo_url.indexOf("/wp-srv/sports/interactives/olympics06/") != -1) kw = 'kw=olympics;'
		if (oo_url.indexOf("AR2005040701359") != -1) kw = 'kw=montgomery;';
		if (oo_url.indexOf("cherryblossom/06/") != -1) kw = 'kw=cherryblossom;';
		if (oo_url.indexOf("onbalance") != -1) kw = 'kw=onbalance;';
		if (tile == 10){kw = 'kw=shermans;';};
	
	
		/* //9514-RZ //Nullified per 9897-MB
		if(location.href.match('emailafriend') || location.href.match('emailalink'))
		{
			kw += "kw=emailconf;";
		}
		*/
	
		if (kw.indexOf(';') == -1 && kw.length > 0)
		{
			kw = kw + ';'
		}


    	if ( firstTimeCalledNew )
		{
	  		adAncestor = getAdAncestor(node) ;
		 	adSite = getAdSite(adAncestor) ;
		  	adNode = getAdNode(node,adAncestor) ;
			adZone = getAdZone(adNode) ;
	  		adDir = getAdDir(node) ;
	  		firstTimeCalledNew = true;

			if (adZone)
	  			adSiteZone = adSite + "/" + adZone ;
			else
	  			adSiteZone = adSite ;
	  	}
		
		


		//this is where the old interstitial routine went--is backed up in oldinterstitial.js
	
		//turned off for multiple size swith 6/18/07
		//(flexdisplay)?adSize = "":adSize = 'sz='+w+'x'+h+';';

		passArticle = (platform.toLowerCase().indexOf("article") != -1)?'article':'';
		page_a = (passArticle.indexOf("article") != -1)?'page=article;front=n;':'page=section;front=y;';
		//if (passArticle != 'article' ) page_a = 'page=section;front=y;'
		//&& commercialNode.split("/").length == 1
		if (typeof v2 != 'undefined')
		{
			if ( typeof adTemplate != 'undefined' && (( adTemplate & BANNER_FLEX_TOP ) == BANNER_FLEX_TOP && ( adTemplate & BIG_FLEX_RIGHT ) == BIG_FLEX_RIGHT) ) _t = (tile == 1)?'t=y;':'';
		}
	

		
		dtile = (typeof dfpcomp == 'undefined')?'':"dfpcomp="+dfpcomp+";";


		var exempt = "";
		if (thisNode == 'nation' || thisNode.indexOf("nation/special") != -1)
		{
			exempt = "!category=supremecourt;";
		}
		//8095-obits,8341-homepage
		if ((tile == 20 && location.href.match('/article/')) || commercialNode.match('obituaries') || commercialNode.match('washingtonpost.com'))
		{
			exempt += "!c=intrusive;";
		}
		
		//9456-MB
		if(typeof commercialNode != 'undefined' && commercialNode.match('timespace'))
		{
			exempt += "!c=intrusive;";
		}
		
		//9514-RZ
		if(location.href.match('emailafriend') || location.href.match('emailalink'))
		{
			exempt += "!c=intrusive;";
		}
		
		if(location.href.match('content/article') && (location.href.match('_Comments.html') || location.href.match('_comments.html')))
		{
			exempt += "!c=comments;";
		}
		
		//MB-05:11:09:05:50
		if(tile == 1 && location.href.match('http://www.washingtonpost.com/wp-dyn/content/article/2009/05/10/AR2009051002045') && commercialNode.match('metro/va'))
		{
			exempt += "!c=intrusive;";
		}
	
		//MB-13311,AK-13429,ST-13668
		//if(urlCheck('/article/') || urlCheck('/gallery/')){
		exempt += wpAds.disaster_kv;
		//}
	
		//JM-12933
		if(typeof commercialNode != 'undefined' && commercialNode.match('artsandliving/crosswords')){
			exempt += '!c=intrusive;';	
		}
			
		var fedpage = new Array('opinion/columns/politics/feddiary','opinion/columns/politics/kamena','opinion/columns/politics/sarasohnj','opinion/columns/politics/lanec','opinion/columns/politics/offcamera','politics/congress')

		for (var i=0; i<fedpage.length; i++)
		{
			if (thisNode == fedpage[i])
			{
				exempt = 'dir=fedpage;'
			}
		}
		
		//13625-JM
		if(tile==1 && (typeof commercialNode != 'undefined' && commercialNode.match('politics')) && !urlCheck('/wp-dyn/content/article/')){
			exempt += "!c=intrusive;";
		}
		
		//-RZ
		(function(){
			function checkURLS(){
				var urls = ["/alaska-native/","power-outages-still-a-problem.html","forecast_crippling_historic.html","/area-snow-totals/","/kevin-ricks-timeline/","/traumatic-brain-injury/","pepco-outages-interactive-map.html","live_chat_social_media_brings.html","AR2010123003056.html","AR2010123003056.html","LI2011012104999.html","AR2010030502233.html","AR2010011504690.html","the_complexity_problem.html","AR2010061803289.html","how_presidents_polarize.html","the_gops_bad_idea.html","AR2010100103123.html","the_irrelevance_of_the_liberal.html","motivated_skepticism_draft.html","the_republicans_genius_comprom.html","GA2009012701325.html"]; 
				var i = urls.length;
				while(i--){
					if(urlCheck(urls[i])){
						return true;  
					}
				}
    
			}
			if((typeof commercialNode!=="undefined" && ( commercialNode==="nation/investigative/gun" || commercialNode==="nation/tsa" || commercialNode==="metro/chesser") ) || checkURLS()){
				wpniAds.noIntrusive = true;
				exempt += "!c=intrusive;";
			}
		})();
		
		
		// wpid TEST!
		if(typeof(wpidTestCheck) == 'undefined')
		{
			var url = document.location.href.split('?')[0];
			url = url.toLowerCase()
			var urlarray = url.split('/');
			var tail = urlarray[urlarray.length -1];
			if (tail.indexOf('nav=') != -1)
			{
				tail = tail.substring(0,tail.indexOf('nav='));
			}
			if (tail.match(';'))
			{
				tail = tail.split(';')[0];
			}
			var illegals = ['test_ads','debugAdCode','?test_ads','?debugadcode','wpidtest','?template_test','?','=','/','\\',':',';',',','*','#','(',')','&','$','%','@','!','^','+',' ','[',']','{','}','.html','.htm','.',];
			for (var i=0;i<illegals.length;i++)
			{
				sRE = new RegExp('(\\' + illegals[i] + ')', 'g');
				tail = tail.replace(sRE,"");
			}
			if (tail == 'index' || tail == '')
			{
				tail = urlarray[urlarray.length -2];
			}
			var nodedump = thisNode.split('/');
			var wpidnode = '';
			for (var i=0;i < nodedump.length;i++)
			{
				wpidnode += nodedump[i];
			}
			wpid = 'wpid='+wpidnode+'_'+tail;
			if (wpid.length > 55)
			{
				wpid = wpid.substring(0,55);
			}
			if (url.indexOf('?wpidtest') != -1)
			{
				prompt('wpid',wpid);
			}
			wpidTestCheck = 1;
	
			if(typeof wpid == 'undefined')
			{
				wpid=''
			}

			
			//small biz hack
			sba = new Array('jobs_inside-job','liveonlinespecialsjobs_di2006102000737','liveonlinejobsslayterm_talk_di2006100900744','liveonlinespecialsjobs_di2006102000740','liveonlinespecialsjobs_di2006102000739','liveonlinespecialsjobs_di2006102000738','opinioncolumnsbusinessslayterm_ar2006101400332','jobs_ar2006102001235','jobs_success-stories','liveonline_smallbusiness101','liveonline_di2005110101296','liveonlinespecialsjobs_di2006022700702','liveonline_di2005101100729','liveonline_di2005100500899','liveonline_di2005103101365','liveonline_di2005100501552','liveonline_di2005110101296','liveonlinejobsslayterm_talk_di2005111601352','liveonline_di2005102001378','technologywashtech_ar2005112000918','opinioncolumnsbusinessslayterm_ar2005102900440','jobscareernews_ar2005111101484','jobscareernews_ar2005101401501','jobscareernews_ar2005101401472','jobs_ar2005100501786','jobscareernews_ar2005101000794');
			var sbatest=wpidnode+'_'+tail;
			for(var i = 0; i < sba.length; i++)
			{
				if(sbatest == sba[i]){wpid+=';kw=smallbiz';}
			}
			//end small biz hack
		}
		//end wpid
		grp = '';
		if (location.href.indexOf('financial') != -1) {grp = "grp=financial;"}

		/*if(commercialNode=='washingtonpost.com' && tile==20)
		{	
			tile = 15;
			pos = 'ad15';
		}*/

		if(tile==99)
		{
			config['adServerURL'] =  "http://ad.doubleclick.net/pfadx/wpni." + node + ";";
			config['additionalAdTargetingParams'] =  ";" + static_wpatc +  heavy + 'ad=video;' + grp + kw +  _rs + poe + ";";
	
			if(location.href.match('debugAdCode'))
			{
				var output = "config['adServerURL']:" + config['adServerURL'] + "\n\r";
				output += "config['additionalAdTargetingParams']:" + config['additionalAdTargetingParams'] + "\n\r";
				adopsDebug('<div>' + output + '</div>');
			}  
		}
		
			if(wpid == 'wpid=politics_politics' && tile == 6 && now < '03292359')
			{
				adSiteZone = 'wpni.politics/bigbox'
			}
		
		/*function setPos(argTile)
		{
			if(argTile=='16' || argTile=='6' || argTile=='5')
			{
				return "pos=ad5;"
			}
			return "pos=ad" + tile + ";";
		}*/
		
		
		
		
		var thisTileVal = tileNum()
		if(tile == 20 && location.href.match('/article/') && kw.match('inline=y'))
		{
			adSiteZoneArray = adSiteZone.split('/');
			adSiteZone = '';
			for(var a = 0; a< adSiteZoneArray.length;a++)
			{
				adSiteZone += adSiteZoneArray[a] + '/';
			}
			adSiteZone += 'inlinead/';
			adSiteZone = adSiteZone.substring(0,adSiteZone.length-1)
		}

		
		//5378 start
		var del = (parent != self || kw=='inline=y;')?'del=iframe;':'del=js;';
		if(kw=='inline=y;'){kw='';pos='pos=inline_bb;';}
		//5378 end
		
		if(typeof(dir)!='object'){ //check for json object in placeAd
			dir = {'return_type':'code','execute':true,'dfp_server':'adj'}; //use this as the default
		}
		if(typeof dir.dfp_server == 'undefined'){
			dir.dfp_server = 'adj';
		}
		if(tile == 20 && location.href.match('/article/') && kw.match('inline=y')){
			dir.dfp_server = 'adi';
		}
		if(typeof dir.return_type == 'undefined'){
			dir.return_type = 'code';
		}
		if(typeof dir.execute == 'undefined'){
			dir.execute  = true;	
		}
				
		var keyvalues = adSiteZone + ";" + setFlexvalue(tile) + pos + poe + doubleClickTestCode() + contComments + interstitials(dir) + new_interstitial(dir) + beta_kv() + realEstateAreaId() + static_wpatc + grp + kw + aptco() + mediaPage() + adDir + print_kv() + orbitFlag() + locExpSponsor() + socialMediaSite() + dtile + del + _t + wp_quantcast.init() + _rs + heavy + page_a + pageId() + articleId()  + innovations_kv() + exempt + _cn + ((typeof revSci() != 'undefined')?revSci():'')  + user_id_kv() + _tc + "=" + thisTileVal + ";ord=" + adUniqueNumber + "?";
		
		var adCode, returnCode;
		//build adCode

		switch (dir.dfp_server) {
		case 'adi':
			adCode = '<iframe width="336" height="280" frameborder="0" scrolling="no" marginwidth="0" marginheight="0" src="http://ad.doubleclick.net/adi/' + keyvalues + '"></iframe>';
			returnCode = '{\'src\':\'http://ad.doubleclick.net/adi/' + keyvalues + '\'}';
		break;
		case 'adj':
			adCode = '<script type="text/javascript" src="http://ad.doubleclick.net/adj/' + keyvalues + '"></script>';
			returnCode = "{\'src\':\'http://ad.doubleclick.net/adj/" + keyvalues + "\'}";
		break;
		case 'ad':
			adCode = '<a href="http://ad.doubleclick.net/jump/' + keyvalues + '" target="_blank"><img src="http://ad.doubleclick.net/ad/' + keyvalues + '" border="" width="" height="" alt="Washington Post Advertisement"/></a>';
			returnCode = '{"href":"http://ad.doubleclick.net/jump/' + keyvalues + '","src":"http://ad.doubleclick.net/ad/' + keyvalues + '"}';
		break;
		}
	
		if ( (typeof ceTag != 'undefined') && (ceTag) ) adCode = '';
		if (debugAdCode) {  adCode += debugTextArea(adCode); }
		
		//8947-DG,rev-11545-DG
		/*if((commercialNode=='washingtonpost.com' || location.href.match('/wp-dyn/content/')) && (tile==5||tile==6||tile==16))
		{
			slugCompanion()
		}*/
		
		//10946-MM
		if(tile==26 && commercialNode=='education'){
			document.write('<div><a href="http://www.washingtonpost.com/wp-adv/specialsales/exec_education/index.html" target="_blank"><img src="http://www.washingtonpost.com/wp-adv/advertisers/education/images/grad_336x60.gif" alt="" width="336" height="60" border="0"/></a></div>')
		}
	
		if(tile!=99 && dir.execute)
		{
			if (tile == 24)
			{ 
				document.writeln ('<div align="left" style="padding:6px 0px 4px 0px"><img src="http://media3.washingtonpost.com/wp-srv/hp/img/ad_label_leftjust.gif" alt="ad_icon" width="100" height="13" border="0"/></div>' );  
			}
			if (tile == 7 && thisNode == "artsandliving/cityguide" )
			{
				
				document.write('<img src="http://media.washingtonpost.com/wp-srv/hp/img/ad_label_vertical_small.jpg" border="0" width="14" height="33">');
			}
			if (tile == 7 && commercialNode == "weather")
			{
				
				document.write('<img style="margin-right:4px" src="http://media.washingtonpost.com/wp-srv/images/ad_horiz_16x33.gif" border="0" width="16" height="33">');
			}
			else if(tile == 7 && thisNode != "business" && (location.href.indexOf('?test_ads') != -1))
			
		  	{	
				document.write('<div style="padding-top:10px"><img src="http://media.washingtonpost.com/wp-srv/hp/img/ad_label_leftjust.gif" border="0" width="100" height="13" valign="top"></div>');
		  	}
			if (document.domain == 'washingtonpost.homescape.com' || document.domain == 'washingtonpost.homehunter.com')
			{
				if (typeof sponsor != 'undefined' && sponsor)
				{
					if (tile != 5) document.write(adCode);
				}
				else document.write(adCode);
			}
			
			else document.write(adCode.toString());
			
			
		}
		

	}// end of show_doubleclick_ad test

	firstTimeCalled = false ;
	return (dir.return_type=='json')?returnCode:adCode;
} //end of placeAd

function articleId(){
	var url = location.href;
	if( url.match('/wp-dyn/content/article/') ) {
		url = url.split('\/');
		url = url[url.length-1];
		url = url.split('.');
		url = url[0];
		url = url.split('_');
		url = 'articleId='+url[0]+';';
		return url;
	}
	else{
		return '';
	}
}

function setPosition(tile)
{

	if (typeof this.usedSpots == 'undefined')
	{
		this.usedSpots = new Array();
	}
	if (this.usedSpots[tile] == null)
	{
		this.usedSpots[tile] = 1;
		return 'pos=ad'+tile+';';
	}
	else
	{
		this.usedSpots[tile]++;
		return 'pos=ad'+tile+"_"+this.usedSpots[tile]+';';
	}
}


function setFlexvalue(tile) {
  var fv ;
  if ( tile >= 1 && tile <= 2) { fv = "ad=lb;sz=728x90;"; } // top leaderboard
  else if ( tile >= 2 && tile <= 2 ) { fv = "ad=lb;sz=728x90;"; } // bottom leaderboard
  else if ( tile >= 3 && tile <= 3 ) { fv = "ad=ss;sz=160x600;"; } // skyscraper left only
  else if ( tile >= 4 && tile <= 4 ) { fv = "ad=ss;sz=160x600;"; } // skyscraper only
  else if ( tile >= 5 && tile <= 5 ) { fv = "ad=ss;ad=bb;sz=160x600,300x250;"; } // big box and skyscraper
  else if ( tile >= 6 && tile <= 6 ) { fv = "ad=ss;ad=bb;ad=hp;sz=160x600,300x250,336x850;"; } // half page
  else if ( tile >= 7 && tile <= 7 ) { fv = "ad=fb;sz=446x33;"; } // feature bar
  else if ( tile >= 8 && tile <= 8 ) { fv = "ad=tt;sz=336x45;"; } // travel tile
  else if ( tile >= 9 && tile <= 9 ) { fv = "ad=rss;sz=479x40;"; } // rss tile
  else if ( tile >= 10 && tile <= 10) { fv = "ad=tt;sz=336x45;"; } // travel tile right
  else if ( tile >= 11 && tile <= 11) { fv = "ad=tl;sz=120x60;"; } // 120x60
  else if ( tile >= 12 && tile <= 12) { fv = "ad=260x30;sz=260x30;"; } // 260X30
  else if ( tile >= 13 && tile <= 13) { fv = "ad=re300;sz=300x190;"; } // 300x190
  else if ( tile >= 14 && tile <= 14) { fv = "ad=tiff;sz=200x60,234x60,290x60,300x45;"; } // 300x45
  else if ( tile >= 15 && tile <= 15) { fv = "ad=vb;sz=120x240;"; } // 120x240
  else if ( tile >= 16 && tile <= 16) { fv = "ad=bb;ad=hp;sz=300x250,336x850;"; } // 120x240
  else if ( tile >= 17 && tile <= 17 ) { fv = "ad=88x31;sz=88x31;";} // 88x31
  else if ( tile >= 18 && tile <= 18 ) { fv = "ad=180x20;sz=180x20;"; } // 180x20
  else if ( tile >= 19 && tile <= 19 ) { fv = "ad=336x35;sz=336x35;";} // 336x35
  else if ( tile >= 20 && tile <= 20 ) { fv = "ad=bb;sz=300x250;";} // 300x250
  else if ( tile >= 22 && tile <= 22 ) { fv = "ad=110x90;sz=110x90;"; } // 110x90 tile
  else if ( tile >= 23 && tile <= 23) { fv = "ad=blog;sz=446x45;"; } // 446x45 blog feature bar
  else if ( tile >= 24 && tile <= 24) { fv = "ad=208x40;sz=208x40;"; } // 446x45 blog feature bar
  else if ( tile >= 25 && tile <= 25) { fv = "ad=314x57;sz=314x57;"; } // 314x57 
  else if ( tile >= 26 && tile <= 26) { fv = "ad=336x60;sz=336x60;"; } // 336x60
  else if ( tile >= 27 && tile <= 27) { fv = "ad=120x30;sz=120x30;"; } // 120x30
  else if ( tile >= 28 && tile <= 28) { fv = "ad=toolbox_tile;sz=180x31;"; } // 180x31
  else if ( tile >= 29 && tile <= 29 ) { fv = "ad=cars_tile;sz=234x60;"; } // 234x60 
  else if ( tile >= 30 && tile <= 30 ) { fv = "ad=293x100;sz=293x100;"; } // 293x100
  else if ( tile >= 31 && tile <= 31 ) { fv = "ad=160x146;sz=160x146;"; } // 160x146
  else if ( tile >= 32 && tile <= 32 ) { fv = "ad=336x200;sz=336x200;"; } // 336x200
	else if ( tile >= 33 && tile <= 33 ) { fv = "ad=228x60;sz=228x60;"; } // 228x60
	else if ( tile >= 34 && tile <= 34 ) { fv = "ad=150x60;sz=150x60;"; } // 150x60
	else if ( tile >= 35 && tile <= 35 ) { fv = "ad=965x30;sz=965x30;"; } // 150x60
	else if ( tile >= 36 && tile <= 36 ) { fv = "ad=100x35;sz=100x35;"; } // 100x35
	else if ( tile >= 37 && tile <= 37 ) { fv = "ad=336x200;sz=336x200;"; } // 336x200
	else if ( tile >= 38 && tile <= 38 ) { fv = "ad=381x50;sz=381x50;"; } // 381x50
	else if ( tile >= 39 && tile <= 39 ) { fv = "ad=900x150;sz=900x150;"; } // 900x150
	else if ( tile >= 40 && tile <= 40 ) { fv = "ad=200x31;sz=200x31;"; } // 200x31
	else if ( tile >= 41 && tile <= 41 ) { fv = "ad=50x100;sz=50x100;"; } // 50x100
	else if ( tile >= 42 && tile <= 42 ) { fv = "ad=90x180;sz=90x180;"; } // 90x180	
	else if ( tile >= 43 && tile <= 43 ) { fv = "sz=1x1;"; } // 90x180	
	else if ( tile >= 44 && tile <= 44 ) { fv = "ad=bb;sz=300x250;"; } // right_rail_bb	
	else if ( tile >= 45 && tile <= 45 ) { fv = "sz=1x1;"; } // 336x280 deal widget	
	else if ( tile >= 46 && tile <= 46 ) { fv = "ad=200x30;sz=200x30;"; } // 200x30 Networked News Tile
  //99 is for brightcove

/*TM see above*/
if (tile >= 12 && tile <= 12 && location.href.indexOf('areaId') != -1) {fv="ad=ss120;sz=160x600;"}

/*8793-JM*/
if( ( location.href.match('/gallery') || location.href.match('/video') ) && tile==1 ){
	fv = 'ad=vplayer;'+fv;
}

return fv ;


}


function mkKeyword(myKeyword,myNode)
{
  if (myKeyword == "" )
  {
    if (myNode.indexOf("/") != -1 )
    {
      nodeAry = myNode.split("/") ;
      myKeyword = nodeAry[1] ;
	}
  }
  return myKeyword ;
}

//8947--DG
function slugCompanion()
{
		document.write('<div id="axis" style="display:none"></div>');
		var axis = document.getElementById('axis');
		var axisImg = document.getElementById('axis').parentNode.getElementsByTagName('img');
		var a = document.createElement('a');
		a.href = 'http://ad.doubleclick.net/clk;211852992;17836555;s?http://www.washingtonpost.com/wp-adv/media_kit/wpni/contact_us.html';
		a.target = '_blank';
		var img = document.createElement('img');
		img.alt = 'Your Ad Here';
		img.title = 'Your Ad Here';
		img.border = '0';
		if(commercialNode=='washingtonpost.com')
		{
			img.style.marginBottom = '2px';
		}
		a.appendChild(img);
		if(axisImg.length > 0)
		{
			img.src = 'http://media.washingtonpost.com/wp-adv/test/ad_slug/ad_slug_compainion.gif';
			img.width = '74';
			img.height = '14';
			if(orbitFlag()=='orbit=y;')
			{
				a.style.lineHeight = "13px";
				a.style.marginLeft = "-30px";
			}
			for(var z=0;z<axisImg.length;z++)
			{
				if(axisImg[z].src.match('label'))
				{
					axisImg[z].parentNode.appendChild(a);
				}
			}
			axis.parentNode.removeChild(axis);
		}
		/*else {
			axis.appendChild(a)
			img.src = 'http://media.washingtonpost.com/wp-adv/test/ad_slug/gog_ad_slug_compainion.gif';
			img.width = '16';
			img.height = '73';
			axis.style.display = 'block';
			axis.style.cssFloat = 'right';
			axis.style.styleFloat = 'right'; 
			axis.style.marginTop = '68px';
			axis.style.marginRight = '-17px';
			
		}
		*/
}



function textifyCode(_code)
{
	_code = _code.replace(/</gi,'&lt;');
	_code = _code.replace(/>/gi,'&gt;');
	return _code;
}


function debugTextArea(ac)
{ 
	
	if(!location.href.match('debugAdCode')) return '';	
    var debugPre = '<div style="position:relative;float:left;z-index:1000000000">';
	var debug = '<div style="text-align:left;text-transform:none;letter-spacing:normal;line-spacing:normal;padding:8px;position:absolute:top:0px;left:0px;width:300px;background-color:#FFAA00;color:#770000;font-family:verdana;font-size:9px;word-wrap:break-word;text-wrap:unrestricted;overflow:scroll">' + textifyCode(ac) + '</div>';
	var debugPost = '</div>'
	var debugReturn = debugPre  + debug + debugPost;
	return debugReturn;
}

function getWPATCookie()
{
  if (document.cookie.indexOf("WPATC") != -1)
  {
    var start = (document.cookie.indexOf("WPATC") + 6);
    var end = (document.cookie.indexOf(";",start)) == -1 ? document.cookie.length : document.cookie.indexOf(";",start);
    var cookie = document.cookie.substring(start,end) + ";";
    while (cookie.indexOf(":") != -1)
      cookie = cookie.substring(0,cookie.indexOf(":"))+";"+cookie.substring(cookie.indexOf(":")+1,cookie.length);
    if (cookie.lastIndexOf(";") != cookie.length - 1) cookie += ';';
    if (cookie.indexOf("=") == 0) cookie = cookie.substring(cookie.indexOf(";")+1,cookie.length);
  }
  else var cookie = "" ;
  return cookie ;
}



//Revenue Science Values
/*
function (name) {
	var cookie = " " + document.cookie;
	var search = " " + name + "=";
	var setStr = null;
	var offset = 0;
	var end = 0;
	if (cookie.length > 0) {
		offset = cookie.indexOf(search);
		if (offset != -1) {
			offset += search.length;
			end = cookie.indexOf(";", offset)
			if (end == -1) {
				end = cookie.length;
			}
			setStr = unescape(cookie.substring(offset, end));
		}
	}
	return(setStr);
}*/

var crumbs = (getCookie("DMSEG"))?"".concat(getCookie("DMSEG")).split("&"):"";
var segments = (crumbs[5])?crumbs[5]:"";
var seg = (segments)?segments.split(","):"";


// mimic revenue science value for rss users
// check to see if url has "rss" and set up a value
// that AMs can target to
// added 6/28/05 sja
function setCookie (name, value, expires, path, domain, secure) {
      document.cookie = name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}

function createTime() {
var cDate = new Date();
var cMil = cDate.getTime();
var e = cMil % (1000 * 60 * 60 * 24);
var r = (1000 * 60 * 60 * 24) - e;
var nr = 28 * 24 * 60 * 60 * 1000;
return(nr);
}

var wpniPOE = new Date();
var interval = 0;

var wpniWeek = wpniPOE.getTime() + createTime();
wpniPOE.setTime(wpniWeek);

if (urlLoc.indexOf('nav=rss') != -1)
{_rs+="fromrss=y;";
setCookie('rss_now','true',''+wpniPOE.toString()+'','/','.washingtonpost.com','');
setCookie('rss','true',''+wpniPOE.toString()+'','/','.washingtonpost.com','');
}
else
{_rs+="fromrss=n;";
setCookie('rss_now','false',''+wpniPOE.toString()+'','/','.washingtonpost.com','');
}

if (getCookie("rss") == 'true') {_rs += 'rss=y;'}
else _rs += 'rss=n;';

	

var poe = 'poe=no;';
if (getCookie("wpni_poe") == null || getCookie("wpni_poe") == "false") {
poe = 'poe=yes;';
setCookie("wpni_poe","true","","/",".washingtonpost.com",'')
}

if (getCookie("wpni_poe") == null && !(urlLoc.match("washingtonpost.com")))
{
	poe = 'poe=no;';
}

// end rss code
/**
 * crk added 17 July 2002
 * methods for 5 parameter placeAd call
 * placeAd(platform,node,tile,kw,assertive)
 **/

  // get ancestor from node
  function getAdAncestor(node)
  {
	var end = node.indexOf("/") ;
	if ( end == -1 )
	  return node ;
    else
	{
	  var adAncestor = node.substring(0,end) ;	
      return adAncestor ;
	}
  }

  // get adSite
  function getAdSite(ancestor)
  {
    if ( isNewsAncestor(ancestor) )
      return "wpni.news" ;
    else
      return "wpni."+ancestor ;
  }
  
  // get ad node
  function getAdNode(node,ancestor)
  {
    if ( isNewsAncestor(ancestor) )
	  return node ;
	else
	{
	  var start = node.indexOf("/")+1 ;
	  if (start)
        return node.substring(start) ;
	  else
	    return "" ;
	}
  }

  // get ad node
  function getAdZone(node)
  {
    var ary = new Array() ;
	if ( node.indexOf("/") != -1 )
	  ary = node.split("/") ;
	else
	  ary[0] = node ;

	if ( ary.length <= 8 )
	  return node ;
	else
	{
	  var zone = '' ;
	  for(var i=0; i<8; i++)
	  {
	    zone += ary[i] ;
		if (i==0) zone += "/" ;
	  }
	  return zone ;
	}
  }
  
  function getAdDir(node)
  {
    var page = "" ;
    var ary = new Array() ;
	if ( node.indexOf("/") != -1 )
	  ary = node.split("/") ;
	else
	  ary[0] = node ;

	var dir = '' ;
	for(var i=0; i<ary.length; i++)
	{
	  // parse out article string if present in ancestor
	  if ( i == 0 &&
	       ary[i].indexOf("article") != -1 &&
		   ary[i].indexOf("article") == ary[i].length - "article".length &&
		   ary[i] != "article" )
	  {
	    ary[i] = ary[i].substring(0,ary[i].indexOf("article")) ;
		page = "page=article;" ;
	  }
	  dir += "dir="+ary[i]+";" ;
	}
	//return "dir="+ary[ary.length-1]+"node;"+dir+page ;
	return page;
  }

  // check if adSite should be wpni.news
  function isNewsAncestor(ancestor)
  {
    if ( newsAncestorAsString != null &&
	     newsAncestorAsString != ""   &&
		 newsAncestorAsString.indexOf(","+ancestor+",") != -1
	   )
      return true  ;
    else
	  return false ;
  }
  
  function cleanNode(node)
  {
	if ( node.charAt(node.length-1) == "/" )
	  return node.substring(0,node.length-1) ;
	else
	  return node ;
  }
// begin: for inline article ad
function getInlineAdGraf(container_id,obstacle_id) {
	if ( document.getElementById(obstacle_id) && document.getElementById(container_id) ) {
		var obstacle = document.getElementById(obstacle_id);
		var bottom_of_obstacle = obstacle.offsetTop+obstacle.offsetHeight ;

		var container = document.getElementById(container_id);
		var bottom_of_container = container.offsetTop+container.offsetHeight ;

		var grafs = container.getElementsByTagName("p");
		for( var i=0; i<grafs.length; i++ ) {
			var graf = grafs[i] ;
			// if ( (graf.offsetTop > bottom_of_obstacle) && (bottom_of_container - bottom_of_obstacle > 200) ) {
			if ( graf.offsetTop > bottom_of_obstacle + document.getElementById("content_column_table").clientHeight + 200) {
				return graf ;
			}
		}
	}
	return false;
}
function getInlineAdGraf2(container_id,obstacle_id,clearance) {
	if ( document.getElementById(obstacle_id) && document.getElementById(container_id) ) {
		if ( typeof clearance == "undefined" ) {
			clearance = 200 ;
		}
		var obstacle = document.getElementById(obstacle_id);
		var bottom_of_obstacle = findPosition(obstacle_id).y+obstacle.offsetHeight ;

		var container = document.getElementById(container_id);
		var bottom_of_container = findPosition(container_id).y+container.offsetHeight ;

		var grafs = container.getElementsByTagName("p");
		for( var i=0; i<grafs.length; i++ ) {
			var graf = grafs[i] ;
			if ( (findPositionByElement(graf).y > bottom_of_obstacle + clearance) ) {
				return graf ;
			}
		}
	}
	return false;
}
function move_the_inline_ad(parent,ad,sibling) {
	if ( parent && ad && sibling )
		parent.insertBefore( ad, sibling ) ;
}
// end: for inline article ad

//start of wpniAds object
wpniAds = new Object();
wpniAds.utils = new Object();
wpniAds.utils.visibilityByTagName = function()
{
	for(var a = 1; a < arguments.length; a++)
	{
		badElements = document.getElementsByTagName(arguments[a]);
		for(var b = 0;b< badElements.length;b++)
		{
				badElements[b].style.visibility = arguments[0];
		}
	}
}

wpniAds.utils.wabs = new Object();

wpniAds.utils.wabs.recalc = function ()
{
	var rootElement = (document.compatMode != 'BackCompat')?document.documentElement:document.body;
	this.bodyheight = rootElement.scrollHeight;
	this.bodywidth = rootElement.scrollWidth;
	this.scrollheight= rootElement.scrollTop;
	this.scrollwidth= rootElement.scrollLeft;
	this.windowheight = rootElement.clientHeight;
	this.windowwidth= rootElement.clientWidth;		
}


wpniAds.utils.preLoadImages = new Object();
wpniAds.utils.preLoadImages.loadedArray = new Array();
wpniAds.utils.preLoadImages.execute = function ()
{
	for(var a = 0; a < arguments.length; a++)
	{
		if(!this.loadedArray[arguments[a]])
		{
			this.loadedArray[arguments[a]] = new Image();
			this.loadedArray[arguments[a]].src = arguments[a];
		}
	}
}

wpniAds.utils.listenerAttacher = function(_event,_func,_bool)
{
	if(window.addEventListener)
		{
			window.addEventListener(_event,_func,_bool);
			return true;
		}
		else if(window.attachEvent)
		{
			window.attachEvent('on'+_event,_func);
			return true;
		}
		return false;
}



wpniAds.utils.resizeDiv = new Object();
wpniAds.utils.resizeDiv.posWords = new Object();
wpniAds.utils.resizeDiv.posWords.width = 'left';
wpniAds.utils.resizeDiv.posWords.height = 'top';

wpniAds.utils.resizeDiv.window = function(_element,_dir)
{	
	document.getElementById(_element).style[_dir]= wpniAds.utils.wabs['window' + _dir] + 'px';
	document.getElementById(_element).style[this.posWords[_dir]] = wpniAds.utils.wabs['scroll' + _dir] + 'px';
}
wpniAds.utils.resizeDiv.body = function(_element,_dir)
{
	document.getElementById(_element).style[_dir] = wpniAds.utils.wabs['body' + _dir] + 'px';
	document.getElementById(_element).style[this.posWords[_dir]] = '0px';
}
wpniAds.utils.resizeDiv.max = function(_element,_dir)
{
	var totalRangeWindow = wpniAds.utils.wabs['window'+_dir] + wpniAds.utils.wabs['scroll' + _dir];
	var totalRangeBody = wpniAds.utils.wabs['body' + _dir];
	
	var HigherString = Math.max(totalRangeWindow,totalRangeBody) + 5
	
	document.getElementById(_element).style[_dir] = HigherString + 'px';
	document.getElementById(_element).style[this.posWords[_dir]] = '-5px';
}





wpniAds.utils.resizeDiv.execute = function (_element,_dimension,_goal)
{	
	wpniAds.utils.wabs.recalc();
	this[_goal](_element,_dimension)
}

//end of wpniAds object

/*start of cbIntercept

wpniAds.utils.preLoadImages.execute("http://www.washingtonpost.com/wp-srv/images/Jobs-splash-page_graphic.gif");

cbIntercept = new Object();

cbIntercept.attachListeners = function()
{
	if(this.listenersAttached) return true;
	if(!wpniAds.utils.listenerAttacher('resize',cbIntercept.resize,false)) this.listenersAttached = false;
	if(!wpniAds.utils.listenerAttacher('scroll',cbIntercept.resize,false)) this.listenersAttached = false;
	this.listenersAttached = true;
	return this.listenersAttached;
}

cbIntercept.resize = function ()
{
	
	var thisFunc = wpniAds.utils.resizeDiv;
	thisFunc.execute('cbIntAbs','width','max')
	thisFunc.execute('cbIntAbs','height','max')
	thisFunc.execute('cbIntContAbs','width','window')
	thisFunc.execute('cbIntContAbs','height','window')
}

cbIntercept.close = function ()
{
	cbIntercept.execute('none');
	return true;
}

cbIntercept.leaveSite = function ()
	{
			cbIntercept.execute('none')
			window.open('http://www.careerbuilder.com/?lr=cbwpni&siteid=cbwpni001&nid=roll_findajob')
	}
	
cbIntercept.execute = function()
{
	
	if(!cbIntercept.attachListeners()) return;
	

	if(!arguments[0]) arguments[0] = 'block';
	
	//check to see if cbContainer DIV is there. If not, intializes it.
	if(document.getElementById && !document.getElementById('cbIntContainer'))
	{
		cbIntContainerDIV = document.createElement('DIV');
		cbIntContainerDIV.id = 'cbIntContainer';
		cbIntContainerDIV.style.position = 'relative';
		cbIntContainerDIV.style.display = 'none';	
		cbIntContainerDIV.style.zIndex = '10000';
		//cbIntContainerDIV.style.width="20%";
		cbIntAbsDIV = document.createElement('DIV');
		cbIntAbsDIV.id = 'cbIntAbs';
		cbIntAbsDIV.style.position = 'absolute';
		cbIntAbsDIV.style.zIndex = '10001';
		cbIntAbsDIV.style.backgroundColor = '#777';
		cbIntAbsDIV.style.filter = "alpha(opacity=80)";
		cbIntAbsDIV.style.opacity = .8;
	
		cbIntAbsContDIV = document.createElement('DIV');
		cbIntAbsContDIV.id = 'cbIntContAbs';
		cbIntAbsContDIV.style.position = 'absolute';
		cbIntAbsContDIV.style.zIndex = '10002';
		cbIntAbsContDIV.style.textAlign = ((navigator.userAgent.toLowerCase().match("firefox"))?'-moz-':'') + 'center';

		cbIntAbsContDIV.innerHTML = '<div style="display: table; height:100%;width:100%;text-align:center;#position: relative;"><div style=" #position: absolute; #top: 50%;#left:50%;display: table-cell; vertical-align: middle;"><div style="#position: relative; #top: -50%;#left:-50%;"><img style="cursor:pointer" src="http://www.washingtonpost.com/wp-srv/images/Jobs_SplashPage_REV4.gif" usemap="#cbMap" border="0" width="429" height="342" /><map name="cbMap"><area shape="rect" coords="360,0,428,20"  onclick = "cbIntercept.close()" target="_blank"/><area shape="rect" coords="0,0,360,251" href="http://www.washingtonpost.com/wl/jobs/home?nav=cbsplash"/><area shape="rect" coords="360,20,428,251" href="http://www.washingtonpost.com/wl/jobs/home?nav=cbsplash"/><area shape="rect" coords="0,254,428,341" href="javascript:cbIntercept.leaveSite()"/></map></div></div></div>';
		 
		cbIntContainerDIV.appendChild(cbIntAbsDIV);
		cbIntContainerDIV.appendChild(cbIntAbsContDIV);
		
		document.body.insertBefore(cbIntContainerDIV,document.body.firstChild);
	}
	
	
	if(document.getElementById && document.getElementById('cbIntContainer'))
	{
		if(arguments[0] == 'block')
		{
			this.resize();
		}
		document.getElementById('cbIntContainer').style.display = arguments[0];
		wpniAds.utils.visibilityByTagName((arguments[0] == 'block')?'hidden':'visible','embed','object','select','iframe')
	}
	
}
end of cbIntercept */


var render_google_ads =  (Math.floor(Math.random()*100)<3 || urlCheck('google_ads=true'))?true:false;
//var render_google_ads =  urlCheck('google_ads=true')?true:false;
googleAds = {
	"googleVars":{"google_safe":"high","google_ad_client":"ca-pub-6288951389250281","google_ad_output":"js","google_ad_channel":"other","google_skip":0,google_max_num_ads:3,google_ad_section:"default"},
	nodeHacks : [],
	hideBox:"",
	category:{
		"washingtonpost.com":"6371669258",
		"artsandliving":"5735109925",
		"news":"2349448776",
		"business":"8141504747",
		"education":"1253622235",
		"health":"4413723416",
		"politics":"7918528095",
		"technology":"1064854213",
		"sports":"3662221933",
		"ros":"0903792148"
	},
	nodeCheck : function(c){
		//loops through nodeHacks
		/*for(var a = 0; a < this.nodeHacks.length; a++){
			if(c.match(this.nodeHacks[a])){
				nodeReg = RegExp(this.nodeHacks[a],'gi');
				return this.nodeHacks[a].replace(/[^a-z0-9]/gi,'');
			}
		}
		return cNode.split('/')[0];*/
		var a = wpAds.textlinks.cat_check(c);
		a = typeof a!='undefined'?a:'ros';
		return googleAds.category[a];
	},
	debug : function(){
		for(var a in this.googleVars){
			adopsDebug('<b>' + a + ':</b> ' + this.googleVars[a]+'<br>');
		}
		return true;
	},
	vertCheck : function (posId1,posId2){
		wpniAds.utils.wabs.recalc();
		var windowHeight = wpniAds.utils.wabs.windowheight, offset1=document.getElementById(posId1).offsetTop, offset2=document.getElementById(posId2).offsetTop;
		adopsDebug('<b>' + posId1 + ' vertical position:</b> ' + offset1 + '<br>');
		adopsDebug('<b>' + posId2 + ' vertical position:</b> ' + offset2 + '<br>');
		adopsDebug('<b>windowHeight:</b> ' + windowHeight + '<br>');
		//return boolean answer to this question:
		//is the distance between the two boxes greater than the height of the viewport?
		return (offset1 - offset2 > windowHeight) || (offset2 - offset1 > windowHeight);
		adopsDebug(e + '<br/>')
		return;
	},
	execute : function (cNode,adCount,test){
		adopsDebug('<b style="font-size:12px">googleAds("'+this.googleVars.google_ad_client+'","'+cNode+'","'+adCount+'",'+test+')</b><br>');

		this.googleVars.google_ad_channel = this.nodeCheck(cNode);
		this.googleVars.google_max_num_ads = adCount;
		this.googleVars.google_adtest = (test)?'on':'off';
		for(var a in this.googleVars){
			eval(a + '="' + this.googleVars[a] + '"');
		}

		if(!document.getElementById('googleBottomBox') || googleAds.vertCheck('googleBottomBox','googleRightBox') ){
			document.write('<div style="clear:both"></div><s\cript type="text/javascript" src="http://media.washingtonpost.com/wp-srv/ad/google_display.js"></s\cript>');
			this.debug();
			this.googleVars.google_skip += parseInt(adCount);
		}
		else{
			this.debug();
			adopsDebug('<b>Sorry, the divs were too close vertically to render a ' + googleAds.hideBox + ' adSense box.</b><br>');
		}
	}
};

//quigo links
wpAds.textlinks =
{
		'templates':{
		'article':{
			'inner':{
				'artsandliving':[1483519,1900773,228,215],
				'business':[1483534,1900771,228,215],
				'education':[1484181,1909768,228,215],
				'health':[1484178,1909769,228,215],
				'politics':[1483549,1900769,228,215],
				'sports':[1483579,1900772,228,215],
				'technology':[1484175,1909767,228,215],
				'news':[1483491,1900767,228,215],
				'ros':[1483564,1900770,228,215]
			},
			'bottom':{
				'artsandliving':[1483522,1900773,624,225],
				'business':[1483537,1900771,624,225],
				'education':[1484172,1909768,624,225],
				'health':[1484169,1909769,624,225],
				'politics':[1483552,1900769,624,225],
				'sports':[1483582,1900772,624,225],
				'technology':[1484166,1909767,624,225],
				'news':[1483494,1900767,624,225],
				'ros':[1483567,1900770,624,225]
			}
		},
		'index':{
			'leftrail':{
				'washingtonpost.com':[1483488,1900768,305,215]
			},
			'rightrail':{
				'artsandliving':[1483525,1900773,336,230],
				'business':[1483540,1900771,336,230],
				'education':[1484190,1909768,336,230],
				'health':[1484187,1909769,336,230],
				'politics':[1483555,1900769,336,230],
				'sports':[1483585,1900772,336,230],
				'technology':[1484184,1909767,336,230],
				'news':[1483497,1900767,336,230],
				'ros':[1483570,1900770,336,230]
			}
		},
		'index2':{
			'rightrail':{
				'artsandliving':[1483528,1900773,336,230],
				'business':[1483543,1900771,336,230],
				'education':[1484199,1909768,336,230],
				'health':[1484196,1909769,336,230],
				'politics':[1483558,1900769,336,230],
				'sports':[1483588,1900772,336,230],
				'technology':[1484193,1909767,336,230],
				'news':[1483500,1900767,336,230],
				'ros':[1483573,1900770,336,230]
			}
		},
		'subsection':{
			'bottom':{
				'artsandliving':[1483531,1900773,420,230],
				'business':[1483546,1900771,420,230],
				'education':[1484208,1909768,420,230],
				'health':[1484205,1909769,420,230],
				'politics':[1483561,1900769,420,230],
				'sports':[1483591,1900772,420,230],
				'technology':[1484202,1909767,420,230],
				'news':[1483503,1900767,420,230],
				'ros':[1483576,1900770,420,230]
			}
		},
		'blog_main':{
			'inner':{
				'artsandliving':[1484031,1900773,454,215],
				'business':[1484034,1900771,454,215],
				'education':[1484133,1909768,454,215],
				'health':[1484130,1909769,454,215],
				'politics':[1484037,1900769,454,215],
				'sports':[1484043,1900772,454,215],
				'technology':[1484127,1909767,454,215],
				'news':[1484028,1900767,454,215],
				'ros':[1484040,1900770,454,215]
			},
			'rightrail':{
				'artsandliving':[1484049,1900773,336,215],
				'business':[1484052,1900771,336,215],
				'education':[1484142,1909768,336,215],
				'health':[1484139,1909769,336,215],
				'politics':[1484055,1900769,336,215],
				'sports':[1484061,1900772,336,215],
				'technology':[1484136,1909767,336,215],
				'news':[1484046,1900767,336,215],
				'ros':[1484058,1900770,336,215]
			}
		},
		'blog_permalink':{
			'inner':{
				'artsandliving':[1484067,1900773,454,215],
				'business':[1484070,1900771,454,215],
				'education':[1484154,1909768,454,215],
				'health':[1484151,1909769,454,215],
				'politics':[1484073,1900769,454,215],
				'sports':[1484079,1900772,454,215],
				'technology':[1484145,1909767,454,215],
				'news':[1484064,1900767,454,215],
				'ros':[1484076,1900770,454,215]
			},
			'rightrail':{
				'artsandliving':[1484085,1900773,336,215],
				'business':[1484088,1900771,336,215],
				'education':[1484163,1909768,336,215],
				'health':[1484160,1909769,336,215],
				'politics':[1484091,1900769,336,215],
				'sports':[1484097,1900772,336,215],
				'technology':[1484157,1909767,336,215],
				'news':[1484082,1900767,336,215],
				'ros':[1484094,1900770,336,215]
			}
		}
	},
	'cat_check':function(c){
		var c = c.split('/')[0];
		for(var b in wpAds.textlinks.category)
		{
			for(var e in wpAds.textlinks.category[b])
			{
				if(wpAds.textlinks.category[b][e]==c)
				{
					var d = b;
				}
			}
		}
		return d
	},
	'article_check':function(){
		return ((!urlCheck('_Comments.html')) && (urlCheck('/wp-dyn/content/article/') || urlCheck('/wp-dyn/content/discussion/')))?true:false;
	},
	'index_check':function(){
		var k = ['politics','opinion','business','technology'];
		var j = k.length;
		for(var i=0;i<j;i++)
		{
			if(typeof commercialNode != 'undefined' && commercialNode.match(k[i]))
			{
				return (commercialNode.match(k[i]+'/'))?false:'index';
			}
		}
		return 'index2'
	},
	'blog_check':function(){
		return (urlCheck(/\/\d{4}\/\d{2}\/.*\.htm/gi))?'blog_permalink':'blog_main';
	},
	'category':{
		'washingtonpost.com':['washingtonpost.com'],
		'artsandliving':['artsandliving','artsandlivingarticle','artsandleisure','artsandleisurearticle','dating','entertain','entertainarticle','entertainbestbets','entertainment','entertainmentarticle','food','foodarticle','market','pets','photo','photoarticle','shoplocal','shopping','shoppingNEW','shoppingUSED','style','stylearticle','tastepost','travel','traveldirectory','travel.sidestep','travelarticle'],
		'news':['nation','nationarticle','news','world','worldarticle','religion','realestate','digest','digestarticle','fairfaxextra','liveonline','liveonlinearticle','localportal','metro','metroarticle','mostemailed','mostviewedarticles','opinion','opinionarticle'],
		'business':['business','allbusiness','businessarticle'],
		'education':['education'],
		'health':['health'],
		'politics':['politics','supertuesday','wiki'],
		'technology':['technology'],
		'sports':['sports','sportsarticle']
	},
	'init':function(a,b,c){
		var c = (typeof wpAds.textlinks.cat_check(c)!='undefined') ? wpAds.textlinks.cat_check(c) : 'ros';
		var c = (typeof wpAds.textlinks.templates[a][b][c] == 'undefined') ? 'ros' : c;
		var d = a+'-'+b+'-'+c;
		wpAds.textlinks.exec(wpAds.textlinks.templates[a][b][c],d);
	},
	'exec':function(a,b)
	{
		if(urlCheck('debugAdCode'))
		{
			var b = b.split('-');
			document.write('template='+b[0]+';pos='+b[1]+';channel='+b[2]+';');	
		}
		document.write('<s'+'cript type="text/javascript">adsonar_placementId=' + a[0] + ';adsonar_pid=' + a[1] + ';adsonar_ps=-1;adsonar_zw=' + a[2] + ';adsonar_zh=' + a[3] + ';adsonar_jv="ads.adsonar.com";</s'+'cript><s'+'cript type="text/javascript" src="http://js.adsonar.com/js/adsonar.js"></s'+'cript>');
	}
}

function checkForQuigoSizes()
{
	if(document.getElementById('ad_links_inner') && document.getElementById('article_body') && document.getElementById('inline-ad')){
		var ad_links_inner = {
			'top':document.getElementById('ad_links_inner').offsetTop,
			'height':document.getElementById('ad_links_inner').scrollHeight
		}
		var article_body = {
			'top':document.getElementById('article_body').offsetTop,
			'height':document.getElementById('article_body').offsetHeight
		}
		var inline_ad = {
			'top':document.getElementById('inline-ad').offsetTop,
			'height':document.getElementById('inline-ad').scrollHeight
		}
		if ( ( article_body.top + article_body.height ) > ( ad_links_inner.top + ad_links_inner.height + inline_ad.height + ( inline_ad.top - ( ad_links_inner.top + ad_links_inner.height ) ) ) ) {
			document.getElementById('ad_links_inner').style.display = 'block';
		}
	}
}


// This code is calling an Orbit/Non-commercial javascript which piggy-backs on ad_v2.js because this file has such
// deep penetration across all our pages and vendors
if ( typeof PIGGY_BACK_ALREADY_CALLED == "undefined" || !PIGGY_BACK_ALREADY_CALLED ) {
   document.write('<s\cript src="http://media.washingtonpost.com/wp-srv/javascript/piggy-back-on-ads.js"></s\cript>');
}




//Firefox 3 Iframe Issue
function addLoadEvent(_function) {
	
var _onload = window.onload;
if ( typeof window.onload != 'function' ) {
if ( window.onload ) {
window.onload = _function;
} else {
var _addEventListener = window.addEventListener || document.addEventListener;
var _attachEvent = window.attachEvent || document.attachEvent;
if ( _addEventListener ) {
_addEventListener('load', _function, true);
return true;
} else if ( _attachEvent ) {
var _result = _attachEvent('onload', _function);

return _result;
} else {
//todo: preloading fix for ie5.2 on mac os
return false;
}
}
} else {
window.onload = function() {
_onload();
_function();
}
}
}

function reloadIframe()
{
	var f = document.getElementsByTagName('iframe');
	for (var i=0; i<f.length; i++) f[i].src = f[i].src;
}


if (navigator.userAgent.match('Firefox/3') && location.href.match('http://projects.washingtonpost.com/2008/elections/')){
	addLoadEvent(reloadIframe)
}
/*
//11565-JM-219456646 - 11020-MM
if( urlCheck('center_skin') || ( commercialNode == 'washingtonpost.com' && (estNowWithYear >= '200911110000' && estNowWithYear <= '200911112359') ) ){
	document.write('<link rel="stylesheet" type="text/css" href="http://www.washingtonpost.com/wp-srv/ad/skin_margin.css"/>');
}
*/
//14990-ST
if( urlCheck('center_skin') || ( commercialNode == 'washingtonpost.com' && estNowWithYear.substring(0,8) == '20101108' ) ){
	document.write('<link rel="stylesheet" type="text/css" href="http://www.washingtonpost.com/wp-srv/ad/skin_margin.css"/>');
}


