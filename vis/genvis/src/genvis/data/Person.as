package genvis.data
{
	import genvis.vis.data.NodeSprite;
	
	public class Person
	{
		private var _id:String;
		private var _name:String;
		private var _gender:String;
		private var _date_of_birth:Date;
		private var _date_of_death:Date;
		
		private var _parents:Array;
		private var _children:Array;
		private var _spouses:Array;
		private var _marriages:Array; //synchronized with _spouses
		
		private var _isSorted:Boolean;
		
		private var _estimated:int 		= NONE;
		private var _isVisited:Boolean	= false;
		
		private var _doi:Number;
		private var _sprite:NodeSprite;
		private var _marEvtPts:Array;
		
		public static const NONE:int		= 0;
		public static const DOB:int 		= 1;
		public static const DOD:int 		= 2;
		public static const GENDER:int		= 4;
		
		public static const MALE:String		= "Male";
		public static const FEMALE:String   = "Female";
		public static const NOGENDER:String	= "None";
		
		public function Person(){
			_isSorted 		= false;
			_parents		= new Array();
			_spouses		= new Array();
			_children		= new Array();
			_marriages 	= new Array();
		}
		public function get id():String { return _id; }
		public function set id(id:String):void { _id = id; }
		
		public function get name():String { return _name; }
		public function set name(n:String):void { _name = n; }
		
		public function get gender():String { return _gender; }
		public function set gender(g:String):void{ _gender = g; }
		
		public function get date_of_birth():Date { return _date_of_birth; }
		public function set date_of_birth(dob:Date):void { _date_of_birth = dob; }
		
		public function get date_of_death():Date { return _date_of_death; }
		public function set date_of_death(dod:Date):void{ _date_of_death = dod; }
		
		public function get estimated():int { return _estimated; }
		public function set estimated(flag:int):void { _estimated = flag; }
		
		public function get isSorted():Boolean { return _isSorted; }
		public function set isSorted(isSorted:Boolean):void { _isSorted = isSorted; }
		
		public function get isVisited():Boolean { return _isVisited; }
		public function set isVisited(isVisited:Boolean):void { _isVisited = isVisited;}
		
		public function get sprite():NodeSprite { return _sprite; }
		public function set sprite(spr:NodeSprite):void { _sprite = spr; }
		
		public function get doi():Number { return _doi; }
		public function set doi(doi:Number):void { _doi = doi; }
		
		public function get parents():Array { return _parents; }
		
		public function get spouses():Array { 
			if (_isSorted==false) this.sort();
			return _spouses; 
		}
		
		public function get children():Array { return _children; }
		
		public function get marriages():Array { return _marriages; }
		
//		public function get marEvtPts():Array { 			
//			if (_marEvtPts == null){
//				if (_isSorted == false) this.sort();
//				_marEvtPts = new Array();
//				for each (var marInfo:MarriageInfo in _marriages){
//					_marEvtPts.push(new EvtPt(marInfo.startDate, EvtPt.MARSTART, marInfo.spouseOf(this)));
//					if (marInfo.isDivorced == true)	_marEvtPts.push(new EvtPt(marInfo.endDate, EvtPt.MAREND, marInfo.spouseOf(this)));
//				}
//				_marEvtPts.sort(function (A:EvtPt, B:EvtPt):Number{
//					if (A.date == null && B.date!=null) return 1;
//					if (A.date != null && B.date==null) return -1;
//					return (A.date == B.date? 0: (A.date>B.date? 1: -1));
//				}); 				
//			}
//			return _marEvtPts;
//		}
		
		public function getAttribute(attrName:String):Object{
			switch (attrName){
				case "id":				return _id;
				case "name":			return _name;
				case "gender":			return _gender;	
				case "date_of_birth": 	return _date_of_birth;
				case "date_of_death": 	return _date_of_death;
				default:				return null;
			}		
		}
		public function setAttribute(attrName:String, val:Object):void{
			switch (attrName){
				case "id":				if (val is Number) 	_id 	= val as String; break;
				case "name":			if (val is String) 	_name 	= val as String; break;
				case "gender":			if (val is String) 	_gender = val as String; break;	
				case "date_of_birth": 	if (val is Date) 	_date_of_birth = val as Date; break;
				case "date_of_death": 	if (val is Date) 	_date_of_death = val as Date; break;
			}
		}
		public function addParent(parent:Person):void { _isSorted = false; _parents.push(parent); }
		public function addChild(child:Person):void {  _isSorted = false; _children.push(child); }
		public function addMarriage(marriage:Marriage):void {  _isSorted = false; _marriages.push(marriage); }
		
		public function isSpouseOf(person:Person):Boolean{
			if (_isSorted == false) this.sort();
			return _spouses.indexOf(person)!=-1? true:false;
		}
		public function isParentOf(person:Person):Boolean{
			return _children.indexOf(person)!=-1? true:false;
		}
		public function isChildOf(person:Person):Boolean{
			return _parents.indexOf(person)!=-1? true:false;			
		}
		public function get father():Person { 
			if (_parents.length == 0) return null;
			return _parents[0].gender == "Male"? _parents[0]: (_parents.length == 2? _parents[1] : null);
		}//for now, assume that data is sorted by gender
		public function get mother():Person { 
			if (_parents.length == 0) return null;
			return _parents[1].gender == "Female"? _parents[1]: (_parents.length == 2? _parents[0] : null);
		}	
		public function sort(attrName:String = null):void {
			if (_isSorted) return;
			if (attrName==null || attrName=="parents") _parents.sortOn("gender", Array.CASEINSENSITIVE| Array.DESCENDING);
			if (attrName==null || attrName=="spouses"){
				_marriages.sortOn("startDate", Array.NUMERIC); //earliest marriage first
				var sortedSpouses:Array = new Array();
				for each (var marriage:Marriage in _marriages){
					var sp:Person = marriage.spouseOf(this);
					if (sortedSpouses.indexOf(sp)==-1) sortedSpouses.push(sp);
				}
				_spouses = sortedSpouses;
			}
			if (attrName==null || attrName=="children") _children.sortOn("date_of_birth", Array.NUMERIC|Array.DESCENDING);//youngest first
			if (attrName==null) _isSorted = true;
		}
		public function copy():Person{
			var spouse:Person 	= new Person;
			spouse.id			= "copy_of_"+_id;
			spouse.gender		= _gender=="None"? "None" : (_gender=="Male"?"Female":"Male");
			spouse.name 		= "copy_of_"+ _name;
			return spouse;
		}
		public function get isDivorced():Boolean{
			if (this.lastMarriage == null) return false;
			return this.lastMarriage.isDivorced;
		}
		public function get isDead():Boolean{
			if (_date_of_death!=null) return true;
			return false;
		}
		public function isEstimated(flag:int):Boolean{
			return _estimated & flag? true : false;
		}
		
		public function get firstChild():Person{//only used after data sorted
			if (_children.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _children[_children.length-1];
		}
		public function get lastChild():Person{
			if (_children.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _children[0];
		}
		public function get firstSpouse():Person{
			if (_marriages.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _marriages[0].spouseOf(this);
		}
		public function get lastSpouse():Person{
			if (_marriages.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _marriages[_marriages.length -1].spouseOf(this);			
		}
		public function get firstMarriage():Marriage{
			if (_marriages.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _marriages[0];
		}
		public function get lastMarriage():Marriage{
			if (_marriages.length == 0) return null;
			if (_isSorted == false) this.sort();
			return _marriages[_marriages.length - 1];
		}
		public function get siblings():Array{//only used missing parents must be two a
			if (_parents.length!=2) return null;
			var siblings:Array = new Array();
			for each (var sibling:Person in _parents[0].children){
				if (_parents[0].isParentOf(sibling) && sibling != this)
					siblings.push(sibling);
			}
			return siblings;
		}
		public function childrenWith(spouse:Person):Array{
			if (_isSorted == false) this.sort();
			var children:Array = new Array();
			for each (var child:Person in _children){
				if (child.isChildOf(spouse))
					children.push(child);
			}
			return children;
		}
		public function marriageInfoWith(spouse:Person):Array{
			if (_isSorted == false) this.sort();
			var ms:Array = new Array();
			for each (var marriage:Marriage in _marriages){
				if (marriage.spouseOf(this) == spouse){
					ms.push(marriage);
				}
			}
			return (ms.length==0?null:ms);
		}
		public function apply(callback:Function, applySpouse:Boolean = false):void{
			callback(this);
			if (applySpouse){
				for each (var spouse:Person in this.spouses){
					callback(spouse);
				}
			}
		}
		/**
		 * depth first search over ancestors
		 * depth: maximum depth of search space
		 **/		
		public function visitAncestors(func:Function, depth:Number = Infinity, visitSps:Boolean = false):void{
			if (depth!=Infinity && depth <= 0) return;
			else if (depth!=Infinity && depth > 0) depth--;
			
			for each (var parent:Person in _parents){
				parent.apply(func, visitSps);				
				parent.visitAncestors(func, depth, visitSps);
			}
		}
//		public static function visitAncestorsBreadthFirst(f:Function, preorder:Boolean=false):Boolean{
//			
//		}
		/**
		 * depth first search over descendants
		 **/		
		public function visitDecendants(func:Function, depth:Number = Infinity, visitSps:Boolean = false):void{
			if (depth!=Infinity && depth <= 0) return;
			else if (depth!=Infinity && depth > 0) depth--;
			for each (var child:Person in _children){
				child.apply(func, visitSps);	
				child.visitDecendants(func, depth, visitSps);
			}
		}
//		public function visitDecendantsBreadthFirst(	f:Function, preorder:Boolean=false):Boolean{
//			
//		}		
	}
}