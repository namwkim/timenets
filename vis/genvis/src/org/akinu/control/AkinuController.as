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
			//GENERIC COMMANDS
			this.addCommand(RootChangeEvent.ROOT_CHANGE, RootChangeCommand);
			this.addCommand(InitializeEvent.INITIALIZE, InitializeCommand);
			this.addCommand(SelectEvent.SELECTION, SelectCommand);
			this.addCommand(StateChangeEvent.STATE_CHANGE, StateChangeCommand);
			this.addCommand(PageChangeEvent.PAGE_CHANGE, PageChangeCommand);
			
			//PERSON COMMANDS
			this.addCommand(CreatePersonEvent.CREATE_PERSON, PersonCommand);
			this.addCommand(UpdatePersonEvent.UPDATE_PERSON, PersonCommand);
			this.addCommand(RemovePersonEvent.REMOVE_PERSON, PersonCommand);
			this.addCommand(AddRelationshipEvent.ADD_RELATIONSHIP, PersonCommand);
			this.addCommand(RemoveRelationshipEvent.REMOVE_RELATIONSHIP, PersonCommand);
			this.addCommand(UpdateMarriageEvent.UPDATE_MARRIAGE, PersonCommand);
		}
		
	}
}