package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import org.akinu.business.PersonDelegate;
	import org.akinu.events.InitializeEvent;
	import org.akinu.model.ModelLocator;
	import org.akinu.responders.InitializeResponder;

	public class InitializeCommand implements ICommand {
		private var model:ModelLocator = ModelLocator.getInstance();
		public function InitializeCommand()	{
		}

		public function execute(event:CairngormEvent):void {
			var initEvent:InitializeEvent  = event as InitializeEvent;
			//Set visualization object shared across application
			model.vis = initEvent.vis; 
			var delegate:PersonDelegate = new PersonDelegate( new InitializeResponder());
			delegate.initialize(initEvent.rootID);
		}
		
	}
}