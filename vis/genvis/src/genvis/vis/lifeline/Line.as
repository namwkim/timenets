package genvis.vis.lifeline
{
	import genvis.data.EvtPt;
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.NodeSprite;
	
	public class Line extends Lifeline
	{
		public function Line(style:int = Lifeline.LABELINSIDE)
		{
			super(style);
		}
		
		
//		public override function lifeline(node:NodeSprite):void{
//			var person:Person    = node.data as Person;
//			var points:Array = new Array();	
//			//add born point
//			var evt:EvtPt = new EvtPt(0, 0, EvtPt.BORN)
//			points.push(evt);
//			var dist:Number = ref == null? (GAMMA+_lineWidth/2):Math.abs(node.y-ref.sprite.y)-(GAMMA+BETA+1.5*_lineWidth);
//			
//			
//			//add marriage and divorce points
//			if (person.spouses.length !=0){
//				for each (var marInfo:MarriageInfo in person.marriageInfo){
//					var spouse:Person = marInfo.spouseOf(person);
//					if (ref && ref.id != marInfo.spouseOf(person).id) continue;
//					var dir:Number = (node.y-spouse.sprite.y)>0? UP:DOWN;	
//					//marriage point
//					var marX:Number = node.toLocalX(axes.xAxis.X(marInfo.startDate));
//					var marY:Number = dir==UP? -dist:dist;				
//					evt = new EvtPt(marX, 0, EvtPt.DATING, marInfo.startDate, spouse);
//					points.push(evt);
//					evt = new EvtPt(marX, marY, EvtPt.MARRIAGE, marInfo.startDate, spouse);
//					points.push(evt);
//					//divorce point
//					if (marInfo.isDivorced){
//						var divX:Number = node.toLocalX(axes.xAxis.X(marInfo.endDate));
//						var divY:Number = dir==UP? -dist:dist;		
//						evt = new EvtPt(divX, divY, EvtPt.DIVORCE, marInfo.endDate, spouse);
//						points.push(evt);			
//						evt = new EvtPt(divX, 0, EvtPt.RESTING, marInfo.endDate, spouse);
//						points.push(evt);
//					}				
//				}
//			}
//			//add death point	
//			var isDivorced:Boolean = ref==null? person.isDivorced: person.marriageInfoWith(ref).isDivorced;
//			var deathX:Number = node.toLocalX(axes.xAxis.X(person.isDead? person.date_of_death: new Date()));
//			var deathY:Number = isDivorced? 0 : (person.spouses.length == 0? 0: (dir==UP? -dist:dist));
//			evt = new EvtPt(deathX, deathY, EvtPt.DEAD);
//			points.push(evt);	
//			//rearrange evt points 
//			node.points = points;	
//		}
//		public override function lifelineOfSpouse(node:NodeSprite, refNode:NodeSprite):void{
//			
//		}
//		public override function generateLifeline(node:NodeSprite, marDir:Number, birthLine:Boolean = true, refSpouse:Person = null):void{
//			var points:Array = new Array();
//			var estPts:Array = new Array();
//			
//			var person:Person = node.data as Person;
//			//born to marriage
//			var bornX:Number, bornY:Number, marX:Number, marY:Number, dx:Number, deathX:Number, 
//				deathY:Number, divX:Number, divY:Number;
//			bornX = 0;
//			if (birthLine && person.parents.length != 0){	
//				node.props.divPts = new Array();
//				bornY = (person.yorder - (person.father.yorder+person.mother.yorder)/2)*_dy;		
//				node.props.divPts.push(new Point(bornX, bornY));
//				node.props.divPts.push(new Point(0,0));
//				
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
//				for each (var marInfo:MarriageInfo in person.marriageInfo){
//					var spouse:Person = marInfo.spouseOf(person);
//					if (refSpouse && refSpouse.id != marInfo.spouseOf(person).id) continue;
//					var dir:Number = person.yorder-spouse.yorder;					
//					marX = _xAxis.X(marInfo.startDate) - node.x;
//					marY = dir<0? -dist:dist;//dir<0 = UP
//					points.push(new Point(marX, prevY));
//					points.push(new Point(marX, marY));	
//					if (marInfo.isEstimated(MarriageInfo.STARTDATE)) estPts.push(new Point(marX, marY));
//					prevY = marY;					
//					if (marInfo.isDivorced){//divorce 
//						divX = _xAxis.X(marInfo.endDate!=null? marInfo.endDate: _curDate)-node.x;
//						divY = 0;
//						points.push(new Point(divX, prevY));
//						points.push(new Point(divX, divY)); //dummy point
//						if (marInfo.isEstimated(MarriageInfo.ENDDATE)) estPts.push(new Point(divX, prevY));		
//						prevY = divY;
//										
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
//			node.points 		= points;	
//			node.props.estPts 	= estPts;	
//		}
		
	}
}