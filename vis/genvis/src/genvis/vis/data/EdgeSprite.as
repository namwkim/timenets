package genvis.vis.data
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import genvis.data.Person;
	
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
			if (_child.simplified) drawEdge = false;
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
		public function get start():Point{
			var p:Person = _child.data as Person;
			//var marInfo:MarriageInfo = p.father.marriageInfoWith(p.mother);
			var bx:Number = _child.block.gbLayout.xAxis.X(p.dateOfBirth);
			var fy:Number = p.father? p.father.sprite.Y(bx):NaN;
			var my:Number = p.mother? p.mother.sprite.Y(bx):NaN; 
			var by:Number = (isNaN(fy)? my: (isNaN(my)? fy: (fy+my)/2));
			return new Point(bx, by);	//in global coord
		}
		public function get end():Point{
			var p:Person = _child.data as Person;
			var x:Number = _child.block.gbLayout.xAxis.X(p.dateOfBirth);
			var y:Number = _child.toGlobalY(0);
			return new Point(x, y);
		}
		
			
	} // end of class EdgeSprite
}