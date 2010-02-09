var Lightbox = {
	isIE: false, id: null,
	showBoxString:function(content,width,height) {
		this.id=null;
		$('lb_box_contents').innerHTML = content;
		this.showBox(width,height);
		return false;
	},
	showBoxByID:function(id,width,height) {
		while ($(id).hasChildNodes()) $('lb_box_contents').appendChild($(id).firstChild);
		this.showBox(width,height);
		return false;
	},
	showBox:function(width,height) {
		$('lb_box').style.width =width ? width + 'px' : 'auto';
		$('lb_box').style.height = height ? height + 'px' : 'auto';
		this.isIE = (navigator.userAgent.indexOf("MSIE") > -1) ? true : false;
		if(this.isIE) this.fixIE("100%", "hidden","hidden");
		Element.show('lb_overlay');
		this.displayBox('lb_box');
		return false;
	},
	hideBox:function() {
		var contents = $('lb_box_contents');
		if(!this.isIE) while(contents.hasChildNodes()) contents.removeChild(contents.firstChild); //for Safari
		contents.innerHTML = '';
		Element.hide('lb_box');
		Element.hide('lb_overlay');
		if(this.isIE) this.fixIE("auto", "auto","visible");
		return false;
	},
	getPageSize:function() {
		var xScroll, yScroll;
		xScroll = document.body.scrollWidth || document.body.offsetWidth;
		yScroll = (window.innerHeight + window.scrollMaxY) || document.body.scrollHeight || document.body.offsetHeight;
		var de = document.documentElement;
	    var windowWidth = self.innerWidth || (de&&de.clientWidth) || window.innerWidth  || document.body.clientWidth;
	    var windowHeight = self.innerHeight || (de&&de.clientHeight) || window.innerHeight  || document.body.clientHeight;
		var pageHeight = (yScroll < windowHeight) ? windowHeight : yScroll;
		var pageWidth = (xScroll < windowWidth) ? windowWidth : xScroll;
		var scrollY = (de&&de.scrollTop) || (document.body&&document.body.scrollTop) || window.pageYOffset || window.scrollY || 0;
		return new Array(windowWidth, windowHeight, pageWidth, pageHeight, scrollY, yScroll);
	},
	displayBox:function(id) {
		try{element = document.getElementById(id);}
		catch(e) {return;}
		var windowSize = this.getPageSize();
		var windowWidth = windowSize[0];
		var windowHeight = windowSize[1];
		var scrollY = windowSize[4];
		
		$('lb_overlay').style.height = ((windowSize[5]<windowHeight) ? windowHeight : windowSize[5]) + "px";
		element.style.position = 'absolute';
		element.style.zIndex   = 99;
		var dimensions = Element.getDimensions(element);
		
		var setX = ( windowWidth  - dimensions.width  ) / 2;
		var setY = ( windowHeight - dimensions.height ) / 2 + scrollY;
		setX = ( setX < 0 ) ? 0 : setX;
		setY = ( setY < 0 ) ? 0 : setY;
		element.style.left = setX + "px";
		element.style.top  = setY + "px";
		Element.show(element);
	},
	fixIE: function (height, overflow, visibility) {
		body = document.getElementsByTagName("body")[0];
		html = document.getElementsByTagName("html")[0];
		//body.style.height = html.style.height = height;
		//body.style.overflow = html.style.overflow = overflow;
		body_selects = document.getElementsByTagName("select");
		for (i = 0; i < body_selects.length; i++) body_selects[i].style.visibility = visibility;
		box_selects = $('lb_box').getElementsByTagName("select");
		for (i = 0; i < box_selects.length; i++) box_selects[i].style.visibility = 'visible';
	}
};

function lb_initialize() {
	if(!$('lb_box')) {
		var body = document.getElementsByTagName("body").item(0);
		new Insertion.Bottom(body, '<div id="lb_overlay" style="display:none"></div><div id="lb_box" style="display:none"><div id="lb_box_contents"></div></div>');
	}
}
Event.observe(window, "load", lb_initialize, false);