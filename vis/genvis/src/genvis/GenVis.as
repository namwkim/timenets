package genvis
{
	import flare.display.DirtySprite;
	import flare.display.TextSprite;
	import flare.util.Colors;
	import flare.util.palette.ColorPalette;
	import flare.vis.data.DataSprite;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import genvis.animate.Transitioner;
	import genvis.data.DataEstimator;
	import genvis.data.Person;
	import genvis.data.converters.XMLConverter;
	import genvis.scale.ScaleType;
	import genvis.vis.Visualization;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.controls.ClickControl;
	import genvis.vis.controls.DragControl;
	import genvis.vis.controls.HoverControl;
	import genvis.vis.controls.PanZoomControl;
	import genvis.vis.controls.TooltipControl;
	import genvis.vis.data.AttributeSprite;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.Data;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.EventSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.data.render.AttributeRenderer;
	import genvis.vis.data.render.EventRenderer;
	import genvis.vis.data.render.LifelineRenderer;
	import genvis.vis.events.SelectionEvent;
	import genvis.vis.events.TooltipEvent;
	import genvis.vis.lifeline.Lifeline;
	import genvis.vis.operator.encoder.ColorEncoder;
	import genvis.vis.operator.filter.FisheyeFilter;
	import genvis.vis.operator.label.Labeler;
	import genvis.vis.operator.layout.LifelineLayout;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.HSlider;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.ResizeEvent;
	import mx.events.SliderEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import org.akinu.events.RootChangeEvent;
	import org.akinu.events.SelectEvent;
	import org.akinu.helper.Helper;
	
//	import org.alivepdf.display.Display;
//	import org.alivepdf.layout.Orientation;
//	import org.alivepdf.pdf.PDF;
//	import org.alivepdf.saving.Download;
//	import org.alivepdf.saving.Method;

	public class GenVis extends Canvas
	{
		//visualization
		private var _vis:Visualization 				= null;
		private var _hoverCtrl:HoverControl 		= null;
		private var _dragCtrl:DragControl			= null;
		private var _toolTip:TooltipControl 		= null;
		private var _colorEncoder:ColorEncoder 		= null;
		private var _fisheyeFilter:FisheyeFilter	= null;
		private var _renderer:LifelineRenderer 		= null;
		private var _attrRenderer:AttributeRenderer	= null;
		private var _evtRenderer:EventRenderer		= null;
		private var _lifelineLayout:LifelineLayout 	= null;
		private var _root:Person;	
		private var _events:Array;
		private var _selectedNode:NodeSprite	= null;		
		private var _focusNodes:Array 			= new Array(); 	//all foci	
		private var _persistentFoci:Array		= new Array();	//pernanent foci		
		private var _recentFocus:NodeSprite		= null;			//recent focus
 		private var _range:TextArea				= null;
 		private var _t:Transitioner				= null; 		
		//child components
		private var _visarea:UIComponent 	= null;
//		private var _visScroll:ScrollBar	= null;
		private var _uiCtrls:Canvas			= null;
		private var _spanSlider:HSlider		= null;
		private var _tmp:*;
//		var colors:Array = [0xffffff, 0xe8d138, 0xffffff, 0xffffff];
// var alphas:Array = [0.0, 1, 1, 1];
// var ratios:Array = [0, 64, 86, 128];
// var _glowFilter:GradientGlowFilter = new GradientGlowFilter(0, 0, colors, alphas, ratios, 16, 16, 1, 2, BitmapFilterType.OUTER, false);

		
		
		//****************//
		//configuration   //
		//****************//
		public static const NOMARKER:uint	= 0;
		public static const GRADIENT:uint	= 1;
		public static const QSMARK:uint		= 2;
		
		public static const AUTOMATIC:int	= 0;
		public static const MANUAL:int	 	= 1;
	
		private static const MINWIDTH:Number 	= 400;
		private static const MINHEIGHT:Number 	= 400;
		
		private static const ENCODER:String		= "colorEncoder";
		private static const FILTER:String		= "fisheyeFilter";
		private static const LAYOUT:String		= "layout";
		private static const LABLER:String		= "labler";
		public static const OPS:Array			= [ENCODER, FILTER, LAYOUT, LABLER];
				
		private var _labelStyle:int = Lifeline.LABELINSIDE;
		private var _layoutMode:int	= AUTOMATIC;
		private var _layoutType:int = LifelineLayout.HOURGLASSCHART;
		private var _lifelineType:int				= Lifeline.LINESPLINE;
		private var _doiEnabled:Boolean				= false;
		private var _doiDist:int					= 2;
		private var _xrange:Number					= 90;
		private var _selectedBlock:BlockSprite		= null;
		//node config
		private var _nColors:Array 		= [0x3465a4, 0xcc0000, 0x555753];
		private var _nLineAlpha:Number	= 0.7;
		private var _nFillAlpha:Number	= 0.5;
		private var _nodeGlow:GlowFilter 	= new GlowFilter(0x8ae234, 0.7, 24, 24, 5);
		private var _focusGlow:GlowFilter 	= new GlowFilter(0xe8d138, 0.7, 24, 24, 5);
		private var _uncGlow:GlowFilter 	= new GlowFilter(0x8ae234, 0.8, 24, 24, 7);
		//block config
		private var _bLineWidth:Number  = 2;
		private var _bFillColor:Number 	= 0x888a85;
		private var _bFillAlpha:Number	= 0.6;
		private var _bLineColor:Number	= 0x2e3436;
		private var _bLineAlpha:Number	= 0.6;
		//edge config
		private var _edgeColor:Number  	= 0x4e9a06;//0xbabdb6;
		private var _edgeWidth:Number	= 2;	
		private var _edgeAlpha:Number	= 0.6;
		//attr config (marriage)
		private var _attrColor:Number = 0xedd400;//0x888a85;
		private var _attrAlpha:Number = 0.8;
		private var _attrSize:Number  = 7.0;
		
		//historical event
		private var _histColor:Number	= 0xd3d7cf;
		private var _histAlpha:Number	= 0.8;
		//event
		private var _evtColor:Number	= 0xfcaf3e;
		private var _evtAlpha:Number	= 0.8;
		private var _evtGlow:GlowFilter 	= new GlowFilter(0xfcaf3e, 0.8, 16, 16, 7);
		
		
		private var _this:GenVis;
		
		//temporary: these variables are used accross the application
		public static var drawBlock:Boolean = false;//true;
		public static var uncType:uint		=  GRADIENT;
				
		public function GenVis()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			_this = this;
			
		}

		/**
		 * genealogy: xml-representation of genealogy databases
		 * it contains four database tables, persons, relationships, relationship_types, person_types
		 **/		
		public function updateData(xml:XML):void{
			//#1. convert xml to array tables and construct relationship info (links among people)
			var personTable:Array  = XMLConverter.transform(xml);
			_root = personTable[0];	//the root will be specified in xml in the future		
			
			//#2. estimate missing data
			DataEstimator.estimate(_root, personTable);	
			
			//#3. construct display list
			var data:Data = new Data(_root);		

			//#3. set initial focus
			_root.sprite.status = NodeSprite.FOCUSED;
			//_focusNodes.push(_root.sprite);
			
			//#4. construct visualization			
			updateVis(data);
			
			//#5. enable vis controls
			_uiCtrls.enabled = true;
		}
		public function visualize(root:Person, events:Array = null):void{
			//#1. clear sprites if reusing data
			clear();
			_root 	= root;
			_events	= events;
			//#2. estimate missing data
			DataEstimator.estimate(_root, null);	
			//#3. construct display list
			var data:Data = new Data(_root, events);		

			//#3. set initial focus
			_root.sprite.status = NodeSprite.FOCUSED;
			//_focusNodes.push(_root.sprite);
			
			//#4. construct visualization			
			updateVis(data);
			
			//#5. enable vis controls
			_uiCtrls.enabled = false;
			
			DirtySprite.renderDirty();
		}
		public function update():void{
			_vis.update(null, OPS);
		}
		public function select(person:Person, update:Boolean=true):void{
			if (person.sprite==null || (_selectedNode && _selectedNode==person.sprite)) return;
			deselect();
			_selectedNode = person.sprite;
			_selectedNode.selected = true;
			
			if (_persistentFoci.indexOf(_selectedNode)<0)	{
				_selectedNode.filters  = [_nodeGlow];
			}
			

			//Dispatch Selection Event
			var selectPerson:SelectEvent = new SelectEvent(SelectEvent.SELECT, SelectEvent.PERSON, person, null);
			selectPerson.dispatch();
			if (update){
				_lifelineLayout.buildScale(person.sprite);
				_vis.update(null, OPS);
			}
			//DirtySprite.renderDirty();
		}
		public function deselect(dispatchEvent:Boolean=false):void{
			if (_selectedNode){
				_selectedNode.selected = false;
				if (_persistentFoci.indexOf(_selectedNode)<0)	_selectedNode.filters  = null;
				_selectedNode = null;
				if (dispatchEvent){
					var evt:SelectEvent = new SelectEvent(SelectEvent.DESELECT, SelectEvent.PERSON);
					evt.dispatch();
				}
			}
		}
		public function setLabelStyle(lbStyle:uint):void{
			_lifelineLayout.lifeline.style = lbStyle;
			_vis.update(_t, OPS);
		}
		private function clear():void{
			if (_vis.data == null) return;
			_vis.data.nodes.visit(function(n:NodeSprite):void{
				var p:Person = n.data as Person;
				p.sprite = null;
				n.data 	 = null;
			});
		}
		private function onResize(evt:ResizeEvent):void{			
			resize(width, height);
		}
		private function init(evt:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			//this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
			this.addEventListener(ResizeEvent.RESIZE, onResize);
			this.name = "GenVis";
			
			//layout components			
			_visarea 	= new UIComponent();
			_uiCtrls	= new Canvas();	
			_vis 		= new Visualization();
//			_visScroll  = new ScrollBar();
			_t			= null;//new Transitioner(1);
			_visarea.addChild(_vis);		
			this.addChild(_visarea);
//			this.addChild(_vis);
//			this.addChild(_uiCtrls);
//			_vis.addChild(_visScroll);				
			resize(width, height);	
//			_visScroll.direction = ScrollBarDirection.HORIZONTAL;
//			_visScroll.lineScrollSize = 1;
//			_visScroll.pageScrollSize = 1;
//			_visScroll.pageSize = 10;
//			addFlexCtrls();
			addFlareCtrls();	
			_uiCtrls.enabled = false;		    
		}
		private function resize(newWidth:Number, newHeight:Number):void
		{
			trace(newWidth);
			trace(newHeight);
			if (newWidth  < MINWIDTH) newWidth 	= MINWIDTH;
			if (newHeight < MINHEIGHT) newHeight = MINHEIGHT;
			_visarea.width 	= newWidth; //-250;
			_visarea.height = newHeight;
//			_uiCtrls.x		= _visarea.width;	
//			_uiCtrls.width 	= 250;
//			_uiCtrls.height = newHeight;
			_vis.x = 20;
			_vis.y = 20;
			_vis.bounds = new Rectangle(0, 0, _visarea.width-40, _visarea.height-40);
//			_visScroll.x = 0;
//            _visScroll.y = _vis.bounds.height;
//            _visScroll.height	= _vis.bounds.width;
			if (_vis.data){
				_vis.update(_t, OPS);
				DirtySprite.renderDirty();
			}
		}
		
		/**
		 * TODO: transition when updating
		 **/
		private function updateVis(data:Data):void{
			//replace old data
			_vis.data = data;	
			//set properties
			_renderer 		= new LifelineRenderer(_lifelineType, _layoutMode);
			_attrRenderer 	= new AttributeRenderer(); 
			_evtRenderer	= new EventRenderer();
			buildOperators();				
			_vis.data.edges.setProperties({"renderer":_renderer, lineColor:Colors.setAlpha(_edgeColor, uint(255*_edgeAlpha)%256), 
					lineWidth:_edgeWidth});
			_vis.data.nodes.setProperties({"renderer":_renderer, lineWidth:_lifelineLayout.lifeline.lineWidth,
					fillAlpha: _nFillAlpha});
			_vis.data.blocks.setProperties({"renderer":_renderer, lineWidth:_bLineWidth, 
					lineColor: Colors.setAlpha(_bLineColor, uint(255*_bLineAlpha)%256), 
					fillColor: Colors.setAlpha(_bFillColor, uint(255*_bFillAlpha)%256)});
			_vis.data.attributes.setProperties({"renderer": _attrRenderer, fillColor:Colors.setAlpha(_attrColor, uint(255*_attrAlpha)%256), size:_attrSize});
			_vis.data.histEvents.setProperties({"renderer": _evtRenderer, fillColor:Colors.setAlpha(_histColor, uint(255*_histAlpha)%256)});
			_vis.data.events.setProperties({"renderer": _evtRenderer, fillColor:Colors.setAlpha(_evtColor, uint(255*_evtAlpha)%256)});
			//postprocessing after operators added
			// Format the y-axis.
		    var axes:CartesianAxes = _vis.axes as CartesianAxes;
		    //axes.xAxis.labelOffsetY = 0;
		    axes.xAxis.showLines = true;
		    axes.xAxis.showLabels =true;
		    axes.xAxis.labelOffsetY = 0;
		    axes.showXLine = true;
		    axes.xAxis.labelTextMode = TextSprite.DEVICE;
		    
//		
//			_spanSlider.minimum = axes.xAxis.axisScale.min.fullYear;
//			_spanSlider.maximum = axes.xAxis.axisScale.max.fullYear;
//			_spanSlider.values  = [_spanSlider.minimum, _spanSlider.maximum];			    

			_vis.update(null, OPS);
			
		}
		private function buildOperators():void{
			//build operators	
			_vis.operators.clear();						
			//add encoders
			var palette:ColorPalette = new ColorPalette([Colors.setAlpha(_nColors[0], uint(255*_nLineAlpha)%256),
				 Colors.setAlpha(_nColors[1], uint(255*_nLineAlpha)%256), 
				 Colors.setAlpha(_nColors[2], uint(255*_nLineAlpha)%256)]); 
			_colorEncoder = new ColorEncoder( "data.gender", Data.NODES, "lineColor", ScaleType.CATEGORIES, palette);					
			_vis.setOperator("colorEncoder", _colorEncoder);		        
 			

 			//add axis layout
// 			switch (_layoutType){
// 				case LifelineLayout.HOURGLASSCHART:
// 				_lifelineLayout = new HourglassChart(_root, "data.dateOfBirth", "data.yorder", _lifelineType);
// 				break;
// 				case LifelineLayout.DESCENDANTCHART:
// 				_lifelineLayout = new DescendantChart(_root, "data.dateOfBirth", "data.yorder", _lifelineType);
// 				break;
// 				case LifelineLayout.PEDIGREECHART:
// 				_lifelineLayout = new PedigreeChart(_root, "data.dateOfBirth", "data.yorder", _lifelineType);
// 				break; 				
// 			} 			
			_fisheyeFilter = new FisheyeFilter(_focusNodes, _doiDist);
			_vis.setOperator("fisheyeFilter",_fisheyeFilter);
			_lifelineLayout = new LifelineLayout(_root.sprite, _doiEnabled, _lifelineType, _labelStyle, _xrange);
			_vis.setOperator("layout", _lifelineLayout);	
// 			_vis.operators.add(new VisibilityFilter(filter));
 			
//			//labeling
		    var labeler:Labeler = new Labeler("data.name", Data.NODES, _lifelineLayout, new TextFormat("Arial", Lifeline.FONTSIZE),
		    function(d:DataSprite):Boolean{
		    	return (d.visible == true);
		    });	
		    _vis.setOperator("labler", labeler);
		}
		private function filter(d:DataSprite):Boolean{
			if (isNaN(d.data.yorder)) return false;
			var birthYear:Number = d.data.dateOfBirth.fullYear;
			var deathYear:Number = d.data.dateOfDeath != null? d.data.dateOfDeath.fullYear : 2009
			if (birthYear < _spanSlider.values[0]) return false;
			if (deathYear > _spanSlider.values[1]) return false;
			return true;
		}

		private function addFlexCtrls():void{
			_uiCtrls.setStyle("border", 0x000000);
			//css styles			
			var titleCSS:CSSStyleDeclaration = new CSSStyleDeclaration(".title");
			titleCSS.setStyle("fontSize", 12);
			titleCSS.setStyle("fontWeight", "bold");			
			var bodyCSS:CSSStyleDeclaration = new CSSStyleDeclaration(".body");
			bodyCSS.setStyle("fontSize", 12);
			
			//screen mode
			var y:Number = 20;
			var lbScrennMode:Label = new Label();
			lbScrennMode.text = "Screen Mode:";
			lbScrennMode.y = y;
			lbScrennMode.styleName = "body";
			lbScrennMode.enabled = false;
			_uiCtrls.addChild(lbScrennMode);
			
			var screenMode:ComboBox = new ComboBox();
			screenMode.dataProvider = ["Normal", "Full"];			
			screenMode.y = y;
			screenMode.x = 100;
			screenMode.addEventListener(ListEvent.CHANGE, onScreenModeChange);
			screenMode.enabled = false;
			_uiCtrls.addChild(screenMode);
			
			//node type 
			y += 30;
			var lbNodeType:Label = new Label();
			lbNodeType.text = "Lifeline Type:";
			lbNodeType.y = y;
			lbNodeType.styleName = "body";
			lbNodeType.enabled = false;
			_uiCtrls.addChild(lbNodeType);
			
			var nodeType:ComboBox = new ComboBox();
			nodeType.dataProvider =  [	{label:"Line", 			data: Lifeline.LINE}, 
										{label:"Spline", 		data : Lifeline.SPLINE}, 
										{label:"LineSpline", 	data : Lifeline.LINESPLINE}];
			nodeType.selectedIndex = _lifelineType;
			nodeType.y = y;
			nodeType.x = 100;
			nodeType.addEventListener(ListEvent.CHANGE, onNodeTypeChange);
			nodeType.enabled = false;
			_uiCtrls.addChild(nodeType);

			//layout type 
			y += 30;
			var lbLayoutType:Label = new Label();
			lbLayoutType.text = "Layout Type:";
			lbLayoutType.y = y;
			lbLayoutType.styleName = "body";
			lbLayoutType.enabled = false;
			_uiCtrls.addChild(lbLayoutType);
			
			var layoutType:ComboBox = new ComboBox();
			layoutType.dataProvider = [	{label:"Descendant", data : LifelineLayout.DESCENDANTCHART},
										{label:"Pedigree", 	 data : LifelineLayout.PEDIGREECHART},
										{label:"Hourglass",  data : LifelineLayout.HOURGLASSCHART}];
			layoutType.selectedIndex = _layoutType;
			layoutType.y = y;
			layoutType.x = 100;
			layoutType.addEventListener(ListEvent.CHANGE, onLayoutTypeChange);
			layoutType.enabled = false;
			_uiCtrls.addChild(layoutType);
			
			//layout mode
			y += 30;
			var lbLayoutMode:Label = new Label();
			lbLayoutMode.text = "Layout Mode:";
			lbLayoutMode.y	  = y;
			lbLayoutMode.styleName = "body";
			_uiCtrls.addChild(lbLayoutMode);
			
			var layoutMode:ComboBox = new ComboBox();
			layoutMode.dataProvider = [	{label:"Automatic", data : AUTOMATIC},
										{label:"Manual", 	data : MANUAL}];
			layoutMode.selectedIndex = _layoutMode;							
			layoutMode.y = y;
			layoutMode.x = 100;
			layoutMode.addEventListener(ListEvent.CHANGE, onLayoutModeChange);
			_uiCtrls.addChild(layoutMode);	
			
			//label style
			y += 30;
			var lbLabelStyle:Label 	= new Label();
			lbLabelStyle.text 		= "Label Style";
			lbLabelStyle.y			= y;
			lbLabelStyle.styleName = "body";
			_uiCtrls.addChild(lbLabelStyle);
			
			var labelStyle:ComboBox = new ComboBox();
			labelStyle.dataProvider = [	{label:"Inside", 	data : Lifeline.LABELINSIDE},
										{label:"Outside", 	data : Lifeline.LABELOUTSIDE}];
			labelStyle.selectedIndex = _labelStyle;							
			labelStyle.y = y;
			labelStyle.x = 100;
			labelStyle.addEventListener(ListEvent.CHANGE, onLabelStyleChange);
			_uiCtrls.addChild(labelStyle);	

			//label style
			y += 30;
			var lbDOI:Label 	= new Label();
			lbDOI.text 		= "DOI:";
			lbDOI.y			= y;
			lbDOI.styleName = "body";
			_uiCtrls.addChild(lbDOI);
			
			var doi:ComboBox = new ComboBox();
			doi.dataProvider = [	{label:"ON", 	data : Boolean(true)},
									{label:"OFF", 	data : Boolean(false)}];
			doi.selectedIndex = 0;							
			doi.y = y;
			doi.x = 100;
			doi.addEventListener(ListEvent.CHANGE, onDOIChange);
			_uiCtrls.addChild(doi);	
						
			//operations on node
			y += 30;
			var btnSp:Button	= new Button();	
			btnSp.label	= "simplify";
			btnSp.y		= y;
			btnSp.addEventListener(FlexEvent.BUTTON_DOWN, onSimplify);
			btnSp.enabled		= true;
			_uiCtrls.addChild(btnSp);
			
			var btnDsp:Button	= new Button();	
			btnDsp.label	= "desimplify";
			btnDsp.y		= y;
			btnDsp.x		= 100;
			btnDsp.addEventListener(FlexEvent.BUTTON_DOWN, onDesimplify);
			btnDsp.enabled		= true;
			_uiCtrls.addChild(btnDsp);

			//operations on node
//			y += 30;
//			var btnSp:Button	= new Button();	
//			btnSp.label	= "Export to PDF";
//			btnSp.y		= y;
//			btnSp.addEventListener(FlexEvent.BUTTON_DOWN, onExportToPDF);
//			btnSp.enabled		= true;
//			_uiCtrls.addChild(btnSp);
						
			//slider filter	
			y += 30;						
			var lbFilter:Label = new Label();
			lbFilter.y = y;
			lbFilter.text = "Filter:";
			lbFilter.styleName = "body";
			lbFilter.enabled = false;
			_uiCtrls.addChild(lbFilter);
			y += 30;						
			_spanSlider = new HSlider();
			_spanSlider.y = y;
			_spanSlider.width = 230;
			_spanSlider.thumbCount = 2;
			_spanSlider.setStyle("showTrackHighlight", "true");
			_spanSlider.tickInterval = 10;
			_spanSlider.snapInterval = 1;
			_spanSlider.liveDragging = true;
//			_spanSlider.minimum = Number.MIN_VALUE;
//			_spanSlider.maximum = Number.MAX_VALUE;
//			_spanSlider.values  = [Number.MIN_VALUE, Number.MAX_VALUE];	
			_spanSlider.enabled = false;
			_spanSlider.dataTipFormatFunction = function (val:String):String{
				return val+" year";
			}
			_spanSlider.addEventListener(SliderEvent.CHANGE, onSliderChange);
			_uiCtrls.addChild(_spanSlider);
			
			//range
			y += 30;
			var lbRange:Label = new Label();
			lbRange.y 			= y;
			lbRange.text		= "Range";
			lbRange.styleName	= "body";
			lbRange.enabled		= true;
			_uiCtrls.addChild(lbRange);
			
			 _range  =  new TextArea();
			_range.text 		=  _xrange.toString();
			_range.y			= y;
			_range.x			= 70; 
			_range.width		= _range.maxWidth = 50;			
			_range.height		= 20;
			_range.enabled		= true;
			_uiCtrls.addChild(_range);
			
			var btnRange:Button  =  new Button();
			btnRange.label	= "update";
			btnRange.y		= y;
			btnRange.x		= 130;
			btnRange.addEventListener(FlexEvent.BUTTON_DOWN, onUpdateRange);
			btnRange.enabled		= true;
			_uiCtrls.addChild(btnRange);
		}
//		private function onExportToPDF(evt:FlexEvent):void{
//			var spr:Sprite = new Sprite();
//			spr.graphics.beginFill(0xff0000,1);
//			spr.graphics.drawCircle(0,0,100);
//			spr.graphics.endFill();					
//			var pdf:PDF = new PDF(Orientation.PORTRAIT);
//			pdf.setDisplayMode(Display.FULL_WIDTH);
//			pdf.addPage();
//			pdf.addImage(spr);
//			pdf.save(Method.REMOTE, "./php/exportVis.php", Download.ATTACHMENT, "genvis.pdf");
//		}
		private function onDOIChange(evt:ListEvent):void{
			_doiEnabled = evt.currentTarget.selectedItem.data;
			_lifelineLayout.doiEnabled = _doiEnabled;		
			_doiEnabled? _vis.update(null, OPS) : _vis.update(null, [ENCODER, LAYOUT, LABLER]);
		}
		private function onSimplify(evt:FlexEvent):void{
			if (_selectedBlock == null) return;
			_selectedBlock.simplify();
			_vis.update(_t, OPS);
		}
		private function onDesimplify(evt:FlexEvent):void{
			if (_selectedBlock == null) return;
			_selectedBlock.desimplify();
			_vis.update(_t, OPS);
		}
		private function onUpdateRange(evt:FlexEvent):void{
			_lifelineLayout.xrange = Number(_range.text);
			_vis.axes.update();
			_lifelineLayout.horizontalPositioning();
			_lifelineLayout.localLayout();
			_vis.axes.update();
			_vis.render();
			DirtySprite.renderDirty();
		}
		private function onScreenModeChange(evt:ListEvent):void{
			var screenMode:String = evt.currentTarget.selectedItem;
			if(screenMode == "Normal" && this.stage.displayState == StageDisplayState.FULL_SCREEN) {
				this.stage.displayState = StageDisplayState.NORMAL;		
			} else {
				this.stage.displayState = StageDisplayState.FULL_SCREEN;				
			}
		}
		private function onNodeTypeChange(evt:ListEvent):void{
			_lifelineType = evt.currentTarget.selectedItem.data;
			updateVis(_vis.data);
		}
		private function onLayoutTypeChange(evt:ListEvent):void{
			_layoutType = evt.currentTarget.selectedItem.data;
			updateVis(_vis.data);
		}
		private function onLayoutModeChange(evt:ListEvent):void{
			_layoutMode = evt.currentTarget.selectedItem.data;
			_renderer.layoutMode = _layoutMode;
			_dragCtrl.isEnabled = _dragCtrl.isEnabled == true? false: true;
			_vis.render(Data.BLOCKS);
		}
		private function onLabelStyleChange(evt:ListEvent):void{
			//1.label calculation
			//2.redraw nodes
			_labelStyle = evt.currentTarget.selectedItem.data;
			_lifelineLayout.lifeline.style = _labelStyle;
//			_lifelineLayout.localLayout();
//			_vis.update(_t, LABLER);
//			_vis.render();
			_vis.update(_t, OPS);
		}
		private function onSliderChange(evt:Event):void{
			_vis.update(_t, OPS);
		}
		
		private function addFlareCtrls():void{
			//add controls
//			_dragCtrl = new DragControl();
//			_vis.controls.add(_dragCtrl);
			_hoverCtrl = new HoverControl(DataSprite,
				HoverControl.MOVE_AND_RETURN,
				function(e:SelectionEvent):void {					
					if ( e.item is EdgeSprite) {
						var edge:EdgeSprite = e.edge;
						//edge highlight
						edge.props.lineWidth = edge.lineWidth;
						edge.lineWidth = 4;
//						//parents highlight
//						for each (var p:NodeSprite in edge.parents){
//							p.props.lineColor = p.lineColor;
//							p.lineColor =0xff73d216;
//						}
//						edge.child.props.lineColor = edge.child.lineColor;
//						edge.child.lineColor = 0xff73d216;
					}else if (e.item is NodeSprite){//node sprite
						var node:NodeSprite = e.node;
						node.filters = [_nodeGlow];
						//highlight connected edges
						node.visitEdges(function (edge:EdgeSprite):void{
							edge.props.lineWidth = edge.lineWidth;
							edge.lineWidth = 4;
							edge.props.lineColor = edge.lineColor;
							edge.lineColor = 0xff73d216;
						});						
//						node.props.lineColor = node.lineColor;
//						node.lineColor = 0xff73d216;
					}else if (e.item is BlockSprite){
						var b:BlockSprite = e.item as BlockSprite;
						b.props.lineWidth = b.lineWidth;
						b.lineWidth = 4;
						b.props.lineColor = b.lineColor;
						b.lineColor = Colors.setAlpha(0x73d216, uint(255*_bLineAlpha)%256);
						b.props.fillColor = b.fillColor;
						b.fillColor = Colors.setAlpha(0x73d216, uint(255*_bFillAlpha)%256);						
					}else if (e.item is AttributeSprite){
						var a:AttributeSprite = e.item as AttributeSprite;
						if (GenVis.uncType == GenVis.QSMARK){								
							a.label.bold  = true;
							a.label.color = 0x73d216;
						}else if (GenVis.uncType == GenVis.GRADIENT){
							//a.props.fillColor = a.fillColor;
							//a.fillColor = Colors.setAlpha(0x73d216, uint(255*a.fillAlpha)%256);
							a.filters = [_uncGlow];
						}
					}else if (e.item is EventSprite){
						var evt:EventSprite = e.item as EventSprite;
						if (evt.event.historical){
							evt.props.fillAlpha = evt.fillAlpha;
							evt.fillAlpha = 1.0;
						}else{
							evt.props.fillColor = evt.fillColor;
							evt.fillColor		= Colors.setAlpha(0xffffff, uint(255*_evtAlpha)%256);
							evt.filters 		= [_evtGlow];
						}			
						//_tmp = ToolTipManager.createToolTip("test", e.cause.stageX, e.cause.stageY, "errorTipAbove") as ToolTip;			
					}
				},
				// Return node to previous state
				function(e:SelectionEvent):void {					
					if (e.item is EdgeSprite) {
						var edge:EdgeSprite = e.edge;
						edge.lineWidth = edge.props.lineWidth;
//						for each (var p:NodeSprite in edge.parents){
//							p.lineColor = p.props.lineColor;
//						}
//						edge.child.lineColor = edge.child.props.lineColor;
					}else if (e.item is NodeSprite){
//						e.node.lineColor = e.node.props.lineColor;
						if (e.node.selected==false && _persistentFoci.indexOf(e.node)<0) e.node.filters = null;
						if (_persistentFoci.indexOf(e.node)>=0) e.node.filters = [_focusGlow];
						e.node.visitEdges(function (edge:EdgeSprite):void{							
							edge.lineWidth = edge.props.lineWidth;
							edge.lineColor = edge.props.lineColor;	
						})
					}else if (e.item is BlockSprite){
						var b:BlockSprite = e.item as BlockSprite;
						b.lineWidth = b.props.lineWidth;
						b.lineColor = b.props.lineColor;
						b.fillColor = b.props.fillColor;
					}else if (e.item is AttributeSprite){
						var a:AttributeSprite = e.item as AttributeSprite;
						if (GenVis.uncType == GenVis.QSMARK){								
							a.label.bold  = false;
							a.label.color = 0x000000;
						}else if (GenVis.uncType == GenVis.GRADIENT){
							//a.fillColor = a.props.fillColor;
							a.filters = null;
						}
						
					}else if (e.item is EventSprite){
						var evt:EventSprite = e.item as EventSprite;
						if (evt.event.historical){
							evt.fillAlpha = evt.props.fillAlpha;
						}else{
							evt.fillColor	= evt.props.fillColor;
							evt.filters 	= null;
						}			
						//ToolTipManager.destroyToolTip(_tmp);			
					}
				});
			_vis.controls.add(_hoverCtrl);
			//2. toolTip Control
//			_toolTip = new TooltipControl (NodeSprite, null,
//        			function( evt:TooltipEvent ):void
//        			{        				
//						var person:Person = evt.node.data as Person;
//						var birthYear:Number = person.dateOfBirth.fullYear
//						var deathYear:Number = person.dateOfDeath != null? person.dateOfDeath.fullYear : (new Date()).fullYear;
//						var toolTip:String = "<b>"+person.name+"<br>"+person.gender+"<br>"+birthYear+"-"+deathYear;
//						for (var i:int=0; i<person.marriages.length; i++){
//							var marriage:Marriage = person.marriages[i];
//							toolTip	+= "<br>marriage#"+(i+1)+
//								": "+ marriage.startDate.fullYear+"-"+
//								(marriage.divorced? marriage.endDate.fullYear : "");
//						}
//						toolTip += "</b>";
//						//father and mother
//						if (person.father) toolTip += "<br>father:" + person.father.name + "<br>";
//						if (person.mother) toolTip += "mother:" + person.mother.name;
//						TextSprite( evt.tooltip ).htmlText = toolTip;
//    	    		});
//			_vis.controls.add(_toolTip);	
			var toolTipCtrl:TooltipControl = new TooltipControl(EventSprite, null, function (te:TooltipEvent):void{
				var e:EventSprite = te.object as EventSprite;
				var text:String = "<b><font color='#e9b96e;'>"+e.event.name+"</font></b><br/>";								
				if (e.event.isRange){
					text += Helper.dateToString(e.event.start) + " to "+Helper.dateToString(e.event.end);
				}else{
					text += Helper.dateToString(e.event.start);
				}
				text += "<br/>"+e.event.location+"<br/>";
				var lineLen:Number = 26;
				var curIdx:Number = 0;
				while (curIdx < e.event.description.length){
					text += e.event.description.substr(curIdx, lineLen) + "<br/>";
					curIdx += lineLen;
				}
				
				var toolTip:TextSprite = te.tooltip as TextSprite;
				toolTip.htmlText = text;			
			})
			toolTipCtrl.tipBounds = _vis.bounds;
			_vis.controls.add(toolTipCtrl);	

			_vis.controls.add(new ClickControl(null, 1,
				// set search query to the occupation name
				function(e:SelectionEvent):void {					
					var selectPerson:SelectEvent;					
					if (e.object is NodeSprite){
						_this.select(e.node.data as Person, false);							
					}else if (e.object is AttributeSprite){
						_this.deselect();		
						var attr:AttributeSprite = e.object as AttributeSprite;	
						var selectAttr:SelectEvent;
						if (attr.objType == AttributeSprite.PERSON){		
							_selectedNode = (attr.data as Person).sprite;
							_selectedNode.selected = true;
							selectAttr = new SelectEvent(SelectEvent.SELECT, SelectEvent.ATTRIBUTE, attr, e.cause);
							selectAttr.dispatch();	
						}else if (attr.objType == AttributeSprite.MARRIAGE){							
							attr = e.object as AttributeSprite;
							selectAttr = new SelectEvent(SelectEvent.SELECT, SelectEvent.ATTRIBUTE, attr, e.cause);
							selectAttr.dispatch();	
						}											
					}else if (e.object is BlockSprite){
//						var b:BlockSprite = e.object as BlockSprite;
//						b.selected = b.selected? false:true;
//						if (e.shiftKey){							
//							e.ctrlKey? b.desimplify():b.simplify();							
//							_vis.update(_t, OPS);
//						}						
					}else{
						deselect(true);							
//						GenVis.drawBlock = !GenVis.drawBlock;
//						_vis.update(_t, OPS);											
					}
				
					if (_doiEnabled){
						if (e.object is NodeSprite && e.node.type != NodeSprite.SPOUSE){
							var pidx:int = _persistentFoci.indexOf(e.node);
							if ( e.node.type != NodeSprite.ROOT && e.ctrlKey){//set persistent focus	
								if (pidx<0){//not a persistent focus								
									_persistentFoci.push(e.node);
									//_focusNodes.push(e.node);
									e.node.filters = [_focusGlow];									
								}else{
									_persistentFoci.splice(pidx,1);
									_focusNodes.splice(_focusNodes.indexOf(e.node),1)
									e.node.filters = null;
								}																	
							}
															
							if (_recentFocus && _persistentFoci.indexOf(_recentFocus)<0) {
								_focusNodes.splice(_focusNodes.indexOf(_recentFocus),1);	//remove current focus
								e.node.status = NodeSprite.NON_FOCUSED;
							}	
							if ( e.node.type != NodeSprite.ROOT){								
								_focusNodes.push(e.node);
								e.node.status = NodeSprite.FOCUSED;									
							}
							_recentFocus = e.node;											
							
							_lifelineLayout.buildScale(e.node);
							_vis.update(null, [ENCODER, FILTER]);
							_vis.update(1, [LAYOUT, LABLER]).play();						
						}
					}
//					if (_layoutMode == MANUAL || e.node.type == NodeSprite.SPOUSE
//						|| _doiEnabled==false) return;
//					if (e.node.type != NodeSprite.ROOT){
//						if (e.node.status == NodeSprite.FOCUSED){
//							//if (_focusNodes.length == 1) return; //make sure there exists at least one nodesprite.
//						 	e.node.status = NodeSprite.NON_FOCUSED;	
//							_focusNodes.splice(_focusNodes.indexOf(e.node), 1);
//						}else{//not previously focused
//							e.node.status = NodeSprite.FOCUSED;
//							_focusNodes.push(e.node);
//						}	
//					}				
//					_lifelineLayout.buildScale(e.node);
//					_vis.update(null, [ENCODER, FILTER]);
//					_vis.update(1, [LAYOUT, LABLER]).play();
					
					//_vis.axes.update();
					//_vis.render();//force render
					//DirtySprite.renderDirty();
				}
			));
			_vis.controls.add( new ClickControl(NodeSprite, 2,
				function (e:SelectionEvent):void{					
					var newRoot:Person = e.node.data as Person;
					var rootChange:RootChangeEvent = new RootChangeEvent(newRoot);
					rootChange.dispatch();					
				}));
//			_vis.controls.add(new ClickControl(BlockSprite, 1,
//				// set search query to the occupation name
//				function(e:SelectionEvent):void {
//					if (_layoutMode != MANUAL) return;
//					var b:BlockSprite = e.block;
//					if (_selectedBlock)	_selectedBlock.selected = false;
//					_selectedBlock = b;
//					_selectedBlock.selected = true;
//					
//				}
//			));
			if (!_doiEnabled) _vis.controls.add(new PanZoomControl(this));
			
		}
	}
}