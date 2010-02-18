package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class StateChangeEvent extends CairngormEvent
	{
		public static const STATE_CHANGE:String = "StateChage";
		public var state:uint;
		public function StateChangeEvent(state:uint, data:*=null){
			super(STATE_CHANGE);
			this.state = state;
			this.data  = data;
		}
		override public function clone():Event{
			return new StateChangeEvent(state, data);
		}
		
	}
}