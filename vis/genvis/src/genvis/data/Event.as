package genvis.data
{
	public class Event
	{
		private var _name:String;
		private var _location:String;
		private var _from:Date;
		private var _to:Date;
		private var _isRange:Boolean;
		private var _description:String;
		
		public function get name():String { return _name;	}		
		public function get location():String { return _location; }
		public function get from():Date		{ return _from;		}
		public function get to():Date		{ return _to;		}
		public function Event()
		{
		}

	}
}