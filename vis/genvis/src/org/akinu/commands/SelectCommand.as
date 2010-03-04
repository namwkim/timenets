package org.akinu.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.data.AttributeSprite;
	
	import org.akinu.events.SelectEvent;
	import org.akinu.model.ModelLocator;

	public class SelectCommand implements ICommand{
		private var model:ModelLocator = ModelLocator.getInstance();
		public function SelectCommand()	{
		}

		public function execute(event:CairngormEvent):void	{
			var select:SelectEvent = event as SelectEvent;
			if (select.objType == SelectEvent.PERSON){
				if (select.evtType == SelectEvent.SELECT){
					model.selectedPerson = select.selected;
					model.page 	 		 = ModelLocator.PERSON_PAGE;
					if (model.selectedPerson.saved == true){
						model.pageState = ModelLocator.PERSON_MAIN;
					}else{
						model.pageState	= ModelLocator.EDIT_PERSON;
					}
				}else if (select.evtType == SelectEvent.DESELECT){
					model.selectedPerson 	= null;
					model.page				= ModelLocator.FRONT_PAGE;
					model.pageState			= ModelLocator.INDEX;
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

			}else if (select.objType == SelectEvent.ATTRIBUTE){//when uncertain marker is clicked
				var attr:AttributeSprite = select.selected;
				if (attr.objType == AttributeSprite.PERSON){
					model.selectedPerson = attr.data as Person;
					model.page 	 		 = ModelLocator.PERSON_PAGE;
					model.pageState		 = ModelLocator.EDIT_PERSON;
					if (model.editInfo) model.editInfo.init();//initialize the edit page
				}else if (attr.objType == AttributeSprite.MARRIAGE){	
					model.selectedPerson = null;
					model.page 	 		 = ModelLocator.PERSON_PAGE;
					model.pageState		 = ModelLocator.EDIT_MARRIAGE;
					model.data			 = attr.data as Marriage;
					if (model.editMarriage) model.editMarriage.init(attr.data as Marriage);//initialize the edit page
				}		
			}

		}
		
	}
}