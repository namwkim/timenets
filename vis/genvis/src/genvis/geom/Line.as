package genvis.geom
{
	import flash.geom.Point;
	
	public class Line
	{
		private var _start:Point;
		private var _end:Point;

		public function get start():Point 	{ return _start; }
		public function get end():Point 	{ return _end; }
		
		public function get x1():Number { return _start.x; }
		public function get y1():Number { return _start.y; }
		public function get x2():Number { return _end.x; }
		public function get y2():Number { return _end.y; }
		
		public function set x1(x:Number):void { _start.x = x; }
		public function set y1(y:Number):void { _start.y = y; }
		public function set x2(x:Number):void { _end.x = x; }
		public function set y2(y:Number):void { _end.y = y; }
		
		public function Line(x1:Number, y1:Number, x2:Number, y2:Number)
		{			
			_start 	= new Point(x1, y1);
			_end 	= new Point(x2, y2);
		}
		
	}
}