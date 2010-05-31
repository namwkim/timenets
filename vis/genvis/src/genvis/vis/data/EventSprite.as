package genvis.vis.data
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import genvis.data.Event;

	public class EventSprite extends DataSprite{
		private var _min:Point;
		private var _max:Point;
		private var _label:TextSprite	= null;
		public function get min():Point { return _min; }
		public function get max():Point { return _max; }
		public function set min(m:Point):void { _min = m; }
		public function set max(m:Point):void { _max = m; }		
		public function get label():TextSprite { return _label; }
		public function set label(l:TextSprite):void{ _label	= l;}
		public function EventSprite(event:Event){
			super();
			_data = event;			
		}
		
		public function get event():Event { return (_data as Event) }
		
	}
}