package org.akinu.model
{
	import com.adobe.cairngorm.CairngormError;
	import com.adobe.cairngorm.CairngormMessageCodes;
	import com.adobe.cairngorm.model.IModelLocator;
	
	import flash.utils.Dictionary;
	
	import genvis.GenVis;
	import genvis.data.Person;
	
	import org.akinu.view.EditBasicInfo;
	import org.akinu.view.EditMarriage;
	import org.akinu.view.PersonMain;
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
		//url
		public var url:String = "http://akinu.org/";//"http://localhost:3000/";
		//context menu variables
		public static const FRONT_PAGE:uint		= 0;
		public static const PERSON_PAGE:uint	= 1;
		public var page:uint = FRONT_PAGE;
		
		//local workflow state variables
		//1. person menu context
		public static const INDEX:uint					= 0;			
		public static const PERSON_MAIN:uint			= 0; 
//		public static const PERSON_EDIT:uint			= 1;
//		public static const EDIT_PERSON:uint			= 2;
		public static const EDIT_MARRIAGE:uint			= 1;
		public var pageState:uint = PERSON_MAIN; //depends on contextViewType
		
		//vis data variables
		public var root:Person; //root person for the visualization (in case of hourglass chart, it's the center node)
		public var events:Array;
		public var selectedPerson:Person;
		public var vis:GenVis;
		
		//other data 
		public var project:Project; //it contains events and people		
		
		//temp data between views
		public var data:*;
		public var editInfo:EditBasicInfo; //to call init function in some cases /TODO: improve this later
		public var editMarriage:EditMarriage;
		public var personMain:PersonMain;
	}
}