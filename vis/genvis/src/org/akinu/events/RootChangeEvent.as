package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Person;
	
	public class RootChangeEvent extends CairngormEvent
	{
		public static const ROOT_CHANGE:String = "RootChange";
		public var root:Person; //person id
		public function RootChangeEvent(root:Person){
			this.root = root;
			super(ROOT_CHANGE);
		}
		override public function clone():Event{
			return new RootChangeEvent(root);
		}

	}
}