
    DISQUS.addBlocks('theme')(function ($d) {
        $d.blocks["comment"] = function block_comment ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cli        id\x3D\x22dsq\x2Dcomment\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22        data\x2Ddsq\x2Dcomment\x2Did\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22        class\x3D\x22dsq\x2Dcomment dsq\x2Dclearfix        ");
if (comment.num_replies > 0) { 
$h.put("dsq\x2Dcomment\x2Dis\x2Dparent");
}
$h.put("        ");
if (comment.author_is_moderator) { 
$h.put("dsq\x2Dmoderator");
}
$h.put("\x22        style\x3D\x22margin\x2Dleft: ");
if (comment.depth > 2) { 
$h.put(($h.esc || function (s) { return s; })(2 * 50));
} else {
$h.put(($h.esc || function (s) { return s; })(comment.depth * 50));
}
$h.put("px\x3B\x22\x3E        \x3Cdiv id\x3D\x22dsq\x2Dcomment\x2Dbody\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 class\x3D\x22dsq\x2Dcomment\x2Dbody\x22 style\x3D\x22max\x2Dwidth: ");
if (comment.depth > 2 || 450-(50*comment.depth) < 200) { 
$h.put(($h.esc || function (s) { return s; })(450-(50*2)));
} else {
$h.put(($h.esc || function (s) { return s; })(450-(50*comment.depth)));
}
$h.put("px\x22\x3E            \x3Cdiv class\x3D\x22dsq\x2Davatar\x22\x3E                \x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(comment.author.url));
$h.put("\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27profile.show\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22\x3E                    \x3Cimg src\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(comment.author.avatar));
$h.put("\x22 class\x3D\x22comment_author_avatar dsq\x2Ddeferred\x2Davatar\x22 data\x2Dsrc\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(comment.author.avatar));
$h.put("\x22 alt\x3D\x22Commenter\x27s avatar\x22 /\x3E                \x3C/a\x3E            \x3C/div\x3E            \x3Cdiv class\x3D\x22dsq\x2Dcomment\x2Dheader\x22\x3E                \x3Cp\x3E                    ");
if (comment.author.blog) { 
$h.put("                        \x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(comment.author.blog));
$h.put("\x22 target\x3D\x22_blank\x22 class\x3D\x22dsq\x2Dcommenter\x2Dname\x22 rel\x3D\x22nofollow\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(comment.author.display_name));
$h.put("\x3C/a\x3E                    ");
} else {
$h.put("                        \x3Cspan class\x3D\x22dsq\x2Dcommenter\x2Dname\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(comment.author.display_name));
$h.put("\x3C/span\x3E                    ");
}
$h.put("                \x3C/p\x3E                \x3Cp\x3E                    \x3Ca href\x3D\x22#comment\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.permalink\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22 title\x3D\x22Permalink\x22\x3E");
if (comment.is_realtime) { 
$h.put(" ");
$h.put(trans("just now"));
$h.put(" ");
} else {
$h.put(($h.esc || function (s) { return s; })(comment.date));
}
$h.put("\x3C/a\x3E                \x3C/p\x3E            \x3C/div\x3E            \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E            ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {"cls": "dsq-comment-message"});
$h.put($d.renderBlock("commentMessage", $l));
}());
$h.put("        \x3C/div\x3E        ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentFooter", $l));
}());
$h.put("    \x3C/li\x3E    \x3Cli class\x3D\x22li_ie_fix\x22\x3E        \x3Cdiv id\x3D\x22dsq\x2Dappend\x2Dedit\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22\x3E\x3C/div\x3E        \x3Cdiv id\x3D\x22dsq\x2Dappend\x2Dreply\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22\x3E\x3C/div\x3E    \x3C/li\x3E    \x3Cli id\x3D\x22dsq\x2Dappend\x2Dpost\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 class\x3D\x22li_ie_fix\x22\x3E\x3C/li\x3E");
return $h.compile();

}

};
$d.blocks["reactions"] = function block_reactions ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("  ");
if (reactions) { 
$h.put("    \x3Ch4 class\x3D\x22dsq\x2Dh4\x2Dreactions\x22\x3ESocial Media Reactions\x3C/h4\x3E    \x3Cul id\x3D\x22dsq\x2Dreactions\x22 class\x3D\x22dsq\x2Dreactions dsq\x2Dclearfix\x22\x3E      ");
$d.each(reactions, function (reaction, $index, $collection) {
var $locals = { "reaction": reaction, "index": $index };
$h.put("        ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("reaction", $l));
}());
$h.put("      ");
});
$h.put("    \x3C/ul\x3E    \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E  ");
}
return $h.compile();

}

};
$d.blocks["trackbacks"] = function block_trackbacks ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    ");
if (forum.linkbacks_enabled && context.trackbacks && context.trackbacks.length) { 
$h.put("    \x09\x3Ch4 id\x3D\x22trackbacks\x22 class\x3D\x22dsq\x2Dh4\x2Dreactions\x22\x3E");
$h.put(trans("Trackbacks"));
$h.put("\x3C/h4\x3E\x09\x09\x3Cul id\x3D\x22dsq\x2Dtrackbacks\x22\x3E\x09\x09\x09");
$d.each(context.trackbacks, function (trackback, $index, $collection) {
var $locals = { "trackback": trackback, "index": $index };
$h.put("\x09\x09\x09\x09\x3Cli class\x3D\x22dsq\x2Dreaction\x22\x3E    \x09\x09\x09\x09\x3Cdiv class\x3D\x22dsq\x2Dcomment\x2Dbody dsq\x2Dreaction\x2Dbody\x22\x3E\x09\x09\x09\x09    \x09\x3Cdiv class\x3D\x22dsq\x2Dreaction\x2Dtooltip dsq\x2Dcomment\x2Dheader\x22\x3E    \x09\x09\x09\x09\x09\x09\x3Cp class\x3D\x22dsq\x2Dreaction\x2Duser\x22\x3E\x09\x09\x09\x09    \x09\x09\x09\x3Cspan class\x3D\x22reaction\x2Dauthor\x2Dname\x22\x3E\x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(trackback.author_url));
$h.put("\x22 rel\x3D\x22nofollow\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(trackback.author_name));
$h.put("\x3C/a\x3E\x3C/span\x3E    \x09\x09\x09\x09\x09\x09\x3C/p\x3E\x09\x09\x09\x09    \x09\x09\x3Cp class\x3D\x22dsq\x2Dreaction\x2Ddate\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(trackback.date));
$h.put("\x3C/p\x3E    \x09\x09\x09\x09\x09\x3C/div\x3E\x09\x09\x09\x09    \x09\x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E    \x09\x09\x09\x09\x09\x3Cdiv class\x3D\x22dsq\x2Dreaction\x2Dmessage dsq\x2Dcomment\x2Dmessage\x22\x3E\x09\x09\x09\x09    \x09\x09");
$h.put(($h.esc || function (s) { return s; })(trackback.excerpt));
$h.put("    \x09\x09\x09\x09\x09\x3C/div\x3E                    \x3C/div\x3E                \x3C/li\x3E\x09\x09\x09");
});
$h.put("\x09\x09\x3C/ul\x3E\x09");
}
return $h.compile();

}

};
$d.blocks["commentCount"] = function block_commentCount ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Ch4\x3E    ");
if (thread.total_posts && thread.total_posts > thread.num_posts) { 
$h.put("      ");
if (thread.pagination_type == 'num') { 
$h.put("        ");
$h.put($d.interpolate(trans("Showing \x3Cspan id\x3D\x27dsq\x2Dnum\x2Dposts\x27\x3E1\x2D%(num)s\x3C/span\x3E of \x3Cspan id\x3D\x27dsq\x2Dtotal\x2Dposts\x27\x3E%(total)s\x3C/span\x3E comments"), { "num": thread.num_posts, "total": thread.total_posts }));
$h.put("      ");
} else {
$h.put("        ");
$h.put($d.interpolate(trans("Showing \x3Cspan id\x3D\x27dsq\x2Dnum\x2Dposts\x27\x3E%(num)s\x3C/span\x3E of \x3Cspan id\x3D\x27dsq\x2Dtotal\x2Dposts\x27\x3E%(total)s\x3C/span\x3E comments"), { "num": thread.num_posts, "total": thread.total_posts }));
$h.put("      ");
}
$h.put("    ");
} else {
$h.put("      ");
if (thread.num_posts == 1) { 
$h.put("        ");
$h.put(trans("Showing \x3Cspan id\x3D\x27dsq\x2Dnum\x2Dposts\x27\x3E1\x3C/span\x3E comment"));
$h.put("      ");
} else {
$h.put("        ");
$h.put($d.interpolate(trans("Showing \x3Cspan id\x3D\x27dsq\x2Dnum\x2Dposts\x27\x3E%(num)s\x3C/span\x3E comments"), { "num": thread.num_posts }));
$h.put("      ");
}
$h.put("    ");
}
$h.put("    \x3C/h4\x3E");
return $h.compile();

}

};
$d.blocks["subscribe"] = function block_subscribe ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cul\x3E        \x3Cli\x3E            \x3Cimg src\x3D\x22http://www.telegraph.co.uk/template/ver1\x2D0/i/disqus/dsq\x2Dicon\x2Demail.png\x22 alt\x3D\x22Email logo\x22 /\x3E            ");
if (context.subscribed) { 
$h.put("                \x3Ca href\x3D\x22#\x22 class\x3D\x22email\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27thread.unsubscribe\x27)\x3B\x22\x3EUnsubscribe\x3C/a\x3E            ");
} else {
$h.put("                \x3Ca href\x3D\x22#\x22 class\x3D\x22email\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27thread.subscribe\x27)\x3B\x22\x3EFollow with email\x3C/a\x3E            ");
}
$h.put("        \x3C/li\x3E        \x3Cli class\x3D\x22last\x2Dchild\x22\x3E            \x3Cimg src\x3D\x22http://www.telegraph.co.uk/template/ver1\x2D0/i/disqus/dsq\x2Dicon\x2Drss.png\x22 alt\x3D\x22RSS logo\x22 /\x3E            \x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(urls.forum_view));
$h.put("/latest.rss\x22 class\x3D\x22dsq\x2Dsubscribe\x2Drss\x22\x3EFollow with RSS\x3C/a\x3E        \x3C/li\x3E    \x3C/ul\x3E");
return $h.compile();

}

};
$d.blocks["maintenanceNotice"] = function block_maintenanceNotice ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    ");
if (settings.read_only) { 
$h.put("    \x3Cdiv class\x3D\x22dsq\x2Dnotice dsq\x2Derror\x22\x3E        The Disqus comment system is temporarily in maintenance mode. You can still read comments during this time, however posting comments and other actions are temporarily delayed.    \x3C/div\x3E    ");
}
return $h.compile();

}

};
$d.blocks["realtimeNotice"] = function block_realtimeNotice ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    ");
if (context.realtime_enabled) { 
$h.put("    \x3Cp id\x3D\x22dsq\x2Drealtime\x2Doptions\x22 class\x3D\x22dsq\x2Doptions\x22\x3E      ");
$h.put(trans("Real\x2Dtime updating is"));
$h.put(" \x3Cstrong id\x3D\x22dsq\x2Drealtime\x2Dstatus\x22 style\x3D\x22text\x2Dtransform:lowercase\x22\x3E");
$h.put(trans("enabled"));
$h.put("\x3C/strong\x3E. \x3Ca href\x3D\x22#\x22 id\x3D\x22dsq\x2Drealtime\x2Dtoggle\x22 style\x3D\x22text\x2Dtransform:capitalize\x22\x3E\x3C/a\x3E    \x3C/p\x3E    ");
}
return $h.compile();

}

};
$d.blocks["commentDate"] = function block_commentDate ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Ca href\x3D\x22#comment\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22       onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.permalink\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22       title\x3D\x22");
$h.put($d.interpolate(trans("Link to comment by %(author)s"), { "author": comment.author.display_name }));
$h.put("\x22\x3E      ");
if (comment.is_realtime) { 
$h.put("          ");
$h.put(trans("Just now"));
$h.put("      ");
} else {
$h.put("          ");
$h.put(($h.esc || function (s) { return s; })(comment.date));
$h.put("      ");
}
$h.put("    \x3C/a\x3E");
return $h.compile();

}

};
$d.blocks["postbox"] = function block_postbox ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cdiv class\x3D\x22dsq\x2Dreply\x22 id\x3D\x22dsq\x2Dreply");
if (comment) { 
$h.put("\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
}
$h.put("\x22 ");
if (!comment) { 
$h.put("style\x3D\x22padding\x2Dtop: 13px\x22");
}
$h.put("\x3E    ");
if (comment) { 
$h.put("    \x3Cdiv class\x3D\x22replyingTo\x22\x3EReplying to ");
$h.put(($h.esc || function (s) { return s; })(comment.author.display_name));
$h.put("\x3C/div\x3E");
}
$h.put("        \x3Cdiv class\x3D\x22dsq\x2Davatar\x22\x3E            \x3Ca href\x3D\x22#\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27profile.show\x27, null, \x27");
$h.put(($h.esc || function (s) { return s; })(request.userkey));
$h.put("\x27)\x3B return false\x22\x3E                \x3Cimg class\x3D\x22dsq\x2Drequest\x2Duser\x2Davatar\x22 src\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(urls.request_user_avatar));
$h.put("\x22 alt\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(request.display_username));
$h.put("\x22 \x3E            \x3C/a\x3E        \x3C/div\x3E        \x3Cdiv class\x3D\x22dsq\x2Dtextarea dsq\x2Dtextarea\x2Dreply\x22\x3E            \x3Cdiv class\x3D\x22userName\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(request.display_username));
$h.put("\x3C/div\x3E                \x3Cdiv class\x3D\x22dsq\x2Dtextarea\x2Dbackground\x22\x3E                \x3Cdiv class\x3D\x22dsq\x2Dtextarea\x2Dwrapper\x22\x3E\x3C/div\x3E            \x3C/div\x3E        \x3C/div\x3E        \x3Cdiv class\x3D\x22userInfoButtons\x22\x3E            \x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })("https://auth.telegraph.co.uk/sam-ui/logoff.htm?redirectTo=" + escape(urls.logout + "?ctkn=" + context.csrf_token)));
$h.put("\x22 class\x3D\x22logout\x22\x3E");
$h.put(trans("Log out"));
$h.put("\x3C/a\x3E        \x3C/div\x3E        \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E        \x3Cdiv class\x3D\x22postMessageButton\x22\x3E                    \x3Cbutton class\x3D\x22dsq\x2Dbutton postButton\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.send\x27, ");
if (comment) { 
$h.put(($h.esc || function (s) { return s; })(comment.id));
} else {
$h.put("null");
}
$h.put(", this)\x3B\x22\x3E");
$h.put(trans("Post comment"));
$h.put("\x3C/button\x3E            ");
if (comment) { 
$h.put("                \x3Cbutton class\x3D\x22dsq\x2Dbutton postButton\x22 id\x3D\x22dsq\x2Dcancel\x2Dbutton\x2D");
$h.put("{\x3D comment.id}");
$h.put("\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.reply\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(", this)\x3B\x22\x3E");
$h.put(trans("Cancel"));
$h.put("\x3C/button\x3E            ");
}
$h.put("            ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentShare", $l));
}());
$h.put("        \x3C/div\x3E        \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E    \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["header"] = function block_header ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("maintenanceNotice", $l));
}());
$h.put("    \x3Cdiv class\x3D\x22commentCount\x22\x3E        \x3Cdiv class\x3D\x22commentNo\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(thread.total_posts));
$h.put(" comments\x3C/div\x3E        \x3Cdiv class\x3D\x22disqusLogo\x22\x3E\x3C/div\x3E    \x3C/div\x3E    ");
if (!integration.reply_position) { 
$h.put("        ");
if (request.is_authenticated) { 
$h.put("            ");
if (context.show_reply) { 
$h.put("                ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("postbox", $l));
}());
$h.put("            ");
}
$h.put("        ");
} else {
$h.put("            \x3Cdiv class\x3D\x22log_in_box\x22\x3E                \x3Cdiv class\x3D\x22telegraphLogin\x22\x3E                    \x3Cdiv class\x3D\x22loginTitle\x22\x3EAdd a comment\x3C/div\x3E            \x09\x09\x3Cdiv class\x3D\x22loginMessage\x22\x3EComment with a Telegraph account\x3C/div\x3E                ");
if (typeof jQuery.cookie != 'undefined' && !jQuery.cookie('tmg_hashd')) { 
$h.put("                  ");
if (typeof jQuery.cookie != 'undefined' && jQuery.cookie('tmg_session')) { 
$h.put("                    \x3Ca href\x3D\x22http://my.telegraph.co.uk/?rt\x3D");
$h.put(($h.esc || function (s) { return s; })(escape(location.href)));
$h.put("\x22\x3EComplete your registration\x3C/a\x3E                  ");
} else {
$h.put("                  \x3Ca href\x3D\x22");
if (forum.url == 'telegraphmy') { 
$h.put("http://my.telegraph.co.uk/wp\x2Dlogin.php");
} else {
$h.put(($h.esc || function (s) { return s; })("https://auth.telegraph.co.uk/sam-ui/login.htm?logintype=communities&redirectTo=" + escape(location.href)));
}
$h.put("\x22\x3ELogin\x3C/a\x3E | \x3Ca href\x3D\x22https://auth.telegraph.co.uk/sam\x2Dui/registration.htm?logintype\x3Dcommunities\x26redirectTo\x3Dhttp%3A%2F%2Fmy.telegraph.co.uk%2F%3Fnl%3Dtrue%26variant%3D1\x22\x3ERegister with the Telegraph\x3C/a\x3E                  ");
}
$h.put("                ");
} else {
$h.put("                  Please refresh the page to comment.                ");
}
$h.put("            \x09\x3C/div\x3E            \x09\x3Cdiv class\x3D\x22otherLogins\x22\x3E            \x09\x09\x3Cdiv class\x3D\x22loginTitle\x22\x3EAlternatively...\x3C/div\x3E            \x09\x09\x3Cdiv class\x3D\x22loginMessage\x22\x3EComment with one of your accounts\x3C/div\x3E            \x09\x09");
$d.each(loginOptions, function (option, $index, $collection) {
var $locals = { "option": option, "index": $index };
$h.put("            \x09\x09\x09");
if (option.enabled) { 
$h.put("            \x09\x09\x09\x09\x3Cimg src\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(option.button_url));
$h.put("\x22  onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27");
$h.put(($h.esc || function (s) { return s; })(option.action));
$h.put("\x27)\x3B\x22 /\x3E            \x09\x09\x09");
}
$h.put("            \x09\x09");
});
$h.put("            \x09\x3C/div\x3E\x09            \x3Cdiv class\x3D\x22cl\x22\x3E\x3C/div\x3E            \x3C/div\x3E        ");
}
$h.put("    ");
}
$h.put("    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("permissionNotice", $l));
}());
$h.put("    \x3Cdiv class\x3D\x22thread_info\x22\x3E        ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentCount", $l));
}());
$h.put("        ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentSort", $l));
}());
$h.put("        \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E        \x3Cdiv id\x3D\x22updates_and_follow\x22\x3E            \x3Cdiv id\x3D\x22notice_and_alert\x22\x3E                ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("realtimeNotice", $l));
}());
$h.put("                ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("realtimeAlert", $l));
}());
$h.put("            \x3C/div\x3E            \x3Cdiv id\x3D\x22dsq\x2Dsubscribe\x22\x3E                ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("subscribe", $l));
}());
$h.put("            \x3C/div\x3E            \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E        \x3C/div\x3E        \x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E    \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["comments"] = function block_comments ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cul id\x3D\x22dsq\x2Dcomments\x22\x3E      ");
$d.each(comments, function (comment, $index, $collection) {
var $locals = { "comment": comment, "index": $index };
$h.put("          ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("comment", $l));
}());
$h.put("      ");
});
$h.put("    \x3C/ul\x3E    \x3Cdiv class\x3D\x22cl\x22\x3E\x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["realtimeAlert"] = function block_realtimeAlert ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("  ");
if (context.realtime_enabled && !forum.streaming_realtime) { 
$h.put("    \x3Cdiv style\x3D\x22display:none\x3B\x22 class\x3D\x22dsq\x2Dnotice dsq\x2Drealtime\x2Dalert\x22\x3E\x3C/div\x3E  ");
}
return $h.compile();

}

};
$d.blocks["commentLikes"] = function block_commentLikes ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Ca onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.showUserVotes\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B return false\x22\x3E        \x3Cimg class\x3D\x22interesting\x22 src\x3D\x22http://www.telegraph.co.uk/template/ver1\x2D0/i/disqus/dsq\x2Dicon\x2Drecommend.png\x22 alt\x3D\x22Comment like count\x22 title\x3D\x22Comment recommend count\x22 /\x3E    \x3C/a\x3E    \x3Ca id\x3D\x22dsq\x2Dcomment\x2Dlike\x2Dcount\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 class\x3D\x22dsq\x2Dcomment\x2Dlike\x2Dcount\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.showUserVotes\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B return false\x22\x3E    ");
if (comment.points > 1) { 
$h.put("        ");
$h.put(trans("Recommended by "));
$h.put(($h.esc || function (s) { return s; })(comment.points));
$h.put(trans(" people"));
$h.put("    ");
} else {
$h.put("        ");
$h.put(trans("Recommended by "));
$h.put(($h.esc || function (s) { return s; })(comment.points));
$h.put(trans(" person"));
$h.put("    ");
}
$h.put("    \x3C/a\x3E");
return $h.compile();

}

};
$d.blocks["commentMessage"] = function block_commentMessage ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("  \x3Cdiv class\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(cls));
$h.put("\x22 id\x3D\x22dsq\x2Dcomment\x2Dmessage\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22\x3E    ");
if (comment.killed) { 
$h.put("      \x3Cem\x3E");
$h.put(trans("Comment removed."));
$h.put("\x3C/em\x3E    ");
} else if (!comment.approved) {
$h.put("      \x3Cem\x3E");
$h.put(trans("This comment was flagged for review."));
$h.put("\x3C/em\x3E    ");
} else {
$h.put("      ");
$h.put("      \x3Cdiv class\x3D\x22dsq\x2Dcomment\x2Dtext\x22 id\x3D\x22dsq\x2Dcomment\x2Dtext\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22\x3E        ");
$h.put(($h.esc || function (s) { return s; })(comment.message));
$h.put("      \x3C/div\x3E      ");
$h.put("      ");
if (forum.comment_max_words != 0) { 
$h.put("        \x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dcomment\x2Dtruncate\x2Dexpand\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27comments.text.expand\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22\x3E ");
$h.put(trans("show more"));
$h.put("\x3C/a\x3E        \x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dcomment\x2Dtruncate\x2Dcollapse\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27comments.text.collapse\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22\x3E ");
$h.put(trans("show less"));
$h.put("\x3C/a\x3E      ");
}
$h.put("      ");
if (comment.last_modified_by == 'moderator') { 
$h.put("        \x3Cp class\x3D\x22dsq\x2Deditedtxt\x22\x3E(");
$h.put(trans("Edited by a moderator"));
$h.put(")\x3C/p\x3E      ");
} else if (comment.last_modified_by == 'author' && comment.has_replies) {
$h.put("        \x3Cp class\x3D\x22dsq\x2Deditedtxt\x22\x3E(");
$h.put(trans("Edited by author"));
$h.put(" ");
$h.put(($h.esc || function (s) { return s; })(comment.last_modified_date));
$h.put(")\x3C/p\x3E      ");
}
$h.put("    ");
}
$h.put("  \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["commentFooter"] = function block_commentFooter ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cdiv class\x3D\x22dsq\x2Dcomment\x2Dfooter\x22\x3E        \x3Cul class\x3D\x22dsq\x2Dcomment\x2Dactions\x22\x3E            ");
if (comment.votable) { 
$h.put("                \x3Cli style\x3D\x22");
if (!comment.points) { 
$h.put("display: none\x3B");
}
$h.put("\x22\x3E                    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentLikes", $l));
}());
$h.put("                \x3C/li\x3E                \x3Cli id\x3D\x22dsq\x2Dlike\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 ");
if (comment.up_voted) { 
$h.put("class\x3D\x22dsq\x2Dis\x2Dliked\x22");
}
$h.put("\x3E                    ");
if (comment.up_voted) { 
$h.put("                        \x3Ca onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.like\x27, this, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B return false\x22\x3EUndo\x3C/a\x3E                    ");
} else {
$h.put("                        \x3Ca onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.like\x27, this, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B return false\x22\x3ERecommend\x3C/a\x3E                    ");
}
$h.put("                \x3C/li\x3E            ");
} else {
$h.put("                \x3Cli style\x3D\x22");
if (!comment.points) { 
$h.put("display: none\x3B");
}
$h.put("\x22\x3E                    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("commentLikes", $l));
}());
$h.put("                \x3C/li\x3E            ");
}
$h.put("            ");
if (comment.can_reply && request.is_authenticated) { 
$h.put("                \x3Cli\x3E                    \x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dcomment\x2Dreply\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.reply\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(", this)\x3B return false\x22\x3E");
$h.put(trans("Reply"));
$h.put("\x3C/a\x3E                \x3C/li\x3E            ");
}
$h.put("            ");
if (comment.can_edit) { 
$h.put("                \x3Cli\x3E                    \x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dcomment\x2Dreply\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.edit\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B return false\x22\x3EEdit\x3C/a\x3E                \x3C/li\x3E            ");
}
$h.put("            ");
if (request.is_moderator && request.is_authenticated) { 
$h.put("                \x3Cli class\x3D\x22dsq\x2Dcomment\x2Dmoderate last\x2Dchild\x22\x3E                    \x3Ca href\x3D\x22#\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27comments.moderate.options\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(")\x3B\x22\x3E");
$h.put(trans("Moderate"));
$h.put("\x3C/a\x3E                \x3C/li\x3E            ");
} else {
$h.put("                \x3Cli class\x3D\x22dsq\x2Dcomment\x2Dflag last\x2Dchild\x22\x3E                    \x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dcomment\x2Dflag dsq\x2Dfont\x22 onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27comments.report\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(", false)\x3B\x22\x3EReport\x3C/a\x3E                \x3C/li\x3E            ");
}
$h.put("        \x3C/ul\x3E    \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["editArea"] = function block_editArea ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cdiv class\x3D\x22dsq\x2Dreply dsq\x2Dedit\x22\x3E    \x09\x3Cdiv class\x3D\x22dsq\x2Dtextarea dsq\x2Dtextarea\x2Dreply\x22\x3E\x09\x09\x09\x3Cdiv class\x3D\x22dsq\x2Dtextarea\x2Dbackground\x22\x3E\x09\x09\x09\x09\x3Cdiv class\x3D\x22dsq\x2Dtextarea\x2Dwrapper\x22\x3E\x09\x09\x09\x09\x09\x3Ctextarea class\x3D\x22dsq\x2Dedit\x2Dtextarea\x22 id\x3D\x22dsq\x2Dedit\x2Dtextarea\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(comment.message));
$h.put("\x3C/textarea\x3E\x09\x09\x09\x09\x09\x3Cdiv id\x3D\x22dsq\x2Dedit\x2Diframe\x2D");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put("\x22 style\x3D\x22display:none\x22\x3E\x3C/div\x3E\x09\x09\x09\x09\x3C/div\x3E\x09\x09\x09\x3C/div\x3E\x09\x09\x3C/div\x3E\x09\x09\x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E        \x3Cdiv class\x3D\x22dsq\x2Dsave\x2Dedit\x22\x3E            \x3Cbutton type\x3D\x22button\x22 class\x3D\x22dsq\x2Dbutton\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27comments.edit.send\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment.id));
$h.put(", this)\x3B\x22\x3E");
$h.put(trans("Save edit"));
$h.put("\x3C/button\x3E        \x3C/div\x3E    \x09\x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E    \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["reaction"] = function block_reaction ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cli id\x3D\x22dsq\x2Dreaction\x2D");
$h.put(($h.esc || function (s) { return s; })(reaction.id));
$h.put("\x22 class\x3D\x22dsq\x2Dreaction\x22\x3E        \x3Cdiv class\x3D\x22dsq\x2Dcomment\x2Dbody dsq\x2Dreaction\x2Dbody\x22\x3E\x09\x09\x09\x3Cdiv class\x3D\x22dsq\x2Davatar dsq\x2Dreaction\x2Davatar\x22 data\x2Ddsq\x2Dcontent\x2Did\x3D\x22dsq\x2Dreaction\x2Dtooltip\x2D");
$h.put(($h.esc || function (s) { return s; })(reaction.id));
$h.put("\x22\x3E\x09\x09\x09\x09");
if (reaction.url) { 
$h.put("\x3Ca target\x3D\x22_blank\x22 href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(reaction.url));
$h.put("\x22\x3E");
}
$h.put("\x09\x09\x09\x09\x09\x3Cimg class\x3D\x22reaction_avatar\x22 src\x3D\x22");
if (reaction.avatar_url) { 
$h.put(($h.esc || function (s) { return s; })(reaction.avatar_url));
} else {
$h.put(($h.esc || function (s) { return s; })(forum.default_avatar_url));
}
$h.put("\x22 alt\x3D\x22Commenter\x27s avatar\x22 /\x3E\x09\x09\x09\x09");
if (reaction.url) { 
$h.put("\x3C/a\x3E");
}
$h.put("\x09\x09\x09\x3C/div\x3E\x09\x09\x09\x3Cdiv id\x3D\x22dsq\x2Dreaction\x2Dtooltip\x2D");
$h.put(($h.esc || function (s) { return s; })(reaction.id));
$h.put("\x22 class\x3D\x22dsq\x2Dreaction\x2Dtooltip dsq\x2Dcomment\x2Dheader\x22\x3E\x09\x09\x09\x09\x3Cp class\x3D\x22dsq\x2Dreaction\x2Duser\x22\x3E                    \x3Cspan class\x3D\x22reaction\x2Dauthor\x2Dname\x22\x3E");
if (reaction.url) { 
$h.put("\x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(reaction.url));
$h.put("\x22 title\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(reaction.author_name));
$h.put("\x22\x3E");
}
$h.put(($h.esc || function (s) { return s; })(reaction.author_name));
if (reaction.url) { 
$h.put("\x3C/a\x3E");
}
$h.put("\x3C/span\x3E                    \x3Cspan\x3E on \x3Cimg class\x3D\x22dsq\x2Dservice\x2Dicon\x22 src\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(settings.media_url));
$h.put("/images/reactions/services/");
$h.put(($h.esc || function (s) { return s; })(reaction.service_icon));
$h.put(".png\x22 /\x3E \x3Ca class\x3D\x22dsq\x2Dservice\x2Dname\x22 href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(reaction.url));
$h.put("\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(reaction.get_service_name));
$h.put("\x3C/a\x3E\x3C/span\x3E                \x3C/p\x3E                \x3Cp class\x3D\x22dsq\x2Dreaction\x2Ddate\x22\x3E\x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(reaction.url));
$h.put("\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(reaction.date_created));
$h.put("\x3C/a\x3E\x3C/p\x3E                ");
if (request.is_moderator) { 
$h.put("                    \x3Cp\x3E\x3Ca href\x3D\x22#\x22 class\x3D\x22dsq\x2Dremove\x2Dreaction\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27reactions.hide\x27, ");
$h.put(($h.esc || function (s) { return s; })(reaction.id));
$h.put(")\x3B return false\x22\x3E(Hide this)\x3C/a\x3E\x3C/p\x3E                ");
}
$h.put("            \x3C/div\x3E        \x3C/div\x3E    \x09\x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E        \x3Cdiv class\x3D\x22dsq\x2Dreaction\x2Dmessage dsq\x2Dcomment\x2Dmessage\x22\x3E            ");
$h.put(($h.esc || function (s) { return s; })(reaction.body));
$h.put("\x09\x09\x09\x3Cdiv style\x3D\x22clear: both\x22\x3E\x3C/div\x3E\x09\x09\x3C/div\x3E\x09\x3C/li\x3E");
return $h.compile();

}

};
$d.blocks["pagination"] = function block_pagination ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cul id\x3D\x22dsq\x2Dfooter\x22 class\x3D\x22dsq\x2Dclearfix\x22\x3E        ");
if (thread.pagination_type == 'num' && thread.num_pages > 1) { 
$h.put("            \x3Cli class\x3D\x22dsq\x2Dnumbered\x2Dpagination\x22\x3E            ");
$h.put("            ");
if (request.page > 1) { 
$h.put("                \x26larr\x3B                ");
$h.put("\x3Ca href\x3D\x22#dsq\x2Dcomments\x22 title\x3D\x22");
$h.put(trans("Previous"));
$h.put("\x22                    onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.paginate\x27,");
$h.put(($h.esc || function (s) { return s; })(request.page - 1));
$h.put(")\x3B return false\x22\x3E");
$h.put(trans("Previous"));
$h.put("\x3C/a\x3E");
$h.put("                \x26nbsp\x3B            ");
}
$h.put("            ");
$h.put("            ");
if (request.page != 1 && !lang.contains(thread.page_numbers, 1)) { 
$h.put("              \x3Ca href\x3D\x22#dsq\x2Dcomments\x22                 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.paginate\x27, 1)\x3B return false\x22\x3E1\x3C/a\x3E              \x26hellip\x3B            ");
}
$h.put("            ");
$d.each(thread.page_numbers, function (number, $index, $collection) {
var $locals = { "number": number, "index": $index };
$h.put("                ");
if (request.page == number) { 
$h.put("\x3Cspan class\x3D\x22current_page\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(number));
$h.put("\x3C/span\x3E");
} else {
$h.put("\x3Ca href\x3D\x22#dsq\x2Dcomments\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.paginate\x27,");
$h.put(($h.esc || function (s) { return s; })(number));
$h.put(")\x3B return false\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(number));
$h.put("\x3C/a\x3E");
}
$h.put("            ");
});
$h.put("            ");
$h.put("            ");
if (request.page != thread.num_pages && !lang.contains(thread.page_numbers, thread.num_pages)) { 
$h.put("                \x26hellip\x3B                ");
$h.put("\x3Ca href\x3D\x22#dsq\x2Dcomments\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.paginate\x27,");
$h.put(($h.esc || function (s) { return s; })(thread.num_pages));
$h.put(")\x3B return false\x22\x3E");
$h.put(($h.esc || function (s) { return s; })(thread.num_pages));
$h.put("\x3C/a\x3E");
$h.put("            ");
}
$h.put("            ");
$h.put("            ");
if (request.page < thread.num_pages) { 
$h.put("                \x26nbsp\x3B                ");
$h.put("\x3Ca href\x3D\x22#dsq\x2Dcomments\x22  title\x3D\x22");
$h.put(trans("Next"));
$h.put("\x22                    onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.paginate\x27,");
$h.put(($h.esc || function (s) { return s; })(request.page + 1));
$h.put(")\x3B return false\x22\x3E");
$h.put(trans("Next"));
$h.put("\x3C/a\x3E");
$h.put("                \x26rarr\x3B            ");
}
$h.put("            \x3C/li\x3E        ");
}
$h.put("    \x3C/ul\x3E    ");
if (thread.pagination_type == 'append' && thread.num_pages > 1) { 
$h.put("        ");
if (request.page < thread.num_pages) { 
$h.put("            \x3Ca class\x3D\x22dsq\x2Dmore\x2Dbutton\x22                onclick\x3D\x22return DISQUS.dtpl.actions.fire(\x27thread.paginate\x27, ");
$h.put(($h.esc || function (s) { return s; })(request.page + 1));
$h.put(", this)\x3B\x22\x3E            ");
$h.put(trans("Load more comments"));
$h.put("            \x3C/a\x3E        ");
}
$h.put("    ");
}
return $h.compile();

}

};
$d.blocks["permissionNotice"] = function block_permissionNotice ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("  ");
if (request.missing_perm && request.missing_perm.match(/locked|blacklist|verify/)) { 
$h.put("  \x3Cdiv class\x3D\x22dsq\x2Dnotice\x22\x3E    ");
if (request.missing_perm == 'locked') { 
$h.put("      ");
$h.put(trans("Comments for this page are closed."));
$h.put("    ");
} else if (request.missing_perm == 'blacklist') {
$h.put("      ");
$h.put(trans("The site has blocked you from posting new comments."));
$h.put("    ");
} else if (request.missing_perm == 'verify') {
$h.put("      ");
$h.put(trans("You must verify your Disqus Profile email address before your comments are approved."));
$h.put("      \x3Ca href\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(urls.verify_email));
$h.put("\x22 target\x3D\x22_blank\x22\x3E");
$h.put(trans("Click here to verify"));
$h.put("\x3C/a\x3E    ");
}
$h.put("  \x3C/div\x3E  ");
}
return $h.compile();

}

};
$d.blocks["thread"] = function block_thread ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("  ");
if (request.is_authenticated && request.is_moderator) { 
$h.put("    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("globalToolbar", $l));
}());
$h.put("  ");
}
$h.put("  ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("header", $l));
}());
$h.put("  ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("comments", $l));
}());
$h.put("  ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("footer", $l));
}());
return $h.compile();

}

};
$d.blocks["footer"] = function block_footer ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cdiv id\x3D\x22dsq\x2Dpagination\x22\x3E        ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("pagination", $l));
}());
$h.put("    \x3C/div\x3E    \x3Cdiv class\x3D\x22showDisqusIcon showDisqusIconFooter\x22\x3E\x3C/div\x3E   ");
if (integration.reply_position) { 
$h.put("        ");
if (context.show_reply) { 
$h.put("            ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("postbox", $l));
}());
$h.put("        ");
}
$h.put("    ");
}
$h.put("    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("reactions", $l));
}());
$h.put("    ");
(function () {
var $l = {};
$d.extend($l, $locals);
$d.extend($l, {});
$h.put($d.renderBlock("trackbacks", $l));
}());
return $h.compile();

}

};
$d.blocks["cookieFailure"] = function block_cookieFailure ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cp class\x3D\x22dsq\x2Dnotice dsq\x2Derror\x22\x3E      \x3Cstrong\x3E");
$h.put(trans("Warning"));
$h.put(":\x3C/strong\x3E ");
$h.put(trans("A browser setting is preventing you from logging in."));
$h.put("      ");
$h.put("\x3Ca href\x3D\x22#\x22 onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27help.login\x27)\x3B return false\x22\x3E");
$h.put(trans("Fix this setting to log in"));
$h.put("\x3C/a\x3E");
$h.put("    \x3C/p\x3E");
return $h.compile();

}

};
$d.blocks["commentSort"] = function block_commentSort ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

