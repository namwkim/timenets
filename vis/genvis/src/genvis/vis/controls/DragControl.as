package genvis.vis.controls
{
	import flare.display.DirtySprite;
	import flare.vis.data.DataSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import genvis.vis.Visualization;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.NodeSprite;
	
	/**
	 * Interactive control for dragging items. A DragControl will enable
	 * dragging of all Sprites in a container object by clicking and dragging
	 * them.
	 */
	public class DragControl extends Control
	{
		private var _isEnabled:Boolean = false;
		private var _cur:Sprite;
		private var _mx:Number, _my:Number;
		
		public function get isEnabled():Boolean {return _isEnabled; }
		public function set isEnabled(e:Boolean):void { _isEnabled = e; }
		/** Indicates if drag should be followed at frame rate only.
		 *  If false, drag events can be processed faster than the frame
		 *  rate, however, this may pre-empt other processing. */
		public var trackAtFrameRate:Boolean = false;
		
		/** The active item currently being dragged. */
		public function get activeItem():Sprite { return _cur; }
		
		/**
		 * Creates a new DragControl.
		 * @param filter a Boolean-valued filter function determining which
		 *  items should be draggable.
		 */		
		public function DragControl(filter:*=null) {
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/** @inheritDoc */
		public override function detach() : InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			return super.detach();
		}
		
		private function onMouseDown(event:MouseEvent) : void {
			if (!_isEnabled) return;
			var s:Sprite = event.target as Sprite;
			if (s is NodeSprite) s = (s as NodeSprite).block;
			if (s==null || (s is BlockSprite) ==  false) return; // exit if not a sprite
			
			if (_filter==null || _filter(s)) {
				_cur = s;
				//_mx = _object.mouseX;
				_my = _object.mouseY;
				if (_cur is DataSprite) (_cur as DataSprite).fix();

				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				event.stopPropagation();
			}
		}
		
		private function onDrag(event:Event) : void {
//			var x:Number = _object.mouseX;
//			if (x != _mx) {
//				_cur.x += (x - _mx);
//				_mx = x;
//			}
			
			var y:Number = _object.mouseY;
			if (y != _my) {
				_cur.y += (y - _my);
				//boundary check
				var bounds:Rectangle = (_object as Visualization).bounds;
				if (_cur.y <bounds.y) _cur.y = bounds.y;
				if ((_cur.y + (_cur as BlockSprite).bbox.height) >  (_object as Visualization).bounds.height) _cur.y -=(y - _my);
				_my = y;
				DirtySprite.renderDirty();
			}
		}
		
		private function onMouseUp(event:MouseEvent) : void {
			if (_cur != null) {
				_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				
				if (_cur is DataSprite) (_cur as DataSprite).unfix();
				event.stopPropagation();
			}
			_cur = null;
		}
		
	} // end of class DragControl
}