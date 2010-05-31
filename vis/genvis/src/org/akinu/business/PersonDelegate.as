package org.akinu.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.akinu.helper.Helper;
	
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
		//
		//// PERSON
		//
		public function createPerson(person:Person, project_id:String):void{
			var cPerson:Person = ObjectUtil.copy(person) as Person;
			Helper.personToUTC(cPerson);			
			var call:AsyncToken = AsyncToken(_service.create_person({project_id:project_id, person:cPerson}));
			call.addResponder(_responder);
		}
		public function updatePerson(person:Person, project_id:String):void{
			var cPerson:Person = ObjectUtil.copy(person) as Person;
			Helper.personToUTC(cPerson);
			var call:AsyncToken = AsyncToken(_service.update_person({project_id:project_id, person:cPerson}));
			call.addResponder(_responder);
		}
		public function removePerson(id:String):void{
			var call:AsyncToken = AsyncToken(_service.delete_person({id:id}));
			call.addResponder(_responder);
		}
		//
		//// RELATIONSHIP
		//
		public function addRelationship(person:Person, marriage:Marriage, ref_id:String, role:String, create:Boolean):void{
			var call:AsyncToken;
			var cMarriage:Marriage 	= ObjectUtil.copy(marriage) as Marriage;
			Helper.marriageToUTC(cMarriage);
			if (create){
				var cPerson:Person 		= ObjectUtil.copy(person) as Person;
				Helper.personToUTC(cPerson);
				call = AsyncToken(_service.create_relationship({person:cPerson, marriage:cMarriage, ref_id:ref_id, role:role}));
			}else{
				call = AsyncToken(_service.create_relationship({person_id:person.id, marriage:marriage, ref_id:ref_id, role:role}));
			}
			call.addResponder(_responder);			
		}
		public function removeRelationship(id:String, ref_id:String, role:String):void{
			var call:AsyncToken = AsyncToken(_service.delete_relationship({id:id, ref_id:ref_id, role:role}));
			call.addResponder(_responder);						
		}
		public function updateMarriage(marriage:Marriage):void{
			var cMarriage:Marriage 	= ObjectUtil.copy(marriage) as Marriage;
			Helper.marriageToUTC(cMarriage);
			var call:AsyncToken = AsyncToken(_service.update_marriage({marriage:cMarriage}));
			call.addResponder(_responder);
		}
		public function removeMarriage(mar_id:String):void{
			var call:AsyncToken = AsyncToken(_service.delete_marriage({id:mar_id}));
			call.addResponder(_responder);
		}


	}
}