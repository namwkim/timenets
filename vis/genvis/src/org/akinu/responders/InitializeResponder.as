package org.akinu.responders
{
	import flare.display.DirtySprite;
	
	import genvis.data.Person;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.model.ModelLocator;

	public class InitializeResponder implements IResponder
	{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function InitializeResponder(){
		}

		public function result(e:Object):void{
			var event:ResultEvent = e as ResultEvent;
			model.root = event.result as Person;
			model.vis.visualize(model.root);
			DirtySprite.renderDirty();
						
		}
		
		public function fault(info:Object):void{
			trace("InitializeResponder - Fault");

		}
		
	}
}