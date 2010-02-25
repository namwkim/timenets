package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SelectEvent extends CairngormEvent
	{
		public static const PERSON:uint = 0;
		public static const EVENT:uint	= 1;
	
		public static const SELECTION :String = "Selection";
		public var selected:*;
		public var objType:uint;
		public function SelectEvent(objType:uint, selected:*)
		{
			super(SELECTION);
			this.objType 	= objType;
			this.selected 	= selected;
		}
		override public function clone():Event{
			return new SelectEvent(objType, selected);
		}
	}
}