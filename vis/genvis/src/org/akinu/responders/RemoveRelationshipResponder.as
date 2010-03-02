package org.akinu.responders
{
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	
	import org.akinu.model.ModelLocator;

	public class RemoveRelationshipResponder implements IResponder{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function RemoveRelationshipResponder(){
		}

		public function result(data:Object):void{
			model.page = ModelLocator.FRONT_PAGE;
			model.pageState = ModelLocator.INDEX;
			//update vis
			model.vis.visualize(model.root);
		}
		
		public function fault(info:Object):void{
			Alert.show("RemoveRelationshipResponder-Fault");
		}
		
	}
}