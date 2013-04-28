var omniture_vars = new Array('wp_photo_gallery','wp_photo_name','wp_search_keywords','wp_search_type','wp_sectionfront','wp_content_type','wp_content_id','wp_headline','wp_page_name','wp_section','wp_subsection','wp_author','wp_page_num','wp_channel','wp_hierarchy','wp_application','wp_source','wp_topic','wp_blog_name','wp_story_id','wp_events','wp_printed','wp_search_result_count');

function echoOmniture() {
	if ( location.search.match(/debugOmniture/) ) {
		var output = '' ;
		for (var i=0; i<omniture_vars.length; i++) {
			var o_var = omniture_vars[i] ;
			try {
				output += '<b>' + o_var + '</b> = \'' + eval(o_var) + '\' ;<br/>' ;
			} catch(error) {
				output += '<b>' + o_var + '</b> is not defined<br/>' ;
			}
		}
		document.write(output);
	}
}