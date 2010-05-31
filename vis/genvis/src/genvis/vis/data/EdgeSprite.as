package genvis.vis.data
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.lifeline.Lifeline;
	
	/**
	 * Visually represents a connection between two data elements. Examples
	 * include an edge in a graph structure or a line between points in a line
	 * chart. EdgeSprites maintain <code>source</code> and <code>target</code>
	 * properties for accessing the NodeSprites connected by this edge. By
	 * default, EdgeSprites are drawn using an <code>EdgeRenderer</code>.
	 * EdgeSprites are typically managed by a <code>Data</code> object.
	 */
	public class EdgeSprite extends DataSprite
	{		
		public static const UP:uint		= 1;
		public static const DOWN:uint	= 2;
		// -- Properties ------------------------------------------------------		
		private var _parents:Array;
		private var _child:NodeSprite;
		private var _doi:Number;
		private var _draw:Boolean = true;
		// -- Methods ---------------------------------------------------------
		public function get child():NodeSprite 		{ return _child;	}
		public function get parents():Array 		{ return _parents; 	}
		public function get doi():Number			{ return _doi; 		}		
		public function set doi(d:Number):void		{ _doi 		= d; 	}			
		
		public function get draw():Boolean	{
			var drawEdge:Boolean = false;
			if (_child.simplified) return false;
			for (var i:uint=0; i<_parents.length; i++){
				if (_parents[i].simplified==false){
					drawEdge = true;
					break;
				} 
			}			
			return drawEdge;
		}
		/**
		 * Creates a new EdgeSprite.
		 * @param source the source node
		 * @param target the target node
		 * @param directed true for a directed edge, false for undirected
		 */		
		public function EdgeSprite(father:NodeSprite, mother:NodeSprite, child:NodeSprite, data:Object = null)
		{
			_parents = new Array();
			if (father){
				_parents.push(father);
				father.addOutEdge(this);
			}
			if (mother){
				mother.addOutEdge(this);
				_parents.push(mother);
			}			
			_child	= child;	
			child.inEdge = this;
			this.data	= data;
		}
		public function get outOfWedlock():Boolean{
			var within:Boolean = false;
			var p:Person = _child.data as Person;
			if (p.father && p.mother){
				//1. if child's birth is within marriage date				
				var marriages:Array = p.father.marriageWith(p.mother);
				for each (var marriage:Marriage in marriages){
					if (p.dateOfBirth>marriage.startDate && (!marriage.divorced || p.dateOfBirth<marriage.endDate)){
						within = true;
					}	
				}				
			}else{
				return false;
			}
				
			return (!within);		
		}
		public function get direction():uint{
			var py:Number = _parents[0].toGlobalY();
			var cy:Number = _child.toGlobalY();
			return (py>cy? UP:DOWN);
		}
		/**
		 * should be called when within returns true, which means always two parents 
		 * return two starting points
		 **/
		public function get startOutOfWedlock():Array{
			var p:Person = _child.data as Person;
			var pts:Array = new Array();
			var bx:Number = _child.block.gbLayout.xAxis.X(p.dateOfBirth);
			if (_parents.length==2){
				var fy:Number = p.father.sprite.Y(bx);
				var my:Number = p.mother.sprite.Y(bx);
				if (fy>my){
					pts.push(new Point(bx, my));
					pts.push(new Point(bx, fy));				
				}else{
					pts.push(new Point(bx, fy));
					pts.push(new Point(bx, my));				
				}
			}else if (_parents.length==1){
				var y:Number = _parents[0].Y(bx);
				pts.push(new Point(bx, y));
			}else{
				pts.push(new Point(bx, 0));
			}
			return (pts);
						
		}
		public function get start():Point{
			var p:Person = _child.data as Person;
			//var marInfo:MarriageInfo = p.father.marriageInfoWith(p.mother);
			var bx:Number = _child.block.gbLayout.xAxis.X(p.dateOfBirth);
			//find non-focus parent
			var nfParent:NodeSprite;			
			for each (var parent:NodeSprite in _parents){
				if (parent.block.focus!=parent){
					nfParent = parent; break;
				}
			}			
			var y:Number;
			if (nfParent){
				y = nfParent.Y(bx);
				y += nfParent.block.gbLayout.lifeline.lineWidth/2+Lifeline.BETA/2;
			}else if (_parents.length>0){
				y = _parents[0].Y(bx);
			}else{
				y = 0;
			}
//			var my:Number = p.mother? p.mother.sprite.Y(bx):NaN;
//			var by:Number = (isNaN(fy)? my: (isNaN(my)? fy: (fy+my)/2));
			return new Point(bx, y);	//in global coord
		}
		
		public function get end():Point{
			var p:Person = _child.data as Person;
			var x:Number = _child.block.gbLayout.xAxis.X(p.dateOfBirth);
			var y:Number = _child.toGlobalY(0);
			return new Point(x, y);
		}
		
			
	} // end of class EdgeSprite
}