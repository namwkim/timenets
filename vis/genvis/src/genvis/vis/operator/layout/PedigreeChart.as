package genvis.vis.operator.layout
{
	import flare.vis.data.NodeSprite;
	
	import genvis.data.Person;
	import genvis.vis.lifeline.Lifeline;
	
	public class PedigreeChart extends LifelineLayout
	{
//		public function PedigreeChart(focus:Person, xAxisField:String=null, yAxisField:String=null, nodeType:Number=Lifeline.LINEBSPLINE)
//		{
//			super(focus, xAxisField, yAxisField, nodeType);
//		}
//
//		protected override function specifyShapes():void{
//			var focusNode:NodeSprite = _nodeMap[_focus.id];
//			_lifeline.generateLifeline(focusNode, Lifeline.UP);
//			specifyShapesOfSpouses(focusNode);
//			specifyShapesOfAncestors(focusNode);
//		}
//		public function specifyShapesOfSpouses(focusNode:NodeSprite):void{
//			for each (var spouse:Person in focusNode.data.spouses){//earliest  marriage first
//				_lifeline.generateLifeline(_nodeMap[spouse.id], Lifeline.DOWN, false, focusNode.data as Person);				
//			}			
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
//		protected override function arrangeLifelines():void{
//			var yorder:Number = 0;			
//			_focus.yorder = yorder;
//			//focusNode's spouses
//			arrangeSpouses(yorder+1, _focus);
//			//focusNode's descendants
//			var allocator:Object = new Object();
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
	}
}