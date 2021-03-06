package genvis.vis.lifeline
{
	import genvis.data.EvtLine;
	import genvis.data.EvtPt;
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.NodeSprite;
	
	public class Lifeline
	{
		//font size
		public static const FONTSIZE:int	= 14;
		public static const TOPMARGIN:int	= 2;
		public static const BOTTOMMARGIN:int= 1;
		
		//params for lifeline
		public static const ALPHA:int		= 5; //in years, time-span between dating & marriage, divorce & resting
		public static const BETA:int		= 2; //marriage line width
		public static const GAMMA:int		= (TOPMARGIN+FONTSIZE+BOTTOMMARGIN); //y-dist from baseline to marriage line
		public static const DELTA:int		= 3;// in years, time-span between routing points.
		
		//public static const EPSILON:int		= 2; //threshold for ensuring no overlaps between marriage and divorce
		
		//lifeline type
		public static const LINE:uint 		= 0;
		public static const SPLINE:uint 	= 1;
		public static const LINESPLINE:uint	= 2;	
		
		//lifeline style
		public static const LABELINSIDE:uint	= 0;
		public static const LABELOUTSIDE:uint 	= 1;
		//default linewidth
		private static const LINEWIDTH:Number	= 2.5;
		
		protected static const UP:uint	 = 0;
		protected static const DOWN:uint = 1;
		
		protected var _lineWidth:int;
		protected var _style:int;
		protected var _axes:CartesianAxes;
		protected var EPSILON:Number;
		
		public function Lifeline(s:int = Lifeline.LABELINSIDE)
		{
			_style		= s;
			_lineWidth  = s == Lifeline.LABELOUTSIDE? LINEWIDTH : (TOPMARGIN + FONTSIZE + BOTTOMMARGIN);
			EPSILON		= s == Lifeline.LABELOUTSIDE? LINEWIDTH : (TOPMARGIN + FONTSIZE + BOTTOMMARGIN);
		}
		public function get lineWidth():int { return _lineWidth; }
		public function get style():int		{ return _style;	 }
		public function set style(s:int):void {
			_style		= s;
			_lineWidth  = s == Lifeline.LABELOUTSIDE? LINEWIDTH : (TOPMARGIN + FONTSIZE + BOTTOMMARGIN);			
		}
		public function set axes(a:CartesianAxes):void { _axes = a; }
		public function get axes():CartesianAxes { return _axes; }
		
		public function lifeline(n:NodeSprite):void	{	}
		public function lifelineOfSpouse(n:NodeSprite, refNode:NodeSprite):void	{	}
		/**
		 * This function should be called by lifelinelayout and after horizontal positioning of blocks
		 * Currently layout happens around the local focus
		 **/
		public function layout(b:BlockSprite):void{
			if (b.aggregated){//prevent redering nodes in an aggregated block
				b.nodes.forEach(function (n:NodeSprite, idx:int, array:Array):void{
					n.points = new Array();
				});
				b.calcBBox();
				return;
			}
			horizontalPositioning(b);
			verticalPositioning(b);
			generateLifelines(b);
			//generate visual markers for simplified nodes
			//Simplify non-displayed nodes
			var displayList:Array = new Array();
			displayList.push(b.focus);
			for each (var spouse:Person in b.focus.data.spouses){
				displayList.push(spouse.sprite);
			}
			//for other nodes, use simplified representation if possible
			for each (var node:NodeSprite in b.nodes){
				if (displayList.indexOf(node) == -1){
					node.simplify();					
					simplify(node);
				}
			}
			b.calcBBox();			
		}
		/**
		 * Generate Event Points. Their position are relative to the origin of each Node.
		 **/
		public function generateLifelines(block:BlockSprite):void{
			var node:NodeSprite = block.focus;
			var person:Person   = node.data as Person;
			//node.simplified != true? lifeline(node):simplify(node);
			lifeline(node)
			node.calcBBox();
			for each (var spouse:Person in person.spouses){
				//spouse.sprite.simplified!=true? lifelineOfSpouse(spouse.sprite, node):simplify(spouse.sprite);
				lifelineOfSpouse(spouse.sprite, node);
				spouse.sprite.calcBBox();
			}	
		}
		public function simplify(n:NodeSprite):void{
			var person:Person = n.data as Person;
			n.points = new Array();
			for each (var spouse:Person in person.spouses){
				if (spouse.sprite!=null && spouse.sprite.type != NodeSprite.SPOUSE && spouse.sprite.simplified == false){
					//add evtpt at marriage
					var marriages:Array = person.marriageWith(spouse);
					for each (var marriage:Marriage in marriages){
						var x:Number = n.toLocalX(_axes.xAxis.X(marriage.startDate));
						//TODO: fix this or move this function to render
						var y:Number = spouse.sprite.toLocalY(spouse.sprite.Y(n.toGlobalX(x)))+spouse.sprite.y-n.y;
						n.points.push(new EvtPt(x, y, EvtPt.MARRIAGE, marriage.startDate, spouse));
					}
				}
			}
		}
		public function horizontalPositioning(block:BlockSprite):void{
			//TODO: onlde do for displayed nodes
			for each (var node:NodeSprite in block.nodes){
				node.x = axes.xAxis.X(node.data.dateOfBirth)-block.x;
			}
			
		}
		public function verticalPositioning(block:BlockSprite):void{
			//determine spacing between adjacent nodes
			//params: font-size(with top-margin, bottom-margin) + space between marriage lines.
			//drawing order (youngest marriage first, focus last)
			var person:Person = block.focus.data as Person;					
			//1.determine y-position of spouses	
			var noMarEvtPts:Boolean = true;
			for each (var spouse:Person in block.focus.data.spouses){
				if (spouse.sprite.simplified!=true) noMarEvtPts = false;
				else spouse.sprite.y = 0;
			}
			var y:Number 	 = 0;
			var initY:Number = 0;
			if (block.gbLayout.lifeline.style == Lifeline.LABELOUTSIDE){
				initY = (Lifeline.BOTTOMMARGIN + Lifeline.FONTSIZE + Lifeline.TOPMARGIN);						
			}else{
				initY = block.gbLayout.lifeline.lineWidth/2;
			}
			y = initY;
			if (person.spouses.length !=0 && noMarEvtPts==false){
				var dist:Number = Lifeline.GAMMA +_lineWidth;				
				for (var i:int = person.spouses.length-1; i>=0; i--){
					var spouse:Person = person.spouses[i];	
					if (spouse.sprite.simplified) continue;											
					spouse.sprite.y = y;		
					y += dist;	
					 
				}
//				//position first half of spouses above focus
//				for (var i:int = person.spouses.length-1; i>=0; i-=2){
//					var spouse:Person = person.spouses[i];
//					if (spouse.sprite.simplified) continue;
//					spouse.sprite.y = y;
//					y += dist;					
//					//trace("name:"+spouse.name+", y:"+spouse.sprite.y);			
//				}
//				for (i = int(person.spouses.length/2)-1; i>=0; i--){
//					var spouse:Person = person.spouses[i];
//					if (spouse.sprite.simplified) continue;
//					spouse.sprite.y = y;
//					y += dist;
//				}	
				//2.determine y-position of the focus
				//2.1. calculate the maximum number of overapping marriages
				
				var evt:EvtPt;
				var points:Array = new Array();	
				var line:EvtLine;				
				for each (var marriage:Marriage in person.marriages){
					line = marriage.marriageLine();
					if (line){
						points.push(line.start);
						if (line.end) points.push(line.end);	
					}								
				}
				
				points.sortOn("date", Array.NUMERIC);
				var numMar:int = 0;
				var maxMar:int = 0; // # of overlap * beta
				for each (evt in points){
					switch(evt.type){
						case EvtPt.MARRIAGE: 
						numMar++; 
						if (numMar > maxMar) maxMar = numMar;
						break;
						case EvtPt.DIVORCE:	 
						numMar--; 
						break;					 
					}	
				} 				
				
				if (maxMar>1) 	dist = (maxMar-1)*(Lifeline.BETA + _lineWidth);
				else			dist = 0;
				if (y!=initY) y += Lifeline.GAMMA + Lifeline.BETA + _lineWidth + dist;			
				person.sprite.y = y;	
							
//				//position another half of spouses below the focus
//				y += Lifeline.GAMMA + Lifeline.BETA + _lineWidth + dist;
//				for (i=(i==-2?1:0);i<person.spouses.length; i+=2){
//					var spouse:Person = person.spouses[i];
//					if (spouse.sprite.simplified) continue;
//					spouse.sprite.y = y;
//					y += dist;
//					//trace("name:"+spouse.name+", y:"+spouse.sprite.y);
//				}
//				for (var i:int = int(person.spouses.length/2); i<person.spouses.length; i++){
//					var spouse:Person = person.spouses[i];
//					if (spouse.sprite.simplified) continue;
//					spouse.sprite.y = y;
//					y += dist;
//				}
			}else{
				person.sprite.y = y;
			}
		}
		public function aggregate():void {
			
		}

		


	}
}