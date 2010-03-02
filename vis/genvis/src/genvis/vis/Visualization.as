package genvis.vis
{
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.core.UIComponent;
	import fl.events.ScrollEvent;
	
	import flare.display.RectSprite;
	import flare.util.Displays;
	import flare.vis.data.DataSprite;
	import flare.vis.events.DataEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import genvis.animate.ISchedulable;
	import genvis.animate.Transitioner;
	import genvis.vis.axis.Axes;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.controls.ControlList;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.Data;
	import genvis.vis.events.VisualizationEvent;
	import genvis.vis.operator.IOperator;
	import genvis.vis.operator.OperatorList;

	[Event(name="update", type="flare.vis.events.VisualizationEvent")]

	/**
	 * The Visualization class represents an interactive data visualization.
	 * A visualization instance consists of
	 * <ul>
	 *  <li>A <code>Data</code> instance containing <code>DataSprite</code>
	 *      objects that visually represent individual data elements</li>
	 *  <li>An <code>OperatorList</code> of visualization operators that
	 *      determine visual encodings for position, color, size and other
	 *      properties.</li>
	 *  <li>A <code>ControlList</code> of interactive controls that enable
	 *      interaction with the visualized data.</li>
	 *  <li>An <code>Axes</code> instance for presenting axes for metric
	 *      data visualizations. Axes are often configuring automatically by
	 *      the visualization's operators.</li>
	 * </ul>
	 * 
	 * <p>Visual objects are added to the display list within the
	 * <code>marks</code> property of the visualization, as the
	 * <code>Data</code> object is not a <code>DisplayObjectContainer</code>.
	 * </p>
	 * 
	 * <p>All visual elements are contained within <code>layers</code> Sprite.
	 * This includes the <code>axes</code>, <code>marks</code>, and
	 * (optionally) <code>labels</code> layers. Clients who wish to add
	 * additional layers to a visualization should add them directly to the
	 * <code>layers</code> sprite. Just take care to maintain the desired order
	 * of elements to avoid occlusion.</p>
	 * 
	 * <p>To create a new Visualization, load in a data set, construct
	 * a <code>Data</code> instance, and instantiate a new
	 * <code>Visualization</code> with the input data. Then add the series
	 * of desired operators to the <code>operators</code> property to 
	 * define the visual encodings.</p>
	 * 
	 * @see flare.vis.operator
	 */
	public class Visualization extends UIComponent
	{	
		// -- Properties ------------------------------------------------------
		
		private var _bounds:Rectangle = new Rectangle(0,0,500,500);
		
		private var _layers:UIComponent; // sprite for all layers in visualization
		private var _marks:Sprite;  // sprite for all visualized data items
		private var _labels:Sprite; // (optional) sprite for labels
		private var _axes:Axes;     // (optional) axes, lines, and axis labels
		
		private var _data:Data;     // data structure holding visualized data
		
		private var _ops:Object;              // map of all named operators
		private var _operators:OperatorList;  // the "main" operator list
		private var _controls:ControlList;    // interactive controls
		
		private var _vismask:RectSprite;
		private var _hscrollbar:ScrollBar;
		private var _vscrollbar:ScrollBar;
		//internal use
		private var _maskEnabled:Boolean 	= true;
		private var _scrollEnabled:Boolean 	= true;
		private var _fitVertBound:Boolean	= true;
		/** An object storing extra properties for the visualziation. */
		public var props:Object = {};
		
		/** The layout bounds of the visualization. This determines the layout
		 *  region for data elements. For example, with an axis layout, the
		 *  bounds determined the data layout region--this does not include
		 *  space used by axis labels. */
		public function get bounds():Rectangle { return _bounds; }
		public function set bounds(r:Rectangle):void {
			_bounds = r;
			if (_maskEnabled) setMask();
			if (_scrollEnabled) setScrollbar();
			if (stage) stage.invalidate();
		}
		
		/** Container sprite holding each layer in the visualization. */
		public function get layers():Sprite { return _layers; }
		
		/** Sprite containing the <code>DataSprite</code> instances. */
		public function get marks():Sprite { return _marks; }
		
		/** Sprite containing a separate layer for labels. Null by default. */
		public function get labels():Sprite { return _labels; }
		public function set labels(l:Sprite):void {
			if (_labels != null)
				_layers.removeChild(_labels);
			_labels = l;
			if (_labels != null) {
				_labels.name = "_labels";
				_layers.addChildAt(_labels, _layers.getChildIndex(_marks)+1);
			}
		}
		
		/**
		 * The axes for this visualization. May be null if no axes are needed.
		 */
		public function get axes():Axes { return _axes; }
		public function set axes(a:Axes):void {
			if (_axes != null)
				_layers.removeChild(_axes);
			_axes = a;
			if (_axes != null) {
				_axes.visualization = this;
				_axes.name = "_axes";
				_layers.addChildAt(_axes, 0);
			}
		}
		/** The axes as an x-y <code>CartesianAxes</code> instance. Returns
		 *  null if <code>axes</code> is null or not a cartesian axes instance.
		 */
		public function get xyAxes():CartesianAxes { return _axes as CartesianAxes; }
		
		/** The visual data elements in this visualization. */
		public function get data():Data { return _data; }
		public function set data(d:Data):void
		{
			if (_data != null) {
				_data.visit(_marks.removeChild, Data.BLOCKS);
				_data.visit(_marks.removeChild, Data.EDGES);
				_data.removeEventListener(DataEvent.ADD, dataAdded);
				_data.removeEventListener(DataEvent.REMOVE, dataRemoved);
			}
			_data = d;
			if (_data != null) {
				_data.visit(_marks.addChild, Data.EDGES);
				_data.visit(_marks.addChild, Data.BLOCKS);
				
				_data.addEventListener(DataEvent.ADD, dataAdded);
				_data.addEventListener(DataEvent.REMOVE, dataRemoved);
			}
		}

		/** The operator list for defining the visual encodings. */
		public function get operators():OperatorList { return _operators; }
		
		/** The control list containing interactive controls. */
		public function get controls():ControlList { return _controls; }
		

		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new Visualization with the given data and axes.
		 * @param data the <code>Data</code> instance containing the
		 *  <code>DataSprite</code> elements in this visualization.
		 * @param axes the <code>Axes</code> to use with this visualization.
		 *  Null by default; layout operators may re-configure the axes.
		 */
		public function Visualization(data:Data=null, axes:Axes=null) {
			if (_maskEnabled) addChild(this.mask = _vismask = new RectSprite());
			addChild(_layers = new UIComponent());
			_layers.name = "_layers";
			
			_layers.addChild(_marks = new Sprite()); 
			_marks.name = "_marks";
			
			if (data != null) this.data = data;
			//if (axes != null) this.axes = axes;
			
			_operators = new OperatorList();
			_operators.visualization = this;
			_ops = { main:_operators };
			
			_controls = new ControlList();
			_controls.visualization = this;
			
			Displays.addStageListener(this, Event.RENDER,
				setHitArea, false, int.MIN_VALUE+1);
			
			if (_scrollEnabled){
				this.addChild(_hscrollbar = new ScrollBar());
				this.addChild(_vscrollbar = new ScrollBar());	
				_hscrollbar.enabled = true;
				_hscrollbar.direction = ScrollBarDirection.HORIZONTAL;
				_hscrollbar.addEventListener(ScrollEvent.SCROLL, hscrollHandler);			
		
				_vscrollbar.enabled = true;
				_vscrollbar.direction = ScrollBarDirection.VERTICAL;
				_vscrollbar.addEventListener(ScrollEvent.SCROLL, vscrollHandler);	
			}						
			
		}
		public function setMask():void{
			_vismask.x = bounds.x;
			_vismask.y = bounds.y-15;
			_vismask.w = bounds.width+15;//+_vscrollbar.width;
			_vismask.h = bounds.height+30;//+_hscrollbar.height;
			_vismask.fillColor = 0xff000000;
		}
		public function setScrollbar():void{
			_hscrollbar.y 		= -15;//bounds.height;	
			_hscrollbar.width 	= bounds.width;
			_vscrollbar.x		= bounds.width;
			_vscrollbar.height	= bounds.height+_hscrollbar.height;
		}
		public function updateScrollbar():void{
			//horizontal scrollbar
			var min:Number 	= bounds.x;
			var max:Number 	= bounds.width;
			_data.visit(function(b:BlockSprite):void{
					if (b.visible==false || b.aggregated==true) return;
					if (b.x < min) min = b.x;
					if (max < (b.x + b.bbox.width)) max = b.x + b.bbox.width;

			}, Data.BLOCKS);
			
			var range:Number = (bounds.x - min) + (max-(bounds.x+bounds.width));
			//trace("SCROLL-"+min+","+max+","+range);
			_hscrollbar.setScrollProperties(range, 0, range);
			_hscrollbar.setScrollPosition(0);
			_layers.x = (bounds.x - min);
			_hscrollbar.visible = true;	
			
			//vertical scrollbar
			min = bounds.y;
			max = bounds.height;
			_data.visit(function(b:BlockSprite):void{
					if (b.visible==false || b.aggregated==true) return;
					if (b.y < min) min = b.y;
					if (max < (b.y + b.bbox.height)) max = b.y + b.bbox.height;
			}, Data.BLOCKS);			
			
			range = (bounds.y - min) + (max-(bounds.y+bounds.height));
			//trace("SCROLL-"+min+","+max+","+range);
			_vscrollbar.setScrollProperties(range, 0, range);
			_vscrollbar.setScrollPosition(0);
			_layers.y = (bounds.y - min);	
			_vscrollbar.visible = true;		
		}
		public function hscrollHandler(se:ScrollEvent):void{
			_layers.x -= se.delta;
		}
		public function vscrollHandler(se:ScrollEvent):void{
			_layers.y -= se.delta;
		}
		/**
		 * Update this visualization, re-calculating axis layout and running
		 * the operator chain. The input transitioner is used to actually
		 * perform value updates, enabling animated transitions. This method
		 * also issues a <code>VisualizationEvent.UPDATE</code> event to any
		 * registered listeners.
		 * @param t a transitioner or time span for updating object values. If
		 *  the input is a transitioner, it will be used to store the updated
		 *  values. If the input is a number, a new Transitioner with duration
		 *  set to the input value will be used. The input is null by default,
		 *  in which case object values are updated immediately.
		 * @param operators an optional list of named operators to run in the
		 *  update. 
		 * @return the transitioner used to store updated values.
		 */
		public function update(t:*=null, ...operators):Transitioner
		{
			if (operators) {
				if (operators.length == 0) {
					operators = null;
				} else if (operators[0] is Array) {
					operators = operators[0].length > 0 ? operators[0] : null;
				}
			}
			var trans:Transitioner = Transitioner.instance(t);
			if (_axes != null) {
				_axes.update(trans);
			}
			if (operators) {
				for each (var name:String in operators) {
					if (_ops.hasOwnProperty(name))
						_ops[name].operate(trans);
					else
						throw new Error("Unknown operator: " + name);
				}
			} else {
				_operators.operate(trans);
			}
			if (_axes != null) {
				if (_fitVertBound){
					var min:Number = bounds.y;
					var max:Number = bounds.height;
					_data.visit(function(b:BlockSprite):void{
							if (b.visible==false || b.aggregated==true) return;
							if (b.y < min) min = b.y;
							if (max < (b.y + b.bbox.height)) max = b.y + b.bbox.height;
					}, Data.BLOCKS);
					bounds.y = min;
					bounds.height = max;	
				}
				_axes.update(trans);			
			}
			fireEvent(VisualizationEvent.UPDATE, trans, operators);
			renderBounds();
			if (_scrollEnabled) updateScrollbar();
			return trans;
		}
		public function render(group:String = null):void{
			if (_data) _data.visit(function (d:DataSprite):void{ d.dirty(); }, group);
		}
		/**
		 * A function generator that can be used to invoke a visualization
		 * update at a later time. This method returns a function that
		 * accepts a <code>Transitioner</code> as its sole argument and then
		 * executes a visualization update using the specified named
		 * operators. 
		 * @param operators an optional array of named operators to run
		 * @return a function that takes a <code>Transitioner</code> argument
		 *  and invokes an update.
		 */
		 public function renderBounds():void{
		 	var g:Graphics = this.graphics;
		 	g.clear();
		 	g.lineStyle(1, 0x2e3436, 0.3);
		 	g.beginFill(0xff0000, 0);			
			g.drawRect(_bounds.x, bounds.y, _bounds.width, _bounds.height);
			g.endFill();
		 }
		public function updateLater(...operators):Function
		{
			return function(t:Transitioner):Transitioner {
				return update(t, operators);
			}
		}
		
		/**
		 * Updates the data display bounds for a visualization based on a
		 * given aspect ratio and provided width and height values. If both
		 * width and height values are provided, they will be treated as the
		 * maximum bounds. If only one of the width or height is provided, then
		 * the width or height will match that value, and the other will be
		 * determined by the aspect ratio. Finally, if neither width nor height
		 * is provided, then the current width and height of the display bounds
		 * will be used as the maximum bounds. After calling this method, a
		 * call to <code>update</code> is necessary to reflect the change.
		 * @param ar the desired aspect ratio for the data display
		 * @param width the desired width. If a height value is also provided,
		 *  this width value will be treated as the maximum possible width
		 *  (the actual width may be lower).
		 * @param height the desired height. If a width value is also provided,
		 *  this height value will be treated as the maximum possible height
		 *  (the actual height may be lower).
		 */
		public function setAspectRatio(ar:Number, width:Number=-1,
			height:Number=-1):void
		{
			// compute new bounds
			if (width > 0 && height < 0) {
				height = width / ar;
			} else if (width < 0 && height > 0) {
				width = ar * height;
			} else {
				if (width < 0 && height < 0) {
					width = bounds.width;
					height = bounds.height;
				}
				if (ar > 1) {          // width > height
					height = width / ar;
				} else if (ar < 1) {   // height > width
					width = ar * height;
				}
			}	
			// update bounds
			bounds.width = width;
			bounds.height = height;
		}
		
		// -- Named Operators -------------------------------------------------
		
		/**
		 * Sets a new named operator. This method can be used to add extra
		 * operators to a visualization, in addition to those in the main
		 * <code>operators</code> property. These operators can be invoked by
		 * passing the operator name as an additional parameter of the
		 * <code>update</code> method. If an operator of the same name
		 * already exists, it will be replaced. Note that the name "main"
		 * refers to the same operator list as the <code>operators</code>
		 * property and can not be replaced. 
		 * @param name the name of the operator to add
		 * @param op the operator to add
		 * @return the added operator
		 */
		public function setOperator(name:String, op:IOperator):IOperator
		{
			if (name=="main") {
				throw new ArgumentError("Illegal group name: " + 
						"\"main\" is a reserved name.");
			}
			_ops[name] = op;
			op.visualization = this;
			return op;
		}
		
		/**
		 * Removes a named operator. An error will be thrown if the caller
		 * attempts to remove the operator "main". 
		 * @param name the name of the operator to remove
		 * @return the removed operator
		 */
		public function removeOperator(name:String):IOperator
		{
			if (name=="main") {
				throw new ArgumentError("Illegal group name: " + 
						"\"main\" is a reserved name.");
			}
			var op:IOperator = _ops[name];
			if (op) delete _ops[name];
			return op;
		}
		
		/**
		 * Retrieves the operator with the given name.  The name "main" will
		 * return the operator list stored in the <code>operators</code>
		 * property.
		 * @param name the name of the operator
		 * @return the operator
		 */
		public function operator(name:String):IOperator
		{
			return _ops[name];
		}

		// -- Event Handling --------------------------------------------------

		/**
		 * Creates a sprite covering the bounds for this visualization and
		 * sets it to be this visualization's hit area. Typically, this
		 * method is triggered in response to a <code>RENDER</code> event.
		 * <p>To disable automatic hit area calculation, use
		 * <code>stage.removeEventListener(Event.RENDER, vis.setHitArea)</code>
		 * <em>after</em> the visualization has been added to the stage.</p>
		 * @param evt an event that triggered the hit area update
		 */
		public function setHitArea(evt:Event=null):void
		{
			// get the union of the specified and actual bounds
			var rb:Rectangle = getBounds(this);
			var x1:Number = rb.left, x2:Number = rb.right;
			var y1:Number = rb.top, y2:Number = rb.bottom;
			if (bounds) {
				x1 = Math.min(x1, bounds.left);
				y1 = Math.min(y1, bounds.top);
				x2 = Math.max(x2, bounds.right);
				y2 = Math.max(y1, bounds.bottom);
			}
			
			// create the hit area sprite
			var hit:Sprite = getChildByName("_hitArea") as Sprite;
			if (hit == null) {
				hit = new Sprite();
				hit.name = "_hitArea";
				addChildAt(hit, 0);
			}
			hit.visible = false;
			hit.mouseEnabled = false;
			hit.graphics.clear();
			hit.graphics.beginFill(0xffffff, 1);
			hit.graphics.drawRect(x1, y1, x2-x1, y2-y1);
			hitArea = hit;
		}

		/**
		 * Fires a visualization event of the given type.
		 * @param type the type of the event
		 * @param t a transitioner that listeners should use for any value
		 *  updates performed in response to this event
		 */
		protected function fireEvent(type:String, t:Transitioner,
			params:Array):void
		{			
			// fire event, if anyone is listening
			if (hasEventListener(type)) {
				dispatchEvent(new VisualizationEvent(type, t, params));
			}
		}
		
		/**
		 * Data listener invoked when new items are added to this
		 * Visualization's <code>data</code> instance.
		 * @param evt the data event
		 */
		protected function dataAdded(evt:DataEvent):void
		{
			if (evt.node) {
				for each (var d:DisplayObject in evt.items)
					_marks.addChild(d);
			} else {
				for each (d in evt.items)
					_marks.addChildAt(d, 0);
			}
		}
		
		/**
		 * Data listener invoked when new items are removed from this
		 * Visualization's <code>data</code> instance.
		 * @param evt the data event
		 */
		protected function dataRemoved(evt:DataEvent):void
		{
			for each (var d:DisplayObject in evt.items)
				_marks.removeChild(d);
		}

	} // end of class Visualization
}

import genvis.animate.ISchedulable;
import genvis.vis.Visualization;

/**
 * Simple ISchedulable instance that repeatedly calls a Visualization's
 * <code>update</code> method.
 */
class Recurrence implements ISchedulable {
	private var _vis:Visualization;
	public function get id():String { return null; }
	public function set id(s:String):void { /* do nothing */ }
	public function cancelled():void { /* do nothing */ }
	public function Recurrence(vis:Visualization) {
		_vis = vis;
	}
	public function evaluate(t:Number):Boolean {
		_vis.update(); return false;
	}
}