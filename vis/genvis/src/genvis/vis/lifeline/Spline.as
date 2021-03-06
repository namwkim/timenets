package genvis.vis.lifeline
{
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Point;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	
	public class Spline extends Lifeline
	{
		public function Spline(style:int = Lifeline.LABELINSIDE)
		{
			super(style);
		}
//		public override function generateLifeline(node:NodeSprite, marDir:Number, birthLine:Boolean = true, refSpouse:Person = null):void{
//			var points:Array 	= new Array();
//			var estPts:Array = new Array();
//			
//			var person:Person 	= node.data as Person;
//			//born to marriage
//			var bornX:Number, bornY:Number, marX:Number, marY:Number, dx:Number, deathX:Number, 
//				deathY:Number, divX:Number, divY:Number;
//			bornX = 0;
//			if (birthLine && person.parents.length != 0){	
//				bornY = (person.yorder - (person.father.yorder+person.mother.yorder)/2)*_dy;
//				if (person.spouses.length != 0){
//					marX  = _xAxis.X(person.firstMarriage.startDate) - node.x;
//					dx	  = ((marX - bornX)/3)/3;
//				}else{
//					deathX 	= _xAxis.X(person.date_of_death!=null? person.date_of_death: _curDate)-node.x;
//					dx		=((deathX - bornX)/3)/6;
//				}				
//				points.push(new Point(bornX, bornY));
//				points.push(new Point(bornX+dx,   bornY));
//				points.push(new Point(bornX+2*dx, 0));
//				points.push(new Point(bornX+3*dx, 0));
//			}else{
//				points.push(new Point(0,0));
//			}
//			if (person.isEstimated(Person.DOB)) estPts.push(new Point(0,0));
//			//divorce and remarriage
//			if (person.spouses.length !=0){
//				var dist:Number;
//				if (!refSpouse){
//					dist = (_dy/2-1);
//				}else{
//					dist = (Math.abs(person.yorder-refSpouse.yorder)-1/2)*_dy - 1;
//				}
//				var prevX:Number = bornX; 
//				var prevY:Number = 0;
//				var nextX:Number;
//				for each (var marInfo:MarriageInfo in person.marriageInfo){
//					var spouse:Person = marInfo.spouseOf(person);
//					if (refSpouse && refSpouse.id != spouse.id) continue;
//					var dir:Number = person.yorder-spouse.yorder;					
//					marX = _xAxis.X(marInfo.startDate) - node.x;
//					marY = dir<0? -dist:dist;//dir<0 = UP
//					dx	  = ((marX - prevX)/3)/3;
//					points.push(new Point(marX-3*dx, prevY)); 
//					points.push(new Point(marX-3*dx, prevY));
//					points.push(new Point(marX-2*dx, prevY));
//					points.push(new Point(marX-dx, marY)); 
//					points.push(new Point(marX, marY));
//					points.push(new Point(marX, marY));	
//					if (marInfo.isEstimated(MarriageInfo.STARTDATE)) estPts.push(new Point(marX, marY));
//					prevX = marX;
//					prevY = marY;
//					if (marInfo.isDivorced){//divorce 
//						divX = _xAxis.X(marInfo.endDate!=null? marInfo.endDate: _curDate)-node.x;
//						divY = 0;
//						if (person.lastMarriage!=marInfo){
//							var nextMarInfo:MarriageInfo = person.marriageInfo[person.marriageInfo.indexOf(marInfo)+1];
//							nextX = _xAxis.X(nextMarInfo.startDate) - node.x;
//						}else{
//							nextX = _xAxis.X(person.isDead? person.date_of_death:_curDate)-node.x;
//						}
//						dx	 = ((divX - prevX)/3)/3;
//						points.push(new Point(divX-3*dx, prevY)); //dummy point
//						points.push(new Point(divX-3*dx, prevY));
//						points.push(new Point(divX-2*dx, prevY));
//						points.push(new Point(divX-dx, divY)); 
//						points.push(new Point(divX, divY));
//						points.push(new Point(divX, divY)); //dummy point	
//						if (marInfo.isEstimated(MarriageInfo.ENDDATE)) estPts.push(new Point(divX, prevY));	
//						prevX = divX;	
//						prevY = divY;			
//					}			
//				}
//			}
//			//marriage to death
//			// death point
//			deathX = _xAxis.X(person.isDead? person.date_of_death:_curDate)-node.x;
//			var isDivorced:Boolean = refSpouse==null? person.isDivorced : person.marriageInfoWith(refSpouse).isDivorced;
//			if (isDivorced){
//				points.push(new Point(deathX, 0));
//				if (person.isEstimated(Person.DOD)) estPts.push(new Point(deathX, 0));
//			}else{				
//				points.push(new Point(deathX, person.spouses.length!=0? marY:0));
//				if (person.isEstimated(Person.DOD)) estPts.push(new Point(deathX, person.spouses.length!=0? marY:0));
//			}							
//			node.points = points;
//			node.props.estPts = estPts;	
//		}
		
	}
}