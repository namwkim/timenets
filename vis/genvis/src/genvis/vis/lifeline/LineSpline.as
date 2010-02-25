package genvis.vis.lifeline
{
	import flare.util.Dates;
	
	import genvis.data.EvtPt;
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.data.NodeSprite;
	
	public class LineSpline extends Lifeline
	{
		public function LineSpline(style:int = Lifeline.LABELINSIDE)
		{
			super(style);
		}		
		public override function lifeline(node:NodeSprite):void{		
			var person:Person    = node.data as Person;
			var points:Array = new Array();	
			//add born point
			var evt:EvtPt = new EvtPt(0, 0, EvtPt.BORN, person.dateOfBirth)
			points.push(evt);
			var dist:Number = (GAMMA+_lineWidth/2);
			
			
			//add marriage and divorce points
			if (person.spouses.length !=0){
				for each (var marriage:Marriage in person.marriages){
					var spouse:Person = marriage.spouseOf(person);
					if (spouse.sprite.simplified == true) continue;
					var dir:Number = (node.y-spouse.sprite.y)>0? UP:DOWN;	
					//marriage point
					var marX:Number = node.toLocalX(axes.xAxis.X(marriage.startDate));
					var marY:Number = dir==UP? -dist:dist;	
//					var datX:Number = node.toLocalX(axes.xAxis.X(Dates.addYears(marInfo.startDate, -ALPHA)));
//					var datY:Number = 0;			
//					evt = new EvtPt(datX, datY, EvtPt.DATING, marInfo.startDate, spouse);
//					points.push(evt);
					evt = new EvtPt(marX, marY, EvtPt.MARRIAGE, marriage.startDate, spouse);
					points.push(evt);
					//divorce point
					if (marriage.divorced){
						var divX:Number = node.toLocalX(axes.xAxis.X(marriage.endDate));
						var divY:Number = dir==UP? -dist:dist;
//						var retX:Number = node.toLocalX(axes.xAxis.X(Dates.addYears(marInfo.endDate, ALPHA)));		
//						var retY:Number = 0;
						evt = new EvtPt(divX, divY, EvtPt.DIVORCE, marriage.endDate, spouse);
						trace(spouse.name);
						points.push(evt);			
//						evt = new EvtPt(retX, retY, EvtPt.RESTING, marInfo.endDate, spouse);
//						points.push(evt);
					}			
				}
			}
			//sort evt points
			points.sortOn("date", Array.NUMERIC);
			var numMar:int = 0;
			for each (evt in points){
				switch(evt.type){
					case EvtPt.MARRIAGE: numMar++; break;
					case EvtPt.DIVORCE:	 numMar--; break;					 
				}	
			}
			//add death point	
			var isDivorced:Boolean = numMar==0? true:false;//person.isDivorced;
			var deathDate:Date = person.deceased? person.dateOfDeath: node.block.gbLayout.curDate;
			var deathX:Number = node.toLocalX(axes.xAxis.X(deathDate));
			var deathY:Number = isDivorced? 0 : (person.spouses.length == 0? 0: (dir==UP? -dist:dist));
			evt = new EvtPt(deathX, deathY, EvtPt.DEAD, deathDate);
			points.push(evt);	
			
			//sort evt points
			points.sortOn("date", Array.NUMERIC);
			//filter redundant event points (necessary for overlaps)
			node.points = new Array();
			var numMar:int = 0;			
			var evtPt:EvtPt = null;
			points.reverse();
			trace("prev len:"+points.length);
			while (evtPt = points.pop()){
				switch(evtPt.type){
					case EvtPt.MARRIAGE: numMar++; if(numMar==1) node.points.push(evtPt); break;
					case EvtPt.DIVORCE:	 numMar--; if(numMar==0) node.points.push(evtPt); break;
					default:	node.points.push(evtPt);
					 
				}				
			}
			trace("next len:"+node.points.length);
			//ensure minimum distance between event points
			var prevPt:EvtPt = null;			
			for (var i:int = 1; i<node.points.length; i++){
				prevPt = node.points[i-1];
				evtPt  = node.points[i];
				var threshold:Number = (evtPt.type == EvtPt.DIVORCE? EPSILON:2*EPSILON);
				if ((evtPt.x-prevPt.x)< threshold){
					evtPt.x = prevPt.x + threshold;
					evtPt.isEstimated = true;
				}
			}
			//allocate dating and resting points
			var nextPt:EvtPt = null;
			for (i= 0; i<node.points.length; i++){
				prevPt = (i-1)>=0? node.points[i-1] : null;
				evtPt  = node.points[i];
				nextPt = (i+1)<node.points.length? node.points[i+1]:null;
				if (evtPt.type == EvtPt.MARRIAGE){
					var datX:Number = evtPt.x - (axes.xAxis.X(evtPt.date) - axes.xAxis.X(Dates.addYears(evtPt.date, -ALPHA)));
					var datY:Number = 0;
					var marThreshold:Number = (prevPt.x+(evtPt.x-prevPt.x)/2);			
					if (datX<marThreshold)	datX = evtPt.isEstimated? (evtPt.x-EPSILON):marThreshold;
					points.push(new EvtPt(datX, datY, EvtPt.DATING, evtPt.date, evtPt.data));
				}
				points.push(evtPt);
				if (evtPt.type == EvtPt.DIVORCE){
					var retX:Number = evtPt.x + (axes.xAxis.X(Dates.addYears(evtPt.date, ALPHA))-axes.xAxis.X(evtPt.date));		
					var retY:Number = 0;
					var divThreshold:Number = (nextPt.x-(nextPt.x-evtPt.x)/2);
					if (retX>divThreshold)	retX = nextPt.isEstimated? (evtPt.x+EPSILON):divThreshold;					
					points.push(new EvtPt(retX, retY, EvtPt.RESTING, evtPt.date, evtPt.data));
				}
			}	
			node.points = points;
		}
		public override function lifelineOfSpouse(node:NodeSprite, refNode:NodeSprite):void{	
			var person:Person    = node.data as Person;
			var refPerson:Person = refNode.data as Person;
			var points:Array = new Array();	
			//add born point
			var evt:EvtPt = new EvtPt(0, 0, EvtPt.BORN, person.dateOfBirth)
			points.push(evt);
			var mergeY:Number = refNode.y-node.y+((node.y-refNode.y)<0?-(GAMMA+BETA+1.5*_lineWidth):(GAMMA+BETA+1.5*_lineWidth));		
			
			var marriages:Array = person.marriageWith(refPerson);
			//var isDivorced:Boolean = person.isDivorced;
			var deathDate:Date = person.deceased? person.dateOfDeath: node.block.gbLayout.curDate;
			var deathX:Number = node.toLocalX(axes.xAxis.X(deathDate));
			var deathY:Number;// = isDivorced? 0 : (person.spouses.length == 0? 0:mergeY);
			//add marriage and divorce points
			//assume that multiple marriages with a single person shouldn't be overlapping
			for each (var marriage:Marriage in marriages){
				var prevEvt:EvtPt=null;
				for each (evt in refNode.points){
					if (evt.date == marriage.startDate){					
						if (evt.type == EvtPt.DATING){
							points.push(new EvtPt(node.toLocalX(refNode.toGlobalX(evt.x)), 0, EvtPt.DATING, marriage.startDate, refPerson));
						}else if (evt.type == EvtPt.MARRIAGE){
							points.push(new EvtPt(node.toLocalX(refNode.toGlobalX(evt.x)), mergeY, EvtPt.MARRIAGE, marriage.startDate, refPerson));
							deathY = mergeY;
						}
					}else if (evt.date == marriage.endDate){
						if (evt.type == EvtPt.DIVORCE){
							points.push(new EvtPt(node.toLocalX(refNode.toGlobalX(evt.x)), mergeY, EvtPt.DIVORCE, marriage.endDate, refPerson));
						}else if (evt.type == EvtPt.RESTING){
							if (deathX< node.toLocalX(refNode.toGlobalX(evt.x))){//if restingX is greater than deathX								
								evt.x 	= prevEvt.x+EPSILON;
								deathX 	= node.toLocalX(refNode.toGlobalX(evt.x)) + EPSILON;
							}
							points.push(new EvtPt(node.toLocalX(refNode.toGlobalX(evt.x)), 0, EvtPt.RESTING, marriage.endDate, refPerson));
							deathY = 0;
						}
					}
					prevEvt = evt;
				}
			}
			
			//add death point	
			points.push(new EvtPt(deathX, deathY, EvtPt.DEAD, deathDate));	
			
			//points.sortOn("date", Array.NUMERIC);
			//ensure minimum distance between event points (only date of death is necessary to check)


			node.points = points;			
		}
//		public override function generateLifeline(node:NodeSprite, marDir:Number, birthLine:Boolean = true, refSpouse:Person = null):void{
//			var points:Array 	= new Array();
//			var estPts:Array = new Array();
//			
//			var person:Person 	= node.data as Person;
//			
//			/////////////////////
//			//born to marriage //
//			/////////////////////
//			var bornX:Number, bornY:Number, marX:Number, marY:Number, dx:Number, deathX:Number, 
//				deathY:Number, divX:Number, divY:Number;
//			bornX = 0;
//			if (birthLine && person.parents.length != 0){	
//				node.props.divPts = new Array();
//				bornY = (person.yorder - (person.father.yorder+person.mother.yorder)/2)*_dy; // need to fix this. if child is diverging from second or later spouse, then this will break
//				node.props.divPts.push(new Point(bornX, bornY));
//				node.props.divPts.push(new Point(0,0));
//			}
//			points.push(new Point(0,0));
//			if (person.isEstimated(Person.DOB)) estPts.push(new Point(0,0));
//			
//			////////////////////////////
//			//divorce and remarriage  //
//			////////////////////////////
//			if (person.spouses.length !=0){
//				var dist:Number, dir:Number;
//				var prevX:Number = bornX, prevY:Number = 0;
//				var curX:Number, curY:Number;
//				var nextX:Number;
//				var span:Number, stack:Number = 0; //keep track of number of marriages
//				if (!refSpouse){
//					dist = (_dy/2-beta);
//				}else{
//					dist = (Math.abs(person.yorder-refSpouse.yorder)-1/2)*_dy - beta;
//				}
//				for (var i:Number = 0; i<person.marEvtPts.length; i++){
//					var evtPt:EvtPt = person.marEvtPts[i];
//					if (refSpouse && refSpouse.id != evtPt.spouse.id) continue;
//					dir 	= person.yorder-evtPt.spouse.yorder;
//					curX 	= _xAxis.X(evtPt.date) - node.x;
//					
//					if (evtPt.type == EvtPt.MARSTART){
//						stack++;
//						curY 	= dir<0? -dist:dist;//dir<0 = UP
//						if (node.props["mar"]!=null){
//							curX = curX + node.props["threshold"];
//							span = _xAxis.X(new Date (evtPt.date.fullYear - alpha,evtPt.date.month, evtPt.date.day)) - node.x;//curX - node.props["mar"];
//						}else{
//							span = _xAxis.X(new Date (evtPt.date.fullYear - alpha,evtPt.date.month, evtPt.date.day)) - node.x;
//						}
//						if (span<prevX) span = prevX;
//						if (refSpouse == null && (curX - span)<gamma){
////							var spouse:Person = evtPt.spouse;
////							spouse.sprite.props["threshold"]	= (gamma-(curX - span));
////							curX = curX + spouse.sprite.props["threshold"];							
////							spouse.sprite.props["mar"] 		= (curX - span)*2;
//						}
//						dx	  	= (curX - span)/3
//						points.push(new Point(curX-3*dx, prevY)); 
//						points.push(new Point(curX-3*dx, prevY));
//						points.push(new Point(curX-2*dx, prevY));
//						points.push(new Point(curX-dx, curY)); 
//						points.push(new Point(curX, curY));
//						points.push(new Point(curX, curY));		
//						prevX = curX;
//						prevY = curY;						
//					}else if (evtPt.type == EvtPt.MAREND){
//						stack--;
//						if (stack != 0 || evtPt.date==null) continue;
//						
//						//derive next evtPt_X
//						if (i<(person.marEvtPts.length-1)){
//							var nextEvtPt:EvtPt = person.marEvtPts[i+1];
//							var secNextX:Number = _xAxis.X(nextEvtPt.date) - node.x;
//							nextX = _xAxis.X(new Date (nextEvtPt.date.fullYear - alpha, nextEvtPt.date.month, nextEvtPt.date.day)) - node.x;
//							if (curX>nextX){
//								nextX = (secNextX-curX)/2 + curX;
//							}
//						}else{
//							nextX = _xAxis.X(person.isDead? person.dateOfDeath:_curDate)-node.x;
//						}
//						curY = 0;
//						if (node.props["div"]!=null){
//							curX = curX - node.props["threshold"];
//							span = _xAxis.X(new Date (evtPt.date.fullYear + alpha, evtPt.date.month, evtPt.date.day)) - node.x;//curX + node.props["div"];//need to be fixed
//						}else{
//							span = _xAxis.X(new Date (evtPt.date.fullYear + alpha, evtPt.date.month, evtPt.date.day)) - node.x;
//						}						
//						if (span>nextX) span = nextX;
//						if (refSpouse == null && (span - curX)<gamma) {
////							var spouse:Person = evtPt.spouse;
////							spouse.sprite.props["threshold"] = (gamma-(span - curX));
////							curX = curX - spouse.sprite.props["threshold"];
////							spouse.sprite.props["div"] = (span - curX)*2;
//						}
//						dx	 = (span - curX)/3;
//						points.push(new Point(curX, prevY)); //dummy point
//						points.push(new Point(curX, prevY));
//						points.push(new Point(curX+dx, prevY));
//						points.push(new Point(curX+2*dx, curY)); 
//						points.push(new Point(curX+3*dx, curY));
//						points.push(new Point(curX+3*dx, curY)); //dummy point		
//						prevX = curX+3*dx;
//						prevY = curY;						
//					}
//
//				}
//
////				var prevX:Number = bornX; 
////				var prevY:Number = 0;
////				var nextX:Number;
////				for each (var marInfo:MarriageInfo in person.marriageInfo){
////					var spouse:Person = marInfo.spouseOf(person);
////					if (refSpouse && refSpouse.id != spouse.id) continue;
////					var dir:Number = person.yorder-spouse.yorder;					
////					marX = _xAxis.X(marInfo.startDate) - node.x;
////					marY = dir<0? -dist:dist;//dir<0 = UP
////					dx	  = ((marX - prevX)/3)/3;
////					points.push(new Point(marX-3*dx, prevY)); 
////					points.push(new Point(marX-3*dx, prevY));
////					points.push(new Point(marX-2*dx, prevY));
////					points.push(new Point(marX-dx, marY)); 
////					points.push(new Point(marX, marY));
////					points.push(new Point(marX, marY));	
////					if (marInfo.isEstimated(MarriageInfo.STARTDATE)) estPts.push(new Point(marX, marY));
////					prevX = marX;
////					prevY = marY;
////					if (marInfo.isDivorced){//divorce 
////						divX = _xAxis.X(marInfo.endDate!=null? marInfo.endDate: _curDate)-node.x;
////						divY = 0;
////						if (person.lastMarriage!=marInfo){
////							var nextMarInfo:MarriageInfo = person.marriageInfo[person.marriageInfo.indexOf(marInfo)+1];
////							nextX = _xAxis.X(nextMarInfo.startDate) - node.x;
////						}else{
////							nextX = _xAxis.X(person.isDead? person.dateOfDeath:_curDate)-node.x;
////						}
////						dx	 = ((nextX - divX)/3)/3;
////						points.push(new Point(divX, prevY)); //dummy point
////						points.push(new Point(divX, prevY));
////						points.push(new Point(divX+dx, prevY));
////						points.push(new Point(divX+2*dx, divY)); 
////						points.push(new Point(divX+3*dx, divY));
////						points.push(new Point(divX+3*dx, divY)); //dummy point	
////						if (marInfo.isEstimated(MarriageInfo.ENDDATE)) estPts.push(new Point(divX, prevY));	
////						prevX = divX;	
////						prevY = divY;			
////					}			
////				}
//			}
//			//marriage to death
//			// death point
//			deathX = _xAxis.X(person.isDead? person.dateOfDeath:_curDate)-node.x;
//			var isDivorced:Boolean = refSpouse==null? person.isDivorced : person.marriageInfoWith(refSpouse).isDivorced;
//			if (isDivorced){
//				points.push(new Point(deathX, 0));
//				if (person.isEstimated(Person.DOD)) estPts.push(new Point(deathX, 0));
//			}else{				
//				points.push(new Point(deathX, person.spouses.length!=0? curY:0));
//				if (person.isEstimated(Person.DOD)) estPts.push(new Point(deathX, person.spouses.length!=0? marY:0));
//			}										
//			node.points = points;
//			node.props.estPts = estPts;	
//		}
	}
}