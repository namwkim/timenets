package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Person;

	public class RemovePersonEvent extends CairngormEvent
	{
		public static const REMOVE_PERSON:String = "RemovePerson";
		public var id:String;
		public function RemovePersonEvent(id:String){
			super(REMOVE_PERSON);
			this.id = id;
		}
		override public function clone():Event{
			return new RemovePersonEvent(id);
		}
		
	}
}