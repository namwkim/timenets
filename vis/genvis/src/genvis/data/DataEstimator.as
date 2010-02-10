package genvis.data
{
	import mx.controls.Alert;
	
	public class DataEstimator
	{
		//offset and threshold for data estimation
		private static var _threshold:int = 100;//100 years;
		private static var _offset:int = 20;//20 years	
		private static var _data:Array = null;
		private static var _curDate:Date;
		public static const MALE:String 	= "Male";
		public static const FEMALE:String 	= "Female";
		public static const NONE:String		= "None";
		public static const DATE_OF_BIRTH:String = "date_of_birth";
		public static const DATE_OF_DEATH:String = "date_of_death";
		
		protected static function firstPass(person:Person):void{			
			estimateGender(person);
			if (estimateDate(person, "date_of_birth")==false){//TODO: if cannot estimate
				//this means there is no person having "date_of_birth" information
				//TODO: return message saying that data cannot be displayed	
				Alert.show("Cannot Estimate " + person.name + "'s Date of Birth!", 'Data Estimator', mx.controls.Alert.OK);			
			}	
			var dob:Date = person.date_of_birth;
			if ((dob.fullYear + _threshold) < _curDate.fullYear){
				if (estimateDate(person, "date_of_death")==false){
					Alert.show("Cannot Estimate " + person.name + "'s Date of Death.", 'Data Estimator', mx.controls.Alert.OK);						
				}	
			}
		}
		public static function secondPass(person:Person):void{
			for each(var marriage:Marriage in person.marriages){	
				if (marriage.startDate ==null && estimateMarriageDateStarted(person, marriage.spouseOf(person), marriage)==false){
					//TODO: if cannot estimate...
					Alert.show('Cannot Estimate Marriage Start-Date of'+person.name, 'Data Estimator', mx.controls.Alert.OK);
				}	
			}
			person.sort("spouses");//sort by start-date
			if (estimateMarriageDateEnded(person)==false){
				//TODO: if cannot estimate...
				Alert.show('Cannot Estimate Marriage End-Date of '+person.name, 'Data Estimator', mx.controls.Alert.OK);
			}
			
			//2.2
			if (person.parents.length ==1){//infer which spouse is a parent of this person
				//find where the person's birth date reside in which marriage date
				for each (marriage in person.parents[0].marriages){
					var endDate:Date = marriage.endDate==null? (marriage.spouseOf(person.parents[0]).isDead==false? _curDate: marriage.spouseOf(person.parents[0]).date_of_death):marriage.endDate;
					if (marriage.startDate <= person.date_of_birth &&  endDate>= person.date_of_birth){
						marriage.spouseOf(person.parents[0]).addChild(person);
						person.addParent(marriage.spouseOf(person.parents[0]));
						break;
					}
				}
			}
//					//Temporary
//					if ( person.parents.length == 1){
//						trace("Cannot infer a parent of "+person.name);
//						person.parents[0].spouses[0].addChild(person);
//						person.addParent(person.parents[0].spouses[0]);
//					}

			person.sort();

		}
		
		public static function prePass(person:Person):void{
			missingSpouseRelationship(person);
			missingParentChildRelationship(person);
		}
		/**
		 * observed case:
		 * #1. marriage start date cannot be older than end date
		 * #2. marriage end data cannot be older than death date
		 **/		
		public static function validation(person:Person):void{
			var temp:Date;
			for each (var marriage:Marriage in person.marriages){				
				if (marriage.endDate!=null && marriage.startDate>marriage.endDate){
					temp		 	= marriage.endDate;
					marriage.endDate	= marriage.startDate;
					marriage.startDate	= temp;
				}
				if (marriage.endDate!=null && person.date_of_death!=null && marriage.endDate>person.date_of_death){
					temp					= marriage.endDate;
					marriage.endDate		= person.date_of_death;
					person.date_of_death	= temp;
				}
			}
			
		}
		public static function estimate(root:Person, personTable:Array):void{
			_data 		= personTable;
			_curDate 	= new Date();
			//pre pass
			root.apply(prePass, true);
			root.visitAncestors(prePass, Infinity, true);
			root.visitDecendants(prePass, Infinity, true);			
			//first pass
			root.apply(firstPass,true);			
			root.visitAncestors(firstPass, Infinity, true);
			root.visitDecendants(firstPass, Infinity, true);
			//second pass
			root.apply(secondPass,true);			
			root.visitAncestors(secondPass, Infinity, true);
			root.visitDecendants(secondPass, Infinity, true);
			
			//validation
			root.apply(validation,true);			
			root.visitAncestors(validation, Infinity, true);
			root.visitDecendants(validation, Infinity, true);
			
		}
		public static function estimateMarriageDateEnded(person:Person):Boolean{
			var mar:Marriage, prevMar:Marriage=null;
			for (var i:int=person.marriages.length-1; i>=0; i--){
				mar = person.marriages[i];
				var spouse:Person = mar.spouseOf(person);
				if (mar.endDate == null){
					if (mar.spouseOf(person) != person.lastSpouse){
						if (prevMar.startDate > spouse.date_of_death)
							mar.endDate = spouse.date_of_death;
						else//it should be between birthdate of last child and the start date
							mar.endDate = prevMar.startDate;
						mar.estimated = Marriage.ENDDATE;
					}
				}else{
//					if (mar.spouseOf(person) == person.lastSpouse && mar.endDate.fullYear == (person.isDead? person.date_of_death.fullYear: (new Date()).fullYear)){
//						mar.endDate = null;
//					}
				}
				prevMar = mar;
			}			
			return true;//(marInfo.endDate==null? false:true); //always succeed for sure
		}
		//TODO: ensure that startdate is older than enddate
		public static function estimateMarriageDateStarted(person:Person, spouse:Person, marriage:Marriage):Boolean{
			//use oldest child's date of birth
			var children:Array = person.childrenWith(spouse);
			if (children.length !=0){
				var child:Person = children[children.length-1];//
				marriage.startDate = new Date(child.date_of_birth);
			}
			if (person.date_of_birth < spouse.date_of_birth){//if spouse is young
				marriage.startDate = new Date(spouse.date_of_birth.fullYear + _offset, spouse.date_of_birth.month, spouse.date_of_birth.date);
			}else{//if person is young
				marriage.startDate = new Date(person.date_of_birth.fullYear + _offset, person.date_of_birth.month, person.date_of_birth.date);				
			}			
			marriage.estimated = Marriage.STARTDATE;
			return ((marriage.startDate==null? false:true));
		}

		/**
		 * TODO: When using parant and child's dates, call this function recursively
		 **/
		public static function estimateDate(person:Person, type:String):Boolean{
			if (person.getAttribute(type)!=null)
				return (true);	
			//use parents' marriage date + offset	
			if (person.parents.length == 2){	
				var ms:Array	= person.parents[0].marriageInfoWith(person.parents[1]);	
				for each (var mar:Marriage in ms){
					var marDate:Date 	= type=="date_of_birth"? mar.startDate : mar.endDate;												
					if (marDate != null){
						person.setAttribute(type, new Date(marDate.fullYear + type=="date_of_birth"? 0 : _offset,
									marDate.month, marDate.date));
						person.estimated = type=="date_of_birth"? Person.DOB : Person.DOD;
						return (true);
					}
				}
			}
				
			//use child's date of birth or death - offset
			for each(var child:Person in person.children){
				var cDate:Date = child.getAttribute(type) as Date;
				if (cDate != null){
					//TODO: change to recursive call					
					person.setAttribute(type, new Date(cDate.fullYear - _offset, cDate.month, cDate.date));
					person.estimated = type=="date_of_birth"? Person.DOB : Person.DOD;
					return (true);
				}
			}	
			//use spouse's date of birth
			for each(var spouse:Person in person.spouses){
				if (spouse.getAttribute(type) != null){
					person.setAttribute(type, new Date(spouse.getAttribute(type)));
					person.estimated = type=="date_of_birth"? Person.DOB : Person.DOD;
					return (true);
				}
			}
			//use one of siblings's birth date
			var siblings:Array = person.siblings;
			for each(var sibling:Object in siblings){
				if (sibling.getAttribute(type)!=null){
					person.setAttribute(type, new Date(sibling.getAttribute(type)));
					person.estimated = type=="date_of_birth"? Person.DOB : Person.DOD;
					return (true);
				}
			}
			//use parent's date of birth or death + offset
			for each(var parent:Person in person.parents){
				var pDate:Date = parent.getAttribute(type) as Date;
				if (pDate != null){
					person.setAttribute(type, new Date(pDate.fullYear + _offset, pDate.month, pDate.date));
					person.estimated = type=="date_of_birth"? Person.DOB : Person.DOD;
					return (true);
				}
			}
			return (false);
		}
		
		public static function estimateGender(person:Person):Boolean{
			if (person.gender !=null)
				return (true);		
			//estimate gender from immediate spouses
			for each(var spouse:Object in person.spouses){				
				if (spouse.gender != null && spouse.gender != "None"){
					person.gender 	 = spouse.gender == "Male"? "Female" : "Male";
					person.estimated = Person.GENDER;
					return (true);
				}
			}
			//TODO: if fails, try spouses of spoues iteratively
			person.gender 		= "None";
			person.estimated	= Person.GENDER;
			return (false);
		}
		//1. missing spouse relationship
		protected static function missingSpouseRelationship(person:Person):void{
			//1. missing spouse relationship
			if (person.parents.length == 2){
				var marriage:Marriage;
				var father:Person = person.father;
				var mother:Person = person.mother;
				if (father.isSpouseOf(mother)==false){ //means also mother.isSpouseOf(father)==false
					marriage = new Marriage(father, mother);
					father.addMarriage(marriage);
					mother.addMarriage(marriage);					
				}
			}
		}
		//2. missing parent-child relationship
		protected static function missingParentChildRelationship(person:Person):void{
			if (person.parents.length ==1){
				var marriage:Marriage;
				//2.1 if this parent has no spouse, then create a fake person
				if (person.parents[0].spouses.length == 0){
					var spouse:Person 	= person.parents[0].copy();
					//construct spouse-relationship
					marriage = new Marriage(person.parents[0], spouse);
					spouse.addMarriage(marriage);
					person.parents[0].addMarriage(marriage);
					//construct parent-child relationship
					spouse.addChild(person);
					person.addParent(spouse);
					_data.push(spouse);	
				}
				//2.2. if this parent has one or more spouses, infer which spouse is a parent of this person.
				//(this is done after estimation)
			}
		}
	}
}