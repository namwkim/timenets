package genvis.data
{
	[RemoteClass(alias="Event")]
	[Bindable]	
	public class Event
	{
		private var _id:String;
		private var _name:String;
		private var _location:String;
		private var _start:Date;
		private var _end:Date;
		private var _isRange:Boolean;
		private var _description:String;
		private var _historical:Boolean = false;
		
		private var _people:Array;
		
		public function get id():String				{ return _id;			}		
		public function get name():String 			{ return _name;			}		
		public function get location():String 		{ return _location; 	}
		public function get start():Date			{ return _start;		}
		public function get end():Date				{ return _end;			}
		public function get isRange():Boolean		{ return _isRange;		}
		public function get historical():Boolean	{ return _historical;	}
		public function get description():String	{ return _description;	}
		
		public function set id(i:String):void			{ _id = i;			}
		public function set name(n:String):void			{ _name = n; 		}
		public function set location(l:String):void		{ _location = l; 	}
		public function set start(s:Date):void			{ _start = s;		}
		public function set end(e:Date):void			{ _end = e;			}
		public function set isRange(r:Boolean):void		{ _isRange = r;		}
		public function set historical(h:Boolean):void	{ _historical = h;	}	
		public function set description(d:String):void 	{ _description = d; }
		
		public function get people():Array	{ return _people; }
		public function set people(p:Array):void	{ _people = p; }
		
		public function Event()	{
		}

	}
}