$h.put("    \x3Cdiv id\x3D\x22dsq\x2Dsort\x2Dby\x22\x3E        \x3Clabel for\x3D\x22dsq\x2Dsort\x2Dselect\x22\x3EOrder by\x3C/label\x3E        \x3Cselect name\x3D\x22dsq\x2Dsort\x2Dselect\x22 id\x3D\x22dsq\x2Dsort\x2Dselect\x22 onchange\x3D\x22DISQUS.dtpl.actions.fire(\x27thread.sort\x27, this.value)\x3B\x22\x3E            ");
$d.each(sorting, function (option, $index, $collection) {
var $locals = { "option": option, "index": $index };
$h.put("            \x3Coption value\x3D\x22");
$h.put(($h.esc || function (s) { return s; })(option.value));
$h.put("\x22 ");
if (option.selected) { 
$h.put("selected\x3D\x22selected\x22");
}
$h.put("\x3E                ");
$h.put(($h.esc || function (s) { return s; })(option.label.toLowerCase()));
$h.put("            \x3C/option\x3E            ");
});
$h.put("        \x3C/select\x3E    \x3C/div\x3E");
return $h.compile();

}

};
$d.blocks["commentShare"] = function block_commentShare ($globals, $locals) {

    var $h = new $d.Builder();

    var localScope = DISQUS.extend({}, $globals, $locals);
    with (localScope) {

if (request.is_authenticated && (request.sharing.twitter.enabled || request.sharing.facebook.enabled)) { 
$h.put("\x3Cdiv class\x3D\x22sm_share_buttons\x22\x3E\x3Cp\x3EShare on: \x26nbsp\x3B\x3C/p\x3E");
if (request.sharing.twitter.enabled) { 
$h.put("\x3Cspan class\x3D\x22dsq\x2Dshare\x2Dtwitter\x22onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27share.toggle\x27, this, \x27twitter\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment ? comment.id : 'null'));
$h.put(")\x3B\x22\x3ETwitter\x3C/span\x3E");
}
if (request.sharing.facebook.enabled) { 
$h.put("\x3Cspan class\x3D\x22dsq\x2Dshare\x2Dfacebook\x22onclick\x3D\x22DISQUS.dtpl.actions.fire(\x27share.toggle\x27, this, \x27facebook\x27, ");
$h.put(($h.esc || function (s) { return s; })(comment ? comment.id : 'null'));
$h.put(")\x3B\x22\x3EFacebook\x3C/span\x3E");
}
$h.put("\x3C/div\x3E");
}
return $h.compile();

}

};
    });

