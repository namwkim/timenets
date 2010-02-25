package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Person;

	public class CreatePersonEvent extends CairngormEvent{
		public static const CREATE_PERSON:String = "CreatePerson";
		public var person:Person;
		public function CreatePersonEvent(person:Person){
			super(CREATE_PERSON);
			this.person;
		}
		override public function clone():Event{
			return new CreatePersonEvent(person);
		}
		
	}
}