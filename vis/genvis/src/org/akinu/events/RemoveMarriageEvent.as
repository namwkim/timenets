package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class RemoveMarriageEvent extends CairngormEvent
	{
		public static const REMOVE_MARRIAGE:String	 = "RemoveMarriage";
		public var mar_id:String;
		public function RemoveMarriageEvent(mar_id:String){
			super(REMOVE_MARRIAGE);
			this.mar_id = mar_id;			
		}
		override public function clone():Event{
			return new RemoveMarriageEvent(mar_id);
		}
		
	}
}