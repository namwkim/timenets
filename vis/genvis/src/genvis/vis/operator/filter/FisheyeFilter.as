package genvis.vis.operator.filter
{
	import genvis.animate.Transitioner;
	import flare.vis.data.DataSprite;
	
	import genvis.data.Person;
	import genvis.vis.data.Data;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.operator.Operator;

	/**
	 * Filter operator that computes a fisheye degree-of-interest function over
	 * a tree structure. Visibility and DOI (degree-of-interest) values are set
	 * for the nodes and edges in the structure. This function includes a set
	 * of focus nodes, and includes neighbors only in a limited window around
	 * these foci. The size of this window is determined by this operator's
	 * <code>distance</code> property. All ancestors of a focus up to the root
	 * of the tree are considered foci as well. By convention, DOI values start
	 * at zero for focus nodes, with decreasing negative numbers for each hop
	 * away from a focus. The DOI values computed by this filter are stored in
	 * the <code>DataSprite.props.doi</code> property.
	 * 
	 * <p>This form of filtering was described by George Furnas as early as 1981.
	 * For more information about Furnas' fisheye view calculation and DOI values,
	 * take a look at G.W. Furnas, "The FISHEYE View: A New Look at Structured 
	 * Files," Bell Laboratories Tech. Report, Murray Hill, New Jersey, 1981. 
	 * Available online at <a href="http://citeseer.nj.nec.com/furnas81fisheye.html">
	 * http://citeseer.nj.nec.com/furnas81fisheye.html</a>.</p>
	 */
	public class FisheyeFilter extends Operator
	{
		/** An array of focal NodeSprites. */
		public var focusNodes:/*NodeSprite*/Array;
		/** Graph distance within within which items wll be visible. */
		public var distance:int;
		
		private var _divisor:Number;
		private var _root:NodeSprite;
		private var _t:Transitioner;
		
		/**
		 * Creates a new FisheyeTreeFilter
		 * @param focusNodes focusNodes an array of focal NodeSprites. Graph
		 *  distance is measured as the minimum number of edge-hops to one of
		 *  these nodes or their ancestors up to the root.
		 * @param distance graph distance within which items will be visible
		 */		
		public function FisheyeFilter(focusNodes:Array=null,distance:int=1)
		{
			this.focusNodes = focusNodes;
			this.distance = distance;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t==null ? Transitioner.DEFAULT : t);
			_root = visualization.data.root.sprite;
			_divisor = visualization.data.length;
        
	        // mark the items
	        visualization.data.visit(function(ns:NodeSprite):void {
	        	ns.doi = -Number.MAX_VALUE;
	        }, Data.NODES);
	       	visualization.data.visit(function(es:EdgeSprite):void {
	        	es.doi = -Number.MAX_VALUE;
	        }, Data.EDGES);
	        
	        
	        // compute the fisheye over nodes
	        for each (var fn:NodeSprite in focusNodes) {
	        	visitFocus(fn, null);
	        }
	        visitFocus(_root, null);
	
	        // mark unreached items
	        visualization.data.visit(function(ns:NodeSprite):void {
	        	if (ns.doi == -Number.MAX_VALUE)
	        		setVisibility(ns, false);
	        }, Data.NODES);
	       	visualization.data.visit(function(es:EdgeSprite):void {
	        	if (es.doi == -Number.MAX_VALUE)
	        		setVisibility(es, false);
	        }, Data.EDGES);
		}
		
		/**
		 * Set the visibility of a data sprite.
		 */
		private function setVisibility(ds:DataSprite, visible:Boolean):void
		{
			var alpha:Number = visible ? 1 : 0;
			var obj:Object = _t.$(ds);
				
			obj.alpha = alpha;
			if (ds is NodeSprite){
				(ds as NodeSprite).expanded = (ds.props.doi > -distance);
//				(ds as NodeSprite).willVisible = visible;
//				if ((ds as NodeSprite).type == NodeSprite.ANCESTOR)
//					trace("FISHEYE ("+(ds as NodeSprite).data.name+","+(ds as NodeSprite).visible+","+visible+")");
			}
			if (_t.immediate) {
				ds.visible = visible;
			} else {
				obj.visible = visible;
			}
		}
		
		/**
	     * Visit a focus node.
	     */
	    private function visitFocus(n:NodeSprite, c:NodeSprite):void
	    {
	        if (n.doi < 0 ) {
	            visit(n, c, 0, 0);
	            if (distance > 0) visitDescendants(n, c);
	            visitAncestors(n);
	        }
	    }
	    
	    /**
	     * Visit a specific node and update its degree-of-interest.
	     */
	    private function visit(n:NodeSprite, c:NodeSprite, doi:int, ldist:int):void
	    {
	    	setVisibility(n, true);
	        var localDOI:Number = -ldist / Math.min(1000.0, _divisor);
	        if (n.doi < doi) n.doi = doi + localDOI;
	        //doi scores of spouses
	        var person:Person = n.data as Person;
	        for (var i:int=0; i<person.spouses.length; i++){
	        	var sp:NodeSprite = person.spouses[i].sprite as NodeSprite;
	        	setVisibility(sp, true);
	        	//TODO: clever tradoff between spouses and siblings
	        	var spDOI:Number = n.doi-(i+1)/Math.min(1000.0, _divisor);
	        	if (sp.doi<spDOI) sp.doi = spDOI; 
	        }
	        if (n.inEdge) {
	        	var e:EdgeSprite = n.inEdge;	  
	        	e.doi = (n.type==NodeSprite.ANCESTOR? n.doi-0.5 : n.doi+0.5 );
	        	setVisibility(e, e.doi < -distance? false:true);
	        }
	    }
	    
	    /**
	     * Visit tree ancestors and their other descendants.
	     */
	    private function visitAncestors(n:NodeSprite):void
	    {
	        if (n == _root) return;
	        visitFocus(n.parentNode, n);
	    }
	    
	    /**
	     * Traverse tree descendents.
	     */
	    private function visitDescendants(p:NodeSprite, skip:NodeSprite):void
	    {
	    	var lidx:int = (skip == null ? 0 : skip.parentNode.childNodes.indexOf(skip));
	        
	        p.expanded = p.childNodes.length > 0;
	        for (var i:int=0; i<p.childNodes.length; ++i) {
	        	var c:NodeSprite = p.childNodes[i];
	        	if (c == skip) continue;
	        	
	        	var doi:int = int(p.doi - 1);
	        	visit(c, c, doi, Math.abs(lidx-i));
	        	if (doi > -distance) visitDescendants(c, null);
	        }
	    }

		
	} // end of class FisheyeTreeFilter
}