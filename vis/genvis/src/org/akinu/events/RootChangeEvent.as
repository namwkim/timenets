package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class RootChangeEvent extends CairngormEvent
	{
		public static const ROOT_CHANGE:String = "RootChange";
		public var _root_id:uint; //person id
		public function RootChangeEvent(_root_id:uint){
			_root_id = _root_id;
			super(ROOT_CHANGE);
		}
		override public function clone():Event{
			return new RootChangeEvent(_root_id);
			trace("event cloned");
		}

	}
}