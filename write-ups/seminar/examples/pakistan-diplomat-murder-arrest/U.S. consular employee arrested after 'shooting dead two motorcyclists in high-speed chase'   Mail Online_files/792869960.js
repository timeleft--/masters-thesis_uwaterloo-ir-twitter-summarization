/* AG-develop 12.7.1-649 (2012-09-20 11:43:57 PDT) */
rsinetsegs=[];
    var asiExp=new Date((new Date()).getTime()+2419200000);
    var asiSegs="";
    var rsiSegs="";
    var rsiPat=/.*_5.*/; 
    var rsiDom='.dailymail.co.uk';
    if (rsiDom == ".metro.co.uk") rsiDom="www.metro.co.uk";
    var i=0;
    for(x=0;x<rsinetsegs.length&&i<20;++x){if(!rsiPat.test(rsinetsegs[x])){asiSegs+='|'+rsinetsegs[x];++i;}}
    for(x=0;x<rsinetsegs.length;++x){if(!rsiPat.test(rsinetsegs[x]))rsiSegs+='|'+rsinetsegs[x];}
    document.cookie="asi_segs="+(asiSegs.length>0?asiSegs.substr(1):"")+";expires="+asiExp.toGMTString()+";path=/;domain="+rsiDom;
    document.cookie="rsi_segs="+(rsiSegs.length>0?rsiSegs.substr(1):"")+";expires="+asiExp.toGMTString()+";path=/;domain="+rsiDom;
    if(typeof(DM_onSegsAvailable)=="function"){DM_onSegsAvailable([],'d05509');}