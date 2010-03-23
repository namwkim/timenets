package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class SelectEvent extends CairngormEvent
	{
		public static const PERSON:uint 	= 0;
		public static const ATTRIBUTE:uint	= 1;	
		public static const EVENT:uint		= 2;
		
		public static const SELECT:uint		= 1;
		public static const DESELECT:uint	= 2;
	
		public static const SELECTION :String = "Selection";
		public var selected:*;
		public var objType:uint;
		public var evt:MouseEvent;
		public var evtType:uint;
		public function SelectEvent(evtType:uint, objType:uint, selected:*=null, evt:MouseEvent = null)
		{
			super(SELECTION);
			this.objType 	= objType;
			this.selected 	= selected;
			this.evt		= evt;
			this.evtType	= evtType;
		}
		override public function clone():Event{
			return new SelectEvent(evtType, objType, selected, evt);
		}
	}
}