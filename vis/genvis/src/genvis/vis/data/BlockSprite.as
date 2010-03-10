package genvis.vis.data
{
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	
	import genvis.data.Person;
	import genvis.geom.Box;
	import genvis.vis.operator.layout.LifelineLayout;
	/**
	 * BlockNode is a class to represent local space where local layout happens
	 **/
	public class BlockSprite extends DataSprite
	{		
		public static const ROOT:int			= 0;
		public static const ANCESTOR:int		= 1;
		public static const DESCENDANT:int		= 2;
		public static const UNDETERMINED:int	= 4; 
		
		private var _bbox:Box 					= null;
		private var _primaryNodes:Array 		= null;
		private var _secondaryNodes:Array		= null;
		private var _nodes:Array				= null;
		private var _focus:NodeSprite			= null;
		private var _min:Date					= null;	
		private var _max:Date					= null;	
		private var _gbLayout:LifelineLayout	= null;
		private var _parentBlock:BlockSprite	= null;
		private var _pseudoParents:Array		= null;
		private var _childBlocks:Array			= null;
		private var _blockType:int				= UNDETERMINED;
		private var _aggregated:Boolean			= false;
		private var _selected:Boolean			= false;
		private var _visited:Boolean			= false;
		private var _ty:Number; // temporary y-pos for layout calculation
		private var _tx:Number;
		
		public function get bbox():Box 				{ return _bbox; 			}
		public function get primaryNodes():Array 	{ return _primaryNodes; 	}
		public function get secondaryNodes():Array 	{ return _secondaryNodes;	}
		public function get focus():NodeSprite		{ return _focus;			}		
		public function get min():Date 				{ return _min;				}
		public function get max():Date				{ return _max;				}
		public function get gbLayout():LifelineLayout	{ return _gbLayout;		}
		public function get parentBlock():BlockSprite	{ return _parentBlock;	}
		public function get pseudoParents():Array	{ return _pseudoParents;	}
		public function get childBlocks():Array		{ return _childBlocks;		}
		public function get type():int				{ return _blockType;		}
		public function get aggregated():Boolean	{ return _aggregated;		}
		public function get selected():Boolean		{ return _selected;			}
		public function get visited():Boolean		{ return _visited;			}
		public function get ty():Number				{ return _ty;				}
		public function get tx():Number				{ return _tx;				}
				
		public function set bbox(box:Box):void 				{ _bbox = box;			}
		public function set primaryNodes(pn:Array):void 	{ _primaryNodes = pn; 	}
		public function set secondaryNodes(sn:Array):void 	{ _secondaryNodes = sn;	}
		public function set focus(n:NodeSprite):void 		{ _focus =  n;			}
		public function set gbLayout(g:LifelineLayout):void { _gbLayout = g;		}
		public function set parentBlock(p:BlockSprite):void	{ _parentBlock = p;		}		
		public function set type(t:int):void				{ _blockType = t;		}
		public function set selected(s:Boolean):void		{ _selected	= s;dirty();}
		public function set visited(v:Boolean):void			{ _visited	= v;		}
		public function set ty(y:Number):void				{ _ty = y;				}
		public function set tx(x:Number):void				{ _tx = x;				}
		
		public function set aggregated(a:Boolean):void		{ _aggregated = a;		}
//		/**
//		 * manual layout: visible if _focus.visible is true whicn also means there exists bbox calculated
//		 * automatic layout: visible if aggregated, otherwise nothing to show, so false
//		 */
		public override function get visible():Boolean		{ 
			return (_aggregated || _focus.visible);	
		}
		public function get nodes():Array {	return _nodes;	}
		
		public function addChildBlock(child:BlockSprite):void{
			if (_childBlocks.indexOf(child)<0) _childBlocks.push(child);
		}
		public function addPseudoParent(p:BlockSprite):void{
			if (_pseudoParents.indexOf(p)<0) _pseudoParents.push(p);
		}
						
		public function BlockSprite()
		{
			_primaryNodes 	= new Array();
			_secondaryNodes = new Array();
			_nodes			= new Array();		
			_childBlocks	= new Array();	
			_pseudoParents  = new Array();
			
		}
		public override function set x(v:Number):void { 
			super.x = v; 
			if (_aggregated) dirty();
			for each (var n:NodeSprite in _primaryNodes){
				n.dirtyEdges();	
				n.dirtyAttributes();
			}
			for each (var sn:NodeSprite in _secondaryNodes){
				sn.dirtyAttributes();
			} 
		}
		public override function set y(v:Number):void { 
			super.y = v; 
			if (_aggregated) dirty();
			for each (var n:NodeSprite in _primaryNodes){
				n.dirtyEdges();	
				n.dirtyAttributes();
			}
			for each (var sn:NodeSprite in _secondaryNodes){
				sn.dirtyAttributes();
			} 
		}		
		public function exist(n:NodeSprite):Boolean {
			return _nodes.indexOf(n)==-1? false: true;
		}
		public function addNode(node:NodeSprite):void {
			if (exist(node)==true) return ;
			switch (node.type){
			case NodeSprite.ANCESTOR:	_primaryNodes.push(node);		break;
			case NodeSprite.DESCENDANT: _primaryNodes.push(node); 		break;
			case NodeSprite.ROOT:		_primaryNodes.push(node);		break;
			case NodeSprite.SPOUSE:		_secondaryNodes.push(node);		break;
			break;
			}
			_nodes.push(node);
			//todo choose maximal doi node
			_focus = _focus == null? node : (node.doi > _focus.doi? node:_focus);

			node.block = this;
			this.addChild(node);
			//update min
			var d:Date = node.data.deceased? node.data.dateOfDeath : new Date();
			_min = _min == null? node.data.dateOfBirth:(node.data.dateOfBirth < _min? node.data.dateOfBirth:_min);
			_max = _max == null? d : (d > _max? d:_max);
		}
		
		public static function union(b1:BlockSprite, b2:BlockSprite):BlockSprite {
			if (b1 == null && b2 == null) return null;
			if (b1 == null) return b2;
			if (b2 == null) return b1;
			
			var newBlock:BlockSprite = new BlockSprite();
			
			//1. merge nodes from block 1 and block 2
			var node:NodeSprite = null;
			while (node = b1.primaryNodes.pop()) newBlock.addNode(node);
			while (node = b1.secondaryNodes.pop()) newBlock.addNode(node);

			while (node = b2.primaryNodes.pop()) newBlock.addNode(node);
			while (node = b2.secondaryNodes.pop()) newBlock.addNode(node);			
			
			//2. chooose a local focus among foci of two blocks
			
			//3. determine type of the union block
			if (b1.type == BlockSprite.ROOT){
				newBlock.type = b1.type;
			}else if (b2.type == BlockSprite.ROOT){
				newBlock.type = b2.type;
			}else{
				newBlock.type = b1.type;//assume that ANCESTOR & DESCENDANT BLOCKS don't collapse
			}
			
			return (newBlock);
		}
		public function toLocalX(gx:Number):Number{
			return (gx-(this.x));
		}
		public function toLocalY(gy:Number):Number{
			return (gy-(this.ty));
		}
		public function toGlobalX(lx:Number):Number{
			return (lx+(this.x));
		}
		public function toGlobalY(ly:Number):Number{
			return (ly+(this.ty));
		}
		public function toLocal(lpt:Point):Point{
			return new Point(toLocalX(lpt.x), toLocalY(lpt.y));
		}
		public function toGlobal(gpt:Point):Point{
			return new Point(toGlobalX(gpt.x), toGlobalY(gpt.y));
		}
		/**
		 * intersection between two axis-aligned boxes
		 **/
		public function intersect(b:BlockSprite):Boolean {
			var box1:Box = _bbox;
			var box2:Box = b.bbox;
			var min1:Point = this.toGlobal(box1.min);
			var max1:Point = this.toGlobal(box1.max);
			var min2:Point = b.toGlobal(box2.min);
			var max2:Point = b.toGlobal(box2.max);
			return (min1.x < max2.x) && (max1.x > min2.x) && (min1.y < max2.y) && (max1.y > min2.y);			
		}
		/**
		 * after this function is called, layout has to be re-performed
		 * return false if no longer simplified (aggregated)
		 */
		public function simplify():Boolean{
			var ret:Boolean = false;
			//construct display list
			var displayList:Array = new Array();
			displayList.push(_focus);
			//backward for-loop to maintain ordered spouses
			//i.e. latest spouse is desimplified or simplified first
			for (var i:int=_focus.data.spouses.length-1; i>=0; i--){
				displayList.push(_focus.data.spouses[i].sprite);
			}
			displayList.sortOn("doi", Array.DESCENDING);//ascending order (lowest first)
			
			for each (var n:NodeSprite in displayList){
				if (n.simplified == false){
					n.simplify();
					ret = true;
					break;
				}
			}
			var aggregatable:Boolean = true;
			for each (n in displayList){
				if (n.simplified == false) aggregatable = false;
			}
			if (aggregatable) aggregate();
			return (ret);
		}
		/**
		 * return false if no longer desimplified
		 **/
		public function desimplify():Boolean{
			var ret:Boolean = false; 
			if (_aggregated) _aggregated = false;
			//construct display list
			var displayList:Array = new Array();
			displayList.push(_focus);
			//backward for-loop to maintain ordered spouses
			//i.e. latest spouse is desimplified or simplified first
			for (var i:int=_focus.data.spouses.length-1; i>=0; i--){
				displayList.push(_focus.data.spouses[i].sprite);
			}
			displayList.sortOn("doi");//ascending order (lowest first)
			for each (var n:NodeSprite in displayList){
				if (n.simplified == true){
					n.desimplify();
					ret = true;
					break;
				}
			}
			return (ret);
		}
		/**
		 * 
		 **/
		public function aggregate():void{
			//TODO: make sure to check if all nodes are simplify
			_aggregated = true;
		}
//		public function setVisibility(visible:Boolean):void{
//			for each (var node:NodeSprite in this.nodes){
//				node.visible = visible;
//			}
//		}
		/**
		 * bounding box is in local coordinate of box
		 **/
		public function calcBBox():Box{
			dirty();
			if (_aggregated) return (_bbox=new Box(0,0,0,0));//if aggregated no lifelines are visible.
			//calculate bounding box of each node
			var min:Point = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
			var max:Point = new Point(-Number.MAX_VALUE,-Number.MAX_VALUE);
			for each (var node:NodeSprite in nodes){
				var box:Box = node.bbox;//bbox should have been calculated beforehand
				if (box == null) continue;
				//translate into block space				
				if ((box.min.x + node.x) < min.x ) min.x = (box.min.x + node.x);
				if ((box.max.x + node.x) > max.x ) max.x = (box.max.x + node.x);
				if ((box.min.y + node.y) < min.y ) min.y = (box.min.y + node.y);
				if ((box.max.y + node.y) > max.y ) max.y = (box.max.y + node.y);	
			}			
			return (_bbox = new Box(min.x, min.y, max.x, max.y));
		}
		public function visit(func:Function, depth:Number = Infinity):void{
			if (depth!=Infinity && depth < 0) return;
			else if (depth!=Infinity && depth >= 0) depth--;
			func(this);
			for each (var child:BlockSprite in _childBlocks){
					child.visit(func, depth);
			}
		}
		/**
		 * only works for pedigree tree (binary tree)
		 **/
		public function visitInOrder(func:Function, forward:Boolean = true, depth:Number = Infinity):void{
			if (depth!=Infinity && depth < 0) return;
			else if (depth!=Infinity && depth >= 0) depth--;
			if (_childBlocks.length == 2){			
				forward? _childBlocks[0].visitInOrder(func, forward, depth):_childBlocks[1].visitInOrder(func, forward, depth);
				func(this);
				forward? _childBlocks[1].visitInOrder(func, forward, depth):_childBlocks[0].visitInOrder(func, forward, depth);
			}else if (_childBlocks.length == 1){
				var cb:BlockSprite = _childBlocks[0];
				if (forward){
					if (cb.focus.parentNode.data.gender == Person.MALE) cb.visitInOrder(func, forward, depth);
				}else{
					if (cb.focus.parentNode.data.gender == Person.FEMALE) cb.visitInOrder(func, forward, depth);
				}
				func(this);
				if (forward){
					if (cb.focus.parentNode.data.gender == Person.FEMALE) cb.visitInOrder(func, forward, depth);
				}else{
					if (cb.focus.parentNode.data.gender == Person.MALE) cb.visitInOrder(func, forward, depth);
				}
				
			}else{
				func(this);
			}
		}
	}
}