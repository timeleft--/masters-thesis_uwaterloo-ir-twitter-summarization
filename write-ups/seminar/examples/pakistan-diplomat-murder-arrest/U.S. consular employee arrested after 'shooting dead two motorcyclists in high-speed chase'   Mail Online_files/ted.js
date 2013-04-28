(function(){
   
   var enabled = true,
       u = '//t.dailymail.co.uk/s/';

   if(!enabled) return;
   
   var pixel = new Image(1,1);
   pixel.src = [u,'l','?g=',window.ted.g,"&r=",encodeURI(document.referrer),"&" + Math.random()*10000000].join("");


})();