package org.akinu.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class PersonDelegate
	{
		private var _responder:IResponder;
		private var _service:Object;
		
		public function PersonDelegate(responder:IResponder)
		{
			_responder 	= responder;
			_service	= ServiceLocator.getInstance().getRemoteObject("personService");
		}
		public function initialize(rootID:String):void{
			var call:AsyncToken = AsyncToken(_service.root({id: rootID}));
			call.addResponder(_responder);
		}
		public function addRelationship(person:Person, marriage:Marriage, ref_id:String, role:String, create:Boolean):void{
			var call:AsyncToken;
			if (create){
				call = AsyncToken(_service.create_relationship({person:person, marriage:marriage, ref_id:ref_id, role:role}));
			}else{
				call = AsyncToken(_service.create_relationship({person_id:person.id, marriage:marriage, ref_id:ref_id, role:role}));
			}
			call.addResponder(_responder);			
		}
		public function createPerson(person:Person, project_id:String):void{
			var call:AsyncToken = AsyncToken(_service.create_person({project_id:project_id, person:person}));
			call.addResponder(_responder);
		}
		public function updatePerson(person:Person, project_id:String):void{
			var call:AsyncToken = AsyncToken(_service.update_person({project_id:project_id, person:person}));
			call.addResponder(_responder);
		}

	}
}