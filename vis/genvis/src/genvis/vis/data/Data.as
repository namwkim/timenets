package genvis.vis.data
{
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.events.DataEvent;
	
	import flash.events.EventDispatcher;
	
	import genvis.data.Person;
	
	[Event(name="add",    type="flare.vis.events.DataEvent")]
	[Event(name="remove", type="flare.vis.events.DataEvent")]
	
	/**
	 * Data structure for managing a collection of visual data objects. The
	 * Data class manages both unstructured data and data organized in a
	 * general graph (or network structure), maintaining collections of both
	 * nodes and edges. Collections of data sprites are maintained by
	 * <code>DataList</code> instances. The individual data lists provide
	 * methods for accessing, manipulating, sorting, and generating statistics
	 * about the visual data objects.
	 * 
	 * <p>In addition to the required <code>nodes</code> and <code>edges</code>
	 * lists, clients can add new custom lists (for example, to manage a
	 * selected subset of the data) by using the <code>addGroup</code> method
	 * and then accessing the list with the <code>group</code> method.
	 * Individual data groups can be directly processed by many of the
	 * visualization operators in the <code>flare.vis.operator</code> package.
	 * </p>
	 * 
	 * <p>While Data objects maintain a collection of visual DataSprites,
	 * they are not themselves visual object containers. Instead a Data
	 * instance is used as input to a <code>Visualization</code> that
	 * is responsible for processing the DataSprite instances and adding
	 * them to the Flash display list.</p>
	 * 
	 * <p>The data class also manages the automatic generation of spanning
	 * trees over a graph when needed for tree-based operations (such as tree
	 * layout algorithms). This implemented by a
	 * <code>flare.analytics.graph.SpanningTree</code> operator which can be
	 * parameterized using the <code>treePolicy</code>,
	 * <code>treeEdgeWeight</code>, and <code>root</code> properties of this
	 * class. Alternatively, clients can create their own spanning trees as
	 * a <code>Tree</code instance and set this as the spanning tree.</p>
	 * 
	 * @see flare.vis.data.DataList
	 * @see flare.analytics.graph.SpanningTree
	 */
	public class Data extends EventDispatcher
	{
		/** Constant indicating the nodes in a Data object. */
		public static const NODES:String 	= "nodes";
		public static const EDGES:String	= "edges";
		public static const BLOCKS:String 	= "blocks";

		/** Internal list of NodeSprites. */
		protected var _root:Person;
		protected var _nodes:DataList 	= new DataList(NODES);
		protected var _edges:DataList 	= new DataList(EDGES);
		protected var _blocks:DataList 	= new DataList(BLOCKS);

		/** The total number of items (nodes and edges) in the data. */
		public function get length():int { return _nodes.length; }
		
		/** Internal set of data groups. */
		protected var _groups:Object;
		
		/** The collection of NodeSprites. */
		public function get nodes():DataList { return _nodes; }
		public function get edges():DataList { return _edges; }
		public function get blocks():DataList { return _blocks; }
		public function get root():Person { return _root; }

		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new Data instance.
		 * @param directedEdges the default directedness of new edges
		 */
		public function Data(root:Person) {
			constructNodes(root);
			constructEdges(root);
			constructDOITree(root);	
			constructBlocks(root);			
			
			_root	= root;
			_groups = { nodes: _nodes, edges: _edges, blocks: _blocks};
		}
		// -- Group Management ---------------------------------
		
		/**
		 * Adds a new data group. If a group of the same name already exists,
		 * it will be replaced, except for the groups "nodes" and "edges",
		 * which can not be replaced. 
		 * @param name the name of the group to add
		 * @param group the data list to add, if null a new,
		 *  empty <code>DataList</code> instance will be created.
		 * @return the added data group
		 */
		public function addGroup(name:String, group:DataList=null):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			if (group==null) group = new DataList(name);
			_groups[name] = group;
			return group;
		}
		
		/**
		 * Removes a data group. An error will be thrown if the caller
		 * attempts to remove the groups "nodes" or "edges". 
		 * @param name the name of the group to remove
		 * @return the removed data group
		 */
		public function removeGroup(name:String):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			var group:DataList = _groups[name];
			if (group) delete _groups[name];
			return group;
		}
		
		/**
		 * Retrieves the data group with the given name. 
		 * @param name the name of the group
		 * @return the data group
		 */
		public function group(name:String):DataList
		{
			return _groups[name] as DataList;
		}

		


		/**
		 * Indicates if this Data object contains the input DataSprite.
		 * @param d the DataSprite to check for containment
		 * @return true if the sprite is in this data collection, false
		 *  otherwise.
		 */
		public function contains(d:DataSprite):Boolean
		{
			return (_nodes.contains(d));
		}
		
		// -- Add ----------------------------------------------
		
		/**
		 * Adds a node to this data collection.
		 * @param d either a data tuple or NodeSprite object. If the input is
		 *  a non-null data tuple, this will become the new node's
		 *  <code>data</code> property. If the input is a NodeSprite, it will
		 *  be directly added to the collection.
		 * @return the newly added NodeSprite
		 */
		public function addNode(d:Object=null):NodeSprite
		{
			var ns:NodeSprite = NodeSprite(d is NodeSprite ? d : newNode(d));
			if (_nodes.contains(ns)==false)
				_nodes.add(ns);
			return ns;
		}
		
		
		/**
		 * Internal function for creating a new node. Creates a NodeSprite,
		 * sets its data property, and applies default values.
		 * @param data the new node's data property
		 * @return the newly created node
		 */
		protected function newNode(data:Object):NodeSprite
		{
			var ns:NodeSprite = new NodeSprite();
			_nodes.applyDefaults(ns);
			if (data != null) { ns.data = data; }
			return ns;
		}
		
	
		/**
		 * Clears this data set, removing all nodes and edges.
		 */
		public function clear():void
		{
			_nodes.clear();
			_edges.clear();
			_blocks.clear();			
		}
		
		/**
		 * Removes a DataSprite (node or edge) from this data collection.
		 * @param d the DataSprite to remove
		 * @return true if removed successfully, false if not found
		 */
		public function remove(d:DataSprite):Boolean
		{
			if (d is NodeSprite) return removeNode(d as NodeSprite);
			if (d is EdgeSprite) return removeEdge(d as EdgeSprite);
			if (d is BlockSprite) return removeBlock(d as BlockSprite);
			return false;
		}
				
		/**
		 * Removes a node from this data set. All edges incident on this
		 * node will also be removed. If the node is not found in this
		 * data set, the method returns null.
		 * @param n the node to remove
		 * @returns true if sucessfully removed, false if not found in the data
		 */
		public function removeNode(n:NodeSprite):Boolean
		{
			return _nodes.remove(n);
		}
		public function removeEdge(e:EdgeSprite):Boolean
		{
			return _edges.remove(e);
		}
		public function removeBlock(b:BlockSprite):Boolean
		{
			return _blocks.remove(b);
		}
		// -- Visitors -----------------------------------------
		
		/**
		 * Visit items, invoking a function on all visited elements.
		 * @param v the function to invoke on each element. If the function
		 *  return true, the visitation is ended with an early exit
		 * @param group the data group to visit (e.g., NODES or EDGES). If this
		 *  value is null, both nodes and edges will be visited.
		 * @param filter an optional predicate function indicating which
		 *  elements should be visited. Only items for which this function
		 *  returns true will be visited.
  		 * @param reverse an optional parameter indicating if the visitation
		 *  traversal should be done in reverse (the default is false).
		 * @return true if the visitation was interrupted with an early exit
		 */
		public function visit(v:Function, group:String=null,
			filter:*=null, reverse:Boolean=false):Boolean
		{
			if (group == null) {
				if (_nodes.length > 0 && _nodes.visit(v, filter, reverse))
					return true;
				if (_blocks.length > 0 && _blocks.visit(v, filter, reverse))
					return true;
				if (_edges.length > 0 && _edges.visit(v, filter, reverse))
					return true;
			}else {
				var list:DataList = _groups[group];
				if (list.length > 0 && list.visit(v, filter, reverse))
					return true;
			}
			return false;
		}
		public function constructNode(person:Person, type:int):NodeSprite{
			var ns:NodeSprite  = person.sprite == null? this.addNode(person) : this.addNode(person.sprite);
			ns.type = type;
			person.sprite = ns;

			for each (var spouse:Person in person.spouses){
				spouse.sprite		= spouse.sprite==null? this.addNode(spouse) : this.addNode(spouse.sprite);
				spouse.sprite.type  = NodeSprite.SPOUSE;
			}
			return ns;
		}
		//static methods
		/**
		 * construct display list. this also initializes node types
		 * node type: ancestor, descendant, root, 
		 **/
		protected function constructNodes(root:Person):void{
			//1. root
			constructNode(root, NodeSprite.ROOT);			
			//construct hourglass chart with spouses
			//2. ancestor side
			root.visitAncestors(function (p:Person):void{
				constructNode(p, NodeSprite.ANCESTOR);
				p.sprite.type = NodeSprite.ANCESTOR; //force the type				
			});
			//3. descendant side
			root.visitDecendants(function (p:Person):void{
				constructNode(p, NodeSprite.DESCENDANT);
				p.sprite.type = NodeSprite.DESCENDANT; //force the type			
			});	
		}
		protected function constructEdge(person:Person):void{
			//if (person.parents.length != 2) return;
			var e:EdgeSprite = new EdgeSprite(person.father? person.father.sprite:null, person.mother?person.mother.sprite:null, person.sprite);
			_edges.add(e);
		}
		protected function constructEdges(root:Person):void{
			//1. root
			constructEdge(root);			
			//2. ancestor side
			root.visitAncestors(function (p:Person):void{
				constructEdge(p);								
			});
			//3. descendant side
			root.visitDecendants(function (p:Person):void{
				constructEdge(p);							
			});	
		}
		/**
		 * construct block hierarchy
		 * this function should be called after 'constructDisplayList(...)'
		 **/
		protected function constructBlocks(root:Person):void{	
			//walkdown ancestor hierarchy
			constructBlock(root, BlockSprite.ROOT ); //root block
			root.visitAncestors(function(p:Person):void{
				constructBlock(p, BlockSprite.ANCESTOR);				
			});
			//walkdown descendant hierarchy
			root.visitDecendants(function(p:Person):void{
				constructBlock(p, BlockSprite.DESCENDANT);
			});
			//construct tree block structure
			// descendant blocks are added in youngest to oldest manner
			// ancestors blocks are added in male's ancestor block to female's
			//TODO: what if a block span multiple generations
			root.sprite.visit(function(n:NodeSprite):void{
				for each (var childNode:NodeSprite in n.childNodes){
					if (n.block.childBlocks.indexOf(childNode.block)!=-1) continue;
					n.block.addChildBlock(childNode.block);
					//if not null, this block is where intermarriage happens
					childNode.block.parentBlock==null? childNode.block.parentBlock = n.block 
													 : childNode.block.addPseudoParent(n.block);	
					if (childNode.block.pseudoParents.length >0) trace("pseudo-block");					
				} 
			});
			
		}
		protected function constructBlock(p:Person, type:int): BlockSprite {			
			//1. find existing blocks and merge them
			// case #1 more than one already have blocks
			// csee #2. two of them in the same block
			var union:BlockSprite 		= null;
			var existingBlocks:Array	= new Array();
			var newBlock:BlockSprite 	= p.sprite.block? p.sprite.block:new BlockSprite();
			newBlock.type = type;
			newBlock.addNode(p.sprite);
			for each (var sp:Person in p.spouses){
				if (sp.sprite.block && sp.sprite.block != newBlock) {
					if (existingBlocks.indexOf(sp.sprite.block)==-1) existingBlocks.push(sp.sprite.block);
				}else{
					newBlock.addNode(sp.sprite);
				}
			}
			//2. union existing blocks and the new block
			for each (var block:BlockSprite in existingBlocks){
				union = union == null? block : BlockSprite.union(union, block);
				//remove the existing block from blcokList				
				if (_blocks.contains(block)) _blocks.remove(block);
			}
			newBlock = BlockSprite.union(union, newBlock);
			if (_blocks.contains(newBlock)==false)	_blocks.add(newBlock);
			return newBlock;
		}
		/**
		 * parents are added in from Male to Female order
		 * children are added in from Youngest to Oldest Order
		 **/
		protected function constructDOITree(root:Person):void {
			
			//root's links
			for each (var parent:Person in root.parents){				
				root.sprite.addChildNode(parent.sprite);
				parent.sprite.parentNode == null? parent.sprite.parentNode = root.sprite
												: parent.sprite.addPseudoParent(root.sprite);
				if (parent.sprite.pseudoParents.length >0) trace("pseudo:"+parent.sprite.data.name);
			}
			for each (var child:Person in root.children){
				root.sprite.addChildNode(child.sprite);
				child.sprite.parentNode == null? child.sprite.parentNode = root.sprite
											: child.sprite.addPseudoParent(root.sprite);
				if (child.sprite.pseudoParents.length >0) trace("pseudo:"+child.sprite.data.name);							
			}
			//walkdown ancestor hierarchy
			root.visitAncestors(function(p:Person):void{
				for each (var parent:Person in p.parents){					
					p.sprite.addChildNode(parent.sprite);
					parent.sprite.parentNode == null? parent.sprite.parentNode = p.sprite
												: parent.sprite.addPseudoParent(p.sprite);
					if (parent.sprite.pseudoParents.length >0) trace("pseudo:"+parent.sprite.data.name);							
				}
			});
			//walkdown descendant hierarchy
			root.visitDecendants(function(p:Person):void{
				for each (var child:Person in p.children){
					p.sprite.addChildNode(child.sprite);
					child.sprite.parentNode == null? child.sprite.parentNode = p.sprite
												: child.sprite.addPseudoParent(p.sprite);
					if (child.sprite.pseudoParents.length >0) trace("pseudo:"+child.sprite.data.name);							
				}
			});
		}
	} // end of class Data
}