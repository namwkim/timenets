package genvis.vis.data.render
{
	import com.degrafa.geometry.Circle;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.RadialGradientFill;
	
	import flare.display.TextSprite;
	import flare.util.Dates;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import genvis.GenVis;
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
			var g:Graphics = d.graphics;
			g.clear();		
			
			if (attr.uncertain){	
				//**************************************************//
				//	determine the position of the attribute			//
				//**************************************************//
				var lifeline:Lifeline; 
				var evtPt:EvtPt;				
				if (attr.objType == AttributeSprite.PERSON){					
					var person:Person = attr.data as Person;
					var node:NodeSprite	= person.sprite;			
					
					if (node.simplified) return;
					lifeline = node.block.gbLayout.lifeline;
					for each (evtPt in node.points){
						var refPt:Point;
						if (evtPt.type == EvtPt.BORN && attr.attrType == AttributeSprite.DATE_OF_BIRTH){
							refPt 	= node.toGlobal(evtPt.pt);
							attr.x 	= refPt.x;
							attr.y 	= refPt.y;
									
						}else if (evtPt.type == EvtPt.DEAD && attr.attrType == AttributeSprite.DATE_OF_DEATH){
							refPt 	= node.toGlobal(evtPt.pt);
							attr.x 	= refPt.x;
							attr.y 	= refPt.y;					
						}						
					}
				}else if (attr.objType == AttributeSprite.MARRIAGE){
					var marriage:Marriage 	= attr.data as Marriage;
					var node1:NodeSprite	= marriage.person1.sprite;
					var node2:NodeSprite	= marriage.person2.sprite;
					if (node1.simplified || node2.simplified) return;
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
					lifeline = node1.block.gbLayout.lifeline;
					var span:Number = (Lifeline.BETA+lifeline.lineWidth)/2;
					if (node1.block.focus!=node1 && refPt1!=null){						
						attr.y = refPt1.y + ((node1.y-node2.y)>0? -span:span);	
						attr.x = refPt1.x;					
					}else if (node2.block.focus!=node2 && refPt2!=null){
						attr.y = refPt2.y + ((node2.y-node1.y)>0? -span:span);
						attr.x = refPt2.x;
					}else{
						return;
					}		
							
				}
				
				//**************************************************//
				//	handling different representations				//
				//**************************************************//
				if (GenVis.uncType == GenVis.GRADIENT){
					if (attr.objType == AttributeSprite.PERSON){
//						var p:Person 		= attr.data as Person;
//						var n:NodeSprite	= p.sprite;
//						var gs:Number, ge:Number, gy:Number, dy:Number;
//						var uncertain:Line, gradient:LinearGradientStroke;	
//						var width:Number = n.block.gbLayout.lifeline.lineWidth;
//						var gSpan:Number = Math.abs(n.toLocalX(n.block.gbLayout.lifeline.axes.xAxis.X(p.dateOfBirth))-n.toLocalX(n.block.gbLayout.lifeline.axes.xAxis.X(Dates.addYears(p.dateOfBirth, 3))));					
//						if (attr.attrType == AttributeSprite.DATE_OF_BIRTH){												
//							gs = 0;
//							ge = -gSpan;
//							gy = 0;				
//							uncertain = new Line(gs, gy, ge, gy);
//							gradient = new LinearGradientStroke();	
//							gradient.caps = CapsStyle.NONE;						
//							gradient.gradientStops.push(new GradientStop(n.lineColor, 0, 0));	
//							gradient.gradientStops.push(new GradientStop(n.lineColor, 0, 1));				
//							gradient.weight = width;				
//							uncertain.stroke = gradient;
//							uncertain.draw(g, null);					
//						}else if (attr.attrType == AttributeSprite.DATE_OF_DEATH){
//							//if (p.isDodUncertain && p.deceased && p.dateOfDeath){						
//								gs = 0;
//								ge = gSpan;
//								gy = 0;	
//								uncertain = new Line(gs, gy, ge, gy);
//								gradient = new LinearGradientStroke();	
//								gradient.caps = CapsStyle.NONE;							
//								gradient.gradientStops.push(new GradientStop(n.lineColor, n.lineAlpha, 0));
//								gradient.gradientStops.push(new GradientStop(n.lineColor, 0, 1));
//								gradient.weight = width;				
//								uncertain.stroke = gradient;
//								uncertain.draw(g, null);					
//							//}
//						}
					}else if (attr.objType == AttributeSprite.MARRIAGE){
						var circle:Circle = new Circle(0, 0, attr.size);
						var rGradient:RadialGradientFill = new RadialGradientFill();
						rGradient.gradientStops.push(new  GradientStop(attr.fillColor, attr.fillAlpha, 0.3));
						rGradient.gradientStops.push(new GradientStop(attr.fillColor, 0.2, 0.8));					
						circle.fill = rGradient;
						circle.draw(g, null);
					}
						
				}else if (GenVis.uncType == GenVis.QSMARK){
				var label:TextSprite = attr.label;				
					if (attr.label==null) {
						label = attr.label  = new TextSprite();
						label.textFormat	= new TextFormat("Arial", Lifeline.FONTSIZE)
						attr.addChild(label);
					}	
					label.text 		= "?";
					label.size		= 24;
					label.visible	= d.visible;
					label.textMode	= TextSprite.DEVICE;
					label.mouseEnabled 		= false;
					label.mouseChildren 	= false;
					label.verticalAnchor	= TextSprite.MIDDLE;
					label.horizontalAnchor	= TextSprite.CENTER;
					if (attr.objType == AttributeSprite.PERSON){	
						if (attr.attrType == AttributeSprite.DATE_OF_BIRTH){
							if (lifeline.style == Lifeline.LABELINSIDE){								
								label.y = (lifeline.lineWidth-Lifeline.FONTSIZE)/2-Lifeline.BOTTOMMARGIN;
							}							
							label.x = -label.size/2;
						}else if (attr.attrType == AttributeSprite.DATE_OF_DEATH){
							if (person.sprite.block.gbLayout.lifeline.style == Lifeline.LABELINSIDE){
								label.y = (lifeline.lineWidth-Lifeline.FONTSIZE)/2-Lifeline.BOTTOMMARGIN;							
							}else{
								//label.y = -Lifeline.FONTSIZE/2-Lifeline.BOTTOMMARGIN;;
							}
							label.x = label.size/2;
						}
					}else if (attr.objType == AttributeSprite.MARRIAGE){
						if (attr.attrType == AttributeSprite.MARRIAGE_DATE){
							label.x = -label.size;
						}else if (attr.attrType == AttributeSprite.DIVORCE_DATE){
							label.x = label.size;
						}							
					}
			
				}else if (GenVis.uncType == GenVis.NOMARKER){
					
				}

				

					//draw uncertain marriage marker					
//					var mg:Graphics = attr.marker.graphics;
//					//inner circle
//					mg.clear();
//					mg.lineStyle(0, 0, 0);
//					mg.beginFill(color, alpha);
//					mg.drawCircle(0, 0, size);					
//					mg.endFill();
					//outer radial gradient circle
				

				//draw label
				//label.render();
			}
		}
		
	}
}