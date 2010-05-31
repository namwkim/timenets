package org.akinu.helper
{
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	public class Helper
	{

		public static const thisYear:int = new Date().fullYear;
	
		public static const sexArray:Array = [{label:"Select Sex:",data:""},{label:"Male",data:"Male"},{label:"Female",data:"Female"}];
		
		public static const monthArray:Array = [{label:"Month",data:""},{label:"Jan",data:"0"},{label:"Feb",data:"1"}, {label:"Mar",data:"2"}, 
			{label:"Apr",data:"3"}, {label:"May",data:"4"}, {label:"June",data:"5"}, {label:"July",data:"6"}, {label:"Aug",data:"7"},
			{label:"Sep",data:"8"}, {label:"Oct",data:"9"}, {label:"Nov",data:"10"}, {label:"Dec",data:"11"} ];
		
		public static const dayArray:Array = [{label:"Day", data:""}, {label:"1", data:"1"}, {label:"2", data:"2"}, {label:"3", data:"3"}, {label:"4", data:"4"},
		{label:"5", data:"5"}, {label:"6", data:"6"}, {label:"7", data:"7"}, {label:"8", data:"8"}, {label:"9", data:"9"}, {label:"10", data:"10"}, 
		{label:"11", data:"11"}, {label:"12", data:"12"}, {label:"13", data:"13"}, {label:"14", data:"14"}, {label:"15", data:"15"}, {label:"16", data:"16"},
		{label:"17", data:"17"}, {label:"18", data:"18"}, {label:"19", data:"19"}, {label:"20", data:"20"}, {label:"21", data:"21"}, {label:"22", data:"22"},
		{label:"23", data:"23"}, {label:"24", data:"24"}, {label:"25", data:"25"}, {label:"26", data:"26"}, {label:"27", data:"27"}, {label:"28", data:"28"}, 
		{label:"29", data:"29"}, {label:"30", data:"30"}, {label:"31", data:"31"}];
		public static const MonthLabels:Array = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
		public static function dateToString(date:Date):String{
			return Helper.MonthLabels[date.month]+" "+date.date+", "+date.fullYear;
		}
				
		public static function assignDate(year:Number, month:Number, day:Number):Date{
			if (isNaN(year)==false){
				var newDate:Date = new Date();
				newDate.setFullYear(year, isNaN(month)? 0:month, isNaN(day)? 1:day);
				return newDate;
			}
			return null;
		}
		public static function assignUTCDate(yearUTC:Number, monthUTC:Number, dayUTC:Number):Date{
			if (isNaN(yearUTC)==false){
				var newDate:Date = new Date();
				newDate.setUTCFullYear(yearUTC, isNaN(monthUTC)? 0:monthUTC, isNaN(dayUTC)? 1:dayUTC);
				return newDate;
			}
			return null;			
		}
		public static function personFromUTC(person:Person):void{
			if (person.dateOfBirth){
				person.dateOfBirth = Helper.assignDate(person.dateOfBirth.fullYearUTC, person.dateOfBirth.monthUTC, person.dateOfBirth.dateUTC);
			}
			if (person.dateOfDeath){
				person.dateOfDeath = Helper.assignDate(person.dateOfDeath.fullYearUTC, person.dateOfDeath.monthUTC, person.dateOfDeath.dateUTC);
			}
		}
		public static function personToUTC(person:Person):void{
			if (person.dateOfBirth){
				person.dateOfBirth = Helper.assignUTCDate(person.dateOfBirth.fullYear, person.dateOfBirth.month, person.dateOfBirth.date);
			}
			if (person.dateOfDeath){
				person.dateOfDeath = Helper.assignUTCDate(person.dateOfDeath.fullYear, person.dateOfDeath.month, person.dateOfDeath.date);
			}		
		}
		public static function marriageFromUTC(marriage:Marriage):void{
			if (marriage.startDate){
				marriage.startDate = Helper.assignDate(marriage.startDate.fullYearUTC, marriage.startDate.monthUTC, marriage.startDate.dateUTC);
			}
			if (marriage.endDate){
				marriage.endDate = Helper.assignDate(marriage.endDate.fullYearUTC, marriage.endDate.monthUTC, marriage.endDate.dateUTC);
			}
		}
		public static function marriageToUTC(marriage:Marriage):void{
			if (marriage.startDate){
				marriage.startDate = Helper.assignUTCDate(marriage.startDate.fullYear, marriage.startDate.month, marriage.startDate.date);
			}
			if (marriage.endDate){
				marriage.endDate = Helper.assignUTCDate(marriage.endDate.fullYear, marriage.endDate.month, marriage.endDate.date);
			}			
		}

	}
}