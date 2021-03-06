package genvis.vis.data
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import genvis.data.EvtPt;
	import genvis.data.Person;
	import genvis.geom.Box;
	import genvis.geom.GeomUtil;
	import genvis.geom.Line;
	import genvis.vis.lifeline.Lifeline;
	/**
	 * Visually represents a data element, such as a data tuple or graph node.
	 * By default, NodeSprites are drawn using a <codeShapeRenderer<code>.
	 * NodeSprites are typically managed by a <code>Data</code> object.
	 * 
	 * <p>NodeSprites can separately maintain adjacency lists for both a
	 * general graph structure (managing lists for inlinks and outlinks) and a
	 * tree structure (managing a list for child links and a parent pointer).
	 * The graph and tree lists are maintained completely separately to
	 * maximize flexibility. While the the tree lists are often used to record
	 * a spanning tree of the general network structure, they can also be used
	 * to represent a hierarchy completely distinct from a co-existing graph
	 * structure. Take this into account when iterating over the edges incident
	 * on this node.</p>
	 */
	public class NodeSprite extends DataSprite
	{
		public static const FOCUSED:int		= 1; 
		public static const NON_FOCUSED:int = 0; 
		
		//primary nodes
		public static const ROOT:int			= 0;
		public static const ANCESTOR:int		= 1;
		public static const DESCENDANT:int		= 2;
		//secondary nodes (not part of genealogy of the root)
		public static const SPOUSE:int			= 3; //is there better name for this ?
		public static const UNDETERMINED:int	= 4; 
		//birth edges
		public static const IN_EDGE:int    = 1;
		public static const OUT_EDGES:int   = 2;
		public static const ALL_EDGES:int   = 3;
		
		private var _bbox:Box 			= null;// bounding box;
		private var _lines:Array 		= null;// line segments approximating lifeline
		private var _label:TextSprite	= null;
		private var _type:int			= UNDETERMINED;
		private var _status:int; 
		private var _selected:Boolean	= false;		
		
		private var _doi:Number;		
		//private var _willVisible:Boolean;
		private var _block:BlockSprite = null;
		private var _simplified:Boolean = false;
		//tree
		private var _childNodes:Array = new Array();
		private var _parentNode:NodeSprite;
		private var _pseudoParents:Array = new Array();
		private var _expanded:Boolean   = false;
		private var _visited:Boolean	= false;
		
		//attributes
		private var _attributes:Array = new Array();
		
		//birth edges
		private var _inEdge:EdgeSprite 	= null;
		private var _outEdges:Array		= null;
		
		public function get inEdge():EdgeSprite 	{ return _inEdge; 	}
		public function get outEdges():Array		{ return _outEdges; }
		
		public function addOutEdge(oe:EdgeSprite):void	{ 
			if (_outEdges == null) _outEdges = new Array();
			_outEdges.push(oe);	
		}		
		public function set inEdge(e:EdgeSprite):void { _inEdge = e; }		
		
		public function get childNodes():Array 		{ return _childNodes; }
		public function get pseudoParents():Array	{ return _pseudoParents;	}
		public function get parentNode():NodeSprite { return _parentNode; }
		public function get expanded():Boolean		{ return _expanded;   }
		public function get visited():Boolean		{ return _visited;    }
		public function get selected():Boolean		{ return _selected;	  }		
		
		public function set parentNode(p:NodeSprite):void 	{ _parentNode	= p;  }
		public function set expanded(e:Boolean):void		{ _expanded 	= e;  }
		public function set visited(v:Boolean):void			{ _visited 		= v;  }
		public function set selected(s:Boolean):void		{ _selected		= s;  dirty(); }		
		
		public function get label():TextSprite { return _label; }
		public function get bbox():Box 		{ return _bbox; 	}
		public function get lines():Array 	{ return _lines; 	}
		public function get type():int 		{ return _type;		}
		public function get status():int 	{ return _status;	}
		public function get doi():Number	{ return _doi; 		}
		//public function get willVisible():Boolean { return _willVisible; }
		public function get simplified():Boolean { return _simplified; }
		public function get block():BlockSprite { return _block; }

		public function set label(l:TextSprite):void{ _label	= l;	}
		public function set bbox(box:Box):void 		{ _bbox  	= box;	}
		public function set lines(ls:Array):void 	{ _lines 	= ls; 	}
		public function set type(t:int):void 		{ _type	 	= t;	}
		public function set status(s:int):void 		{ _status	=  s;	}
		public function set doi(d:Number):void		{ _doi 		= d; 	}	 
		//public function set willVisible(v:Boolean):void { _willVisible = v; }
		public function set block(b:BlockSprite):void	{ _block	= b; }	
		
		public function addAttribute(attr:AttributeSprite):void {
			 if (_attributes.indexOf(attr)>=0) return;
			 _attributes.push(attr);
		}
		public function removeAttribute(attr:AttributeSprite):void{
			if (_attributes.indexOf(attr)<0) return;
			_attributes.splice(_attributes.indexOf(attr), 1);
		}
		public function addChildNode(child:NodeSprite):void{
			if (_childNodes.indexOf(child)<0) childNodes.push(child);
		}
		public function addPseudoParent(p:NodeSprite):void{
			if (_pseudoParents.indexOf(p)<0) _pseudoParents.push(p);
		}
		public function simplify():void { 
			_simplified = true;
			//recursively simplify childNodes (may not be necessary if automatically simplified according to doi)
		}			
		public function desimplify():void {
			_simplified = false;
			//recursively desimplify childNodes (may not be necessary if automatically simplified according to doi)
		}
		public function NodeSprite(){			
			_type	= UNDETERMINED;
			_status = NON_FOCUSED;			
		}
		public override function set x(v:Number):void { 
			super.x = v; dirty(); 
		}
		public override function set y(v:Number):void { 
			super.y = v; dirty(); 
		}
		
		public function toLocalX(gx:Number):Number{
			return (gx-(this.x + this.block.x));
		}
		public function toLocalY(gy:Number):Number{
			return (gy-(this.y + this.block.ty));
		}
		public function toGlobalX(lx:Number=0):Number{
			return (lx+(this.x + this.block.x));
		}
		public function toGlobalY(ly:Number=0):Number{
			return (ly+(this.y + this.block.ty));
		}
		public function toLocal(gpt:Point):Point{
			return new Point(toLocalX(gpt.x), toLocalY(gpt.y));
		}
		public function toGlobal(lpt:Point):Point{
			return new Point(toGlobalX(lpt.x), toGlobalY(lpt.y));
		}
		public function calcBBox():Box{		
			if (points == null ||  points.length==0) return null;	//TODO: return Box(0,0,0,0);

			//2. calculate bounding box
				
			var min:Point = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
			var max:Point = new Point(-Number.MAX_VALUE,-Number.MAX_VALUE);
			for each (var pt:EvtPt in points){
				if (pt.x < min.x ) min.x = pt.x;
				if (pt.x > max.x ) max.x = pt.x;
				if (pt.y < min.y ) min.y = pt.y;
				if (pt.y > max.y ) max.y = pt.y;				
			}
			//if (!simplified){
				_lines	= new Array();
				//1. approximate lifeline using linesegments
				for (var i:int = 0; i<(points.length-1); i++){
					_lines.push(new Line(points[i].x, points[i].y, points[i+1].x, points[i+1].y));
				}
				var lineWidth:Number = block.gbLayout.lifeline.lineWidth;
				var miny:Number = 0;
				if (block.gbLayout.lifeline.style == Lifeline.LABELOUTSIDE){
					miny = -(Lifeline.BOTTOMMARGIN + Lifeline.FONTSIZE + Lifeline.TOPMARGIN);
					if (miny < min.y) min.y = miny;
				}else{
					min.y = min.y - lineWidth/2
				}
				max.y = max.y + lineWidth/2;
//			}else{
//				_lines = null;
//			}
			return (_bbox = new Box(min.x, min.y, max.x, max.y));			
		}
//		public function intersect(obj:Object):Boolean{
//			if (obj is NodeSprite){
//				
//			}
//			if (obj is BlockNode){
//				
//			}
//		}
		/**
		 * return # of marrianges
		 **/
		public function overlaps(start:Date, end:Date):int {
			return (0);
		}
		public function evtPt(type:int, data:Object):EvtPt{
			if (points == null || points.length==0) return null;
			for each (var evt:EvtPt in points){
				if (evt.type == type && evt.data == data) return evt;
			}
			return null;
		}
		/**
		 * qx: in global-coord
		 * return y-pos corresponding to the query x-pos
		 **/
		public function Y(qx:Number):Number{
			if (_lines == null || _lines.length == 0) return NaN;
			var lx:Number = toLocalX(qx);
			var ly:Number = NaN;
			for each (var line:Line in _lines){
				ly = GeomUtil.intersectLineX(line, lx);
				if (!isNaN(ly)) break;					
			}	
			return (toGlobalY(ly));
		}
		public function dirtyEdges():void{
			visitEdges(function(e:EdgeSprite):void{
				e.dirty();
			});
		}
		public function dirtyAttributes():void{
			for each (var attr:AttributeSprite in _attributes){
				attr.dirty();
			}
		}
		public function visitEdges(f:Function, opt:int=ALL_EDGES):void
		{
			if (_inEdge && opt!=OUT_EDGES) f(_inEdge);
			if (_outEdges && opt!=IN_EDGE){
				for each (var e:EdgeSprite in _outEdges){
					f(e);
				}
			}
		}
		public function visit(func:Function, depth:Number = Infinity):void{
			if (depth!=Infinity && depth < 0) return;
			else if (depth!=Infinity && depth >= 0) depth--;
			func(this);
			for each (var child:NodeSprite in _childNodes){			
				child.visit(func, depth);
			}
		}
		
		
	} // end of class NodeSprite
}