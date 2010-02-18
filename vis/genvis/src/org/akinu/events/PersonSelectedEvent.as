package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Person;

	public class PersonSelectedEvent extends CairngormEvent
	{
		public static const SELECTION :String = "Selection";
		public var selected:Person;
		public function PersonSelectedEvent(selected:Person)
		{
			super(SELECTION);
			this.selected = selected;
		}
		override public function clone():Event{
			return new PersonSelectedEvent(selected);
		}
	}
}