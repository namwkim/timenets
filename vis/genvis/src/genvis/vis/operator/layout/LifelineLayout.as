package genvis.vis.operator.layout
{
	import genvis.data.Person;
	import genvis.scale.TimeScale;
	import genvis.vis.axis.Axis;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.lifeline.Lifeline;
	import genvis.vis.lifeline.Line;
	import genvis.vis.lifeline.LineSpline;
	import genvis.vis.lifeline.Spline;

	public class LifelineLayout extends Layout
	{
//		//axis layout
//		protected var _xField:Property;
//		protected var _yField:Property;
//		protected var _xBinding:ScaleBinding;
//		protected var _yBinding:ScaleBinding;
//		//lifeline layout
//		protected var _displayList:Array;
//		protected var _nodeType:Number;
//		protected var _nodeMap:Dictionary;
//		protected var _focus:Person;
//		protected var _lifeline:Lifeline;
//		
//		
		public static const DESCENDANTCHART:Number 	= 0;
		public static const PEDIGREECHART:Number	= 1;
		public static const HOURGLASSCHART:Number 	= 2;
		
		protected var _lifelineType:int;
		protected var _doiEnabled:Boolean;
		
		protected var _root:NodeSprite  = null
		protected var _xscale:TimeScale = null;
		protected var _xrange:Number;
		protected var _curDate:Date = new Date();
		protected var _lifeline:Lifeline= null;
		protected var _recentFocus:NodeSprite = null;
		protected var _displayNodeList:Array  = null;
		protected var _displayBlockList:Array = null;		
		
		protected var _fitHorzBound:Boolean = true;	
		
		public function get curDate():Date			{ return _curDate; 	}
		public function set curDate(d:Date):void	{ _curDate = d;		}
		public function get xrange():Number 	{ return _xrange; 	}
		public function set xrange(r:Number):void 	{ 			
			_xrange = r; 	
			buildScale(_recentFocus);
		}
		public function get doiEnabled():Boolean 		{ return _doiEnabled; 	}
		public function set doiEnabled(d:Boolean):void 	{ _doiEnabled = d;		}
		public function get xAxis():Axis{ return (visualization.axes as CartesianAxes).xAxis }
		/**
		 * xrange : in years
		 * 			
		 **/
		public function LifelineLayout(root:NodeSprite, doiEnabled:Boolean, lifelineType:int = Lifeline.LINESPLINE,  
				lifelineStyle:int = Lifeline.LABELOUTSIDE, xrange:Number = 150){
			super();
			_root		= root;
			_xscale		= new TimeScale();
			_xrange 	= xrange;
			
			_lifelineType = lifelineType;
			switch(_lifelineType){
				case Lifeline.LINE:
				_lifeline = new Line(lifelineStyle);
				break;
				case Lifeline.SPLINE:
				_lifeline = new Spline(lifelineStyle);
				break;
				case Lifeline.LINESPLINE:
				_lifeline = new LineSpline(lifelineStyle);
				break;
			}
			_doiEnabled = doiEnabled;
		}
		public function get lifeline():Lifeline { return _lifeline; }
		
		public function clear():void{

		}
		/**
		 * should be called when visualization is set (also when this operator is added to visualization)
		 **/
		public override function setup():void{
			//1. build x-scale (we need to move this to layout() when fisheye is integrated
			buildScale(_root);
			var axes:CartesianAxes 	= super.xyAxes;
			axes.xAxis.axisScale	= _xscale;
			lifeline.axes = axes;
			//set global layout property for blocks to this 
			for each (var block:BlockSprite in visualization.data.blocks){
				block.gbLayout = this;
			}
		}
		/**
		 * build xscale
		 **/
		public function buildScale(recentFocus:NodeSprite):void{
			_recentFocus = recentFocus;
			//find min and max within xrange
			var min:Date, max:Date;			
			//temporary : hourglass chart

			var person:Person = recentFocus.data as Person;
			if (!_fitHorzBound){
				if (!person.deceased){
					var minYear:Number = _curDate.fullYear-_xrange;
					_xscale.min = new Date(minYear, 1, 1);
					_xscale.max = _curDate;
				}else{	
					var median:Number = person.dateOfBirth.fullYear + (person.dateOfDeath.fullYear - person.dateOfBirth.fullYear)/2;
					_xscale.min = new Date(median-(_xrange/2), 1, 1);
					_xscale.max = new Date((median+(_xrange/2))>_curDate.fullYear?_curDate.fullYear:(median+(_xrange/2)) , 1 ,1);				
				}
			}else{
				//find xmin and xmax from the whole data
//				var people:Array  = new Array();
//				var isAlive:Boolean = false;
//				visualization.data.nodes.visit(function (n:NodeSprite):void{
//					var person:Person = n.data as Person;
//					people.push(person);
//					if (!person.isDead && isAlive == false){
//						isAlive = true;
//					}					
//				});
//				people.sortOn("dateOfBirth", Array.NUMERIC);
//				_xscale.min = people[0].dateOfBirth;
//				if (isAlive) {
//					_xscale.max = _curDate;
//				}else{
//					people.sortOn("dateOfDeath", Array.NUMERIC);
//					_xscale.max = people[people.length-1].dateOfDeath;
//					
//				}
				//temp for study data
				_xscale.min = new Date(1900,1,1);				
				_xscale.max = new Date();
			}
			trace("XRANGE-"+_xscale.min.fullYear+","+_xscale.max.fullYear);
//			var people:Array  = new Array();
//			people.push(person);
//			person.visitAncestors(function (p:Person):void{
//				people.push(p);
//			}, _xrange);
//			person.visitDecendants(function (p:Person):void{
//				people.push(p);
//			}, _xrange);	
//					
//			people.sortOn("dateOfBirth", Array.NUMERIC);
//			var minYear:Number = Math.floor(people[0].dateOfBirth.fullYear/10)*10;
//			_xscale.min = new Date(minYear, 1, 1);
//			
//			var isAlive:Boolean = false;
//			for each (person  in people){
//				if (!person.isDead){
//					isAlive = true;
//					break;
//				}				
//			}
//			var maxYear:Number;
//			if (isAlive){
//				 _xscale.max = new Date();				 
//			}else{
//				people.sortOn("dateOfDeath", Array.NUMERIC);
//				maxYear = Math.ceil(people[people.length-1].dateOfDeath.fullYear/10)*10;
//				_xscale.max =  new Date(maxYear, 11, 31);;
//			}				
		}
		/**
		 * this function is called after fisheye scores are calculated
		 **/
		protected override function layout():void{
			//construct displayList
			_displayNodeList 	= new Array();
			_displayBlockList	= new Array();
			if (_doiEnabled){
				//desimplify all the visible nodes which have been visible by fisheye calcuation
				visualization.data.nodes.visit(function (n:NodeSprite):void{
					if (n.visible == true)	{
						_displayNodeList.push(n);
						n.desimplify();
					}				
				});
				//block should be visible if its focus node is set visible by fisheye calculation
				//if block is previously aggregated, then its visibility will be true too
				//   but its focus node may not be visible for this frame.
				visualization.data.blocks.visit(function (b:BlockSprite):void{
					if (b.focus.visible == true) {	
						if (b.aggregated) b.alpha = 0;	
						b.aggregated = false;			
						_displayBlockList.push(b);
						
					}else{
						//find blocks to be shown as aggregates
						if (b.parentBlock.focus.visible){
							while (b.simplify());
							_displayBlockList.push(b);
						}else{
							b.aggregated = false;
						}					
					}		
					_t.$(b).alpha = b.visible ? 1 : 0;	
					
				});
			}else{//all nodes are assumed to be visible
				visualization.data.edges.visit(function (e:EdgeSprite):void{
					e.visible = true;
					e.alpha	  = 1;
				});
				visualization.data.nodes.visit(function (n:NodeSprite):void{
					n.visible = true;
					n.alpha = 1;
					n.desimplify();
					_displayNodeList.push(n);
				});
				visualization.data.blocks.visit(function (b:BlockSprite):void{						
					while (b.desimplify());							
					_displayBlockList.push(b);
				});
			}
			//trace("disp:"+(visualization.data.blocks.length == _displayBlockList.length));
			//trace(visualization.data.nodes.length+","+ _displayNodeList.length);
			horizontalPositioning();
			localLayout();
			//construct interval tree
			//constructIntervalTree(_root.block);
			verticalPositioning();
		}
		public function horizontalPositioning():void{
			var axes:CartesianAxes = super.xyAxes;
			for each (var block:BlockSprite in _displayBlockList){
				block.x = axes.xAxis.X(block.min);								
				//trace(block.focus.data.name+", x:"+block.x);					
			}
		}
		public function localLayout():void{
			for each (var block:BlockSprite in _displayBlockList){
//				var max:Number = this.xAxis.X(block.max);
//				if (block.x < visualization.bounds.x || max > visualization.bounds.width){
//					block.setVisibility(false);	continue;
//				}
				_lifeline.layout(block);
				block.calcBBox();
			}
		}

		public function verticalPositioning():void{			
			//1. calculate initial height
			verticalLayout();
			var top:Number 		= Number.MAX_VALUE;	
			if (_doiEnabled){
				top = fitLayoutToScreen();
			}else{						
				visualization.data.blocks.visit(function (b:BlockSprite):void{
					if (b.visible==false) return;
					if (b.ty < top) top = b.ty;
				});
			}
			
			//translate layout (use transitionor to set final y position)
			var offset:Number = -top;
			trace("OFFSET:"+offset);
			visualization.data.blocks.visit(function (b:BlockSprite):void{				
				b.ty = b.ty + offset;
//				if (!b.aggregated){					
//					_t.$(b).y = b.ty;
//				}else{
//					b.y = b.ty;
//				}
				_t.$(b).y = b.ty;
				trace("FINAL:"+b.focus.data.name +":"+b.y);
			});	
		}
		public function fitLayoutToScreen():Number{
			if (_doiEnabled == false) {trace("doi is not enabled!!-LifelineLayout"); return (-1); }
			
			var top:Number 		= Number.MAX_VALUE;
			var bottom:Number 	= -Number.MIN_VALUE;
			visualization.data.blocks.visit(function (b:BlockSprite):void{
				if (b.visible==false) return;
				if (b.ty < top) top = b.ty;
				if (bottom < (b.ty + b.bbox.height)) bottom = b.ty + b.bbox.height;
			});
			var newHeight:Number = bottom-top;
			trace('newHeight:'+newHeight+', bound:'+ visualization.bounds.height);
			
			_displayNodeList.sortOn("doi", Array.NUMERIC);
			var idx:int = 0;
			var revertedNodeList:Array = new Array();//will contain nodes in lowest doi first
			while (newHeight > visualization.bounds.height && idx<_displayNodeList.length){
				trace('newHeight:'+newHeight+', bound:'+ visualization.bounds.height);
				var prevHeight:Number = newHeight;
				trace(idx+", "+( _displayNodeList.length-1));
				//find a lifeline whose doi is lowest
				var n:NodeSprite = _displayNodeList[idx++];
				//trace(n.data.name+", doi:"+n.doi);
				if (n.simplified == true) continue; //skip if already simplified
				

				//trace(_displayNodeList[idx].name+", doi:"+_displayNodeList[idx].doi);
				//recalculate block layout
				//trace("bbox oldheight"+n.block.bbox.height);
				var simplifiable:Boolean = true;
				for each (var child:NodeSprite in n.childNodes){
					if (child.block.aggregated != true && child.block.visible) { 
						simplifiable = false; break; 
					}
				}	

				if (!simplifiable){
					idx--;
					//find one from reverted node list (this 
					for (var i:int = 0; i<revertedNodeList.length; i++){
						n = revertedNodeList[i];
						n.block.simplify();
						_lifeline.layout(n.block);
						n.block.calcBBox();
						verticalLayout();
						top 	= Number.MAX_VALUE;
						bottom	= -Number.MIN_VALUE;
						visualization.data.blocks.visit(function (b:BlockSprite):void{
							if (b.visible==false) return;
							if (b.ty < top) top = b.ty;
							if (bottom < (b.ty + b.bbox.height)) bottom = b.ty + b.bbox.height;
						});
						newHeight = bottom-top;
						if (newHeight >= prevHeight){
							newHeight = prevHeight;
							n.block.desimplify();
							_lifeline.layout(n.block);//recalculate layout for the block
							n.block.calcBBox(); //and bounding box
						}else{
							prevHeight = newHeight;
							revertedNodeList.splice(i,1);
							if (newHeight <=  visualization.bounds.height) break;
						}
						if (newHeight <=  visualization.bounds.height) break;						
					}					
					continue;
				}
				n.block.simplify();
				_lifeline.layout(n.block);
				n.block.calcBBox();
				//trace("bbox newHeight"+n.block.bbox.height);
				//efficiently recalculate newHeight...
				verticalLayout();
				top 	= Number.MAX_VALUE;
				bottom	= -Number.MIN_VALUE;
				visualization.data.blocks.visit(function (b:BlockSprite):void{
					if (b.visible==false) return;
					if (b.ty < top) top = b.ty;
					if (bottom < (b.ty + b.bbox.height)) bottom = b.ty + b.bbox.height;
				});
				newHeight = bottom-top;
				//trace('newHeight:'+newHeight+', bound:'+ visualization.bounds.height);
				//TODO if the node simplification doesn't improve vertical layout, revert it...
				if (newHeight >= prevHeight){
					//desimplify the lifeline
					//trace("reverted: prevH:"+prevHeight+", newH:"+newHeight);					
					newHeight = prevHeight;
					n.block.desimplify();
					_lifeline.layout(n.block);//recalculate layout for the block
					n.block.calcBBox(); //and bounding box
					revertedNodeList.push(n); 
					//the desimplified node should be reconsidered if appropriate....					
					//cleverly reorder display list so that this node will be reconsidered later..
//					var cutItem:Array = _displayNodeList.splice(idx-1, 1);
//					_displayNodeList.splice(idx, 0, cutItem[0]);
//					idx--;
				}else{
					
				}
			}
			trace('newHeight:'+newHeight+', bound:'+ visualization.bounds.height);
			return (top);
		}
		/**
		 * produce layout without overlaps
		 * each of descendant chart, pedigree chart do not have overlaps within themselves
		 * so, only need to check intersection between nodes in different charts including root node.
		 **/
		public function verticalLayout():void{
			visualization.data.blocks.visit(function (b:BlockSprite):void{
				if (b.visible) b.visited = false;
			});
			var y:Number 	= 0;
			_root.block.ty	= y;

			//ancestor layout 
			for each (childBlock in _root.block.childBlocks){
				if (childBlock.type == BlockSprite.ANCESTOR){
					if (childBlock.visited) continue;
					childBlock.visited = true;
					y = _root.block.bbox.height;
					childBlock.ty = y;
					y = 0;					
					for (var i:int=childBlock.childBlocks.length-1; i>=0; i--){
						var db:BlockSprite = childBlock.childBlocks[i];
						if (db.focus.parentNode.data.gender == Person.FEMALE)
							db.visitInOrder(function (b:BlockSprite):void{
								if (b.visible==false || b.visited) return;									
								b.visited = true;			
								y 	-= b.bbox.height;
								b.ty = y;						
								trace(b.focus.data.name +":"+b.ty);
							}, true);
						else 
							y = childBlock.ty + childBlock.bbox.height;
							db.visitInOrder(function (b:BlockSprite):void{
								if (b.visible==false || b.visited) return;
								b.visited = true;
								b.ty = y;
								y	+= b.bbox.height;
								trace(b.focus.data.name +":"+b.ty);
							}, false);
					}
//					if (childBlock.childBlocks.length == 2){
//						childBlock.childBlocks[1].visitInOrder(forward,true);
//						y = childBlock.ty + childBlock.bbox.height;
//						childBlock.childBlocks[0].visitInOrder(backward,false);
//					}else if (childBlock.childBlocks.length==1){
//						
//					}
				}
			}
			
			//descendant layout without overlaps with ancestors
			// TODO: construct interval tree of ancestors (assuming that no ancestors whose depths are 
			// greater than 2 intersect descendants
			y = _root.block.bbox.height;					
			var childBlock:BlockSprite;
			for each (childBlock in _root.block.childBlocks){
				if (childBlock.type == BlockSprite.DESCENDANT){
					childBlock.visit(function(b:BlockSprite):void{
						if (b.visible==false || b.visited) return;
						b.visited = true;
						b.ty	= y;//initialize vertical position
						//find ancestors intersecting with this descendant
						var ancestors:Array = new Array();
						_root.block.visit(function (ab:BlockSprite):void{
							if (ab.type == BlockSprite.ANCESTOR){
								if (ab.intersect(b)) {
									ancestors.push(ab);
								}
							}
						},2);
						//calculate aggregated height of those ancestors
						if (ancestors.length !=0){
							var newY:Number = b.ty;
							for each (var ab:BlockSprite in ancestors){
								if (newY < (ab.ty+ab.bbox.height)) newY = (ab.ty+ab.bbox.height);
							}
							b.ty = y = newY; //update new position
						}
						y += b.bbox.height + 4;						
					});
				}
			}
	 		//post-condition: all visible blocks should have been visited 
	 			
		}
		
		
//		
//		public function LifelineLayout(focus:Person, xAxisField:String=null, yAxisField:String=null, nodeType:Number=Lifeline.LINEBSPLINE)
//		{
//			super();
//			
//			layoutType = CARTESIAN;
//			
//			_xBinding = new ScaleBinding();
//			_xBinding.group = Data.NODES;
//			_xBinding.property = xAxisField;
//			
//			_yBinding = new ScaleBinding();
//			_yBinding.group = Data.NODES;
//			_yBinding.property = yAxisField;
//			
//			_focus		= focus;
//			_nodeType 	= nodeType;
//			switch (_nodeType){
//				case Lifeline.LINE:
//					_lifeline = new Line();
//					break;
//				case Lifeline.BSPLINE:
//					_lifeline = new BSpline();
//					break;
//				case Lifeline.LINEBSPLINE:
//					_lifeline = new LineBSpline();
//					break;
//			}			
//		}
//		/** The x-axis source property. */
//		public function get xField():String { return _xBinding.property; }
//		public function set xField(f:String):void { _xBinding.property = f; }
//		
//		/** The y-axis source property. */
//		public function get yField():String { return _yBinding.property; }
//		public function set yField(f:String):void { _yBinding.property = f; }
//		
//		/** The scale binding for the x-axis. */
//		public function get xScale():ScaleBinding { return _xBinding; }
//		public function set xScale(b:ScaleBinding):void {
//			if (_xBinding) {
//				if (!b.property) b.property = _xBinding.property;
//				if (!b.group) b.group = _xBinding.group;
//				if (!b.data) b.data = _xBinding.data;
//			}
//			_xBinding = b;
//		}
//		/** The scale binding for the y-axis. */
//		public function get yScale():ScaleBinding { return _yBinding; }
//		public function set yScale(b:ScaleBinding):void {
//			if (_yBinding) {
//				if (!b.property) b.property = _yBinding.property;
//				if (!b.group) b.group = _yBinding.group;
//				if (!b.data) b.data = _yBinding.data;
//			}
//			_yBinding = b;
//		}
//
//		public override function setup():void{		
//			if (visualization==null) return;
//			_xBinding.data = visualization.data;
//			_yBinding.data = visualization.data;
//			
//			var axes:CartesianAxes = super.xyAxes;
//			axes.xAxis.axisScale = _xBinding;
//			axes.yAxis.axisScale = _yBinding;
//			
//			//lifeline layout variables
//			_nodeMap 		= new Dictionary();
//			_displayList	= new Array();
//			visualization.data.nodes.visit( function (d:DataSprite):void{
//				_nodeMap[d.data.id] = d;
//			});
//			arrangeLifelines();//give y-coord of nodes		
//			updataMinMax();	
//		}
//		protected function axisLayout():void{
//			_xField = Property.$(_xBinding.property);
//			_yField = Property.$(_yBinding.property);
//			
//			var axes:CartesianAxes = super.xyAxes;
//			_xBinding.updateBinding(); axes.xAxis.axisScale = _xBinding;
//			_yBinding.updateBinding(); axes.yAxis.axisScale = _yBinding;
//						
//			var x0:Number = axes.originX;
//			var y0:Number = axes.originY;
//			
//			visualization.data.nodes.visit(function(d:DataSprite):void {
//				var dx:Object, dy:Object, x:Number, y:Number, s:Number, z:Number;
//				var o:Object = _t.$(d);
//				dx = _xField.getValue(d); dy = _yField.getValue(d);
//				
//				var map:Object;
//				if (_xField != null) {
//					x = axes.xAxis.X(dx);
//					o.x = x;
//					o.w = x - x0;
//				}
//				if (_yField != null) {
//					y = axes.yAxis.Y(dy);
//					o.y = y;
//					o.h = y - y0;
//				}
//			});			
//		}
//		protected override function layout():void{
//			axisLayout();//apply axis layout
//			
//			//update min and max			
//			_lifeline.setup(super.xyAxes as CartesianAxes);
//			specifyShapes();//specify node designs		
//		}
//
//		/**
//		 * determine y-ordering of nodes
//		 **/
//		protected function arrangeLifelines():void{
//			//sub-class should override this
//		}
//		/**
//		 * specify node shapes
//		 **/
//		protected function specifyShapes():void{
//
//		}
//		protected function updataMinMax():void{
//			visualization.data.nodes.visit( function (d:DataSprite):void{
//				if (!isNaN(d.data.yorder)) _displayList.push(d.data);
//				//if (d.data.isVisited) _displayList.push(d.data);
//			});
//		    _displayList.sortOn("dateOfBirth", Array.NUMERIC);
//		    
//
//		    // Group years by decade.  Range of years depend on data being displayed.  Scale will change as necessary.    
//		    var minYear:Number = Math.floor(_displayList[0].dateOfBirth.fullYear/10)*10;
//		    this.xScale.min = new Date(minYear, 1, 1);
//		   	
//			var isAlive:Boolean = false;
//		 	var min:Number = _displayList[0].yorder;
//		    var max:Number = _displayList[0].yorder;
//			for each (var person:Person in _displayList){
//				if (min>person.yorder) min = person.yorder;
//		    	if (max<person.yorder) max = person.yorder;	
//				if (person.dateOfDeath ==null){
//					isAlive = true;
//				}				
//			}
//			var maxYear:Number;
//			if (isAlive){
//				 this.xScale.max = new Date();
//				 maxYear = this.xScale.max.fullYear;
//			}else{
//				_displayList.sortOn("dateOfDeath", Array.NUMERIC);
//				maxYear = Math.ceil(_displayList[_displayList.length-1].dateOfDeath.fullYear/10)*10;
//				 this.xScale.max = new Date(maxYear, 11, 31);
//			}	
//		   			   
//			
//			var axes:CartesianAxes = visualization.axes as CartesianAxes;
//   			axes.xAxis.numLabels = (maxYear - minYear) / 10;
// 			
// 			// Only consider the nodes that we're displaying so maximize the space.
// 			this.yScale.min = min-1;//_displayList[0].data.order;
//			this.yScale.max = max+1;//_displayList[_displayList.length-1].data.order;
//			//vis.update( transition, "axis" ).play();
//		}

	}
}