package genvis.vis.operator.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import genvis.data.Event;
	import genvis.data.Person;
	import genvis.scale.TimeScale;
	import genvis.vis.axis.Axis;
	import genvis.vis.axis.CartesianAxes;
	import genvis.vis.data.AttributeSprite;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.Data;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.EventSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.lifeline.Lifeline;
	import genvis.vis.lifeline.Line;
	import genvis.vis.lifeline.LineSpline;
	import genvis.vis.lifeline.Spline;
	
	import org.akinu.helper.Helper;

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
		protected var _gap:Number	= 5;//gap between blocks
		protected var _yPan:Number	= 0;
		protected var _defaultYPan:Number;
		protected var _yMin:Number;
		protected var _yMax:Number;
		
		protected var _fitHorzBound:Boolean = false;	
		
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
		public function set yPan(y:Number):void { _yPan = y; }
		public function get yPan():Number { return _yPan  }
		public function get yMin():Number { return _yMin; }
		public function get yMax():Number { return _yMax; }
		public function get defaultYPan():Number { return _defaultYPan; }
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
//				if (!person.deceased){
//					var minYear:Number = _curDate.fullYear-_xrange;
//					_xscale.min = new Date(minYear, 1, 1);
//					_xscale.max = _curDate;
//				}else{	
					var end:Date = person.dateOfDeath!=null? person.dateOfDeath:_curDate;
					var median:Number = person.dateOfBirth.fullYear + (end.fullYear - person.dateOfBirth.fullYear)/2;
					_xscale.min = Helper.assignDate(median-(_xrange/2), 1, 1);
					_xscale.max = Helper.assignDate(median+(_xrange/2) , 1 ,1);				
//				}
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
				_xscale.max = _curDate;
			}
