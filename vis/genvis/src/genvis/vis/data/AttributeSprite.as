package genvis.vis.data
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import genvis.data.Marriage;
	import genvis.data.Person;

	public class AttributeSprite extends DataSprite{
		public static const DATE_OF_BIRTH:uint	= 1;
		public static const DATE_OF_DEATH:uint	= 2;
		public static const MARRIAGE_DATE:uint	= 3;
		public static const DIVORCE_DATE:uint	= 4;
		
		public static const PERSON:uint		= 1;
		public static const MARRIAGE:uint	= 2;
		private var _label:TextSprite	= null;
		private var _uncertain:Boolean;
		private var _attrType:uint;
		private var _objType:uint;
		/**
		 * uncertain: indicates which attribute is uncertain
		 * data		: it could be Person or Marriage object.
		 */
		public function AttributeSprite(attrType:uint, objType:uint, uncertain:Boolean, data:Object){
			_attrType 	= attrType;
			_objType	= objType;
			_uncertain	= uncertain;
			_data		= data;
			if (_objType == PERSON){
				var person:Person = data as Person;
				person.sprite.addAttribute(this);
			}else{
				var marriage:Marriage = data as Marriage;
				marriage.person1.sprite.addAttribute(this);
				marriage.person2.sprite.addAttribute(this);				
			}			
		}
		public function get label():TextSprite { return _label; }
		public function set label(l:TextSprite):void{ _label	= l;}
		
		public function get uncertain():Boolean { return _uncertain; }
		public function get attrType():uint		{ return _attrType;	 }
		public function get objType():uint		{ return _objType;	 }
		

	}
}