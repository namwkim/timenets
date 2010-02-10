package genvis.geom
{
	import flash.geom.Point;
	
	public class Box
	{
		private var _min:Point, _max:Point;
		
		public function get min():Point { return _min; }
		public function get max():Point { return _max; }
		
//		public function get minx():Number { return _min.x; }
//		public function get miny():Number { return _min.y; }
//		public function get maxx():Number { return _max.x; }
//		public function get maxy():Number { return _max.y; }
		
		public function set minx(x:Number):void { _min.x = x; }
		public function set miny(y:Number):void { _min.y = y; }
		public function set maxx(x:Number):void { _max.x = x; }
		public function set maxy(y:Number):void { _max.y = y; }
		
		public function get width():Number 	{ return _max.x - _min.x;  }
		public function get height():Number { return _max.y - _min.y;; }
				
		public function Box(minx:Number, miny:Number, maxx:Number, maxy:Number)
		{
			_min	= new Point(minx, miny);
			_max	= new Point(maxx, maxy);
		}

	}
}