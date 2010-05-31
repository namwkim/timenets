package genvis.vis.data.render
{
	import com.degrafa.geometry.CubicBezier;
	import com.degrafa.geometry.Line;
	import com.degrafa.paint.GradientStop;
	import com.degrafa.paint.LinearGradientStroke;
	import com.degrafa.paint.SolidStroke;
	
	import flare.util.Dates;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	import genvis.GenVis;
	import genvis.data.EvtPt;
	import genvis.data.Person;
	import genvis.util.GraphicsUtil;
	import genvis.vis.data.BlockSprite;
	import genvis.vis.data.EdgeSprite;
	import genvis.vis.data.NodeSprite;
	import genvis.vis.lifeline.Lifeline;
	
	public class LifelineRenderer implements IRenderer
	{
		
		public function LifelineRenderer(lifelineType:int, layoutMode:int) 
		{
			_lifelineType = lifelineType;
			_layoutMode	  = layoutMode;
		}

		private var _lifelineType:Number;
		private var _layoutMode:Number;
		public function set layoutMode(m:int):void { _layoutMode = m; }
		public function renderLine(n:NodeSprite):void{
			var g:Graphics = n.graphics;					
			//2. draw lifeline		
			g.lineStyle( n.lineWidth, n.lineColor, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);	
			for each (var evt:EvtPt  in n.points){				
				switch (evt.type){
				case EvtPt.BORN:
					g.moveTo(evt.x,evt.y);
					break;
				case EvtPt.DATING:
				case EvtPt.MARRIAGE:
				case EvtPt.DIVORCE:
				case EvtPt.RESTING:
				case EvtPt.DEAD:				
					g.lineTo(evt.x, evt.y);
					break;
				}
			}

		}
//		public function test(n:NodeSprite):void{
//			var g:Graphics = n.graphics;
//			var points:Array = new Array();
//			for each (var evtPt:EvtPt in n.points){
//				points.push(evtPt.pt);
//			}
//			CubicBezier.curveThroughPoints(g, points);
//		}
		public function renderLineSpline(n:NodeSprite):void{
			if (!n.data) return;
			
			var g:Graphics = n.graphics;
			//2.draw lifeline
			var color:Number = n.lineColor;
			var width:Number = n.block.gbLayout.lifeline.lineWidth;
			//Draw Gradient line
			
			var p:Person = (n.data as Person);
			var gs:Number, ge:Number, gy:Number, dy:Number;
			var uncertain:Line, gradient:LinearGradientStroke;	
			if (p.isDobUncertain && GenVis.uncType == GenVis.GRADIENT){
				gs = 0;
				ge = n.toLocalX(n.block.gbLayout.lifeline.axes.xAxis.X(Dates.addYears(p.dateOfBirth, -3)));
				gy = 0;				
				uncertain = new Line(gs, gy, ge, gy);
				gradient = new LinearGradientStroke();	
				gradient.caps = CapsStyle.NONE;						
				gradient.gradientStops.push(new GradientStop(n.lineColor, 0, 0));	
				gradient.gradientStops.push(new GradientStop(n.lineColor, n.lineAlpha, 1));				
				gradient.weight = width;				
				uncertain.stroke = gradient;
				uncertain.draw(g, null);				
			}
			g.lineStyle(width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			var bezier:CubicBezier, stroke:SolidStroke, evt:EvtPt;
			stroke = new SolidStroke(color, n.lineAlpha, width);
			stroke.caps = CapsStyle.NONE;
			for (var i:int=0; i<n.points.length; i++){		
				evt = n.points[i];		
				switch (evt.type){
				case EvtPt.BORN:
					g.moveTo(evt.x,evt.y);
					break;
				case EvtPt.DATING:
					g.lineTo(evt.x, evt.y);
					break;
				case EvtPt.MARRIAGE:
					var datEvt:EvtPt = n.points[i-1];
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//					Shapes.drawCubic(g, datEvt.x, datEvt.y, (datEvt.x+evt.x)/2, datEvt.y, 
//							(datEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(datEvt.x, datEvt.y, (datEvt.x+evt.x)/2, datEvt.y, (datEvt.x+evt.x)/2, evt.y, evt.x, evt.y);					
					bezier.stroke = stroke;
					bezier.draw(g, null);
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);		
					g.moveTo(evt.x, evt.y);
					break;
				case EvtPt.DIVORCE:
					g.lineTo(evt.x, evt.y);
					var resEvt:EvtPt = n.points[i+1];					
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//					Shapes.drawCubic(g, resEvt.x, resEvt.y, (resEvt.x+evt.x)/2, resEvt.y, 
//							(resEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(resEvt.x, resEvt.y, (resEvt.x+evt.x)/2, resEvt.y, (resEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier.stroke = stroke;	
					bezier.decorators.pus
					bezier.draw(g, null);				
					break;					
				case EvtPt.RESTING:
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
					g.moveTo(evt.x, evt.y);
				case EvtPt.DEAD:				
					g.lineTo(evt.x, evt.y);
					break;				
				case EvtPt.ROUTESTART:
					g.lineTo(evt.x, evt.y);
					break;
				case EvtPt.ROUTEEND:
					var routeStart:EvtPt = n.points[i-1];
//					Shapes.drawCubic(g, routeStart.x, routeStart.y, (routeStart.x+evt.x)/2, routeStart.y, 
//							(routeStart.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(routeStart.x, routeStart.y, (routeStart.x+evt.x)/2, routeStart.y, (routeStart.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier.stroke = stroke;
					bezier.draw(g, null);		
					g.moveTo(evt.x, evt.y);
					break;
				}
			}
			if (p.isDodUncertain && p.deceased && p.dateOfDeath && GenVis.uncType == GenVis.GRADIENT){						
				gs = evt.x;
				ge = n.toLocalX(n.block.gbLayout.lifeline.axes.xAxis.X(Dates.addYears(p.dateOfDeath, 3)));;
				gy = evt.y;	
				uncertain = new Line(gs, gy, ge, gy);
				gradient = new LinearGradientStroke();	
				gradient.caps = CapsStyle.NONE;							
				gradient.gradientStops.push(new GradientStop(n.lineColor, n.lineAlpha, 0));
				gradient.gradientStops.push(new GradientStop(n.lineColor, 0, 1));
				gradient.weight = width;				
				uncertain.stroke = gradient;
				uncertain.draw(g, null);					
			}			
		}
		public function renderSpline(n:NodeSprite):void{
			var g:Graphics = n.graphics;
		}
		public function renderSimplifiedLifeline(n:NodeSprite):void{
			if (!n.data) return;
			
			var g:Graphics = n.graphics;
			//2.draw lifeline
			var color:Number = n.lineColor;
			var width:Number = n.block.gbLayout.lifeline.lineWidth;
			//Draw Gradient line
			
			var p:Person = (n.data as Person);
			
			var gs:Number, ge:Number, gy:Number, dy:Number;
			//var gradientBoxMatrix:Matrix;
			var marGradient:LinearGradientStroke, divGradient:LinearGradientStroke;
			marGradient = new LinearGradientStroke();	divGradient = new LinearGradientStroke();
			marGradient.caps = divGradient.caps = CapsStyle.NONE;						
			marGradient.gradientStops.push(new GradientStop(color, 0, 0));	
			marGradient.gradientStops.push(new GradientStop(color,n.lineAlpha, 1));		
			divGradient.gradientStops.push(new GradientStop(color, n.lineAlpha, 0));	
			divGradient.gradientStops.push(new GradientStop(color, 0, 1));					
			marGradient.weight = divGradient.weight = width;
			g.lineStyle(width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			var bezier:CubicBezier, stroke:SolidStroke, evt:EvtPt;
			stroke = new SolidStroke(color, n.lineAlpha, width);
			stroke.caps = CapsStyle.NONE;
			for (var i:int=0; i<n.points.length; i++){		
				evt = n.points[i];		
				switch (evt.type){

				case EvtPt.MARRIAGE:
					var datEvt:EvtPt = n.points[i-1];
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//					Shapes.drawCubic(g, datEvt.x, datEvt.y, (datEvt.x+evt.x)/2, datEvt.y, 
//							(datEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(datEvt.x, datEvt.y, (datEvt.x+evt.x)/2, datEvt.y, (datEvt.x+evt.x)/2, evt.y, evt.x, evt.y);					
					bezier.stroke = marGradient;
					bezier.draw(g, null);
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);		
					g.moveTo(evt.x, evt.y);
					break;
				case EvtPt.DIVORCE:
					g.lineTo(evt.x, evt.y);
					var resEvt:EvtPt = n.points[i+1];					
					//g.lineStyle( width, color, n.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//					Shapes.drawCubic(g, resEvt.x, resEvt.y, (resEvt.x+evt.x)/2, resEvt.y, 
//							(resEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(resEvt.x, resEvt.y, (resEvt.x+evt.x)/2, resEvt.y, (resEvt.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier.stroke = divGradient;	
					bezier.draw(g, null);				
					break;					
				case EvtPt.DEAD:				
					g.lineTo(evt.x, evt.y);
					break;				
				case EvtPt.ROUTESTART:
					g.lineTo(evt.x, evt.y);
					break;
				case EvtPt.ROUTEEND:
					var routeStart:EvtPt = n.points[i-1];
//					Shapes.drawCubic(g, routeStart.x, routeStart.y, (routeStart.x+evt.x)/2, routeStart.y, 
//							(routeStart.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier = new CubicBezier(routeStart.x, routeStart.y, (routeStart.x+evt.x)/2, routeStart.y, (routeStart.x+evt.x)/2, evt.y, evt.x, evt.y);
					bezier.stroke = stroke;
					bezier.draw(g, null);		
					g.moveTo(evt.x, evt.y);
					break;
				}
			}
		}
		public function renderBlock(b:BlockSprite):void {
			var g:Graphics = b.graphics;
			g.clear();			
			if (b.visible == false) return;
			if (b.aggregated && b.focus.parentNode.visible && b.parentBlock.aggregated==false){
				var pn:NodeSprite = b.focus.parentNode;
				var upward:Boolean = (b.ty - pn.block.ty)>0? false:true;	
				var fPerson:Person = b.focus.data as Person;				
				g.lineStyle(b.lineWidth, b.selected? 0x73d216:b.focus.lineColor, b.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.beginFill(b.selected? 0x73d216:b.focus.lineColor, b.fillAlpha);
										
				var start:Point = new Point;
				var end:Point 	= new Point;
				var lifeline:Lifeline = b.gbLayout.lifeline;
				var height:Number = Lifeline.GAMMA+lifeline.lineWidth;				
				if (b.focus.type == NodeSprite.ANCESTOR){					
					start.x = b.toLocalX(b.gbLayout.xAxis.X(pn.data.dateOfBirth));
					start.y = b.toLocalY(pn.toGlobalY(0));	
					end.x 	= start.x;					
					end.y	= start.y + (upward? -height:height);				
				}else if (b.focus.type == NodeSprite.DESCENDANT){
					var e:EdgeSprite = b.focus.inEdge;									
					if (e.outOfWedlock){
						var startPts:Array = e.startOutOfWedlock;
						if (startPts.length==2){
							end.x = b.toLocalX(e.end.x);
							end.y = b.toLocalY(pn.toGlobalY(0)) + (upward? -height:height);
							if (e.direction==EdgeSprite.UP){	
								start = b.toLocal(startPts[1]);									
								GraphicsUtil.drawTriangleUp(g, b.toLocalX(startPts[0].x), b.toLocalY(startPts[0].y));
							}else{
								start = b.toLocal(startPts[0]);
								GraphicsUtil.drawTriangleUp(g, b.toLocalX(startPts[1].x), b.toLocalY(startPts[1].y));
							}
						}
					}else{
						start = b.toLocal(e.start);
						end.x = b.toLocalX(e.end.x);
						end.y = b.toLocalY(pn.toGlobalY(0)) + (upward? -height:height);
					}
	
				}
				GraphicsUtil.drawDashedArrow(g, start, end, true, {thickness:b.lineWidth, color:(b.selected? 0x73d216:b.focus.lineColor), alpha:b.lineAlpha});
				g.endFill();					
			}
			
			if (GenVis.drawBlock && b.aggregated == false) {
				g.lineStyle(b.lineWidth, b.selected? 0x73d216:b.lineColor, b.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.beginFill(b.selected? 0x73d216:b.fillColor, b.fillAlpha);		
				g.drawRect(0, 0, b.bbox.width, b.bbox.height);
				g.endFill();	
			}
		}
		public function renderLifeline(n:NodeSprite):void {			
			var g:Graphics = n.graphics;
			g.clear();			
//			//draw bounding box
//			if (n.status == NodeSprite.FOCUSED && n.block.gbLayout.doiEnabled == true){
//				g.beginFill(n.lineColor, n.fillAlpha);
//				g.lineStyle(2, n.lineColor, 0.2, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//				g.drawRect(n.bbox.min.x, n.bbox.min.y, n.bbox.width, n.bbox.height);
//				g.endFill();
//			}
			if (n.points == null) return;	
			if (n.simplified == false){
				switch(_lifelineType){
					case Lifeline.LINE:
						renderLine(n);
						break;
					case Lifeline.SPLINE:
						renderSpline(n);
						break;
					case Lifeline.LINESPLINE:
						renderLineSpline(n);
						break;
				}
			}else{
				renderSimplifiedLifeline(n);
			}
		}
		/**
		 * only used for lifelineType == (Line || LineSpline)
		 **/
		protected function renderEdge(e:EdgeSprite):void{
			var g:Graphics = e.graphics;
			g.clear();		
			if (e.draw == false) return;
			//1. draw edge	
			var child:Person = e.child.data as Person;
			if (child == null) return;		
			if (child.gender == Person.MALE){
				g.lineStyle(e.lineWidth, 0x3465a4, 0.6, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.beginFill(0x3465a4, 0.6);
			}else if (child.gender == Person.FEMALE){
				g.lineStyle(e.lineWidth, 0xcc0000, 0.6, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.beginFill(0xcc0000, 0.6);
			}else{
				g.lineStyle(e.lineWidth, 0x555753, 0.6, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.beginFill(0x555753, 0.6);				
			}
			if (e.outOfWedlock){
				var startPts:Array = e.startOutOfWedlock;
				if (startPts.length==2){
					if (e.direction==EdgeSprite.UP){
						GraphicsUtil.drawDashedArrow(g, startPts[1], e.end);
						GraphicsUtil.drawTriangleUp(g, startPts[0].x, startPts[0].y);
					}else{
						GraphicsUtil.drawDashedArrow(g, startPts[0], e.end);
						GraphicsUtil.drawTriangleUp(g, startPts[1].x, startPts[1].y);
					}
				}
			}else{
				GraphicsUtil.drawDashedArrow(g, e.start, e.end);
			}
			
			g.endFill();
		}
		/** @inheritDoc */
		public function render(d:DataSprite):void
		{
			if (d.visible == false) return;
			
			if (d is BlockSprite){				
				renderBlock(d as BlockSprite);
			}else if (d is NodeSprite){ 				
//				if ((d as NodeSprite).type == NodeSprite.ANCESTOR) {
//					trace((d as NodeSprite).willVisible == (d as NodeSprite).visible);
//					trace((d as NodeSprite).data.name);
//				}				
				renderLifeline(d as NodeSprite);
			}else if (d is EdgeSprite){				
				renderEdge(d as EdgeSprite);
			}

//			if (d.lineAlpha > 0) { 
//				g.lineStyle(d.lineWidth, d.lineColor, d.lineAlpha);
//			}
//
//
//			switch(_mode){
//				case Lifeline.LINE:
//					if ((d.points!=null) && d.visible) {
//						if (d.props.divPts){
//							g.lineStyle(d.lineWidth-1, 0xbabdb6, d.lineAlpha);
//							GraphicsUtil.drawLine(g, d.props.divPts[0], d.props.divPts[1]);
//						}
//						g.lineStyle(d.lineWidth, d.lineColor, d.lineAlpha);
//						for (var i:uint=0; i<d.points.length; i++) {					
//							g.lineTo(d.points[i].x, d.points[i].y);							
//						}						
//					}
//				break;
//				case Lifeline.SPLINE:
//					if ((d.points!=null) && d.visible) {
//						//construct ctrl points from d.points
//						var ctrlPts:Array = new Array();
//						for each(var point:Point in d.points){
//							ctrlPts.push(point.x);
//							ctrlPts.push(point.y);
//						}
//						
//						//draw ctrl points
//		//				for (i=0; i<ctrlPts.length; i+=2){
//		//					g.drawCircle(ctrlPts[i],ctrlPts[i+1],2);
//		//				}
//						Shapes.drawBSpline(g, ctrlPts, 2+(ctrlPts.length-4)/2);					
//					}
//				break;
//				case Lifeline.LINESPLINE:
//					if ((d.points!=null) && d.visible) {
//						if (d.props.divPts){
//							g.lineStyle(d.lineWidth-1, 0xbabdb6, d.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//							g.beginFill(0xbabdb6, d.lineAlpha);
//							GraphicsUtil.drawDashedArrow(g, d.props.divPts[1], d.props.divPts[0]);
//							g.endFill();
//						}
//						//construct ctrl points from d.points
//						g.lineStyle(d.lineWidth, d.lineColor, d.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//						var ctrlPts:Array = new Array();
//						for each(var point:Point in d.points){
//							ctrlPts.push(point.x);
//							ctrlPts.push(point.y);
//						}						
//						//draw ctrl points
//		//				for (i=0; i<ctrlPts.length; i+=2){
//		//					g.drawCircle(ctrlPts[i],ctrlPts[i+1],2);
//		//				}
//						Shapes.drawBSpline(g, ctrlPts, 2+(ctrlPts.length-4)/2);					
//					}					
//				break;
//			}	
//			if (d.props.isSelected){
//				d.props.box = calculateBoundingBox(d.points);
//				g.lineStyle(d.lineWidth, 0x73d216, d.lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
//				g.drawRect(d.props.box.x-2, d.props.box.y-2, d.props.box.width+2, d.props.box.height+2);
//			}		
//			var estVis:Shape = new Shape();
//			estVis.graphics.lineStyle(1, 0xfcaf3e, d.lineAlpha);
//			estVis.graphics.beginFill(0xfcaf3e, 1);
//						//visualize estimated Data
//			for each (var pt:Point in d.props.estPts){
//				estVis.graphics.drawCircle(pt.x, pt.y, 2);
//			}
//			estVis.graphics.endFill();
//			d.addChild(estVis);

		}		

//		private function calculateBoundingBox(points:Array):Rectangle{
//			var min:Point = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
//			var max:Point = new Point(Number.MIN_VALUE,Number.MIN_VALUE);
//			for each (var pt:Point in points){
//				if (pt.x < min.x ) min.x = pt.x;
//				if (pt.x > max.x ) max.x = pt.x;
//				if (pt.y < min.y ) min.y = pt.y;
//				if (pt.y > max.y ) max.y = pt.y;				
//			}
//			return new Rectangle(min.x, min.y, max.x - min.x, max.y - min.y);
//		}

	}

	
}