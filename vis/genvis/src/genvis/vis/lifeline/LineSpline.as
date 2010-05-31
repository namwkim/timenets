package genvis.vis.lifeline
{
	import flare.util.Dates;
	
	import genvis.data.EvtLine;
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
					//if (spouse.sprite.simplified == true) continue;
					var dir:Number = (node.y-spouse.sprite.y)>0? UP:DOWN;	
					//marriage point
					var marX:Number = node.toLocalX(axes.xAxis.X(marriage.startDate));
					var marY:Number = dir==UP? -dist:dist;	
//					var datX:Number = node.toLocalX(axes.xAxis.X(Dates.addYears(marInfo.startDate, -ALPHA)));
//					var datY:Number = 0;			
//					evt = new EvtPt(datX, datY, EvtPt.DATING, marInfo.startDate, spouse);
//					points.push(evt);
					evt = new EvtPt(marX, marY, EvtPt.MARRIAGE, marriage.startDate, marriage);
					points.push(evt);
					//divorce point
					if (marriage.divorced){
						var divX:Number = node.toLocalX(axes.xAxis.X(marriage.endDate));
						var divY:Number = dir==UP? -dist:dist;
//						var retX:Number = node.toLocalX(axes.xAxis.X(Dates.addYears(marInfo.endDate, ALPHA)));		
//						var retY:Number = 0;
						evt = new EvtPt(divX, divY, EvtPt.DIVORCE, marriage.endDate, marriage);
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
			//points.sortOn("date", Array.NUMERIC);
			//filter redundant event points (necessary for overlaps)
			node.points = new Array();
			numMar = 0;			
			var evtPt:EvtPt = null;
			points.reverse();
			//trace("prev len:"+points.length);
			while (evtPt = points.pop()){
				switch(evtPt.type){
					case EvtPt.MARRIAGE: numMar++; 
						if(numMar==1) node.points.push(evtPt); 
						break;
					case EvtPt.DIVORCE:	 numMar--; 
						if(numMar==0) node.points.push(evtPt); 
						break;
					default:	node.points.push(evtPt);
					 
				}				
			}
			
			//ensure minimum distance between event points
			var prevPt:EvtPt = null;
			var threshold:Number;			
			for (var i:int = 1; i<node.points.length; i++){
				prevPt = node.points[i-1];
				evtPt  = node.points[i];
				//var threshold:Number = (evtPt.type == EvtPt.DIVORCE? 0:2*EPSILON);//threshold distance between marriage & divorce events = 0
				if (prevPt.type == EvtPt.BORN || evtPt.type == EvtPt.DEAD)
					threshold = EPSILON;
				else if (evtPt.type == EvtPt.DIVORCE)
					threshold = 0;
				else
					threshold = 2*EPSILON;
				if ((evtPt.x-prevPt.x)< threshold){
					evtPt.x = prevPt.x + threshold;
					//evtPt.perturbed = true;
				}
			}
			//allocate dating and resting points 
			var nextPt:EvtPt = null;
			for (i= 0; i<node.points.length; i++){
				prevPt = (i-1)>=0? node.points[i-1] : null;
				evtPt  = node.points[i];
				nextPt = (i+1)<node.points.length? node.points[i+1]:null;
				if (evtPt.type == EvtPt.MARRIAGE){
					var datX:Number =node.toLocalX(axes.xAxis.X(Dates.addYears(evtPt.date, -ALPHA)));
					var datY:Number = 0;
					var marThreshold:Number = (prevPt.type==EvtPt.BORN? prevPt.x : ((prevPt.x+evtPt.x)*(1/2)) );//(evtPt.x-prevPt.x)/2);			
					if (datX<marThreshold)	datX = marThreshold;//evtPt.perturbed? (evtPt.x-EPSILON):marThreshold;
					points.push(new EvtPt(datX, datY, EvtPt.DATING, evtPt.date, evtPt.data));
				}
				points.push(evtPt);
				if (evtPt.type == EvtPt.DIVORCE){
					var retX:Number = node.toLocalX(axes.xAxis.X(Dates.addYears(evtPt.date, ALPHA)));		
					var retY:Number = 0;
					var divThreshold:Number = (nextPt.type==EvtPt.DEAD? nextPt.x : ((nextPt.x+evtPt.x)*(1/2)) );//-(nextPt.x-evtPt.x)/2);
					if (retX>divThreshold)	retX = divThreshold;//nextPt.perturbed? (evtPt.x+EPSILON):divThreshold;					
					points.push(new EvtPt(retX, retY, EvtPt.RESTING, evtPt.date, evtPt.data));
				}
			}	
			node.points = points;
			//construct maps to be used when deriving render-points of spouses
			datMap = new Object();
			marMap = new Object();
			divMap = new Object();
			retMap = new Object();
			for each (evtPt in node.points){
				switch (evtPt.type){
					case EvtPt.DATING: 		datMap[evtPt.data.id] = evtPt;	break;
					case EvtPt.MARRIAGE:	marMap[evtPt.data.id] = evtPt;	break;
					case EvtPt.DIVORCE:		divMap[evtPt.data.id] = evtPt;	break;
					case EvtPt.RESTING:		retMap[evtPt.data.id] = evtPt;	break;
				}
			}
		}
		private static var datMap:Object;
		private static var marMap:Object;
		private static var divMap:Object;
		private static var retMap:Object;
		
		public static const START:int 	= 0;
		public static const	END:int		= 1;
		public function findIntersectingMarriages(refMarriage:Marriage, type:int, marriages:Array):Array{
			var intersects:Array =  new Array();
			var evtLine:EvtLine = refMarriage.marriageLine();			
			for each (var marriage:Marriage in marriages){
				if (refMarriage==marriage ||(marriage.startDate > evtLine.start.date)) continue;				
				var intersect:EvtLine = marriage.marriageLine();
				if (type == START){
					if (intersect.end == null || intersect.end.date>=evtLine.start.date){
						intersects.push(marriage);
					}
				}else{					
					if (intersect.end == null || (evtLine.end!=null && intersect.end.date>=evtLine.end.date)){
						intersects.push(marriage);
					}
				}
			}	
			return intersects;		
		}
//		public function findRoutingPoints(refMarriage:Marriage, marriages:Array):Array{
//			var routes:Array = new Array();
//			var evtLine:EvtLine = refMarriage.marriageLine();
//			for each (var marriage:Marriage in marriages){
//				if (refMarriage==marriage||(marriage.startDate.time > evtLine.start.date.time)) continue;	
//				var intersect:EvtLine = marriage.marriageLine();
//				if (intersect.end.date !=null && intersect.end.date > evtLine.start.date){
//					
//				}
//			}
//			return (routes);
//		}
		public override function lifelineOfSpouse(node:NodeSprite, refNode:NodeSprite):void{	
			var person:Person    = node.data as Person;
			var refPerson:Person = refNode.data as Person;
			var points:Array = new Array();	
			//add born point
			var evtPt:EvtPt = new EvtPt(0, 0, EvtPt.BORN, person.dateOfBirth)
			if (!node.simplified) points.push(evtPt);//draw only marriage lines for simplified nodes
			var dir:Number = (refNode.y<node.y)?  UP:DOWN;
			var baseY:Number = refNode.y-node.y+(dir==DOWN?-(GAMMA+BETA+1.5*_lineWidth):(GAMMA+BETA+1.5*_lineWidth));					
			var marriages:Array = person.marriageWith(refPerson);			
			
			var deathDate:Date = person.deceased? person.dateOfDeath: node.block.gbLayout.curDate;
			var deathX:Number = node.toLocalX(axes.xAxis.X(deathDate));
			var deathY:Number;// = isDivorced? 0 : (person.spouses.length == 0? 0:mergeY);
			var i:uint;
			//assume that multiple marriages with a single person shouldn't be overlapping
			for each (var marriage:Marriage in marriages){
				if (marriage.spouseOf(person) != refPerson) continue;
				//1. find a starting y-position				
				var startMars:Array = findIntersectingMarriages(marriage, START, refPerson.marriages);
				//2. find a ending y-position
				var endMars:Array = findIntersectingMarriages(marriage, END, refPerson.marriages);				
				//3. if #1 and #2 are different, find routing dates
				var routes:Array;
				if (startMars.length != endMars.length){
					//3.1. Find rounting points
					routes = new Array();
					for each (var sMar:Marriage in startMars){
						if (endMars.length==0 || endMars.indexOf(sMar)<0)	routes.push(sMar.marriageLine().end.date);
					}
				}				
				//4. marriage point & dating point
				var key:String = (startMars.length==0? marriage.id:startMars[0].id);
				var refMarX:Number 	= node.toLocalX(refNode.toGlobalX(marMap[key].x));
				var dateSpan:Number = refMarX - node.toLocalX(refNode.toGlobalX(datMap[key].x));
				//4.1. if this is the first marriage among those overlapping, use refPerson's marriage-point (because of perturbation)
				var marX:Number = startMars.length==0? refMarX : node.toLocalX(axes.xAxis.X(marriage.startDate));
				var marY:Number = baseY+(dir==DOWN?-(startMars.length*(BETA+_lineWidth)):(startMars.length*(BETA+_lineWidth)));				
				var marPt:EvtPt = new EvtPt(marX, marY, EvtPt.MARRIAGE, marriage.startDate, refPerson);
				//4.2. use same datespan as the first marriage
				var datX:Number = marX - dateSpan;//node.toLocalX(axes.xAxis.X(Dates.addYears(marEvt.date, -ALPHA)));
				//if (datX<0) datX = 0;
				var datY:Number	= node.simplified? (marY+(dir==DOWN? -Lifeline.GAMMA:Lifeline.GAMMA)):0;
				var datPt:EvtPt = new EvtPt(datX, datY, EvtPt.DATING, marriage.startDate, refPerson);
				points.push(datPt);
				points.push(marPt);
				
				//5. routing points
				if (routes){
					routes.sort(Array.NUMERIC);
					for (i=0; i<routes.length; i++){
						var rouX:Number = node.toLocalX(axes.xAxis.X(routes[i]));
						var rouY:Number = marY + (dir==DOWN? ((i)*(BETA+_lineWidth)):-((i)*(BETA+_lineWidth)));
						points.push(new EvtPt(rouX, rouY, EvtPt.ROUTESTART, routes[i]));
						rouX = node.toLocalX(axes.xAxis.X(Dates.addYears(routes[i], DELTA)));
						rouY = marY + (dir==DOWN? ((i+1)*(BETA+_lineWidth)):-((i+1)*(BETA+_lineWidth)));
						points.push(new EvtPt(rouX, rouY, EvtPt.ROUTEEND, routes[i]));
						
					}
				}
				//6. ending point & resting pointif necessary
				deathY = baseY+(dir==DOWN?-(endMars.length*(BETA+_lineWidth)):(endMars.length*(BETA+_lineWidth)));;
				if (marriage.divorced){
					key = (endMars.length==0? marriage.id:endMars[0].id);										
					var refDivX:Number	= divMap[key]!=null?node.toLocalX(refNode.toGlobalX(divMap[key].x)):NaN;
					var restSpan:Number	= retMap[key]!=null?(retMap[key].x-divMap[key].x):NaN;					
					var divX:Number = (endMars.length==0 && !isNaN(refDivX))? refDivX:node.toLocalX(axes.xAxis.X(marriage.endDate));
					var divY:Number = deathY;
					var divPt:EvtPt = new EvtPt(divX, divY, EvtPt.DIVORCE, marriage.endDate, refPerson);
					
					var resX:Number = isNaN(restSpan)? node.toLocalX(axes.xAxis.X(Dates.addYears(divPt.date, ALPHA))):(divX + restSpan);
					//if (resX > deathX) resX = deathX;
					var resY:Number = node.simplified? (divY+(dir==DOWN? -Lifeline.GAMMA:Lifeline.GAMMA)):0;
					var resPt:EvtPt = new EvtPt(resX, resY, EvtPt.RESTING, marriage.endDate, refPerson);
					points.push(divPt);
					points.push(resPt);	
					deathY = 0;				
				}
			}
			//add death point				
			if (!node.simplified || deathY!=0) points.push(new EvtPt(deathX, deathY, EvtPt.DEAD, deathDate));	
			//All the render-points are added in order, but their actual coordinates are probably out of order

			node.points = points;
			//ensure minimum distance between event points 
			//TODO: ensure perturbed points are in sync with corresponding points of the reference person: they should be within the span of the marriage at the bottom
			var nextPt:EvtPt;
			var threshold:Number = EPSILON;
			//First Pass on normal events points

			//Second Pass on dummy points
			for (i=1; i<(node.points.length-1); i++){		
				evtPt  = node.points[i];
				nextPt = node.points[i+1];
				
				if (evtPt.type == EvtPt.ROUTEEND){
					//1. route end & route start - best remove the two points
					//2. route end & death - set route end to death
					//3. route end & div - set route end to div
					//Comment: For #1 and #2, type of nextPt should be changed to ROUTEEND...
					if (nextPt.x <evtPt.x){
						if (nextPt.type == EvtPt.ROUTESTART){
							node.points.splice(i, 2);
						}else{
							evtPt.x = nextPt.x;
						}					
					}

				}else{
					//all possible cases
					//1. born - dat - nothing
					//2. dat - mar - maintain threshold
					//3. mar - div - nothing
					//3. div - ret - maintain threshold
					//4. ret - dat - can be merged
					//5. ret - death - can be merged
					//6. born - death
					//7. mar - death

					if (evtPt.type == EvtPt.RESTING && nextPt.type == EvtPt.DATING){//need special treatment
						if (nextPt.x >= evtPt.x) continue;
						var prevPt:EvtPt 	= node.points[i-1];
						var nextNextPt:EvtPt 	= node.points[i+2];
						threshold = 2*EPSILON;
						if ((nextNextPt.x - prevPt.x)<threshold){
							nextNextPt.x = prevPt.x + threshold;							
						}
						var midX:Number = (nextNextPt.x + prevPt.x)*(1/2);
						evtPt.x = nextPt.x = midX;	
						i+=2;//skip next two points					
					}else{
						
						if (evtPt.type == EvtPt.BORN || evtPt.type == EvtPt.MARRIAGE || evtPt.type == EvtPt.RESTING) 
							threshold = 0;
						else 
							threshold = EPSILON;
						if ((nextPt.x-evtPt.x)< threshold){
							nextPt.x = evtPt.x + threshold;
						}
					}
				}
			}
					
		}
	}
}