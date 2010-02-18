package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.business.PersonDelegate;
	import org.akinu.events.AddRelationshipEvent;
	import org.akinu.responders.AddRelationshipResponder;

	public class AddRelationshipCommand implements ICommand{
		public function AddRelationshipCommand(){
		}

		public function execute(event:CairngormEvent):void	{
			var addRelEvent:AddRelationshipEvent  = event as AddRelationshipEvent;
			var delegate:PersonDelegate = new PersonDelegate( new AddRelationshipResponder());
			delegate.add_relationship(addRelEvent.person, addRelEvent.marriage, addRelEvent.ref_id, addRelEvent.role);
		}
		
	}
}