package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.events.StateChangeEvent;
	import org.akinu.model.ModelLocator;

	public class StateChangeCommand implements ICommand{
		private var model: ModelLocator = ModelLocator.getInstance();
		public function StateChangeCommand(){
		}

		public function execute(event:CairngormEvent):void{
			var e:StateChangeEvent = event as StateChangeEvent;
			model.pageState = e.state;
			model.data		= e.data;
		}
		
	}
}