package genvis
{
	import flare.display.DirtySprite;
	import flare.display.TextSprite;
	import flare.util.Colors;
	import flare.util.palette.ColorPalette;
	import flare.vis.data.DataSprite;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	import genvis.animate.Transitioner;
	import genvis.data.DataEstimator;
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.data.converters.XMLConverter;
	import genvis.scale.ScaleType;
	import genvis.vis.Visualization;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.controls.ClickControl;
	import genvis.vis.controls.DragControl;
	import genvis.vis.controls.HoverControl;
	import genvis.vis.controls.TooltipControl;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.Data;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.NodeSprite;
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
	
	import org.akinu.events.SelectEvent;
	
//	import org.alivepdf.display.Display;
//	import org.alivepdf.layout.Orientation;
//	import org.alivepdf.pdf.PDF;
//	import org.alivepdf.saving.Download;
//	import org.alivepdf.saving.Method;

	public class GenVis extends Canvas
	{
		//visualization
		private var _vis:Visualization 			= null;
		private var _hoverCtrl:HoverControl 	= null;
		private var _dragCtrl:DragControl		= null;
		private var _toolTip:TooltipControl 	= null;
		private var _colorEncoder:ColorEncoder 	= null;
		private var _fisheyeFilter:FisheyeFilter= null;
		private var _renderer:LifelineRenderer 	= null;
		private var _lifelineLayout:LifelineLayout = null;
		private var _root:Person;	
		private var _focusNodes:Array 			= new Array();
		private var _selectedNode:NodeSprite		= null;
 		private var _range:TextArea				= null;
 		private var _t:Transitioner				= null; 		
		//child components
		private var _visarea:UIComponent 	= null;
//		private var _visScroll:ScrollBar	= null;
		private var _uiCtrls:Canvas			= null;
		private var _spanSlider:HSlider		= null;
		//****************//
		//configuration   //
		//****************//
		public static const AUTOMATIC:int	= 0;
		public static const MANUAL:int	 	= 1;
	
		private static const MINWIDTH:Number 	= 400;
		private static const MINHEIGHT:Number 	= 400;
		
		private static const ENCODER:String		= "colorEncoder";
		private static const FILTER:String		= "fisheyeFilter";
		private static const LAYOUT:String		= "layout";
		private static const LABLER:String		= "labler";
		private static const OPS:Array			= [ENCODER, FILTER, LAYOUT, LABLER];
				
		private var _labelStyle:int = Lifeline.LABELOUTSIDE;
		private var _layoutMode:int	= AUTOMATIC;
		private var _layoutType:int = LifelineLayout.HOURGLASSCHART;
		private var _lifelineType:int				= Lifeline.LINESPLINE;
		private var _doiEnabled:Boolean				= false;
		private var _xrange:Number					= 100;
		private var _selectedBlock:BlockSprite		= null;
		//node config
		private var _nColors:Array 		= [0x3465a4, 0xcc0000, 0x555753];
		private var _nLineAlpha:Number	= 1.0;
		private var _nFillAlpha:Number	= 0.1;
		//block config
		private var _bLineWidth:Number  = 2;
		private var _bFillColor:Number 	= 0x888a85;
		private var _bFillAlpha:Number	= 0.5;
		private var _bLineColor:Number	= 0x2e3436;
		private var _bLineAlpha:Number	= 0.5;
		
		private var _edgeColor:Number  	= 0x4e9a06;//0xbabdb6;
		private var _edgeWidth:Number	= 2;	
		private var _edgeAlpha:Number	= 0.6;	
		
		public function GenVis()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		public function addRelationship(person:Person, role:String, ref_id:String):void{

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
		public function visualize(root:Person):void{
			//#1. clear sprites if reusing data
			clear();
			_root = root;

			//#2. estimate missing data
			DataEstimator.estimate(_root, null);	
			//#3. construct display list
			var data:Data = new Data(_root);		

			//#3. set initial focus
			_root.sprite.status = NodeSprite.FOCUSED;
			//_focusNodes.push(_root.sprite);
			
			//#4. construct visualization			
			updateVis(data);
			
			//#5. enable vis controls
			_uiCtrls.enabled = false;
			
			DirtySprite.renderDirty();
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
			_renderer = new LifelineRenderer(_lifelineType, _layoutMode);
			
			buildOperators();				
			_vis.data.edges.setProperties({"renderer":_renderer, lineColor:Colors.setAlpha(_edgeColor, uint(255*_edgeAlpha)%256), 
					lineWidth:_edgeWidth});
			_vis.data.nodes.setProperties({"renderer":_renderer, lineWidth:_lifelineLayout.lifeline.lineWidth,
					fillAlpha: _nFillAlpha});
			_vis.data.blocks.setProperties({"renderer":_renderer, lineWidth:_bLineWidth, 
					lineColor: Colors.setAlpha(_bLineColor, uint(255*_bLineAlpha)%256), 
					fillColor: Colors.setAlpha(_bFillColor, uint(255*_bFillAlpha)%256)});
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
			_fisheyeFilter = new FisheyeFilter(_focusNodes, 1);
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
						edge.lineWidth = 3;
						edge.props.lineColor = edge.lineColor;
						edge.lineColor = 0xff73d216;
//						//parents highlight
//						for each (var p:NodeSprite in edge.parents){
//							p.props.lineColor = p.lineColor;
//							p.lineColor =0xff73d216;
//						}
//						edge.child.props.lineColor = edge.child.lineColor;
//						edge.child.lineColor = 0xff73d216;
					}else if (e.item is NodeSprite){//node sprite
						var node:NodeSprite = e.node;
						node.props.lineColor = node.lineColor;
						node.lineColor = 0xff73d216;
					}else if (e.item is BlockSprite){
						var b:BlockSprite = e.item as BlockSprite;
						b.props.lineWidth = b.lineWidth;
						b.lineWidth = 2;
						b.props.lineColor = b.lineColor;
						b.lineColor = Colors.setAlpha(0x73d216, uint(255*_bLineAlpha)%256);
						b.props.fillColor = b.fillColor;
						b.fillColor = Colors.setAlpha(0x73d216, uint(255*_bFillAlpha)%256);						
					}
				},
				// Return node to previous state
				function(e:SelectionEvent):void {					
					if (e.item is EdgeSprite) {
						var edge:EdgeSprite = e.edge;
						edge.lineWidth = edge.props.lineWidth;
						edge.lineColor = edge.props.lineColor;
//						for each (var p:NodeSprite in edge.parents){
//							p.lineColor = p.props.lineColor;
//						}
//						edge.child.lineColor = edge.child.props.lineColor;
					}else if (e.item is NodeSprite){
						e.node.lineColor = e.node.props.lineColor;
					}else if (e.item is BlockSprite){
						var b:BlockSprite = e.item as BlockSprite;
						b.lineWidth = b.props.lineWidth;
						b.lineColor = b.props.lineColor;
						b.fillColor = b.props.fillColor;
					}
				});
			_vis.controls.add(_hoverCtrl);
			//2. toolTip Control
			_toolTip = new TooltipControl (NodeSprite, null,
        			function( evt:TooltipEvent ):void
        			{        				
						var person:Person = evt.node.data as Person;
						var birthYear:Number = person.dateOfBirth.fullYear
						var deathYear:Number = person.dateOfDeath != null? person.dateOfDeath.fullYear : (new Date()).fullYear;
						var toolTip:String = "<b>"+person.name+"<br>"+person.gender+"<br>"+birthYear+"-"+deathYear;
						for (var i:int=0; i<person.marriages.length; i++){
							var marriage:Marriage = person.marriages[i];
							toolTip	+= "<br>marriage#"+(i+1)+
								": "+ marriage.startDate.fullYear+"-"+
								(marriage.divorced? marriage.endDate.fullYear : "");
						}
						toolTip += "</b>";
						//father and mother
						if (person.father) toolTip += "<br>father:" + person.father.name + "<br>";
						if (person.mother) toolTip += "mother:" + person.mother.name;
						TextSprite( evt.tooltip ).htmlText = toolTip;
    	    		});
			_vis.controls.add(_toolTip);			
			_vis.controls.add(new ClickControl(NodeSprite, 1,
				// set search query to the occupation name
				function(e:SelectionEvent):void {
					if (_selectedNode){
						_selectedNode.selected = false;
					}
					
					_selectedNode = e.node;
					_selectedNode.selected = true;
					
					//Dispatch Selection Event
					var selectPerson:SelectEvent = new SelectEvent(SelectEvent.PERSON, _selectedNode.data as Person);
					selectPerson.dispatch();
					
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
//			_vis.controls.add( new PanZoomControl());
			
		}
	}
}