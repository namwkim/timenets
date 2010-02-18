package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.events.PersonSelectedEvent;
	import org.akinu.model.ModelLocator;

	public class PersonSelectedCommand implements ICommand{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function PersonSelectedCommand()	{
		}

		public function execute(event:CairngormEvent):void	{
			var personSelected:PersonSelectedEvent = event as PersonSelectedEvent;
			model.contextMenu 	 = ModelLocator.PERSON_MENU;
			model.workflowState  = ModelLocator.TAKE_ACTION;
			model.selectedPerson = personSelected.selected;
		}
		
	}
}