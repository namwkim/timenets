package genvis.vis.operator.layout
{
	import flare.vis.data.NodeSprite;
	
	import genvis.data.Person;
	import genvis.vis.lifeline.Lifeline;
	
	public class DescendantChart extends LifelineLayout
	{
//		public function DescendantChart(focus:Person, xAxisField:String=null, yAxisField:String=null, nodeType:Number=Lifeline.LINEBSPLINE)
//		{
//			super(focus, xAxisField, yAxisField, nodeType);
//		}
//
//		protected override function specifyShapes():void{
//
//			var focusNode:NodeSprite = _nodeMap[_focus.id];
//			_lifeline.generateLifeline(focusNode, Lifeline.UP, false);
//			specifyShapesOfSpouses(focusNode);
//			specifyShapesOfDescendants(focusNode);
//		}
//		public function specifyShapesOfDescendants(node:NodeSprite):void{
//			if (node.data.children.length == 0){//recursive loop end condition
//				return;
//			}
//			for each (var child:Person in node.data.children){
//				var childNode:NodeSprite = _nodeMap[child.id];
//				//generate ctrl points for the child
//				_lifeline.generateLifeline(childNode, Lifeline.DOWN);
//				if (child.spouses.length>0){
//					for each (var spouse:Person in child.spouses){
//						_lifeline.generateLifeline(_nodeMap[spouse.id], Lifeline.UP, false, child);
//					}
//				}
//				specifyShapesOfDescendants(childNode);
//			}
//		}
//		public function specifyShapesOfSpouses(focusNode:NodeSprite):void{
//			for each (var spouse:Person in focusNode.data.spouses){//earliest  marriage first
//				_lifeline.generateLifeline(_nodeMap[spouse.id], Lifeline.DOWN, false, focusNode.data as Person);				
//				//TODO: add death points for divorce case in a way of preventing overlaps with other spouses
//			}			
//		}
//		protected override function arrangeLifelines():void{
//			var yorder:Number = 0;			
//			_focus.yorder = yorder;
//			//focusNode's spouses
//			arrangeSpouses(yorder+1, _focus);
//			//focusNode's descendants
//			var allocator:Object = new Object();
//			allocator.yorder = yorder -1;
//			arrangeDescendants(allocator, _focus);
//		
//		}
//		public function arrangeSpouses(yorder:Number, person:Person):void{
//			for each (var spouse:Person in person.spouses){
//				spouse.yorder = yorder++;
//			}
//		}
//		public function arrangeDescendants(allocator:Object, parent:Person):void{	
//			// determine y orders of its children
//			//1 sort children in yougest first order
//			for each (var child:Person in parent.children){
//				//determine child's y order
//				child.yorder = allocator.yorder--;
//				
//				//determine y orders of its spouses
//				if (child.spouses.length>0){
//					for each (var spouse:Person in child.spouses){
//						spouse.yorder = allocator.yorder--; //all the spouses have the same y order for each descendant
//					}
//				}
//				//determine y orders of its descendant recursively
//				arrangeDescendants(allocator, child);
//			}
//		}
	}
}