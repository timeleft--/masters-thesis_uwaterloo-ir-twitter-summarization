if(typeof WAPOLABS_PARTNERS_ON != 'undefined' && WAPOLABS_PARTNERS_ON){
		var adOptions = [];
		adOptions.push({
			width: 'auto', 
			height: 'auto',  
			container: 'wapoLabsPromoBox2'
		});
		if(typeof wp_article != 'undefined' && wp_article.id && wp_article.id.match(/^(AR|BL|DI)/)){
			adOptions.push({
				width: 'auto', 
				height: 'auto',  
				container: 'wapoLabsPromoBox'
			});
		 }
		if(commercialNode.match('sports')){
			adOptions.push({
				width: 'auto', 
				height: 'auto',  
				container: 'wapoLabsPromoBox3',
				finderOptions: { livingSocialOnWPSports:'true'}
			});
		 }
        (function(props){
            WAPOLabsPromoBox = {};
            WAPOLabsPromoBox.defaults = {
                "props":{
                    "containers":[
                        {
                            "tag":"div",
                            "id":"wapoLabsPromoBox",
                            "parent":"wrapperMainRight",
                            "setAdOptions":true
                        },{
                            "tag":"div",
                            "id":"wapo_338542",
                            "parent":"wrapperMainRight",
                            "setAdOptions":false
                        }
                    ]
                }
            }
            WAPOLabsPromoBox.Constants = {
                Domains:{
                    "live":"www.washingtonpost.com"
                },
                Scripts:{
                    "live": (function(){
                        return (typeof jQuery !== 'undefined' &&
                            jQuery.fn.jquery >= '1.4.2' &&
                            "http://media3.washingtonpost.com/wp-srv/wapolabs/revplat/prod/1_4_1/js/rev_platform_ads.min.js") ||
                            "http://media3.washingtonpost.com/wp-srv/wapolabs/revplat/prod/1_4_1/js/rev_platform_ads_jquery.min.js";
                     }()),
                    "test":"http://bunsen.wapolabs.com/revplat/test/1.4.1/js/rev_platform_ads.js",
                    "desktop":"./test.js"
                }
            }
            WAPOLabsPromoBox.Constants.Script = (!!(new String(location.hostname).match(WAPOLabsPromoBox.Constants.Domains.live)))?WAPOLabsPromoBox.Constants.Scripts.live:WAPOLabsPromoBox.Constants.Scripts.test;

            props=props||WAPOLabsPromoBox.defaults.props;


            for(var i=0;i<props.containers.length;i++){
                var container = props.containers[i];
                if ( document.getElementById(container.parent) ) {  
                    var tag = document.createElement(container.tag);
                    tag.id = container.id;
                    //if(container.setAdOptions){try{adOptions[0].container = container.id;}catch(e){}}
                    document.getElementById(container.parent).appendChild(tag);
                }
            }

            var script = document.createElement('script');
            // script.async = true;
            script.src = WAPOLabsPromoBox.Constants.Script;
            document.getElementsByTagName('head')[0].appendChild(script);

        }());
    } // if is an article
 // if WAPOLABS_PARTNERS_ON