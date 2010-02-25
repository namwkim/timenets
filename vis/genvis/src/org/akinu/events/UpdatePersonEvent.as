package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Person;
	
	public class UpdatePersonEvent extends CairngormEvent{
		public static const UPDATE_PERSON:String = "UpdatePerson";
		public var person:Person
		public function UpdatePersonEvent(person:Person) {
			super(UPDATE_PERSON);
			this.person = person;
		}
		override public function clone():Event{
			return new UpdatePersonEvent(person);
		}

	}
}