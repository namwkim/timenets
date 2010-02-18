package genvis.data
{
	import flare.vis.data.Data;
	[RemoteClass(alias="Marriage")]
	[Bindable]
	public class Marriage
	{
		private var _id:String;
		private var _startDate:Date;
		private var _endDate:Date;
		private var _person1:Person;
		private var _person2:Person;
		private var _divorced:Boolean =true;
		
		private var _estimated:int;
		
		public static const NONE:int		= 0;
		public static const STARTDATE:int	= 1;
		public static const ENDDATE:int		= 2;
		
		public function set id(id:String):void { _id = id; }
		public function get id():String { return _id; }
		
		public function set startDate(sDate:Date):void { 
			_startDate = sDate; 
			person1.isSorted = person2.isSorted = false;
		}
		public function get startDate():Date { return _startDate; }
		
		public function set endDate(eDate:Date):void { _endDate = eDate; }
		public function get endDate():Date { return _endDate; }
		
		public function set person1(p:Person):void { _person1 = p; }
		public function get person1():Person { return _person1; }
		public function set person2(p:Person):void { _person2 = p; }
		public function get person2():Person { return _person2; }
		
		//TODO: is there a better way to handle this discrepancy with the backend?
		public function set person(p:Person):void { _person1 = p; }
		public function get person():Person { return _person1; }
		public function set spouse(p:Person):void { _person2 = p; }
		public function get spouse():Person { return _person2; }
		
		public function set estimated(flag:int):void{ _estimated |= flag; }
		public function get estimated():int	{ return _estimated; }
		
		public function set divorced(d:Boolean):void { _divorced = d; }
		public function get divorced():Boolean {
			if (_endDate == null) return false;
			if ((_endDate.fullYear == (_person1.deceased? _person1.dateOfDeath.fullYear: (new Date()).fullYear)
				|| _endDate.fullYear == (_person2.deceased? _person2.dateOfDeath.fullYear: (new Date()).fullYear))
				&& (_person1.lastMarriage == this && _person2.lastMarriage == this))	{
				return false;
			}		
			return _divorced;
		}
		public function isEstimated(flag:int):Boolean{
			return _estimated & flag? true : false;
		}
		public function spouseOf(p:Person):Person {
			if (p == person1){
				return person2;
			}else if (p == person2){
				return person1;
			}
			trace(p.name + "is not in the relationship");
			return null;			
		}
		public function Marriage(person1:Person = null, person2:Person = null, startDate:Date = null, endDate:Date = null )
		{
			_estimated 	= NONE;
			_person1	= person1;
			_person2	= person2;
			_startDate	= startDate;
			_endDate	= endDate;
			
		}
		
		

	}
}