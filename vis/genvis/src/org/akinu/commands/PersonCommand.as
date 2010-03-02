package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.business.PersonDelegate;
	import org.akinu.events.AddRelationshipEvent;
	import org.akinu.events.CreatePersonEvent;
	import org.akinu.events.RemovePersonEvent;
	import org.akinu.events.RemoveRelationshipEvent;
	import org.akinu.events.UpdateMarriageEvent;
	import org.akinu.events.UpdatePersonEvent;
	import org.akinu.model.ModelLocator;
	import org.akinu.responders.AddRelationshipResponder;
	import org.akinu.responders.CreatePersonResponder;
	import org.akinu.responders.RemovePersonResponder;
	import org.akinu.responders.RemoveRelationshipResponder;
	import org.akinu.responders.UpdateMarriageResponder;
	import org.akinu.responders.UpdatePersonResponder;

	public class PersonCommand implements ICommand{
		private var model:ModelLocator = ModelLocator.getInstance();
		
		public function PersonCommand()	{
		}

		public function execute(event:CairngormEvent):void	{
			var delegate:PersonDelegate;
			if (event is UpdatePersonEvent){
				var updateEvent:UpdatePersonEvent = event as UpdatePersonEvent;
				delegate = new PersonDelegate( new UpdatePersonResponder());
				delegate.updatePerson(updateEvent.person, model.project.id);
			}else if (event is CreatePersonEvent){
				var createEvent:CreatePersonEvent = event as CreatePersonEvent;
				delegate = new PersonDelegate( new CreatePersonResponder());		
				delegate.createPerson(createEvent.person, model.project.id);		
			}else if (event is AddRelationshipEvent){
				var addRelEvent:AddRelationshipEvent  = event as AddRelationshipEvent;
				delegate = new PersonDelegate( new AddRelationshipResponder(addRelEvent.person, addRelEvent.marriage, addRelEvent.nextEvents, addRelEvent.create, addRelEvent.visUpdate));
				delegate.addRelationship(addRelEvent.person, addRelEvent.marriage, addRelEvent.ref_id, addRelEvent.role, addRelEvent.create);					
			}else if (event is RemoveRelationshipEvent){
				var rmRelEvent:RemoveRelationshipEvent = event as RemoveRelationshipEvent;
				delegate = new PersonDelegate( new RemoveRelationshipResponder());
				delegate.removeRelationship(rmRelEvent.id, rmRelEvent.ref_id, rmRelEvent.role);				
			}else if (event is RemovePersonEvent){
				var rmEvent:RemovePersonEvent = event as RemovePersonEvent;
				delegate = new PersonDelegate( new RemovePersonResponder());
				delegate.removePerson(rmEvent.id);
			}else if (event is UpdateMarriageEvent){
				var upMarEvent:UpdateMarriageEvent = event as UpdateMarriageEvent;
				delegate = new PersonDelegate( new UpdateMarriageResponder());
				delegate.updateMarriage(upMarEvent.marriage); 
			}
		}
		
	}
}