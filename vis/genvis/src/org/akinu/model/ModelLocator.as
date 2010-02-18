package org.akinu.model
{
	import com.adobe.cairngorm.CairngormError;
	import com.adobe.cairngorm.CairngormMessageCodes;
	import com.adobe.cairngorm.model.IModelLocator;
	
	import genvis.GenVis;
	import genvis.data.Person;
	
	[Bindable]
	public class ModelLocator implements IModelLocator
	{
		private static var _instance:ModelLocator;
		public function ModelLocator() {
			if (_instance != null){
				throw new CairngormError(CairngormMessageCodes.SINGLETON_EXCEPTION, "ModelLocator");
			}
			_instance = this;
		}
		public static function getInstance():ModelLocator{
			if (_instance==null)	_instance = new ModelLocator();
			return _instance;
		}
		
		//context menu variables
		public static const MAIN_MENU:uint		= 0;
		public static const PERSON_MENU:uint	= 1;
		public var contextMenu:uint = MAIN_MENU;
		
		//local workflow state variables
		//1. person menu context		
		public static const TAKE_ACTION:uint		= 0;
		public static const ADD_RELATIONSHIP:uint	= 1; 
		public var workflowState:uint = TAKE_ACTION; //depends on contextViewType
		
		//vis data variables
		public var root:Person; //root person for the visualization (in case of hourglass chart, it's the center node)
		public var selectedPerson:Person;
		public var vis:GenVis;
		
		//temp data between views
		public var data:*;
	}
}