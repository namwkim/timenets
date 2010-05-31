package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.events.RootChangeEvent;
	import org.akinu.model.ModelLocator;
	
	public class RootChangeCommand implements ICommand
	{
		public var model:ModelLocator = ModelLocator.getInstance();
		public function RootChangeCommand(){
			
		}
		public function execute(event:CairngormEvent):void{
			var rootChangeEvent:RootChangeEvent = event as RootChangeEvent;
			model.root = rootChangeEvent.root;
			model.vis.visualize(model.root, model.events);
			model.vis.select(model.root);
			//model.page = ModelLocator.FRONT_PAGE;			
		}

	}
}