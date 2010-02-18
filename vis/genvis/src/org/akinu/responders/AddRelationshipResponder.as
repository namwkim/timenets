package org.akinu.responders
{
	import flare.display.DirtySprite;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.events.InitializeEvent;
	import org.akinu.model.ModelLocator;

	public class AddRelationshipResponder implements IResponder{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function AddRelationshipResponder()	{
		}

		public function result(e:Object):void	{
			var event:ResultEvent = e as ResultEvent;
			model.workflowState = ModelLocator.TAKE_ACTION;
			//TODD: don't refresh the whole visualization, but update newly added part only.
			var initEvent:InitializeEvent = new InitializeEvent(model.root.id, model.vis);
			initEvent.dispatch();
		}
		
		public function fault(info:Object):void	{
			trace("AddRelationshipResponder - Fault");
		}
		
	}
}