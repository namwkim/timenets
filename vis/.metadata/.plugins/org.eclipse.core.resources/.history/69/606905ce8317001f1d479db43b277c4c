package genvis.data
{
	import flash.geom.Point;
	
	
	public class EvtPt
	{
		private var _pt:Point;
		private var _date:Date;
		private var _type:int;
		private var _data:Object;
		private var _isEstimated:Boolean;
		
		public static const BORN:int		= 0;
		public static const	DATING:int		= 1;
		public static const MARRIAGE:int 	= 2;
		public static const DIVORCE:int 	= 3;
		public static const RESTING:int		= 4;
		public static const DEAD:int		= 5;
		
		public function EvtPt(x:Number, y:Number, t:int, d:Date = null, data:Object = null){
			_pt 	= new Point(x, y);		
			_date 	= d;
			_type 	= t;
			_data	= data;
			_isEstimated = false;
		}
		public function get isEstimated():Boolean { return _isEstimated; }
		public function set isEstimated(e:Boolean):void { _isEstimated = e; }
		
		public function get pt():Point			{ return _pt;	}
		public function get x():Number			{ return _pt.x;	}
		public function set x(x:Number):void	{ _pt.x = x;	}
		
		public function get y():Number			{ return _pt.y;	}
		public function set y(y:Number):void	{ _pt.y = y;	}
		
		public function get type():int 			{ return _type; }
		public function set type(t:int):void { _type = t; }
		
		public function get date():Date { return _date; }
		public function set date(d:Date):void { _date = d; }	
		
		public function get data():Object { return _data; }
		public function set data(d:Object):void { _data = d; }	
		
			
	}
}