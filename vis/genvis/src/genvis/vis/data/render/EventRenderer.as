package genvis.vis.data.render
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import genvis.vis.data.EventSprite;

	public class EventRenderer implements IRenderer	{
		private static const lineColor:Number = 0xd3d7cf;
		private static const fillColor:Number = 0xd3d7cf;
		public function EventRenderer(){
		}

		public function render(d:DataSprite):void{
			if (d.visible == false) return;
			var evt:EventSprite = d as EventSprite;
			if (evt.event.historical){
				renderHistoricalEvent(evt);
			}else{
				renderEvent(evt);
			}
		}
		public function renderHistoricalEvent(h:EventSprite):void {
			var g:Graphics = h.graphics;
			g.clear();		
//			var histEvt:HistoricalEvent = h.event;
//			if (histEvt.end){ //range event
				g.lineStyle();
				g.beginFill(h.fillColor, h.fillAlpha);
				g.drawRect(h.min.x, h.min.y, h.max.x-h.min.x, h.max.y-h.min.y);				
				g.endFill();
						
//			}else{
//				
//			}
		}
		/**
		 * place visual markers on timelines of people involved in this event.
		 *
		 */
	 	
		public function renderEvent(e:EventSprite):void{
			var g:Graphics = e.graphics;
			g.clear();	
			g.lineStyle();
			g.beginFill(e.fillColor, e.fillAlpha);		
			for each (var pt:Point in e.points){//draw circle
				g.drawCircle(pt.x, pt.y, 4);				
			}
			g.endFill();	
		}
		
	}
}