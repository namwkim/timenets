package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.events.PageChangeEvent;
	import org.akinu.model.ModelLocator;
	
	public class PageChangeCommand implements ICommand{
		private var model: ModelLocator = ModelLocator.getInstance();
		public function PageChangeCommand()
		{
		}
		public function execute(event:CairngormEvent):void{
			var e:PageChangeEvent = event as PageChangeEvent;
			model.page 		= e.page;
			model.pageState = ModelLocator.INDEX;
			model.data		= e.data;
		}
	}
}