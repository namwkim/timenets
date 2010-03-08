package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.business.ProjectDelegate;
	import org.akinu.events.UpdateProjectEvent;

	public class ProjectCommand implements ICommand
	{
		public function ProjectCommand()
		{
		}

		public function execute(event:CairngormEvent):void{
			var delegate:ProjectDelegate;
			if (event is UpdateProjectEvent){
				var updateEvent:UpdateProjectEvent = event as UpdateProjectEvent;
				delegate = new ProjectDelegate(null);
				delegate.updateProject(updateEvent.project);
			}
		}
		
	}
}