(function (window, undefined) {
var document = window.document, DISQUS = window.DISQUS;

// CAUTION!
// If you modify this function, bear in mind that
// it is used by both Custom and Next so be careful!
DISQUS.registerActions = function () {
    /**
 * Actions for the Houdini theme
 */

var add = DISQUS.dtpl.actions.register;
var fire = DISQUS.dtpl.actions.fire;

function eachChildComment(id, callback) {
    var container = DISQUS.nodes.get('#dsq-comments'),
        comments = DISQUS.nodes.get('li.dsq-comment', container),
        start = -1,
        root,
        i;

    // Find *all* comment elements on the page. Locate the triggered
    // comment, and its location (index) in the result set.

    for (i = 0; i < comments.length; i++) {
        if (comments[i].id == 'dsq-comment-' + id) {
            root = comments[i];
            start = i + 1;
            break;
        }
    }
    if (start == -1) {
        return; // should never happen
    }

    // Helper method returns the depth of a comment element.
    function getdepth(node) {
        var id = node.getAttribute('data-dsq-comment-id');
        return DISQUS.jsonData.posts[id].depth;
    }

    var rootDepth = getdepth(root),
        root;

    for (i = start; i < comments.length; i++) {
        node = comments[i];

        if (getdepth(node) <= rootDepth) {
            break;
        }
        callback(node);
    }
}

add('comments.reply.onCookieFailure', function(id) {
    var noticeId = 'dsq-cookie-failure-notice' + (id ? '-' + id : '');
    if (DISQUS.nodes.get('#' + noticeId)) {
        // Already on page
        return;
    }

    var div = document.createElement('div');
    div.id = noticeId;
    div.innerHTML = DISQUS.renderBlock('cookieFailure');

    DISQUS.nodes.insertAfter(
        DISQUS.nodes.get('#dsq-reply' + (id ? '-' + id : '')),
        div
    );
});

add('comments.reply.onFocus', function(id) {
    // Only affects top-level reply box; replies-to-comments are
    // already expanded
    if (id) {
        return;
    }

    var reply = DISQUS.nodes.get('#dsq-reply');
    DISQUS.nodes.addClass(reply, 'dsq-show-tools');

    // Apply this class after some ms has passed in order to
    // trigger CSS3 transition animation
    var cb = setInterval(function() {
        DISQUS.nodes.addClass(reply, 'dsq-show-tools-finished');
        clearInterval(cb);
    }, 180);
});

add('comments.reply.onResize', function(id, height) {
    var reply = DISQUS.nodes.get('#dsq-reply' + (id ? '-' + id : ''));

    var wrapper = DISQUS.nodes.get('.dsq-textarea-wrapper', reply)[0];
    if (wrapper.style.height !== 'auto') {
        wrapper.style.height = 'auto';
    }

    var frame = DISQUS.nodes.get('iframe', wrapper)[0];
    frame.style.height = parseInt(height, 10) + 'px';
    if (DISQUS.browser.ie && frame.style.width !== '100%') {
        frame.style.width = '100%';
    }

    frame.style.height = parseInt(height, 10) + 'px';
});

/**
 * Reply box open loading animation
 */
add('comments.reply.new.onLoadingStart', function(id) {
    var reply   = DISQUS.nodes.get('#dsq-reply' + (id ? '-' + id : '')),
        wrapper = DISQUS.nodes.get('div.dsq-textarea-wrapper', reply)[0];

    DISQUS.nodes.addClass(wrapper, 'dsq-textarea-loading');

    var loading = document.createElement('div');
    loading.innerHTML = DISQUS.strings.get('Please wait') + '&hellip;';
    DISQUS.nodes.addClass(loading, 'dsq-textarea-loading-text');
    wrapper.appendChild(loading);
});

add('comments.reply.new.onLoadingEnd', function(id) {
    var reply   = DISQUS.nodes.get('#dsq-reply' + (id ? '-' + id : '')),
        wrapper = DISQUS.nodes.get('div.dsq-textarea-wrapper', reply)[0],
        loading = DISQUS.nodes.get('div.dsq-textarea-loading-text', wrapper)[0];

    DISQUS.nodes.remove(loading);
    DISQUS.nodes.removeClass(wrapper, 'dsq-textarea-loading');
});

add('comments.reply.media.upload.onLoadingStart', function(id) {
    var wrapper = DISQUS.nodes.get('#dsq-reply' + (id ? ('-' + id) : ''));
    var button = DISQUS.nodes.get('.dsq-button', wrapper)[0];

    // called right before the image is uploaded
    fire('private.setLoadingButton', button);
});

add('comments.reply.media.upload.onLoadingEnd', function(id) {
    fire('private.setLoadingButton');
});

add('comments.reply.media.upload.onSuccess', function(data, id) {

    // create image preview
    var wrapper = document.createElement('div');
    var close = document.createElement('a');
    var thumb = document.createElement('a');
    id = id || '';

    wrapper.className = 'dsq-media-wrapper';
    wrapper.appendChild(close);
    wrapper.appendChild(thumb);

    // massage the data object
    var media = data;
    data = {
        forum_id: DISQUS.jsonData.forum.id,
        thread_id: DISQUS.jsonData.thread.id,
        id: id,
        media: media
    };

    // create close button and bind close event
    close.href = '#';
    close.className = 'dsq-media-image-close';
    DISQUS.events.add(close, 'click', function(event) {
        DISQUS.dtpl.actions.fire('comments.reply.media.remove', data, id);
        event.preventDefault();
    });

    // create the thumbnail and bind popup
    thumb.href = '#';
    thumb.innerHTML = '<img class="dsq-media-image" src="' + media.thumbnailURL + '" />';
    DISQUS.events.add(thumb, 'click', function(event) {
        DISQUS.popup.popModal(
            DISQUS.renderBlock('mediaEmbedPopup', { media: media }),
            DISQUS.strings.get('Attached file'),
            null, true, 'dsq-media-embed');
        event.preventDefault();
    });

    // add hover events to close image
    DISQUS.events.add(thumb, 'mouseover', function(event) {
        event.preventDefault();
        DISQUS.nodes.show(close);
    });
    DISQUS.events.add(thumb, 'mouseout', function(event) {
        event.preventDefault();
        DISQUS.nodes.hide(close);
    });
    DISQUS.events.add(close, 'mouseover', function(event) {
        event.preventDefault();
        DISQUS.nodes.show(close);
    });
    DISQUS.events.add(close, 'mouseout', function(event) {
        event.preventDefault();
        DISQUS.nodes.hide(close);
    });

    // initially hide the close button
    DISQUS.nodes.hide(close);

    // get preview pane, and insert into DOM
    var preview = DISQUS.nodes.get('#dsq-media-preview' + (id ? ('-' + id) : ''));
    preview.appendChild(wrapper);
    DISQUS.nodes.show(preview);

});

add('comments.reply.media.remove.onSuccess', function(data) {

    // fired immediately after we the removal response from the server
    var preview = DISQUS.nodes.get('#dsq-media-preview' + (data.id ? ('-' + data.id) : ''));
    var regex;
    if (data && data.media && data.media.thumbnail) {
        regex = new RegExp(data.media.thumbnail, 'i');
    }

    // sanity check
    if (!regex || !preview) {
        return;
    }

    // remove matching images from preview pane
    DISQUS.each(DISQUS.nodes.get('img', preview), function(elem) {
        if (regex.test(elem.src)) {
            elem = DISQUS.nodes.closest(elem, '.dsq-media-wrapper');
            elem.parentNode.removeChild(elem);
            return;
        }
    });

    // if there are no more images, hide the preview pane
    if (!DISQUS.nodes.get('.dsq-media-wrapper').length) {
        DISQUS.nodes.hide(preview);
    }

});


add('comments.reply.media.upload.clear', function(id) {
    var elem = DISQUS.nodes.get('#dsq-media-preview' + (id ? ('-' + id) : ''));
    if (elem) {
        elem.innerHTML = '';
    }
});

/**
 * Collapse a comment
 */
add('comments.collapse', function(id) {
    var root = DISQUS.nodes.get('#dsq-comment-' + id);
    DISQUS.nodes.addClass(root, 'dsq-comment-is-collapsed');

    eachChildComment(id, function(node) {
        // Only hide child comments that aren't already hidden by another child
        if (!node.getAttribute('data-dsq-collapsed-parent-id')) {
            node.style.display = 'none';
            node.setAttribute('data-dsq-collapsed-parent-id', id);
        }
    });
});

/**
 * Expand a comment
 */
add('comments.expand', function(id) {
    var root = DISQUS.nodes.get('#dsq-comment-' + id);
    DISQUS.nodes.removeClass(root, 'dsq-comment-is-collapsed');

    eachChildComment(id, function(node) {
        // Only reveal child comments that were directly hidden by this comment
        if (node.getAttribute('data-dsq-collapsed-parent-id') == id) {
            node.style.display = 'block';
            node.removeAttribute('data-dsq-collapsed-parent-id');
        }
    });
});

add('comments.insert.onSuccess', function(afterId, id) {
    var comment = DISQUS.nodes.get('#dsq-comment-' + id);
    DISQUS.nodes.addClass(comment, 'dsq-comment-new');
    var cb = setInterval(function() {
        // Delayed second class to trigger CSS3 transition
        DISQUS.nodes.addClass(comment, 'dsq-comment-new-reveal');
        clearInterval(cb);
    }, 100);
});

add('comments.like.onLoadingStart', function(id) {
    var like = DISQUS.nodes.get('#dsq-like-' + id);
    DISQUS.nodes.addClass(like, 'dsq-loading');
});

add('comments.like.onLoadingEnd', function(id) {
    var like = DISQUS.nodes.get('#dsq-like-' + id);
    DISQUS.nodes.removeClass(like, 'dsq-loading');
});

add('comments.like.onSuccess', function(id, points, vote) {
    var count = DISQUS.nodes.get("#dsq-comment-like-count-" + id),
        container = DISQUS.nodes.get('#dsq-like-' + id),
        link = DISQUS.nodes.get('a', container)[0];

    if (points > 0) {
        successText = points + ' ' + DISQUS.strings.pluralize(points, 'Like', 'Likes');
        count.innerHTML = successText;
        count.style.display = 'inline';
    } else {
        count.style.display = 'none';
    }

    if (vote > 0) {
        link.innerHTML = DISQUS.strings.get('Liked');
        DISQUS.nodes.addClass(container, 'dsq-is-liked');
    } else {
        link.innerHTML = DISQUS.strings.get('Like')
        DISQUS.nodes.removeClass(container, 'dsq-is-liked');
    }
});

add('thread.paginate.onLoadingStart', function() {
    if (DISQUS.jsonData.thread.pagination_type == 'num') {
        DISQUS.window.anchor('disqus_thread');

        // Replace entire comment thread with regular spinner
        DISQUS.nodes.get('#dsq-comments').innerHTML =
            '<img src="' + DISQUS.jsonData.settings.media_url + '/images/loading.gif"/>';
    } else {
        // Replace pagination area with small spinner
        DISQUS.nodes.get('#dsq-pagination').innerHTML =
            '<img src="' + DISQUS.jsonData.settings.media_url + '/images/loading-small.gif"/>';
    }
});

add('thread.paginate.onLoadingEnd', function() {
    // DO NOTHING
});

add('thread.sort.onLoadingStart', function(type) {
    DISQUS.nodes.get('#dsq-comments').innerHTML =
        '<img src="' + DISQUS.jsonData.settings.media_url + '/images/loading.gif"/>';
});

add('thread.sort.onLoadingEnd', function(type) {
    // DO NOTHING
});

add('thread.subscribe.onSuccess', function() {
    var title = DISQUS.strings.get('Subscribed');
    var message = DISQUS.strings.get('You have subscribed to this comment thread. New comments will be sent directly to your email inbox, where you may read and respond by email.');

    DISQUS.popup.popModal(message, title);

    var subscribe = DISQUS.nodes.get('#dsq-subscribe');
    subscribe.innerHTML = DISQUS.renderBlock('subscribe');
});

add('thread.unsubscribe.onSuccess', function() {
    var title = DISQUS.strings.get('Unsubscribed');
    var message = DISQUS.strings.get('You have unsubscribed from this comment thread. New comments will no longer be sent to your email inbox.');

    DISQUS.popup.popModal(message, title);

    var subscribe = DISQUS.nodes.get('#dsq-subscribe');
    subscribe.innerHTML = DISQUS.renderBlock('subscribe');
});

add('comments.delete.onSuccess', function(id) {
    var comment = DISQUS.nodes.get('#dsq-comment-' + id);
    comment.style.display = 'none';

    var notice = document.createElement('div');
    notice.id = 'dsq-comment-restore-' + id;
    DISQUS.nodes.addClass(notice, 'dsq-notice');
    notice.innerHTML =
        '<a href="#" onclick="return DISQUS.dtpl.actions.fire(\'comments.restore\', ' + id + ');">' +
            DISQUS.strings.get('Undo') +
        '</a>';
    comment.parentNode.insertBefore(notice, comment);
});

add('comments.restore.onSuccess', function(id) {
    var notice = DISQUS.nodes.get('#dsq-comment-restore-' + id);
    DISQUS.nodes.remove(notice);

    var comment = DISQUS.nodes.get('#dsq-comment-' + id);
    comment.style.display = 'block';
});

add('comments.spam.onSuccess', function(id) {
    var comment = DISQUS.nodes.get('#dsq-comment-' + id);
    comment.style.display = 'none';
    var notice = document.createElement('div');
    DISQUS.nodes.addClass(notice, 'dsq-notice');
    notice.innerHTML = DISQUS.strings.get('Comment marked as spam.');

    comment.parentNode.insertBefore(notice, comment);
});

};

/*
 * Alias for registerActions
 * because this function is used in Next
 * to load a bunch of Javascript files that
 * contain DISQUS.define's
 */
DISQUS.runThemeScript = DISQUS.registerActions;

}(this));
