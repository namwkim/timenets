package org.akinu.responders
{
	import genvis.data.Person;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.akinu.model.ModelLocator;

	public class RootChangeResponder implements IResponder
	{
		public var model:ModelLocator = ModelLocator.getInstance();
		public function RootChangeResponder()
		{
		}

		public function result(e:Object):void {
			var event:ResultEvent = e as ResultEvent;
			var root:Person = event.result as Person;
			model.root = root;
			model.vis.visualize(root);
		}
		
		public function fault(info:Object):void	{
			trace("RootChangeResponder-Fault");
		}
		
	}
}