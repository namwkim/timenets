package org.akinu.responders
{
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.events.AddRelationshipEvent;
	import org.akinu.model.ModelLocator;

	public class AddRelationshipResponder implements IResponder{
		private var model:ModelLocator = ModelLocator.getInstance();
		private var person:Person;
		private var marriage:Marriage;
		private var visUpdate:Boolean;
		private var create:Boolean;
		private var nextEvents:Array;
		public function AddRelationshipResponder(person:Person, marriage:Marriage, nextEvents:Array, create:Boolean=true, visUpdate:Boolean=true)	{
			this.person 	= person;
			this.marriage	= marriage;
			this.visUpdate  = visUpdate;
			this.create		= create;
			this.nextEvents = nextEvents;
		}

		public function result(e:Object):void	{
			var event:ResultEvent = e as ResultEvent;
			if (create){
				person.id = e.result["person"].id;
				person.saved = true;
				if (marriage) {
					marriage.id = e.result["marriage"].id;
					marriage.saved = true;
				}
				
			}
			if (nextEvents){
				for each (var evt:AddRelationshipEvent in nextEvents){
					if (person.id != evt.person.id) Alert.show("AddRelationshipResponder-validation failed!");
					evt.dispatch();
				}
			}
			if (visUpdate){//TODD: don't refresh the whole visualization, but update newly added part only.
				model.pageState = ModelLocator.PERSON_MAIN;			
				model.vis.visualize(model.root);
			}
//			var initEvent:InitializeEvent = new InitializeEvent(model.root.id, model.vis);
//			initEvent.dispatch();
		}
		
		public function fault(info:Object):void	{
			Alert.show("AddRelationshipResponder - Fault");
		}
		
	}
}