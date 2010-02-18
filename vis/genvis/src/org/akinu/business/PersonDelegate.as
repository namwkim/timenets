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
			var call:AsyncToken = AsyncToken(_service.root(rootID));
			call.addResponder(_responder);
		}
		public function add_relationship(person:Person, marriage:Marriage, ref_id:String, role:String):void{
			var call:AsyncToken = AsyncToken(_service.create_relationship({person:person, marriage:marriage, ref_id:ref_id, role:role}));
			call.addResponder(_responder);			
		}

	}
}