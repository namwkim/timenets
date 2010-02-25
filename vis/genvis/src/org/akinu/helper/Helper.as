package org.akinu.helper
{
	public class Helper
	{

		public static const thisYear:int = new Date().fullYear;
	
		public static const sexArray:Array = [{label:"Select Sex:",data:""},{label:"Male",data:"Male"},{label:"Female",data:"Female"}];
		
		public static const monthArray:Array = [{label:"Month",data:""},{label:"Jan",data:"1"},{label:"Feb",data:"2"}, {label:"Mar",data:"3"}, 
			{label:"Apr",data:"4"}, {label:"May",data:"5"}, {label:"June",data:"6"}, {label:"July",data:"7"}, {label:"Aug",data:"8"},
			{label:"Sep",data:"9"}, {label:"Oct",data:"10"}, {label:"Nov",data:"11"}, {label:"Dec",data:"12"} ];
		
		public static const dayArray:Array = [{label:"Day", data:""}, {label:"1", data:"1"}, {label:"2", data:"2"}, {label:"3", data:"3"}, {label:"4", data:"4"},
		{label:"5", data:"5"}, {label:"6", data:"6"}, {label:"7", data:"7"}, {label:"8", data:"8"}, {label:"9", data:"9"}, {label:"10", data:"10"}, 
		{label:"11", data:"11"}, {label:"12", data:"12"}, {label:"13", data:"13"}, {label:"14", data:"14"}, {label:"15", data:"15"}, {label:"16", data:"16"},
		{label:"17", data:"17"}, {label:"18", data:"18"}, {label:"19", data:"19"}, {label:"20", data:"20"}, {label:"21", data:"21"}, {label:"22", data:"22"},
		{label:"23", data:"23"}, {label:"24", data:"24"}, {label:"25", data:"25"}, {label:"26", data:"26"}, {label:"27", data:"27"}, {label:"28", data:"28"}, 
		{label:"29", data:"29"}, {label:"30", data:"30"}, {label:"31", data:"31"}];
		
		public static function assignDate(year:Number, month:Number, day:Number):Date{
			if (isNaN(year)==false){
				return new Date(year, isNaN(month)? 0:(month-1), isNaN(day)? 1:day);
			}
			return null;
		}
	}
}