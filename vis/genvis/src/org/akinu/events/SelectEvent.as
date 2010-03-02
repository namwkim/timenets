package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class SelectEvent extends CairngormEvent
	{
		public static const PERSON:uint = 0;
		public static const EVENT:uint	= 1;
	
		public static const SELECTION :String = "Selection";
		public var selected:*;
		public var objType:uint;
		public var evt:MouseEvent
		public function SelectEvent(objType:uint, selected:*, evt:MouseEvent)
		{
			super(SELECTION);
			this.objType 	= objType;
			this.selected 	= selected;
			this.evt		= evt;
		}
		override public function clone():Event{
			return new SelectEvent(objType, selected, evt);
		}
	}
}