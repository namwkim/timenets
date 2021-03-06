package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.GenVis;

	public class InitializeEvent extends CairngormEvent
	{
		public static const INITIALIZE:String = "Initialize";
		public var rootID:String;
		public var vis:GenVis;
		public function InitializeEvent(rootID:String, vis:GenVis) {
			super(INITIALIZE);
			this.rootID = rootID;
			this.vis  = vis;
			
		}
		override public function clone():Event{
			return new InitializeEvent(rootID, vis);
		}
	}
}