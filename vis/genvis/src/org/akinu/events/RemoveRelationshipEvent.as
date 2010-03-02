package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class RemoveRelationshipEvent extends CairngormEvent{
		public static const REMOVE_RELATIONSHIP:String = "RemoveRelationship";
		public var id:String;
		public var ref_id:String;
		public var role:String;
		public function RemoveRelationshipEvent(id:String, ref_id:String, role:String){
			super(REMOVE_RELATIONSHIP);
			this.id 	= id;
			this.ref_id	= ref_id;
			this.role	= role;
		}
		override public function clone():Event{
			return new RemoveRelationshipEvent(id, ref_id, role);			
		}
		
	}
}