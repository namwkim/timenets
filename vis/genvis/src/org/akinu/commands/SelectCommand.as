package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import mx.controls.Menu;
	
	import org.akinu.events.SelectEvent;
	import org.akinu.model.ModelLocator;
	import org.akinu.view.PersonMain;

	public class SelectCommand implements ICommand{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function SelectCommand()	{
		}

		public function execute(event:CairngormEvent):void	{
			var select:SelectEvent = event as SelectEvent;
			if (select.objType == SelectEvent.PERSON){
				model.selectedPerson = select.selected;
				model.page 	 		 = ModelLocator.PERSON_PAGE;
				if (model.selectedPerson.saved == true){
					model.pageState = ModelLocator.PERSON_MAIN;
				}else{
					model.pageState	= ModelLocator.EDIT_UNSAVED_PERSON;
				}
				//Show Menu
//				var xml:XML=<root>
//					<menuitem label="Make This Center"/>
//					<menuitem label="Edit Info"/>
//					<menuitem label="See Life Events"/>
//				</root>;
//				
//				var menu:Menu = Menu.createMenu(model.selectedPerson.sprite, xml,false);
//				menu.labelField="@label";
//				
//				menu.show(select.evt.stageX, select.evt.stageY);

			}

		}
		
	}
}