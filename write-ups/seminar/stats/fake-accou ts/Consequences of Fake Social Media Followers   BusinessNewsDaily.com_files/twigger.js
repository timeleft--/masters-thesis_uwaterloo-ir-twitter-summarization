var box_down = true;

function cookie_get(name) {
  var tmp =  document.cookie.match((new RegExp(name +'=[a-zA-Z0-9.()=|%/]+($|;)','g')));
  if(!tmp || !tmp[0]) return null;
  else return unescape(tmp[0].substring(name.length+1,tmp[0].length).replace(';','')) || null;
}

function cookie_set(name, value, days) {
  var cookie = [name+'='+   escape(value),
               'path='+     '/',
               'domain='+   window.location.hostname,
               'expires='+  cookie_time(days)];
  return document.cookie = cookie.join('; ');
}

function cookie_time(days) {
  var now = new Date();
  now.setTime(now.getTime() + (parseInt(days) * 60 * 60 * 1000));
  return now.toGMTString();     
}

function slide_up(){
  if (box_down == true){
    $jq("#twig_unit").animate({
      bottom: '0',
      opacity: 1
    },{queue: false, duration: "slow"}, "easein");
    box_down = false;
  }
}

function slide_down(){
  if (box_down == false){
    $jq("#twig_unit").animate({
      bottom: '-36',
      opacity: 1
    },{queue: false, duration: "slow"}, "easein");
    box_down = true;
  }
}

function close_twig(){
  $jq("#twig_unit").css('display','none');
  cookie_set('twig_unit','1',(7*24));
}

$jq(document).ready(function(){
  if(!cookie_get('twig_unit')){
    $jq(window).scroll(function(event_info){
      var check_scroll_position = $jq(window).scrollTop();
      if(check_scroll_position<=30){
        slide_down();
      }else{
        slide_up();
      }
      return true;
    });
  }else{
    $jq("#twig_unit").css('display','none');
  }
});