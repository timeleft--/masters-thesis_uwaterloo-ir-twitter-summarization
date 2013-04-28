(function(global) {
	
	var w = getMegatagWindow(),
		_defaults = {
			url: ('https:'==w.document.location.protocol?'https://secure':'http://ib')+'.adnxs.com',
			mtjBase: '/mtj',
			ttjBase: '/ttj'
		},
		checker,	
		_processQueue = function() {
	 		if (global.window._anq && global.window._anq.length > 0) {
	 			for (var i = 0; i < global.window._anq.length; i++) {
	 				if (typeof global.window._anq[i].called === 'undefined') {
	 					global.window._anq[i].cmd();
	 	 				global.window._anq[i].called = true;
	 				}
	 			}
	 		}
	 		cleanUpCmds();
 		};

	getMegatagWindow().adnxs = !!getMegatagWindow().adnxs ? getMegatagWindow().adnxs : {};
	adnxs = getMegatagWindow().adnxs;
	adnxs.richmedia = adnxs.richmedia || {setSize: function() {}};
	adnxs.megatag = adnxs.megatag || {};
	adnxs.megatag.isCleanupSet = adnxs.megatag.isCleanupSet || false;
	adnxs.megatag.errors = adnxs.megatag.errors || [];
	adnxs.megatag.debug = false;
	adnxs.megatag.requests = adnxs.megatag.requests || [];
	
	adnxs.megatag.hasOwnProperty = function(o, p) {
		return (o.hasOwnProperty ? o.hasOwnProperty(p) : (!(typeof o[p] === 'undefined') && o.constructor.prototype[p] !== o[p]));
	}
	
	if (!adnxs.megatag.load) {
		adnxs.megatag.load = function(rawParams) {
			_load(rawParams);
		}
	}
	
	if (!adnxs.megatag.populateIframes) {
		adnxs.megatag.populateIframes = function(requestId) {
			populateIframes(requestId);
		}
	}
	
	if (!adnxs.megatag.forceAdCall) {
		adnxs.megatag.forceAdCall = adnxs.megatag.forceLoad = function(oParams) {
			if (!isAutoLoad()) {
				var params = oParams || {};
				var idsToLoad = [];
				
				if (params.adnxsId) {
				 	idsToLoad.push(params.adnxsId);
				} else {
					for (var i in adnxs.megatag.requests) {
						if (adnxs.megatag.hasOwnProperty(adnxs.megatag.requests, i)) {
							idsToLoad.push(i);
						}
					}
				}
				
				for (var i=0; i < idsToLoad.length; i++) {
					var request = adnxs.megatag.requests[idsToLoad[i]];
					if (request.placementCount && request.placementsLoaded !== request.placementCount) {
						logError('Placement count does not match the number of placements loaded.');
					}
					
					try {
				 		writeMtjIframe({adnxsId: idsToLoad[i]});
					} catch (err) {
						logError(err.message);
					}	
				}
				
			}
		}
	}
	
	if (!adnxs.megatag.refreshAds) {
		adnxs.megatag.refreshAds = function(oParams) {
			var adnxsId = (oParams ? oParams.adnxsId || null : null);
			_refreshAds(adnxsId);
		}
	}
	
	function _load(inputParams) {
		var params = renameParams(inputParams || window.adnxsRoadblockparams),
			tagId = '';
		
		params.adnxsId = params.adnxsId || window.adnxsId;
		
		if (params.debug) {
			adnxs.megatag.debug = params.debug;
		}
		
		if (!params.size) {
			logError('Size parameter not specified for ad spot. No ad will be shown for this spot.');
			return;
		}
		
		try {
			if (adnxs.megatag.requests[params.adnxsId] && adnxs.megatag.requests[params.adnxsId].mtjCalled === true) {
				throw new Error('A placement was loaded after mtj call was started. ' 
					+ 'It is possible that there are more placements on the page than the placement count indicates');
			}
			tagId = updateTags(params);
			writeMarker(params, tagId);
			writeIframe(params, tagId);
			if (adnxs.megatag.requests[params.adnxsId].isOnloadSet === false && isAutoLoad()) {
				setOnload(params);
			}
		} catch (err) {
			logError(err.message);
			writeTtjIframe(params);
		}
		
	}
	
	function _refreshAds(requestId) {
		var idsToRefresh = [];
		if (requestId) {
			idsToRefresh.push(requestId);
		} else { // get all the ids
			for (var i in adnxs.megatag.requests) {
				if (adnxs.megatag.hasOwnProperty(adnxs.megatag.requests, i)) {
					idsToRefresh.push(i);
				}
			}
		}
		
		for (var i=0; i < idsToRefresh.length; i++) {
			var id = idsToRefresh[i];
			adnxs.megatag.requests[id].mtjCalled = false;
			adnxs.megatag.requests[id].iframesPopulated = false;
			
			try {
				if (navigator.userAgent.indexOf('MSIE') !== -1) {
					doIEMtjCall(
						{adnxsId: id, mtjUri: adnxs.megatag.requests[id].mtjUri}, 
						adnxs.megatag.requests[id].mtjIframe
					);
				} else {
					doMtjCall(
						{adnxsId: id, mtjUri: adnxs.megatag.requests[id].mtjUri}, 
						adnxs.megatag.requests[id].mtjIframe
					);
				}	
			} catch (err) {
				logError(err.message);
			}
				
		}
	}
	
	function serializeParams(rawParams) {
		var params = "";
		
		for (var i in rawParams) {
			if (adnxs.megatag.hasOwnProperty(rawParams, i)) {
				params += renameParam(i) + '=' + encodeURIComponent(rawParams[i]) + '&';
			}
		}
		params = params.substring(0, params.length-1);
		
		return params;
	}
	
	function renameParams(rawParams) {
		var output = {};
		for (var i in rawParams) {
			if (adnxs.megatag.hasOwnProperty(rawParams, i)) {
				output[renameParam(i)] = rawParams[i];
			}
		}
		return output;
	}
	
	function renameParam(key) {
		switch (key) {
			case 'promoSizes':
				return 'promo_sizes';
			default:
				return key;
		}
	}
	
	function getScriptParams(serializedParams) {
		var params = {},
			rawParams = serializedParams,
			pair,
			regEx = /([^&=]+)=?([^&]*)/g,
			convertPlusToSpace = function (s) { return decodeURIComponent(s.replace(/\+/g, " ")); };
	
		while (pair = regEx.exec(rawParams)) {
			params[pair[1]] = convertPlusToSpace(pair[2]);
		}
		
		return params;
	}
		 	
	function getMegatagWindow() {
		if (w) {
			try {
				var documentCheck = w.document.a;
			} catch (err){ 
				w = detectMegatagWindow(); 
			}
		} else {
			w = detectMegatagWindow();
		}
		
		return w;
	}
	
	function detectMegatagWindow() {
		var candidateWindow,
			currentWindow,
			parentFrameSet = false;
		
		if (typeof adnxsMegatagWindow !== 'undefined') {
			candidateWindow = adnxsMegatagWindow;
		} else {
			try {
				var currentWindow = global.window;
				
				do {
					if (currentWindow.parent.document.getElementsByTagName('frameset').length > 0) {
						parentFrameSet = true;
						break;
					}
					currentWindow = currentWindow.parent;
				} while (currentWindow.document !== currentWindow.parent.document);
				
				if (parentFrameSet) {
					var parentFrames = currentWindow.parent.document.getElementsByTagName('frame');
					
					for (var i=0; i < parentFrames.length; i++) {
						if (parentFrames[i].contentWindow.document === currentWindow.document) {
							currentWindow = parentFrames[i].contentWindow;
							break;
						} 
					}
				}
				
				candidateWindow = currentWindow;

			} catch (err) {
				candidateWindow = global.window;
			}
			
		}
		
		return candidateWindow;
	}
	
 	function updateTags(params) { 		
 		adnxs.megatag.requests[params.adnxsId] = adnxs.megatag.requests[params.adnxsId] || {};
 		adnxs.megatag.requests[params.adnxsId].tags = adnxs.megatag.requests[params.adnxsId].tags || {};
 		adnxs.megatag.requests[params.adnxsId].iframes = adnxs.megatag.requests[params.adnxsId].iframes || {};
 		adnxs.megatag.requests[params.adnxsId].placementsLoaded = adnxs.megatag.requests[params.adnxsId].placementsLoaded || 0;
 		adnxs.megatag.requests[params.adnxsId].mtjCalled = adnxs.megatag.requests[params.adnxsId].mtjCalled || false;
 		adnxs.megatag.requests[params.adnxsId].iframesPopulated = adnxs.megatag.requests[params.adnxsId].iframesPopulated || false;
 		adnxs.megatag.requests[params.adnxsId].isOnloadSet = adnxs.megatag.requests[params.adnxsId].isOnloadSet || false;
 		
 		var tagId = generateTagId(params.elementId, params.adnxsId);
 		
 		checkTags(params);
		adnxs.megatag.requests[params.adnxsId].placementCount = getPlacementCount(params);
 		
 		adnxs.megatag.requests[params.adnxsId].tags[tagId] = params;
 		adnxs.megatag.requests[params.adnxsId].placementsLoaded++;
 		if (typeof adnxsManualLoad === 'undefined' && params.manualLoad) {
 			adnxs.megatag.manualLoad = params.manualLoad;
 		} else if (typeof adnxsManualLoad !== 'undefined') {
 			adnxs.megatag.manualLoad = adnxsManualLoad;
 		} else {
 			adnxs.megatag.manualLoad = false;
 		}
 		
 		if (adnxs.megatag.requests[params.adnxsId].placementsLoaded === 1*adnxs.megatag.requests[params.adnxsId].placementCount &&
 			isAutoLoad()) {
 			try {
		 		writeMtjIframe(params);
			} catch (err) {
				logError(err.message);
			}
 		}
 		
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId] = {
			params: params
		};
 		
 		return tagId;
 	}
 	
 	function generateTagId(elementId, requestId) {
 		var random = Math.random() * 1000,
 			i = 0;
 		
 		if (elementId) {return elementId + '_' + random;}
 		
 		while (adnxs.megatag.requests[requestId].tags['adnxs_tag_'+random]) { i++; }
 		
 		return 'adnxs_tag_' + random;
 	}
 	
 	function writeMarker(params, tagId) {
 		var writeWindow = params.frameWindow || global.window || window;
 		
 		try {
 			while (writeWindow.document !== writeWindow.parent.document) {
 	 			writeWindow.adnxsMarker = tagId;
 	 			writeWindow = writeWindow.parent;
 	 		}
 		} catch (err) {
 			logError('A parent window could not be marked.');
 		}
 		
 	}
 	
 	function writeIframe(params, tagId) {
 		var iframe = getMegatagWindow().document.createElement('iframe'),
 			div = getMegatagWindow().document.createElement('div'),
 			placeholder = getMegatagWindow().document.createElement('div'),
 			scripts = document.getElementsByTagName('script'),
 			thisScript = scripts[scripts.length-1];
 			
 		params.rawSizes = params.size.toLowerCase().split('x');
 		if (hasInitialSize(params)) {
 			iframe.width = params.rawSizes[0];
 			iframe.height = params.rawSizes[1];
		} else {
			iframe.width = 0;
			iframe.height = 0;
			placeholder.style.display = 'none';
		}
 		
 		placeholder.id = 'ph_'+tagId;
 		placeholder.style.width = iframe.width+'px';
 		placeholder.style.height = iframe.height+'px';
 		
 		div.id = 'div_'+tagId;
 		div.style.display = 'none';
 		
 		iframe.id = tagId;
 		iframe.name = tagId;
 		iframe.frameBorder = "0";
 		iframe.marginWidth = "0";
 		iframe.marginHeight = "0";
 		iframe.scrolling="no";
 		iframe.setAttribute('border', '0');
 		iframe.setAttribute('allowtransparency', "true");
 		iframe.style.display = 'none';
 		iframe.style.visibility = 'hidden';
 		 
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId].scriptEl = thisScript;
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId].frameEl = iframe;
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId].divEl = div;
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId].placeholderEl = placeholder;
 		adnxs.megatag.requests[params.adnxsId].iframes[tagId].params = params;
 		
 		insertPlaceholder(adnxs.megatag.requests[params.adnxsId].iframes[tagId], tagId);
 	}
 	
 	function writeMtjIframe(params) {
		if (adnxs.megatag.requests[params.adnxsId].mtjCalled === false) {
			adnxs.megatag.requests[params.adnxsId].mtjCalled = true;
			
 			var iframe = getMegatagWindow().document.createElement('iframe'),
 				randomizer = Math.random() * 1000,
 				div = getMegatagWindow().document.createElement('div');
 			
 			params.mtjUri = getMtjUri(params);
 			adnxs.megatag.requests[params.adnxsId].mtjUri = params.mtjUri;
 			
 			iframe.id = randomizer;
 			iframe.name = randomizer;
			iframe.style.display = "none";
			div.style.display = 'none';
		
			adnxs.megatag.requests[params.adnxsId].mtjIframe = iframe;
		
			if (getMegatagWindow().document.body) {
				try {
					div.appendChild(iframe);

					if (navigator.userAgent.indexOf('MSIE') !== -1) {
						if (getMegatagWindow().document.body.childNodes && getMegatagWindow().document.body.childNodes.length > 0) {
							getMegatagWindow().document.body.insertBefore(div, getMegatagWindow().document.body.childNodes[0]);
							doIEMtjCall(params, iframe);
						}
					} else {
						getMegatagWindow().document.body.appendChild(div);
						doMtjCall(params, iframe);
					}
				} catch (err) {
					handleMtjError(err, params, iframe);
				}
			}
			
		}
	}
 	
 	function doIEMtjCall(params, iframe) {
 		normalizeDomain(iframe);
 		iframe.contentWindow.contents = '<!DOCTYPE html><head><title></title>\
			<meta http-equiv="content-type" content="text/html; charset=UTF-8">\
			<script type="text/javascript" src="'+params.mtjUri+'"><\/script>\
			<script>try{if (document.domain !== "'+getMegatagWindow().document.domain+'") {\
			document.domain = "'+getMegatagWindow().document.domain+'";}\
			if (window.adnxs_ads) {window.parent.adnxs_ads = window.adnxs_ads || {};\
			window.parent.adnxs_backup_tags = window.adnxs_backup_tags || {};\
			window.parent.adnxs.megatag.populateIframes("'+params.adnxsId+'");}} catch (e) {console.log(e);}<\/script>\
			</head><body></body></html>';
		iframe.src = 'about:blank';
		iframe.src = 'javascript:window["contents"];';
	}
 	
 	function doMtjCall(params, iframe) {
 		normalizeDomain(iframe);
 		var contents = '<!DOCTYPE html><html><head><title></title>\
				<meta http-equiv="content-type" content="text/html; charset=UTF-8">\
				<scr'+'ipt src="'+params.mtjUri+'"></scr'+'ipt></head>\
				<body><scr'+'ipt>try{if (window.adnxs_ads) {\
				window.parent.adnxs_ads = window.adnxs_ads || {};\
				window.parent.adnxs_backup_tags = window.adnxs_backup_tags || {};\
				window.parent.adnxs.megatag.populateIframes("'+params.adnxsId+'");}} catch(e) {}</scr'+'ipt>\
				</body></html>';
		iframe.contentWindow.document.open('text/html', 'replace');
		iframe.contentWindow.document.write(contents);
		iframe.contentWindow.document.close();
 	}
 	
 	function handleMtjError(err, params, iframe) {
 		var caseInsensitiveMessage = err.message.toLowerCase();
 		if (caseInsensitiveMessage.indexOf('permission denied') > -1 
 			|| caseInsensitiveMessage.indexOf('access is denied') > -1) {
 			logError('Access denied to mtj iframe window, making script call', 'WARN');
 			
 			var script = document.createElement('script');
 			script.type = 'text/javascript';
 			script.src = params.mtjUri;
 			
 			if (typeof script.onreadystatechange !== 'undefined') {
 				script.onreadystatechange = function() {
 					if (this.readyState === 'complete' || this.readyState === 'loaded') {
 						adnxs.megatag.populateIframes(params.adnxsId);
 					}
 				}
 			} else {
 				script.onload = function() { 
 					adnxs.megatag.populateIframes(params.adnxsId);
 				}
 			}
 			
 			getMegatagWindow().document.body.appendChild(script);
 			
 		} else {
 	 		throw err;
 		}
 	}
 	
 	function insertIframe(frameObj, tagId) {

		var params = frameObj.params;
		var thisScript = frameObj.scriptEl;
		var placeholderEl = getMegatagWindow().document.getElementById(frameObj.placeholderEl.id);
		var el = placeholderEl.parentNode;
		
		if (el) {
			frameObj.divEl.appendChild(frameObj.frameEl);
			el.insertBefore(frameObj.divEl, placeholderEl);
			placeholderEl.style.display = 'none';
			
			return el;
		}
 				
 		throw new Error('Failed to insert iframe');
 	}
 	
 	function insertPlaceholder(frameObj, tagId) {
		var params = frameObj.params;
		var thisScript = frameObj.scriptEl;
		var tokenIframe = document.createElement('iframe');
		tokenIframe.width = frameObj.placeholderEl.style.width;
		tokenIframe.height = frameObj.placeholderEl.style.height;
		tokenIframe.frameBorder = "0";
		tokenIframe.marginWidth = "0";
		tokenIframe.marginHeight = "0";
		tokenIframe.scrolling="no";
		tokenIframe.setAttribute('border', '0');
		tokenIframe.setAttribute('allowtransparency', "true");
 		tokenIframe.style.visibility = 'hidden';
		
 		if (getMegatagWindow().document === global.window.document) {
 			var el = (params && params.targetId && getMegatagWindow().document.getElementById(params.targetId)) 
 				? getMegatagWindow().document.getElementById(params.targetId) : thisScript;
			
 			frameObj.placeholderEl.appendChild(tokenIframe);
 			el.parentNode.insertBefore(frameObj.placeholderEl, el);
 			return el;
 		} else {
 			var el = ((params && params.targetId && getMegatagWindow().document.getElementById(params.targetId)) 
 				? getMegatagWindow().document.getElementById(params.targetId) : getTopLevelIframe(params.frameWindow || global.window || window, tagId));
 			
 			if (el) {
 				frameObj.placeholderEl.appendChild(tokenIframe);
 				el.parentNode.appendChild(frameObj.placeholderEl);
 				el.style.display = 'none';
 				return el;
 			}
 		}
 		
 		throw new Error('Failed to insert placeholder');
 	}
 	
 	function getTopLevelIframe(currentWindow, tagId) {
 		var parent = currentWindow.parent,
 			parentIframes = parent.document.getElementsByTagName('iframe');
 		
 		for (var i=0; i < parentIframes.length; i++) {
 			var thisWindow = parentIframes[i].contentWindow;
 			
 			try {
 				var a = thisWindow.adnxsMarker;
 			}catch (err) {continue;}
 			
 			if (thisWindow.adnxsMarker && thisWindow.adnxsMarker === tagId) {
 				while (thisWindow.parent.document !== thisWindow.parent.parent.document) {
 					thisWindow = thisWindow.parent;
 				}
 				var topLevelFrames = thisWindow.parent.document.getElementsByTagName('iframe');
 				if (topLevelFrames.length > 0) {
 					for (var j=0; j < topLevelFrames.length; j++) {
 						var upperWindow = topLevelFrames[j].contentWindow;
 						
 						try {
			 				var a = upperWindow.adnxsMarker;
			 			}catch (err) {continue;}
			 			
 	 					if (tagId === upperWindow.adnxsMarker) {
 	 						return topLevelFrames[j];
 	 					}
 	 				}
 				} else {
 					var thisWindowFrames = thisWindow.document.getElementsByTagName('iframe');
 					for (var j=0; j < thisWindowFrames.length; j++) {
 	 					var upperWindow = topLevelFrames[j].contentWindow;
 						
 						try {
			 				var a = upperWindow.adnxsMarker;
			 			}catch (err) {continue;}
			 			
 	 					if (tagId === upperWindow.adnxsMarker) {
 	 						return thisWindowFrames[j];
 	 					}
 	 				}
 				}
 			}
 		}
 		
 		if (parent.document === parent.parent.document) {
 			return null;
 		} else {
 			return getTopLevelIframe(parent.parent, tagId);
 		}
 		
 	}
 	
 	function hasInitialSize(params) {
		if (params && params.setIframeSize && params.setIframeSize === true || 
			(params.setIframeSize && params.setIframeSize === 'true') ||
			(typeof adnxsSetIframeSize !== 'undefined' && adnxsSetIframeSize === true)) {
			
			return true;
		}
 		return false;
 	}
  	
	function getPlacementCount(params) {
		checkCount(params);
		
		if (typeof adnxsPlacementCount !== 'undefined') {
			return adnxsPlacementCount;
		} else {
			return adnxs.megatag.requests[params.adnxsId].placementCount || params.placementCount;
		}
	}
 	
 	function getBaseUrl() {
 		return (typeof adnxs_url !== 'undefined' ? adnxs_url : _defaults.url);
 	}
 	
 	function getMtjEndpoint() {
 		return (typeof adnxs_mtj !== 'undefined' ? adnxs_mtj : _defaults.mtjBase);
 	}

 	function getTtjEndpoint() {
 		return (typeof adnxs_ttj !== 'undefined' ? adnxs_ttj : _defaults.ttjBase);
 	}
 	 	
 	function callMtj(params) {
		try {
			writeMtjIframe(params);
		} catch (err) {
			logError(err.message);
		}
 	}

	// Returns a set of parameters that are used in the mtjparams0...x 
	// parameters passed to mtj for each individual placement
	function getMtjTagParams(params) {
		var output = "";
		for (var i in params) {
			if (adnxs.megatag.hasOwnProperty(params, i)) {
				switch (i) {
					case 'placementCount':
					case 'setDomain':
					case 'frameHelper':
					case 'setIframeSize':
					case 'adnxsId':
					case 'frameWindow':
					case 'adnxsCode':
					case 'adnxsMember':
					case 'elementId':
					case 'targetId':
					case 'debug':
					case 'mtjUri':
					case 'rawSizes':
					case 'pubclick': // not included in mtjparams
					case 'referrer': // not included in mtjparams
					case 'age':
					case 'gender':
						break;
					case 'promoSizes':
					case 'promo_sizes':
						var lowerCaseParams = [];
						for (var j=0; j < params[i].length; j++) {
							lowerCaseParams.push(params[i][j].toLowerCase());
						}
						output += i + "=" + lowerCaseParams + '&';
						break;
					case 'size':
						output += i + "=" + params[i].toLowerCase() + "&";
						break;
					default:
						output += i + "=" + params[i] + "&";
						break;
				}
			}
		}
		output = output.substring(0, output.length-1);
				
		return output;
	}
 	
 	// Parameters that are only listed once for an mtj call
 	function getMtjParams(params) {
 		var output = "";
		for (var i in params) {
			if (adnxs.megatag.hasOwnProperty(params, i)) {
				switch (i) {
					case 'pubclick':
					case 'referrer':
					case 'age':
					case 'gender':
						output += i + "=" + encodeURIComponent(params[i]) + "&";
						break;
					default:
						break;
				}
			}
		}
		output = output.substring(0, output.length-1);
				
		return output;
 	}
 	
 	function getMtjUri(params) {
 		var idParam = (params && params.adnxsId ? params.adnxsId : window.adnxsId),
 			uri = getBaseUrl() + getMtjEndpoint() + "?",
 			placementParam;
 		
 		if (typeof idParam === 'undefined') {
 			if ((params && params.adnxsCode && params.adnxsMember) || (window.adnxsCode && window.adnxsMember)) {
				placementParam = 'inv_code=' + (params && params.adnxsCode ? params.adnxsCode : window.adnxsCode);
				placementParam += '&member=' + (params && params.adnxsMember ? params.adnxsMember : window.adnxsMember);
 			} else {
 				throw new Error('Neither ID nor code was defined for a placement.');
 			}
 		} else {
 			placementParam = 'id=' + idParam;
 		}
 		 		
 		uri += placementParam;
 		
 		// Hack to enable freq capping through querystring targeting
		var possibleTargets = ['A','B','C'];
		var chosenTarget = possibleTargets[Math.floor((Math.random() * 3))];
 		
		var i = 0;
		for (var t in adnxs.megatag.requests[idParam].tags) {
			if (adnxs.megatag.hasOwnProperty(adnxs.megatag.requests[idParam].tags, t)) {
				var uriParams = getMtjTagParams(adnxs.megatag.requests[idParam].tags[t]);

				uriParams += '&fcp_target='+chosenTarget;
				
				uri += "&mtjtag" + i + "=" + t;
				uri += "&mtjparams" + i + "=" + encodeURIComponent(uriParams);
				i++;
			}
		}
	
		uri += "&mtjntags=" + i;
		
		uri += (isPageExclusive(i, params.adnxsId) ? '&exclusive=true' : '&exclusive=false');
		if (typeof adnxs.megatag.requests[params.adnxsId].placementCount !== 'undefined') {
			uri += '&placement_count=' + adnxs.megatag.requests[params.adnxsId].placementCount;
		}
		uri += '&placements_loaded=' + adnxs.megatag.requests[params.adnxsId].placementsLoaded;
		
		var mtjParamsExtension = getMtjParams(params);
		
		uri = (mtjParamsExtension.length > 0 ? uri + '&' + mtjParamsExtension : uri);
		
		return uri;
 	}
 	
 	function populateIframes(requestId) {
 		
 		// Backwards-compatible check
 		// If there's no request ID, find the first call in the requests struct that does not 
 		// have iframes populated and try that one.
 		if (!requestId) {
 			for (var r in adnxs.megatag.requests) {
 				if (adnxs.megatag.hasOwnProperty(adnxs.megatag.requests), r) {
 					if (adnxs.megatag.requests[r].iframesPopulated === false) {
 						requestId = r;
 						break;	
 					}	
 				}	
 			}
 		}

 		if (adnxs.megatag.requests[requestId].iframesPopulated === false) {
 	 		adnxs.megatag.requests[requestId].iframesPopulated = true;
 	 		
 	 		for (var t in adnxs.megatag.requests[requestId].iframes) {
 				if (adnxs.megatag.hasOwnProperty(adnxs.megatag.requests[requestId].iframes, t)) {
 					 					
 					try {
 						var frameObj = adnxs.megatag.requests[requestId].iframes[t],
	 						origEl;
	 					
	 					frameObj.placeholderEl.style.display = 'none';
	 					origEl = insertIframe(frameObj, t);
	 					normalizeDomain(frameObj.frameEl);
	 					
 						if (getMegatagWindow().adnxs_ads && getMegatagWindow().adnxs_ads[t]) {
 							
 	 						if (navigator.userAgent.indexOf('MSIE') !== -1) {
 	 	 					
 	 	 						// Use HTML 4 / loose doctype to prevent padding/margin issues
 	 	 						// in IE with HTML5 doctype and third party mark-up
 	 	 						var content = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\
 	 	 						<html><head>\
 	 	 	 						<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">\
 	 	 	 						<scr'+'ipt type="text/javascript">\
 	 	 	 						try {\
 	 	 	 						if (document.domain !== "'+getMegatagWindow().document.domain+'") {\
									document.domain = "'+getMegatagWindow().document.domain+'";}\
 	 	 	 						inDapIF = true;\
 	 	 	 						var adnxs = {richmedia: {}};\
 	 	 	 						window.frameId = "'+t+'";\
 	 	 	 						adnxs.richmedia.setSize = function(width, height) {\
 	 	 		 					var iframe = window.parent.document.getElementById(window.frameId);\
 	 	 		 						if (!iframe || iframe === false) { return false; }\
 	 	 		 						iframe.width = width;\
 	 	 		 						iframe.height = height;\
 	 	 		 						iframe.style.width = width+"px";\
 	 	 		 						iframe.style.height = height+"px";\
 	 	 			 				};\
 	 	 			 				} catch (err) {}</scr'+'ipt>\
 	 	 			 				</head><body><scr'+'ipt type="text/javascript" src="'+decodeURIComponent(getMegatagWindow().adnxs_ads[t])+'"></scr'+'ipt></body></html>';
 	 	 						
 	 	 						
 	 	 						frameObj.frameEl.contentWindow.contents = content;
 	 	 						frameObj.frameEl.src = 'about:blank';
 	 	 						frameObj.frameEl.src = 'javascript:window["contents"];';
 	 	 	 					
 	 	 					} else {
 	 	 						
 	 	 						var content = '<!DOCTYPE html><html><head>\
 	 	 	 						<meta charset="utf-8">\
 	 	 	 						<scr'+'ipt type="text/javascript">inDapIF = true; var adnxs = {richmedia: {}}; window.frameId = "'+t+'"; adnxs.richmedia.setSize = function(width, height) {\
 	 	 		 					var iframe = window.parent.document.getElementById(window.frameId);\
 	 	 		 						if (!iframe || iframe === false) { return false; }\
 	 	 		 						iframe.width = width;\
 	 	 		 						iframe.height = height;\
 	 	 		 						iframe.style.width = width+"px";\
 	 	 		 						iframe.style.height = height+"px";\
 	 	 			 				};</scr'+'ipt>\
 	 	 			 				</head><body><scr'+'ipt type="text/javascript" src="'+decodeURIComponent(getMegatagWindow().adnxs_ads[t])+'"></scr'+'ipt></body></html>';
 	 	 						
 	 	 						
 	 	 						var cDoc = frameObj.frameEl.contentWindow.document ? frameObj.frameEl.contentWindow.document : frameObj.frameEl.document;
 	 	 						cDoc.open('text/html', 'replace');
 	 	 	 					cDoc.write(content);
 	 	 	 					cDoc.close();
 	 	 	 					
 	 	 					}
 	 					} 

 						frameObj.frameEl.parentNode.style.display = '';
 	 					frameObj.frameEl.style.display = '';
 	 					frameObj.frameEl.style.visibility = 'visible';
 					} catch (err) {
 						handlePopulationError(err, frameObj, t);
 					}
 					
 				}
 			}
 		}
	}
 	
 	function handlePopulationError(err, frameObj, tagId) {
 		var caseInsensitiveMessage = err.message.toLowerCase();
 		if (caseInsensitiveMessage.indexOf('permission denied') > -1 
 			|| caseInsensitiveMessage.indexOf('access is denied') > -1) {
 			logError('Access denied to placement iframe window, making tt call', 'WARN');
 			
 			var iframe = document.createElement('iframe');
 			iframe.width = frameObj.params.rawSizes[0];
 			iframe.height = frameObj.params.rawSizes[1];
 			iframe.src = getBaseUrl() + '/tt?id='+frameObj.params.adnxsId+'&'+getMtjTagParams(frameObj.params);
 	 		iframe.frameBorder = "0";
 	 		iframe.marginWidth = "0";
 	 		iframe.marginHeight = "0";
 	 		iframe.scrolling="no";
 	 		iframe.setAttribute('border', '0');
 	 		iframe.setAttribute('allowtransparency', "true");
 	 		iframe.style.display = 'none';
 	 		iframe.style.visibility = 'hidden';
 	 		
 	 		frameObj.divEl.appendChild(iframe);
 	 		frameObj.frameEl.style.display = 'none';
 	 		frameObj.divEl.style.display = '';
 	 		iframe.style.display = '';
 	 		iframe.style.visibility = '';
 			
 		} else {
 	 		throw err;
 		}
 	}
 	
 	function isPageExclusive(count, requestId) {
 		return (typeof adnxs.megatag.requests[requestId].placementCount !== 'undefined' && 1*adnxs.megatag.placementCount === count);
 	}
 	
 	function setOnload(params) {
 		
 		var callMtjWrapper = function() {
 			callMtj(params);
 		};
 		
 		
 		if (getMegatagWindow().addEventListener) {
 			getMegatagWindow().document.addEventListener('DOMContentLoaded', callMtjWrapper, false);
 			getMegatagWindow().addEventListener('load', callMtjWrapper, false);
 			adnxs.megatag.requests[params.adnxsId].isOnloadSet = true;
 			 			
 		} else if (getMegatagWindow().attachEvent) {
 			getMegatagWindow().attachEvent('onload', callMtjWrapper);
 			adnxs.megatag.requests[params.adnxsId].isOnloadSet = true;
 		} 		
		
 	}
 	
 	function isAutoLoad() {
 		return (typeof adnxs.megatag.manualLoad === 'undefined' || adnxs.megatag.manualLoad === false);
 	}
 	
 	function cleanUpCmds() {
 		if (adnxs.megatag.isCleanupSet === false) {
 			adnxs.megatag.isCleanupSet = true;
 			if (getMegatagWindow().attachEvent) {
 				getMegatagWindow().attachEvent('onload', _processQueue);
 			} else if (getMegatagWindow().addEventListener) {
 				getMegatagWindow().addEventListener('onload', _processQueue, false);
 			}
 		}
 	}
 	
 	function hasConsoleLogger() {
 		return (((adnxs.megatag.debug === true) 
 				|| (typeof adnxsDebug === 'undefined' || (typeof adnxsDebug !== 'undefined' && adnxsDebug !== false))) 
 				&& (window.console && window.console.log));
 	}
 	
 	function logError(msg, code) {
 		var errCode = code || 'GENERAL_ERROR';
 		adnxs.megatag.errors.push({msg: msg, code: errCode});
 		
 		if (hasConsoleLogger()) {
 			console.log(errCode + ': '+msg);
 		}
 	}
 	
 	function checkCount(params) {
 		if (adnxs.megatag.placementCount && params.placementCount && adnxs.megatag.placementCount !== params.placementCount) {
			logError('A placement count of '+params.placementCount
					+ ' has been provided, but a placement count of '
					+ adnxs.megatag.placementCount+' was already registered. '
					+ 'The count of '+adnxs.megatag.placementCount+' will be used.'
			);
		}
 	}
	
 	function checkTags(params) {
 		checkTag('adnxsFrameHelper', 'frameHelper', params);
 		checkTag('adnxsPlacementCount', 'placementCount', params);
 		checkTag('adnxsSetDomain', 'setDomain', params);
 		checkTag('adnxsId', 'adnxsId', params);
 		checkTag('adnxsCode', 'adnxsCode', params);
 		checkTag('adnxsMember', 'adnxsMember', params);
 		checkTag('adnxsSetIframeSize', 'setIframeSize', params);
 	}
 	
 	function checkTag(globalVar, paramVar, params) {
 		if ((typeof window[globalVar] !== 'undefined' && typeof params[paramVar] !== 'undefined') &&
 			(window[globalVar] !== params[paramVar])) {
 			
 			logError('The variable '+globalVar+' was already set to '+window[globalVar]+' and a placement tried to override it with '+params[paramVar]);
 		}
 	}
 	
 	function getTtjUri(params) {
		var	uri = getBaseUrl() + getTtjEndpoint() + "?";
 		
 		if ((params && params.adnxsId) || window.adnxsId) {
 			uri += 'id=' + (params && params.adnxsId ? params.adnxsId : window.adnxsId);
 		} else if ((params && params.adnxsCode && params.adnxsMember) || (window.adnxsCode && window.adnxsMember)) {
 			uri += 'inv_code=' + (params && params.adnxsCode ? params.adnxsCode : window.adnxsCode);
 			uri += '&member=' + (params && params.adnxsMember ? params.adnxsMember : window.adnxsMember);
 		}
 		
 		uri += '&size=' + params.size;
 			
		return uri;
 	}
 	
 	function normalizeDomain(iframe) {
 		if (iframe.contentWindow) {
 			try {
 				var documentCheck = iframe.contentWindow.document.a;
 			} catch (e) {
 				iframe.src = 'javascript:(function(){document.open(); document.domain = "'+getMegatagWindow().document.domain+'";document.close();})();';
 			}
 		}
 	}
 	
 	function writeTtjIframe(params) {
 		var uri = getTtjUri(params),
 			scripts = document.getElementsByTagName('script'),
			thisScript = scripts[scripts.length-1],
			iframe = getMegatagWindow().document.createElement('iframe'),
			randomizer = Math.random() * 1000,
			div = getMegatagWindow().document.createElement('div');
			
 		params.rawSizes = params.size.toLowerCase().split('x');
		iframe.id = 'ttj_' + randomizer;
		iframe.name = 'ttj_' + randomizer;
		iframe.width = params.rawSizes[0];
		iframe.height = params.rawSizes[1];
		iframe.frameBorder = "0";
 		iframe.marginWidth = "0";
 		iframe.marginHeight = "0";
 		iframe.scrolling="no";
 		iframe.setAttribute('border', '0');
 		iframe.setAttribute('allowtransparency', "true");
 		iframe.style.display = 'none';
 		iframe.style.visibility = 'hidden';
		iframe.style.display = "none";
		div.style.display = 'none';
	
		if (thisScript) {
			try {
				div.appendChild(iframe);
				thisScript.parentNode.insertBefore(div, thisScript);
				injectTtjContent(uri, iframe, div);
			} catch (err) {
				logError(err.message);
			}
		}
 	}
 	
 	function injectTtjContent(uri, iframe, div) {
 		if (navigator.userAgent.indexOf('MSIE') !== -1) {
 			normalizeDomain(iframe);
 	 		iframe.contentWindow.contents = '<!DOCTYPE html><head><title></title>\
 				<meta http-equiv="content-type" content="text/html; charset=UTF-8">\
 				<script type="text/javascript" src="'+uri+'"><\/script>\
 				</head><body></body></html>';
 			iframe.src = 'about:blank';
 			iframe.src = 'javascript:window["contents"];';
 		} else {
 			normalizeDomain(iframe);
 	 		var contents = '<!DOCTYPE html><html><head><title></title>\
 					<meta http-equiv="content-type" content="text/html; charset=UTF-8">\
 	 				</head>\
 					<body><scr'+'ipt src="'+uri+'"></scr'+'ipt></body></html>';
 			iframe.contentWindow.document.open('text/html', 'replace');
 			iframe.contentWindow.document.write(contents);
 			iframe.contentWindow.document.close();
 		}
 		iframe.style.display = '';
 		iframe.style.visibility = 'visible';
		div.style.display = '';
 	}
 	
 	_processQueue();
 	 
}(this));