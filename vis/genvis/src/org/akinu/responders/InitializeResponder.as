package org.akinu.responders
{
	import flash.utils.Dictionary;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.helper.Helper;
	import org.akinu.model.ModelLocator;

	public class InitializeResponder implements IResponder
	{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function InitializeResponder(){
		}

		public function result(e:Object):void{
			var event:ResultEvent = e as ResultEvent;	
			model.root 		= event.result.root;
			model.events	= event.result.project.events;
			model.project	= event.result.project;
			//modify UTC dates to local dates. TODO: find a better method (e.g. writing a custom deserialization?)
			var marMap:Dictionary = new Dictionary();
			for each (var person:Person in model.project.people){
				Helper.personFromUTC(person);				
				for each (var marriage:Marriage in person.marriages){
					if (marMap[marriage.id]==null){
						marMap[marriage.id] = marriage;
						Helper.marriageFromUTC(marriage);						
					}
				}
			}
			
			model.vis.visualize(model.root, model.events);
			//DirtySprite.renderDirty();//better way to ensuring rendering?
						
		}
		
		public function fault(info:Object):void{
			Alert.show("InitializeResponder - Fault");

		}
		
	}
}