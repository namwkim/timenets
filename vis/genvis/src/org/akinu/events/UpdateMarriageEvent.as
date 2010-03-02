package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Marriage;

	public class UpdateMarriageEvent extends CairngormEvent
	{
		public static const UPDATE_MARRIAGE:String = "UpdateMarriage";
		public var marriage:Marriage;
		public function UpdateMarriageEvent(marriage:Marriage){
			super(UPDATE_MARRIAGE);
			this.marriage = marriage;			
		}
		override public function clone():Event{
			return new UpdateMarriageEvent(marriage);
		}
		
	}
}