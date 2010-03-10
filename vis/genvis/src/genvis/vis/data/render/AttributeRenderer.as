package genvis.vis.data.render
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import genvis.data.EvtPt;
	import genvis.data.Marriage;
	import genvis.data.Person;
	import genvis.vis.data.AttributeSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.lifeline.Lifeline;

	public class AttributeRenderer implements IRenderer
	{
		public function AttributeRenderer(){
		}

		public function render(d:DataSprite):void{
			if (!d.visible) return;
			var attr:AttributeSprite = d as AttributeSprite;
			if (attr.uncertain){
				var label:TextSprite = attr.label;				
				if (attr.label==null) {
					label = attr.label  = new TextSprite();
					label.textFormat	= new TextFormat("Arial", Lifeline.FONTSIZE)
					attr.addChild(label);
				}	
				label.text 		= "?";
				label.visible	= d.visible;
				label.textMode	= TextSprite.DEVICE;
				label.mouseEnabled 		= false;
				label.mouseChildren 	= false;
				label.verticalAnchor	= TextSprite.MIDDLE;
				label.horizontalAnchor	= TextSprite.CENTER;
				
				var lifeline:Lifeline; 
				var evtPt:EvtPt;
				//Determine label position
				if (attr.objType == AttributeSprite.PERSON){					
					var person:Person = attr.data as Person;
					var node:NodeSprite	= person.sprite;
					lifeline = node.block.gbLayout.lifeline;
					for each (evtPt in node.points){
						var refPt:Point;
						if (evtPt.type == EvtPt.BORN && attr.attrType == AttributeSprite.DATE_OF_BIRTH){
							refPt 	= node.toGlobal(evtPt.pt);
							attr.x 	= refPt.x;
							attr.y 	= refPt.y;
							if (lifeline.style == Lifeline.LABELINSIDE){								
								label.y = (lifeline.lineWidth-Lifeline.FONTSIZE)/2-Lifeline.BOTTOMMARGIN;
							}else{						
								//label.y = -Lifeline.FONTSIZE/2-Lifeline.BOTTOMMARGIN;;
							}
							label.x = -5;
						}else if (evtPt.type == EvtPt.DEAD && attr.attrType == AttributeSprite.DATE_OF_DEATH){
							refPt 	= node.toGlobal(evtPt.pt);
							attr.x 	= refPt.x;
							attr.y 	= refPt.y;
							if (person.sprite.block.gbLayout.lifeline.style == Lifeline.LABELINSIDE){
								label.y = (lifeline.lineWidth-Lifeline.FONTSIZE)/2-Lifeline.BOTTOMMARGIN;							
							}else{
								//label.y = -Lifeline.FONTSIZE/2-Lifeline.BOTTOMMARGIN;;
							}
							label.x = 5;
						}						
					}
				}else if (attr.objType == AttributeSprite.MARRIAGE){
					var marriage:Marriage 	= attr.data as Marriage;
					var node1:NodeSprite	= marriage.person1.sprite;
					var node2:NodeSprite	= marriage.person2.sprite;
					var refPt1:Point;
					var refPt2:Point;
					for each (evtPt in node1.points){
						if (evtPt.date == marriage.startDate  && attr.attrType == AttributeSprite.MARRIAGE_DATE && evtPt.type == EvtPt.MARRIAGE){
							refPt1 = node1.toGlobal(evtPt.pt);
						}
						if (evtPt.date == marriage.endDate  && attr.attrType == AttributeSprite.DIVORCE_DATE && evtPt.type == EvtPt.DIVORCE){
							refPt1 = node1.toGlobal(evtPt.pt);
						}						
					}
					for each (evtPt in node2.points){
						if (evtPt.date == marriage.startDate  && attr.attrType == AttributeSprite.MARRIAGE_DATE && evtPt.type == EvtPt.MARRIAGE){
							refPt2 = node2.toGlobal(evtPt.pt);
						}
						if (evtPt.date == marriage.endDate  && attr.attrType == AttributeSprite.DIVORCE_DATE && evtPt.type == EvtPt.DIVORCE){
							refPt2 = node2.toGlobal(evtPt.pt);
						}						
					}
					attr.x 	= refPt1.x;
					attr.y 	= (refPt1.y+refPt2.y)/2;
					if (attr.attrType == AttributeSprite.MARRIAGE_DATE){
						label.x = -20;
					}else if (attr.attrType == AttributeSprite.DIVORCE_DATE){
						label.x = 20;
					}
										
				}
				
				label.render();
			}else{
				if (attr.label) attr.label.visible = false;
			}
		}
		
	}
}