package org.akinu.responders
{
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.model.ModelLocator;

	public class UpdatePersonResponder implements IResponder
	{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function UpdatePersonResponder()	{
		}

		public function result(data:Object):void{
			var event:ResultEvent = data as ResultEvent;		
			model.vis.visualize(model.root);
			Alert.show("Successfully saved!");
		}
		
		public function fault(info:Object):void	{
			Alert.show("Updating a person failed!");
		}
		
	}
}