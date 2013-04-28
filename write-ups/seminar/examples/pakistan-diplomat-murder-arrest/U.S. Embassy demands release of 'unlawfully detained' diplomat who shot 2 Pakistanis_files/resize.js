if ( !document.getElementById && !document.all )
{
  if(!window.saveInnerWidth)
  {
    window.onresize = resize ;
    window.saveInnerWidth = window.innerWidth ;
    window.saveInnerHeight = window.innerHeight ;
  }
}

function resize()
{
  if (saveInnerWidth < window.innerWidth ||
      saveInnerWidth > window.innerWidth ||
      saveInnerHeight > window.innerHeight ||
      saveInnerHeight < window.innerHeight )
  {
    window.history.go(0) ;
  }
}


if (typeof adTemplate != 'undefined' && adTemplate == 65680) {
top.window.focus();
}