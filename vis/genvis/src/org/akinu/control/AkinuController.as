package org.akinu.control
{
	import com.adobe.cairngorm.control.FrontController;
	
	import org.akinu.commands.*;
	import org.akinu.events.*;

	public class AkinuController extends FrontController
	{
		
		public function AkinuController(){
			this.initialize();
		}
		public function initialize():void{
			//ADD COMMAND
			this.addCommand(RootChangeEvent.ROOT_CHANGE, RootChangeCommand);
			this.addCommand(InitializeEvent.INITIALIZE, InitializeCommand);
			this.addCommand(PersonSelectedEvent.SELECTION, PersonSelectedCommand);
			this.addCommand(StateChangeEvent.STATE_CHANGE, StateChangeCommand);
			this.addCommand(AddRelationshipEvent.ADD_RELATIONSHIP, AddRelationshipCommand);
		}
		
	}
}