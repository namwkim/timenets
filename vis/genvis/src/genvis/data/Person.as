package genvis.data
{
	import genvis.vis.data.NodeSprite;
	[RemoteClass(alias="Person")]
	[Bindable]	
	public class Person{
		
		public static const NONE:uint		= 0;
		public static const DOB:uint 		= 1;
		public static const DOD:uint 		= 2;
		public static const GENDER:uint		= 4;
		public static const SEX:uint		= 4;
		public static const NAME:uint		= 5;
		
		public static const MALE:String		= "Male";
		public static const FEMALE:String   = "Female";
		public static const NOGENDER:String	= "None";
		
		private var _id:String;
		private var _firstName:String;
		private var _lastName:String;		
		private var _gender:String;		
		private var _dateOfBirth:Date;
		private var _dateOfDeath:Date;
		private var _photoUrl:String;
		private var _deceased:Boolean;
		private var _isDobUncertain:Boolean;
		private var _isDodUncertain:Boolean;

		private var _parents:Array;
		private var _children:Array;
		private var _spouses:Array;
		private var _marriages:Array; //synchronized with _spouses
		
		private var _estimated:int = NONE;	
		private var _doi:Number;
		private var _sprite:NodeSprite;
		private var _isVisited:Boolean	= false;
		private var _isSorted:Boolean;
		private var _saved:Boolean = true;//synchronized with server when being initialized
		

		
		public function Person(){
			_isSorted 		= false;
			_parents		= new Array();
			_spouses		= new Array();
			_children		= new Array();
			_marriages 	= new Array();
		}
		public function get id():String { return _id; }
		public function set id(id:String):void { _id = id; }
		
		public function get name():String { return _firstName +" "+_lastName; }
		public function set name(n:String):void { var r:Array = n.split(" ",2); _firstName = r[0]; _lastName = r[1]; }
		
		public function get firstName():String { return _firstName; }
		public function set firstName(f:String):void { _firstName = f; }
		
		public function get lastName():String	{ return _lastName;  }
		public function set lastName(l:String):void { _lastName = l; }
		
		public function get gender():String { return _gender; }
		public function set gender(g:String):void{ _gender = g; }
		
		public function get sex():String	{ return _gender;}
		public function set sex(s:String):void { _gender = s} 
		
		public function get dateOfBirth():Date { return _dateOfBirth; }
		public function set dateOfBirth(dob:Date):void { _dateOfBirth = dob; }
		
		public function get dateOfDeath():Date { return _dateOfDeath; }
		public function set dateOfDeath(dod:Date):void{ _dateOfDeath = dod; }
		
		public function get photoUrl():String	{ return _photoUrl; }
		public function set photoUrl(p:String):void { _photoUrl = p ;	}
		public function get deceased():Boolean{
			if (_dateOfDeath != null) return true;						
			return _deceased; //in this case, dateOfDeath is just missing...(default should be false as deceased value was not previously set, but default 
		}
		public function set deceased(d:Boolean):void { _deceased = d; }
		
		public function get estimated():int { return _estimated; }
		public function set estimated(flag:int):void { 
			_estimated |= flag;
			if (flag == DOB){
				_isDobUncertain = true;
			}else if (flag == DOD){
				_isDodUncertain = true;				
			}
		}

		public function get isDobUncertain():Boolean { return _isDobUncertain; }
		public function set isDobUncertain(du:Boolean):void { _isDobUncertain = du; }
		
		public function get isDodUncertain():Boolean { return _isDodUncertain; }
		public function set isDodUncertain(du:Boolean):void { _isDodUncertain = du; }
	
		public function get isSorted():Boolean { return _isSorted; }
		public function set isSorted(isSorted:Boolean):void { _isSorted = isSorted; }
		
		public function get isVisited():Boolean { return _isVisited; }
		public function set isVisited(isVisited:Boolean):void { _isVisited = isVisited;}
		
		public function get saved():Boolean { return _saved; }
		public function set saved(s:Boolean):void { _saved = s; }
		
		public function get sprite():NodeSprite { return _sprite; }
		public function set sprite(spr:NodeSprite):void { _sprite = spr; }
		
		public function get doi():Number { return _doi; }
		public function set doi(doi:Number):void { _doi = doi; }
		
		public function get parents():Array { return _parents; }
		public function set parents(p:Array):void { _isSorted = false; _parents = p; }
		
		public function get spouses():Array { 
			if (_isSorted==false) this.sort();
			return _spouses; 
		}
		public function set spouses(s:Array):void { _isSorted = false; _spouses = s; }
		
		public function get children():Array { return _children; }
		public function set children(c:Array):void { _isSorted = false; _children = c; }
		
		public function get marriages():Array { return _marriages; }
		public function set marriages(m:Array):void { _isSorted = false; _marriages = m; }
		
		
		public function getAttribute(attrName:String):Object{
			switch (attrName){
				case "id":				return _id;
				case "name":			return _firstName+" "+_lastName;
				case "gender":			return _gender;	
				case "dateOfBirth": 	return _dateOfBirth;
				case "dateOfDeath": 	return _dateOfDeath;
				default:				return null;
			}		
		}
		public function setAttribute(attrName:String, val:Object):void{
			switch (attrName){
				case "id":				if (val is Number) 	_id 	= val as String; break;
				case "name":			if (val is String) 	this.name	= val as String; break;
				case "gender":			if (val is String) 	_gender = val as String; break;	
				case "dateOfBirth": 	if (val is Date) 	_dateOfBirth = val as Date; break;
				case "dateOfDeath": 	if (val is Date) 	_dateOfDeath = val as Date; break;
			}
		}
		public function addParent(parent:Person):void { 
			if (_parents.indexOf(parent)>=0) return; //exist
			_isSorted = false; 
			_parents.push(parent); 
		}
		public function addChild(child:Person):void {  
			if (_children.indexOf(child)>=0) return; //exist
			_isSorted = false; 
			_children.push(child);
		}
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
			return _parents[0].gender == "Female"? _parents[0]: (_parents.length == 2? _parents[1] : null);
		}	
		public function set father(f:Person):void{
			_isSorted = false; _parents.push(f);			
		}
		public function set mother(m:Person):void{
			_isSorted = false; _parents.push(m);
		}
		public function sort(attrName:String = null):void {
			if (_isSorted) return;
			if (attrName==null || attrName=="parents") _parents.sortOn("gender", Array.CASEINSENSITIVE| Array.DESCENDING);
			if (attrName==null || attrName=="spouses"){
				_marriages.sortOn("startDate", Array.NUMERIC); //earliest marriage first
				var sortedSpouses:Array = new Array();
				for each (var marriage:Marriage in _marriages){
					var sp:Person = marriage.spouseOf(this);
					if (sortedSpouses.indexOf(sp)<0) sortedSpouses.push(sp);
				}
				_spouses = sortedSpouses;
			}
			if (attrName==null || attrName=="children") _children.sortOn("dateOfBirth", Array.NUMERIC|Array.DESCENDING);//youngest first
			if (attrName==null) _isSorted = true;
		}
		public function copy():Person{
			var spouse:Person 	= new Person;
			//spouse.id			= "copy_of_"+_id;
			spouse.gender		= _gender=="None"? "None" : (_gender=="Male"?"Female":"Male");
			spouse.name 		= "Add Person";//"copy_of_"+ name;
			spouse.dateOfBirth	= new Date(this.dateOfBirth);
			spouse.isDobUncertain = true;			
			
			if (this.deceased){
				spouse.dateOfDeath		= new Date(this.dateOfDeath);
				spouse.isDodUncertain 	= true;
			}
			spouse.saved		= false;
			return spouse;
		}
		public function get isDivorced():Boolean{
			if (this.lastMarriage == null) return false;
			return this.lastMarriage.divorced;
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
				if (_parents[1].isParentOf(sibling) && sibling != this)
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
		public function marriageWith(spouse:Person):Array{
			if (_isSorted == false) this.sort();
			var ms:Array = new Array();
			for each (var marriage:Marriage in _marriages){
				if (marriage.spouseOf(this) == spouse){
					ms.push(marriage);
				}
			}
			return (ms.length==0?null:ms);
		}
		public function removeMarriages(spouse:Person):void{
			var sidx:uint = _spouses.indexOf(spouse);
			if (sidx<0) return;
			var mars:Array = marriageWith(spouse);
			for each (var mar:Marriage in mars){
				var idx:uint = _marriages.indexOf(mar);
				_marriages.splice(idx, 1);	
			}			
			_spouses.splice(sidx,1);
		}
		public function removeMarriage(marriage:Marriage):void{
			var midx:uint = _marriages.indexOf(marriage);
			if (midx<0) return;
			_marriages.splice(midx, 1);			
		}
		public function removeChild(child:Person):void{
			var cidx:uint = _children.indexOf(child);
			if (cidx<0) return;
			_children.splice(cidx, 1);
		}
		public function removeParent(parent:Person):void{
			var pidx:uint = _parents.indexOf(parent);
			if (pidx<0) return;
			_parents.splice(pidx, 1);
		}
		public function remove():void{
			for each (var spouse:Person in _spouses){
				spouse.removeMarriages(this);	
				if (spouse.saved == false){
					 	var chs:Array = childrenWith(spouse);
					 	for each (var ch:Person in chs) {
					 		ch.removeParent(spouse);
					 	}
				}			
			}
			for each (var parent:Person in _parents){
				parent.removeChild(this);
			}
			for each (var child:Person in _children){
				child.removeParent(this);
			}
					
		}
		
		public function apply(callback:Function, applySpouse:Boolean = false):void{
			callback(this);
			if (applySpouse){
				for each (var spouse:Person in this.spouses){
					callback(spouse);
				}
			}
		}
		public function visit(func:Function, depth:Number = Infinity, visitSps:Boolean = false):void{
			if (depth<0) return;
			this.apply(func, visitSps);
			this.visitAncestors(func, depth, visitSps);
			this.visitDecendants(func, depth, visitSps);	
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