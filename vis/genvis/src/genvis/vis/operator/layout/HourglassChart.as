package genvis.vis.operator.layout
{
	import flare.vis.data.NodeSprite;
	
	import genvis.data.Person;
	import genvis.vis.lifeline.Lifeline;
	
	public class HourglassChart extends LifelineLayout
	{
//		public function HourglassChart(focus:Person, xAxisField:String=null, yAxisField:String=null, nodeType:Number=Lifeline.LINE)
//		{
//			super(focus, xAxisField, yAxisField, nodeType);
//		}
//		protected override function specifyShapes():void{
//			var focusNode:NodeSprite = _nodeMap[_focus.id];
//			_lifeline.generateLifeline(focusNode, Lifeline.UP);
//			specifyShapesOfSpouses(focusNode);
//			specifyShapesOfDescendants(focusNode);
//			specifyShapesOfAncestors(focusNode);
//		}
//		public function specifyShapesOfAncestorSpouses(node:NodeSprite, marDir:Number, directSpouse:NodeSprite):void{
//			for each (var spouse:Person in node.data.spouses){//earliest  marriage first
//				if (spouse.id == directSpouse.data.id) continue;
//				_lifeline.generateLifeline(_nodeMap[spouse.id], marDir, false, node.data as Person);				
//			}	
//		}
//		public function specifyShapesOfAncestors(node:NodeSprite):void{
//			if (node.data.parents.length == 0)
//				return;
//			//derive father and mother of the decendant
//			var fatherNode:NodeSprite, motherNode:NodeSprite;
//			if (node.data.parents.length == 2){				
//				fatherNode = _nodeMap[node.data.father.id];
//				motherNode = _nodeMap[node.data.mother.id];
//				
//				_lifeline.generateLifeline(fatherNode, Lifeline.DOWN, true);
//				specifyShapesOfAncestorSpouses(fatherNode, Lifeline.DOWN, motherNode);
//				_lifeline.generateLifeline(motherNode, Lifeline.UP, true);
//				specifyShapesOfAncestorSpouses(motherNode, Lifeline.UP, fatherNode);
//				
//				specifyShapesOfAncestors(fatherNode); //paternal
//				specifyShapesOfAncestors(motherNode); //maternal
//			}			
//			return;
//		}	
//		public function specifyShapesOfDescendants(node:NodeSprite):void{
//			if (node.data.children.length == 0){//recursive loop end condition
//				return;
//			}
//			var now:Date = new Date();
//
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
//				_lifeline.generateLifeline(_nodeMap[spouse.id], Lifeline.DOWN, focusNode.data as Person);				
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
//			var parents:Array = _focus.parents;
//			allocator.yorder = yorder -1;
//			if (parents.length == 2){			
//				arrangePatriachalAncestors(allocator, parents[0], true, parents[1]);//male on upper side
//				allocator.yorder = yorder -2;
//				arrangeMatriachalAncestors(allocator, parents[1], false, parents[0]);//spouse on down side
//			}				
//		}
//		public function arrangeSpouses(yorder:Number, person:Person):void{
//			for each (var spouse:Person in person.spouses){
//				spouse.yorder = yorder++;
//			}
//		}
//		public function arrangeSpousesOfAncestor(allocator:Object, person:Person, directSpouse:Person, increasing:Boolean, reverse:Boolean):void{
//			//set y orders of indirect spouses
//			var spouses:Array = reverse!=true? person.spouses : person.spouses.reverse();
//			for each (var spouse:Object in spouses){
//				if (spouse.id == directSpouse.id)
//					continue;
//				spouse.yorder = increasing==true? allocator.yorder++ : allocator.yorder--;
//			}
//		}
//		public function arrangeMatriachalAncestors(allocator:Object, person:Person, upward:Boolean, directSpouse:Person):void{
//			
//			var parents:Array = person.parents;
//			if (!isNaN(person.yorder)) return;
//			if (parents.length == 2){				
//				if (upward == true){//up side
//					arrangeMatriachalAncestors(allocator, parents[0], true, parents[1]);
//					arrangeMatriachalAncestors(allocator, parents[1], false, parents[0]);
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, false, true);
//					person.yorder = allocator.yorder--;
//					
//				}else{//down side
//					person.yorder = allocator.yorder--;
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, false, false);
//					arrangeMatriachalAncestors(allocator, parents[0], true, parents[1]);
//					arrangeMatriachalAncestors(allocator, parents[1], false, parents[0]);			
//				}				
//			}else{
//				if (upward == true){
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, false, true);
//					person.yorder = allocator.yorder--;
//				}else{
//					person.yorder = allocator.yorder--;
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, false, false);
//					
//				}
//			}
//		}
//		public function arrangePatriachalAncestors(allocator:Object, person:Person, upward:Boolean, directSpouse:Person):void{
//			
//			var parents:Array = person.parents;
//			if (!isNaN(person.yorder)) return;
//			if (parents.length == 2){				
//				if (upward == true){//up side
//					person.yorder = allocator.yorder++;
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, true, false);
//					arrangePatriachalAncestors(allocator, parents[1], false, parents[0]);
//					arrangePatriachalAncestors(allocator, parents[0], true, parents[1]);
//					
//				}else{//down side					
//					arrangePatriachalAncestors(allocator, parents[1], false, parents[0]);
//					arrangePatriachalAncestors(allocator, parents[0], true, parents[1]);						
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, true, true);
//					person.yorder = allocator.yorder++;		
//				}				
//			}else{
//				
//				if (upward == true){
//					person.yorder = allocator.yorder++;
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, true, false);
//				}else{
//					arrangeSpousesOfAncestor(allocator, person, directSpouse, true, true);
//					person.yorder = allocator.yorder++;
//				}
//				
//			}
//
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