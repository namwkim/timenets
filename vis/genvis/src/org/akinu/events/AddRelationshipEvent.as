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
		public var create:Boolean;
		public var visUpdate:Boolean;
		public var nextEvents:Array;
		public function AddRelationshipEvent(person:Person, marriage:Marriage, ref_id:String, role:String, nextEvents:Array=null, create:Boolean=true, visUpdate:Boolean=true){
			super(ADD_RELATIONSHIP);
			this.person 	= person;
			this.marriage 	= marriage;
			this.ref_id		= ref_id;
			this.role		= role;
			this.create		= create;
			this.visUpdate	= visUpdate
			this.nextEvents = nextEvents;
		}
		override public function clone():Event{
			 return new AddRelationshipEvent(person, marriage, ref_id, role, nextEvents, create, visUpdate);
		}
		
	}
}