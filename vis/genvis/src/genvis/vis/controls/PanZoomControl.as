package genvis.vis.controls
{
	import genvis.util.Displays;
	
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import genvis.GenVis;
	import genvis.scale.TimeScale;
	import genvis.vis.Visualization;
	import genvis.vis.operator.layout.LifelineLayout;
	
	/**
	 * Interactive control for panning and zooming a "camera". Any sprite can
	 * be treated as a camera onto its drawing content and display list
	 * children. The PanZoomControl allows you to manipulate a sprite's
	 * transformation matrix (the <code>transform.matrix</code> property) to
	 * simulate camera movements such as panning and zooming. To pan and
	 * zoom over a collection of objects, simply add a PanZoomControl for
	 * the sprite holding the collection.
	 * 
	 * <pre>
	 * var s:Sprite; // a sprite holding a collection of items
	 * new PanZoomControl().attach(s); // attach pan and zoom controls to the sprite
	 * </pre>
	 * <p>Once a PanZoomControl has been created, panning is performed by
	 * clicking and dragging. Zooming is performed either by scrolling the
	 * mouse wheel or by clicking and dragging vertically while the control key
	 * is pressed.</p>
	 * 
	 * <p>By default, the PanZoomControl attaches itself to the
	 * <code>stage</code> to listen for mouse events. This works fine if there
	 * is only one collection of objects in the display list, but can cause
	 * trouble if you want to have multiple collections that can be separately
	 * panned and zoomed. The PanZoomControl constructor takes a second
	 * argument that specifies a "hit area", a shape in the display list that
	 * should be used to listen to the mouse events for panning and zooming.
	 * For example, this could be a background sprite behind the zoomable
	 * content, to which the "camera" sprite could be added. One can then set
	 * the <code>scrollRect</code> property to add clipping bounds to the 
	 * panning and zooming region.</p>
	 */
	public class PanZoomControl extends Control
	{
		private var px:Number, py:Number;
		private var dx:Number, dy:Number;
		private var mx:Number, my:Number;
		private var _drag:Boolean = false;
		
		private var _hit:InteractiveObject;
		private var _stage:Stage;
		
		//gevis specific
		private var _layout:LifelineLayout;
		/** The active hit area over which pan/zoom interactions can be performed. */
		public function get hitArea():InteractiveObject { return _hit; }
		public function set hitArea(hitArea:InteractiveObject):void {
			if (_hit != null) onRemove();
			_hit = hitArea;
			if (_object && _object.stage != null) onAdd();
		}
		
		/**
		 * Creates a new PanZoomControl.
		 * @param hitArea a display object to use as the hit area for mouse
		 *  events. For example, this could be a background region over which
		 *  the panning and zooming should be done. If this argument is null,
		 *  the stage will be used.
		 */
		public function PanZoomControl(hitArea:InteractiveObject=null):void
		{
			_hit = hitArea;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				if (obj.stage != null) onAdd();
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			onRemove();
			_layout = null;
			_object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			return super.detach();
		}
		
		private function onAdd(evt:Event=null):void
		{
			_stage = _object.stage;
			if (_hit == null) {
				_hit = _stage;
			}
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_hit.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onRemove(evt:Event=null):void
		{
			_hit.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_hit.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
			if (_stage == null) return;
			if (_hit == _object && event.target != _hit) return;

			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			px = mx = event.stageX;
			py = my = event.stageY;
			_drag = true;
		}
			
		private function onMouseMove(event:MouseEvent) : void
		{
			if (!_drag) return;
			
			var x:Number = event.stageX;
			var y:Number = event.stageY;
			var vis:Visualization = _object as Visualization;
			_layout = vis.operator("layout") as LifelineLayout;
			var xscale:TimeScale = _layout.xAxis.axisScale as TimeScale;	
			var max:Date		= xscale.max as Date;
			var min:Date		= xscale.min as Date;		
			if (!event.ctrlKey) {
				//X-panning
				var curPos:Date 	= _layout.xAxis.value(x, 0, false) as Date;
				var prevPos:Date 	= _layout.xAxis.value(mx, 0, false) as Date;
				var dYear:Number	= prevPos.fullYear - curPos.fullYear;
				var dMon:Number		= prevPos.month - curPos.month;
				var dDate:Number	= prevPos.date - curPos.date;		
				trace("yyyy:"+dYear);
				trace("mm"+dMon);
				trace("dd"+dDate);
				max = new Date(max.fullYear+dYear, max.month+dMon, max.date+dDate);
				min = new Date(min.fullYear+dYear, min.month+dMon, min.date+dDate);
//				var update:Boolean = false;
//				if (((vis.data.min.fullYear-_layout.xrange/2)<min.fullYear) && ((vis.data.max.fullYear+_layout.xrange/2)>max.fullYear)){
					xscale.max = max;
					xscale.min = min;		
//					update = true;					
//				}
				//Y-Panning				
				var dy:Number = (y-my);
//				if ((_layout.yMax+_layout.yPan+dy+_layout.defaultYPan)>=0 && (_layout.yMin+_layout.yPan+dy+_layout.defaultYPan)<=vis.bounds.height){
					_layout.yPan = _layout.yPan+dy;
//					update = true;
//				}				
//				if (update) {
					vis.update(null, GenVis.OPS);
					//DirtySprite.renderDirty();
//				}

			} else {
				if (isNaN(dx)) {
					dx = event.stageX;
					dy = event.stageY;
				}
				var dz:Number = 1 + (y-my)/500;
				var start:Date = _layout.xAxis.value(my, 0, false) as Date;
				var end:Date = _layout.xAxis.value(y, 0, false) as Date;
				xscale.max = new Date(max.fullYear+(start.fullYear-end.fullYear), max.month+(start.month-end.month), max.date+(start.date-end.date));
				xscale.min = new Date(min.fullYear-(start.fullYear-end.fullYear), min.month-(start.month-end.month), min.date-(start.date-end.date));
				vis.update(null, GenVis.OPS);
				Displays.zoomY(vis.marks, dz, dx, dy);
			}
			//xscale.flush=false;
			mx = x;
			my = y;
		}
		
		private function onMouseUp(event:MouseEvent) : void
		{
			dx = dy = NaN;
			_drag = false;
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseWheel(event:MouseEvent) : void
		{
			var dw:Number = 1.1 * event.delta;
			var dz:Number = dw < 0 ? 1/Math.abs(dw) : dw;
			Displays.zoomBy(_object, dz);
		}
		
	} // end of class PanZoomControl
}