/* 3.0.6-59768 */ 
(function(){var requirejs,require,define;(function(e){function t(e,t){var n=t&&t.split("/"),r=l.map,i=r&&r["*"]||{},s,o,u,a,f,c,h;if(e&&e.charAt(0)==="."&&t){n=n.slice(0,n.length-1),e=n.concat(e.split("/"));for(f=0;h=e[f];f++){if(h==="."){e.splice(f,1),f-=1;}else{if(h===".."){if(f===1&&(e[2]===".."||e[0]==="..")){return !0;}f>0&&(e.splice(f-1,2),f-=2);}}}e=e.join("/");}if((n||i)&&r){s=e.split("/");for(f=s.length;f>0;f-=1){o=s.slice(0,f).join("/");if(n){for(c=n.length;c>0;c-=1){u=r[n.slice(0,c).join("/")];if(u){u=u[o];if(u){a=u;break;}}}}a=a||i[o];if(a){s.splice(0,f,a),e=s.join("/");break;}}}return e;}function n(t,n){return function(){return d.apply(e,h.call(arguments,0).concat([t,n]));};}function r(e){return function(n){return t(n,e);};}function i(e){return function(t){a[e]=t;};}function s(t){if(f.hasOwnProperty(t)){var n=f[t];delete f[t],c[t]=!0,p.apply(e,n);}if(!a.hasOwnProperty(t)){throw new Error("No "+t);}return a[t];}function o(e,n){var i,o,u=e.indexOf("!");return u!==-1?(i=t(e.slice(0,u),n),e=e.slice(u+1),o=s(i),o&&o.normalize?e=o.normalize(e,r(n)):e=t(e,n)):e=t(e,n),{f:i?i+"!"+e:e,n:e,p:o};}function u(e){return function(){return l&&l.config&&l.config[e]||{};};}var a={},f={},l={},c={},h=[].slice,p,d;p=function(t,r,l,h){var p=[],d,v,m,g,y,b;h=h||t;if(typeof l=="function"){r=!r.length&&l.length?["require","exports","module"]:r;for(b=0;b<r.length;b++){y=o(r[b],h),m=y.f;if(m==="require"){p[b]=n(t);}else{if(m==="exports"){p[b]=a[t]={},d=!0;}else{if(m==="module"){v=p[b]={id:t,uri:"",exports:a[t],config:u(t)};}else{if(a.hasOwnProperty(m)||f.hasOwnProperty(m)){p[b]=s(m);}else{if(y.p){y.p.load(y.n,n(h,!0),i(m),{}),p[b]=a[m];}else{if(!c[m]){throw new Error(t+" missing "+m);}}}}}}}g=l.apply(a[t],p);if(t){if(v&&v.exports!==e&&v.exports!==a[t]){a[t]=v.exports;}else{if(g!==e||!d){a[t]=g;}}}}else{t&&(a[t]=l);}},requirejs=require=d=function(t,n,r,i){return typeof t=="string"?s(o(t,n).f):(t.splice||(l=t,n.splice?(t=n,n=r,r=null):t=e),n=n||function(){},i?p(e,t,n,r):setTimeout(function(){p(e,t,n,r);},15),d);},d.config=function(e){return l=e,d;},define=function(e,t,n){t.splice||(n=t,t=[]),f[e]=[e,t,n];},define.amd={jQuery:!0};})(),define("../vendor/almond",function(){}),fortyone=new function(){this.e=(new Date(2005,0,15)).getTimezoneOffset(),this.f=(new Date(2005,6,15)).getTimezoneOffset(),this.plugins=[],this.d={Flash:["ShockwaveFlash.ShockwaveFlash",function(e){return e.getVariable("$version");}],Director:["SWCtl.SWCtl",function(e){return e.ShockwaveVersion("");}]},this.r=function(e){var t;try{t=document.getElementById(e);}catch(n){}if(t===null||typeof t=="undefined"){try{t=document.getElementsByName(e)[0];}catch(r){}}if(t===null||typeof t=="undefined"){for(var i=0;i<document.forms.length;i++){for(var s=document.forms[i],o=0;o<s.elements.length;o++){var u=s[o];if(u.name===e||u.id===e){return u;}}}}return t;},this.b=function(e){var t="";try{typeof this.c.getComponentVersion!="undefined"&&(t=this.c.getComponentVersion(e,"ComponentID"));}catch(n){e=n.message.length,e=e>40?40:e,t=escape(n.message.substr(0,e));}return t;},this.exec=function(b){for(var c=0;c<b.length;c++){try{var d=eval(b[c]);if(d){return d;}}catch(e){}}return"";},this.p=function(e){var t="";try{if(navigator.plugins&&navigator.plugins.length){var n=RegExp(e+".* ([0-9._]+)");for(e=0;e<navigator.plugins.length;e++){var r=n.exec(navigator.plugins[e].name);r===null&&(r=n.exec(navigator.plugins[e].description)),r&&(t=r[1]);}}else{if(window.ActiveXObject&&this.d[e]){try{var i=new ActiveXObject(this.d[e][0]);t=this.d[e][1](i);}catch(s){t="";}}}}catch(o){t=o.message;}return t;},this.q=function(){for(var e=["Acrobat","Flash","QuickTime","Java Plug-in","Director","Office"],t=0;t<e.length;t++){var n=e[t];this.plugins[n]=this.p(n);}},this.g=function(){return Math.abs(this.e-this.f);},this.h=function(){return this.g()!==0;},this.i=function(e){var t=Math.min(this.e,this.f);return this.h()&&e.getTimezoneOffset()===t;},this.n=function(e){var t=0;return t=0,this.i(e)&&(t=this.g()),t=-(e.getTimezoneOffset()+t)/60;},this.j=function(e,t,n,r){typeof r!="boolean"&&(r=!1);for(var i=!0,s;(s=e.indexOf(t))>=0&&(r||i);){e=e.substr(0,s)+n+e.substr(s+t.length),i=!1;}return e;},this.m=function(){return(new Date(2005,5,7,21,33,44,888)).toLocaleString();},this.k=function(b){var c=new Date,d=[function(){return"TF1";},function(){return"015";},function(){return ScriptEngineMajorVersion();},function(){return ScriptEngineMinorVersion();},function(){return ScriptEngineBuildVersion();},function(e){return e.b("{7790769C-0471-11D2-AF11-00C04FA35D02}");},function(e){return e.b("{89820200-ECBD-11CF-8B85-00AA005B4340}");},function(e){return e.b("{283807B5-2C60-11D0-A31D-00AA00B92C03}");},function(e){return e.b("{4F216970-C90C-11D1-B5C7-0000F8051515}");},function(e){return e.b("{44BBA848-CC51-11CF-AAFA-00AA00B6015C}");},function(e){return e.b("{9381D8F2-0288-11D0-9501-00AA00B911A5}");},function(e){return e.b("{4F216970-C90C-11D1-B5C7-0000F8051515}");},function(e){return e.b("{5A8D6EE0-3E18-11D0-821E-444553540000}");},function(e){return e.b("{89820200-ECBD-11CF-8B85-00AA005B4383}");},function(e){return e.b("{08B0E5C0-4FCB-11CF-AAA5-00401C608555}");},function(e){return e.b("{45EA75A0-A269-11D1-B5BF-0000F8051515}");},function(e){return e.b("{DE5AED00-A4BF-11D1-9948-00C04F98BBC9}");},function(e){return e.b("{22D6F312-B0F6-11D0-94AB-0080C74C7E95}");},function(e){return e.b("{44BBA842-CC51-11CF-AAFA-00AA00B6015B}");},function(e){return e.b("{3AF36230-A269-11D1-B5BF-0000F8051515}");},function(e){return e.b("{44BBA840-CC51-11CF-AAFA-00AA00B6015C}");},function(e){return e.b("{CC2A9BA0-3BDD-11D0-821E-444553540000}");},function(e){return e.b("{08B0E5C0-4FCB-11CF-AAA5-00401C608500}");},function(){return eval("navigator.appCodeName");},function(){return eval("navigator.appName");},function(){return eval("navigator.appVersion");},function(e){return e.exec(["navigator.productSub","navigator.appMinorVersion"]);},function(){return eval("navigator.browserLanguage");},function(){return eval("navigator.cookieEnabled");},function(e){return e.exec(["navigator.oscpu","navigator.cpuClass"]);},function(){return eval("navigator.onLine");},function(){return eval("navigator.platform");},function(){return eval("navigator.systemLanguage");},function(){return eval("navigator.userAgent");},function(e){return e.exec(["navigator.language","navigator.userLanguage"]);},function(){return eval("document.defaultCharset");},function(){return eval("document.domain");},function(){return eval("screen.deviceXDPI");},function(){return eval("screen.deviceYDPI");},function(){return eval("screen.fontSmoothingEnabled");},function(){return eval("screen.updateInterval");},function(e){return e.h();},function(e){return e.i(c);},function(){return"@UTC@";},function(e){return e.n(c);},function(e){return e.m();},function(){return eval("screen.width");},function(){return eval("screen.height");},function(e){return e.plugins.Acrobat;},function(e){return e.plugins.Flash;},function(e){return e.plugins.QuickTime;},function(e){return e.plugins["Java Plug-in"];},function(e){return e.plugins.Director;},function(e){return e.plugins.Office;},function(){return(new Date).getTime()-c.getTime();},function(e){return e.e;},function(e){return e.f;},function(){return c.toLocaleString();},function(){return eval("screen.colorDepth");},function(){return eval("window.screen.availWidth");},function(){return eval("window.screen.availHeight");},function(){return eval("window.screen.availLeft");},function(){return eval("window.screen.availTop");},function(e){return e.a("Acrobat");},function(e){return e.a("Adobe SVG");},function(e){return e.a("Authorware");},function(e){return e.a("Citrix ICA");},function(e){return e.a("Director");},function(e){return e.a("Flash");},function(e){return e.a("MapGuide");},function(e){return e.a("MetaStream");},function(e){return e.a("PDFViewer");},function(e){return e.a("QuickTime");},function(e){return e.a("RealOne");},function(e){return e.a("RealPlayer Enterprise");},function(e){return e.a("RealPlayer Plugin");},function(e){return e.a("Seagate Software Report");},function(e){return e.a("Silverlight");},function(e){return e.a("Windows Media");},function(e){return e.a("iPIX");},function(e){return e.a("nppdf.so");},function(e){return e.o();}];this.q();for(var e="",f=0;f<d.length;f++){b&&(e+=this.j(d[f].toString(),'"',"'",!0),e+="=");var g;try{g=d[f](this);}catch(h){g="";}e+=b?g:escape(g),e+=";",b&&(e+="\\n");}return e=this.j(e,escape("@UTC@"),(new Date).getTime());},this.l=function(e){try{if(!e){return this.k();}var t;t=this.r(e);if(t!==null){try{t.value=this.k();}catch(n){t.value=escape(n.message);}}}catch(r){}},this.a=function(e){try{if(navigator.plugins&&navigator.plugins.length){for(var t=0;t<navigator.plugins.length;t++){var n=navigator.plugins[t];if(n.name.indexOf(e)>=0){return n.name+(n.description?"|"+n.description:"");}}}}catch(r){}return"";},this.o=function(){var e=document.createElement("span");e.innerHTML="&nbsp;",e.style.position="absolute",e.style.left="-9999px",document.body.appendChild(e);var t=e.offsetHeight;return document.body.removeChild(e),t;};};try{fortyone.c=document.createElement("span"),typeof fortyone.c.addBehavior!="undefined"&&fortyone.c.addBehavior("#default#clientCaps");}catch(i){}window.fortyone=fortyone,window.fortyone.collect=fortyone.l,define("../vendor/fortyone",function(){}),define("../src/bootstrap",[],function(){var e=function(e,t){var n=t.split("."),r=e,i;i=n.length;for(var s=0;s<i;s++){typeof r[n[s]]=="undefined"&&(r[n[s]]={}),r=r[n[s]];}return r;};typeof BKTAG=="undefined"&&e(window,"BKTAG"),BKTAG.ns=e;var t={checkFrame:function(e){var t="__bkframe";if(typeof frames[t]=="undefined"||typeof document.getElementById(t)=="undefined"){var n=document.createElement("iframe");n.setAttribute("name",t),n.setAttribute("id",t),n.setAttribute("title","bk"),n.style.border="0px",n.style.width="0px",n.style.height="0px",n.src="javascript:void(0)";var r=document.getElementsByTagName("body")[0];r&&r.appendChild(n);}typeof e=="function"&&e();}};return t;}),define("../vendor/htmlparser",[],function(){var e=function(e){var t={},n=e.split(",");for(var r=0;r<n.length;r++){t[n[r]]=!0;}return t;},t={leftTrim:function(e){return e.replace(/^\s+/,"");},startTag:/^<(\w+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/,endTag:/^<\/(\w+)[^>]*>/,attr:/(\w+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g,empty:e("area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed"),block:e("address,applet,blockquote,button,center,dd,del,dir,div,dl,dt,fieldset,form,frameset,hr,iframe,ins,isindex,li,map,menu,noframes,noscript,NOSCRIPT,object,ol,p,pre,script,SCRIPT,table,tbody,td,tfoot,th,thead,tr,ul"),inline:e("a,abbr,acronym,applet,b,basefont,bdo,big,br,button,cite,code,del,dfn,em,font,i,iframe,img,input,ins,kbd,label,map,object,q,s,samp,script,SCRIPT,select,small,span,strike,strong,sub,sup,textarea,tt,u,var"),closeSelf:e("colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr"),fillAttrs:e("checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected"),special:e("script,SCRIPT,style"),one:e("html,head,body,title"),structure:{link:"head",base:"head"},htmlParser:function(e,n){function r(e,r,s,o){if(t.block[r]){while(a.last()&&t.inline[a.last()]){i("",a.last());}}t.closeSelf[r]&&a.last()==r&&i("",r),o=t.empty[r]||!!o,o||a.push(r);if(n.start){var u=[];s.replace(t.attr,function(e,n){var r=arguments[2]?arguments[2]:arguments[3]?arguments[3]:arguments[4]?arguments[4]:t.fillAttrs[n]?n:"";u.push({name:n,value:r,escaped:r.replace(/(^|[^\\])"/g,'$1\\"')});}),n.start&&n.start(r,u,o);}}function i(e,t){if(!t){var r=0;}else{for(var r=a.length-1;r>=0;r--){if(a[r]==t){break;}}}if(r>=0){for(var i=a.length-1;i>=r;i--){n.end&&n.end(a[i]);}a.length=r;}}var s,o,u,a=[],f=e;a.last=function(){return this[this.length-1];};while(e){o=!0,e=t.leftTrim(e);if(!a.last()||!t.special[a.last()]){e.indexOf("<!--")==0?(s=e.indexOf("-->"),s>=0&&(n.comment&&n.comment(e.substring(4,s)),e=e.substring(s+3),o=!1)):e.indexOf("</")==0?(u=e.match(t.endTag),u&&(e=e.substring(u[0].length),u[0].replace(t.endTag,i),o=!1)):e.indexOf("<")==0&&(u=e.match(t.startTag),u&&(e=e.substring(u[0].length),u[0].replace(t.startTag,r),o=!1));if(o){s=e.indexOf("<");var l=s<0?e:e.substring(0,s);e=s<0?"":e.substring(s),n.chars&&n.chars(l);}}else{var c=new RegExp("</"+a.last()+">","i"),s=e.search(c),h=e.substring(0,s);h.length>0&&(n.chars&&n.chars(h),e=e.replace(h,"")),e=e.replace(c,""),i("",a.last());}if(e==f){throw"Parse Error: "+e;}f=e;}i();},htmlToDom:function(e,n){var r=[],i=n.documentElement||n.getOwnerDocument&&n.getOwnerDocument()||n;!i&&n.createElement&&function(){var e=n.createElement("html"),t=n.createElement("head");t.appendChild(n.createElement("title")),e.appendChild(t),e.appendChild(n.createElement("body")),n.appendChild(e);}();if(n.getElementsByTagName){for(var s in t.one){t.one[s]=n.getElementsByTagName(s)[0];}}var o=t.one.body;t.htmlParser(e,{start:function(e,i,s){if(t.one[e]){o=t.one[e];return;}var u=n.createElement(e);for(var a=0;a<i.length;a++){u.setAttribute(i[a].name,i[a].value);}t.structure[e]&&typeof _one[t.structure[e]]!="boolean"?t.one[t.structure[e]].appendChild(u):o&&o.appendChild&&(window.addEventListener||o.tagName!="NOSCRIPT")&&o.appendChild(u),s||(r.push(u),o=u);},end:function(e){r.length-=1,r.length>0?o=r[r.length-1]:o=t.one.body;},chars:function(e){if(window.addEventListener){var t=n.createTextNode(e);o.appendChild(t);}else{o.text=e;}},comment:function(e){}});}};return t;}),define("../src/utils",["../src/bootstrap","../vendor/htmlparser"],function(e,t){var n={getKwds:function(){var e=document.getElementsByTagName("meta"),t=[],n,r=e.length;for(n=0;n<r;n++){e[n].name&&e[n].name.toLowerCase()==="keywords"&&t.push(e[n].content);}return t.join(",");},getMeta:function(e){var t=document.getElementsByTagName("meta"),n=t.length;for(var r=0;r<n;r++){var i=t[r];if(i.name.toLowerCase()===e.toLowerCase()&&i.content!==""){return i.content;}}return null;},scriptWithOnload:function(e,t){var n=document.createElement("script");return n.src=e,n.onloadDone=!1,n.onload=function(){n.onloadDone||(n.onloadDone=!0,typeof t=="function"&&t());},n.onreadystatechange=function(){("loaded"===n.readyState||"complete"===n.readyState)&&!n.onloadDone&&(n.onloadDone=!0,typeof t=="function"&&t());},n;},isMobile:function(){var e=!1,t=["Mobile","Tablet","Handheld","Android","iPhone","Kindle","Silk","Nokia","Symbian","BlackBerry"];for(var n in t){if(navigator.userAgent.indexOf(t[n])!==-1){e=!0;break;}}return e;},isDebug:function(){var e=!1;return typeof window.location!="undefined"&&typeof window.location.search!="undefined"&&window.location.search.indexOf("debug=1")!==-1&&(e=!0),e;}};return window.BKTAG.htmlToDom=t.htmlToDom,window.BKTAG.util=n,n;}),define("../src/core",["../src/bootstrap","../src/utils"],function(e,t){var n=[],r=!1,s={site:"site_id",limit:"pixel_limit",excludeBkParams:"ignore_meta",excludeTitle:"exclude_title",excludeKeywords:"exclude_keywords",excludeReferrer:"exclude_referrer",excludeLocation:"exclude_location",partnerID:"partner_id",allowMultipleCalls:"allow_multiple_calls",callback:"callback",allData:"all_data",timeOut:"timeout",ignoreOutsideIframe:"ignore_outside_iframe",metaVars:"meta_vars",jsList:"js_list",paramList:"param_list",useMobile:"use_mobile",disableMobile:"disable_mobile",isDebug:"is_debug",limitGetLength:"limit_get_length"},o={_dest:null,addParam:function(e,t,r){return typeof r!="undefined"?n.push(e+"="+encodeURIComponent(t+"="+r)):n.push(e+"="+t),BKTAG;},addBkParam:function(e,t){if(typeof e=="string"&&typeof t=="string"){o.addParam("phint","__bk_"+e,t);}else{for(var n in e){e.hasOwnProperty(n)&&typeof e[n]=="string"&&o.addParam("phint","__bk_"+n,e[n]);}}return BKTAG;},_reset:function(){r=!1,n=[];for(var e in s){delete window["bk_"+s[e]];}return BKTAG;},params:function(){return n;},getGlobals:function(e){if(e.length){for(i=0;i<e.length;i++){val=e[i],typeof window[val]!="undefined"&&val!==""&&window[val]!==""&&bk_addPageCtx(val,window[val]);}}else{for(var t in e){e.hasOwnProperty(t)&&typeof t=="string"&&(typeof e[t]=="string"||typeof e[t]=="number"||typeof e[t]=="boolean")&&bk_addPageCtx(t,e[t]);}}},doTag:function(i,u,a,f,l,c,h,p,d){var v={site:i,limit:u,excludeBkParams:a,partnerID:f,allowMultipleCalls:l,callback:c,allData:h,timeOut:p,ignoreOutsideIframe:d};for(var m in s){typeof window["bk_"+s[m]]!="undefined"&&(v[m]=window["bk_"+s[m]]);}if(typeof i=="object"){for(var g in s){typeof i[s[g]]!="undefined"&&(v[g]=i[s[g]]);}}if(typeof r!="undefined"&&r&&v.allowMultipleCalls!==!0){return;}r=!0,v.timeOut===undefined&&(v.timeOut=1000),n.unshift("ret="+(v.callback?"js":"html"));var y=typeof v.partnerID!="undefined"&&v.partnerID!==null;y&&n.unshift("partner="+encodeURIComponent(v.partnerID));var b={2607:1,2834:1,2894:1,3316:1,3317:1,3318:1,3319:1,3321:1,3322:1,3323:1,3324:1,3325:1,3326:1,3327:1,3328:1,3329:1,3330:1,3331:1,3332:1,3333:1,3334:1,3338:1,3339:1,3340:1,3341:1,3344:1,3345:1,3346:1,3348:1};!v.excludeBkParams&&!v.excludeTitle&&document.title!==""&&o.addBkParam("t",document.title),!v.excludeBkParams&&!v.excludeKeywords&&o.addBkParam("k",t.getKwds()),!v.excludeBkParams&&!v.excludeReferrer&&"referrer" in document&&document.referrer!==""&&o.addBkParam("pr",document.referrer),!v.excludeBkParams&&!v.excludeLocation&&o.addBkParam("l",window.location.toString()),v.callback?o.addParam("jscb",encodeURIComponent(v.callback)):typeof v.limit!="undefined"&&o.addParam("limit",encodeURIComponent(v.limit)),v.allData===!0&&o.addParam("data","all"),v.disableMobile!==!0&&t.isMobile()&&typeof fortyone!="undefined"&&o.addParam("bkfpd",fortyone.collect()),t.isDebug()&&o.addParam("debug","1"),!v.excludeBkParams&&typeof v.paramList!="undefined"&&o.getGlobals(v.paramList),!v.excludeBkParams&&typeof v.jsList!="undefined"&&o.getGlobals(v.jsList);if(!v.excludeBkParams&&typeof v.metaVars!="undefined"){for(var w=0;w<v.metaVars.length;w++){var E=t.getMeta(v.metaVars[w]);E!==null&&o.addBkParam(v.metaVars[w],E,!0);}}o.addParam("r",parseInt(Math.random()*99999999,10));var S=("https:"===document.location.protocol?"https://stags":"http://tags")+".bluekai.com/"+(y?"psite":"site")+"/"+v.site,x=S+"?"+n.join("&");v.limitGetLength&&(x=x.substr(0,2000)),BKTAG._dest=x;if(v.callback){var T=document.createElement("script");T.type="text/javascript",T.src=o._dest,T.id="__bk_script__",b[""+i]&&setTimeout(function(){var e=document.getElementById("__bk_script__");e&&(e.removeNode?e.removeNode(!0):e.parentNode.removeChild(e));},v.timeOut),document.getElementsByTagName("head")[0].appendChild(T);}else{e.checkFrame(function(){frames.__bkframe.location.replace(x);}),n.shift();if(typeof v.ignoreOutsideIframe!="undefined"&&v.ignoreOutsideIframe===!1){n.unshift("ret=jsht"),x=S+"?"+n.join("&"),x=x.substr(0,2000);var N=document.createElement("script");N.src=x,N.type="text/javascript",document.getElementsByTagName("body").item(0).appendChild(N);}}typeof u=="function"&&u(),n=[];}};for(var u in o){window.BKTAG[u]=o[u];}return typeof window.bk_async=="function"&&window.setTimeout(function(){bk_async();},0),o;}),define("../src/aliases",["../src/core"],function(){window.BKTAG.addCtxParam=function(e,t){return BKTAG.addParam("phint",e,t),BKTAG;},window.BKTAG.addBkParam=function(e,t){return BKTAG.addParam("phint","__bk_"+e,t),BKTAG;},window.BKTAG.addPageCtx=window.bk_addPageCtx=window.BKTAG.addUserCtx=window.bk_addUserCtx=function(e,t){return BKTAG.addParam("phint",e,t),BKTAG;},window.BKTAG.doJSTag=window.bk_doJSTag=function(e,t,n){BKTAG.doTag(e,t,!1,null,n);},window.BKTAG.doJSTag2=window.bk_doJSTag2=function(e,t){BKTAG.doTag(e,t);},window.BKTAG.doCarsJSTag=window.bk_doCarsJSTag=function(e,t){BKTAG.doTag(e,t,!0);},window.BKTAG.doPartnerAltTag=window.bk_doPartnerAltTag=function(e,t,n){if(typeof n=="undefined"||n===null){n=0;}BKTAG.doTag(e,t,!1,n);},window.BKTAG.doCallbackTag=window.bk_doCallbackTag=function(e,t,n,r){BKTAG.doTag(e,0,!1,null,n,t,r);},window.BKTAG.doCallbackTagWithTimeOut=window.bk_doCallbackTagWithTimeOut=function(e,t,n,r,i){BKTAG.doTag(e,0,!1,null,n,t,r,i);},window.BKTAG.sendData=function(e){BKTAG.doTag(e);};}),define("mobile",["../vendor/fortyone","../src/core","../src/aliases"],function(){}),require("mobile");})(),BKTAG.version="3.0.6";