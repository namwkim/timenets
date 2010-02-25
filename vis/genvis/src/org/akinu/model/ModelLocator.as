package org.akinu.model
{
	import com.adobe.cairngorm.CairngormError;
	import com.adobe.cairngorm.CairngormMessageCodes;
	import com.adobe.cairngorm.model.IModelLocator;
	
	import genvis.GenVis;
	import genvis.data.Person;
	
	import org.akinu.vo.Project;
	
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
		public static const FRONT_PAGE:uint		= 0;
		public static const PERSON_PAGE:uint	= 1;
		public var page:uint = FRONT_PAGE;
		
		//local workflow state variables
		//1. person menu context			
		public static const PERSON_MAIN:uint			= 0; 
		public static const PERSON_EDIT:uint			= 1;
		public static const EDIT_UNSAVED_PERSON:uint	= 2;
		public var pageState:uint = PERSON_MAIN; //depends on contextViewType
		
		//vis data variables
		public var root:Person; //root person for the visualization (in case of hourglass chart, it's the center node)
		public var selectedPerson:Person;
		public var vis:GenVis;
		
		//project 
		public var project:Project;
		
		//temp data between views
		public var data:*;
	}
}