//			trace("XRANGE-"+_xscale.min.fullYear+","+_xscale.max.fullYear);
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
				visualization.data.attributes.visit(function (a:AttributeSprite):void{
					a.visible = true;
					a.alpha	  = 1;
				});
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
			layoutEvents();
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
			var offset:Number;
			verticalLayout();
			if (_doiEnabled){
				offset = -fitLayoutToScreen();
			}else{		
				var focusBlock:BlockSprite = _recentFocus.block;
				var vmiddle:Number = visualization.bounds.height/2;
				_defaultYPan = -(focusBlock.ty-vmiddle);
				offset =  _defaultYPan + _yPan;
				_yMin 	= Number.MAX_VALUE;
				_yMax 	= -Number.MIN_VALUE;
				visualization.data.blocks.visit(function (b:BlockSprite):void{
					if (b.visible==false) return;
					if (b.ty < _yMin) _yMin = b.ty;
					if (_yMax < (b.ty + b.bbox.height)) _yMax = b.ty + b.bbox.height;
				});
			}
			
			//translate layout (use transitionor to set final y position)
			//trace("OFFSET:"+offset);
			visualization.data.blocks.visit(function (b:BlockSprite):void{				
				b.ty = b.ty + offset;
//				if (!b.aggregated){					
//					_t.$(b).y = b.ty;
//				}else{
//					b.y = b.ty;
//				}
				_t.$(b).y = b.ty;
				//trace("FINAL:"+b.focus.data.name +":"+b.y);
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
					y = - (_root.block.bbox.min.y + childBlock.bbox.height + _gap);
					childBlock.ty = y;							
					var db:BlockSprite;	
					var i:int;							
					for (i=childBlock.childBlocks.length-1; i>=0; i--){
						db = childBlock.childBlocks[i];
						if (db.focus.parentNode.data.gender == Person.MALE){
							var prevBlocks:Array = new Array();
							prevBlocks.push(childBlock);
							y = -_root.block.bbox.min.y;
							db.visitInOrder(function (b:BlockSprite):void{
								if (b.visible==false || b.visited) return;
								b.visited = true;
								prevBlocks.push(b);
								b.ty = y;
								if (b.intersect(_root.block)){//back up
									var ab:BlockSprite = b; 
									var newY:Number = -_root.block.bbox.min.y;
									var reversed:Array = prevBlocks.slice();
									for each (var pb:BlockSprite in reversed.reverse()){
										newY-= (pb.bbox.height + _gap);
										pb.ty = newY;
										trace("ROLLBACK: "+pb.focus.data.name +":"+pb.ty);
									}

									y = -_root.block.bbox.min.y;
								}else{
									y	+= (b.bbox.height+_gap);
								}
								
								trace(b.focus.data.name +":"+b.ty);
							}, false);
						}						
					}
					for (i=childBlock.childBlocks.length-1; i>=0; i--){
						db = childBlock.childBlocks[i];
						if (db.focus.parentNode.data.gender == Person.FEMALE){
							y = childBlock.ty - _gap;
							db.visitInOrder(function (b:BlockSprite):void{
								if (b.visible==false || b.visited) return;									
								b.visited = true;			
								y 	-= (b.bbox.height+_gap);
								b.ty = y;						
								trace(b.focus.data.name +":"+b.ty);
							}, true);
						}
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
			// greater than 3 intersect descendants
			y = _root.block.bbox.height + _gap;					
			var childBlock:BlockSprite;
			for each (childBlock in _root.block.childBlocks){
				if (childBlock.type == BlockSprite.DESCENDANT){
					childBlock.visit(function(b:BlockSprite):void{
						if (b.visible==false || b.visited) return;
						b.visited = true;
						b.ty	= y;//initialize vertical position
//						//find ancestors intersecting with this descendant
//						var ancestors:Array = new Array();
//						_root.block.visit(function (ab:BlockSprite):void{
//							if (ab.type == BlockSprite.ANCESTOR){
//								if (ab.intersect(b)) {
//									//ancestors.push(ab);									
//									if (b.ty < (ab.ty+ab.bbox.height)) b.ty = y = (ab.ty+ab.bbox.height);
//								}
//							}
//						},2);
//						//calculate aggregated height of those ancestors
//						if (ancestors.length !=0){
//							var newY:Number = b.ty;
//							for each (var ab:BlockSprite in ancestors){
//								if (newY < (ab.ty+ab.bbox.height)) newY = (ab.ty+ab.bbox.height);
//							}
//							b.ty = y = newY; //update new position
//						}
						y += b.bbox.height + _gap;						
					});
				}
			}
	 		//post-condition: all visible blocks should have been visited 
	 			
		}
		
		protected function layoutEvents():void{
			//Historical Evnets
			var xAxis:Axis = (visualization.axes as CartesianAxes).xAxis;
			var visbound:Rectangle = visualization.bounds;
			visualization.data.visit(function (h:EventSprite):void{
				var histEvt:Event = h.event;
				var start:Number = xAxis.X(histEvt.start);				
				h.x = start;
				h.y = visbound.y;		
				
				h.min = new Point(0, 0);		
				if (histEvt.end){
					var end:Number = xAxis.X(histEvt.end);
					h.max = new Point(end - start, visbound.height);				
				}else{
					h.max = new Point(0, visbound.height);
				}
				h.dirty();				
			}, Data.HISTORICAL_EVENTS);
			visualization.data.visit(function (e:EventSprite):void{
				e.x = e.y = 0;//set to origin
				if (e.event.people==null) return;
				if (e.event.people.length>0) e.points = new Array();
				for each (var person:Person in e.event.people){
					var timeline:NodeSprite = person.sprite;
					if (timeline == null || timeline.simplified) continue;
					var x:Number = timeline.block.gbLayout.xAxis.X(e.event.start); 
					var y:Number = timeline.Y(x); 
					if (isNaN(x) || isNaN(y)) continue;
					e.points.push(new Point(x, y));					
				}
				e.dirty();
			}, Data.EVENTS);
		} 
	}
}