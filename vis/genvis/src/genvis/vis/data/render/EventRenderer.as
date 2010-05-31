package genvis.vis.data.render
{
	import flare.display.TextSprite;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Graphics;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextFormat;
	
	import genvis.vis.data.EventSprite;
	import genvis.vis.lifeline.Lifeline;

	public class EventRenderer implements IRenderer	{
		private var _evtGlow:GlowFilter 	= new GlowFilter(0xfcaf3e, 0.8, 16, 16, 7);
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
			if (h.event.name == "Current Time") return;
			var label:TextSprite = h.label;
			if (h.label==null) {
				label = h.label  = new TextSprite();
				label.textFormat	= new TextFormat("Arial", Lifeline.FONTSIZE)
				h.addChild(label);
			}	
			label.text		= h.event.name;
			label.color		= 0x555753;
			label.visible	= h.visible;
			label.textMode	= TextSprite.DEVICE;
			label.mouseEnabled 		= false;
			label.mouseChildren 	= false;
			label.verticalAnchor	= TextSprite.MIDDLE;
			label.horizontalAnchor	= TextSprite.LEFT;		
			label.x = h.min.x;
			label.y = h.max.y-10;
			label.render();				
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
				g.drawCircle(pt.x, e.event.name=="Military Service"? (pt.y+2):pt.y, 4);				
			}
			g.endFill();	
//			e.filters = [_evtGlow];
		}
		
	}
}