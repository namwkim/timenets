package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import genvis.data.Marriage;
	import genvis.data.Person;

	public class AddRelationshipEvent extends CairngormEvent{
		public static const ADD_RELATIONSHIP:String = "AddRelationship";
		public var person:Person;
		public var marriage:Marriage;
		public var ref_id:String;
		public var role:String;
		public function AddRelationshipEvent(person:Person, marriage:Marriage, ref_id:String, role:String){
			super(ADD_RELATIONSHIP);
		this.person 		= person;
			this.marriage 	= marriage;
			this.ref_id		= ref_id;
			this.role		= role;
		}
		override public function clone():Event{
			return new AddRelationshipEvent(person, marriage, ref_id, role);
		}
		
	}
}