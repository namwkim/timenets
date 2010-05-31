package genvis.util
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	
	public class GraphicsUtil
	{
		public static function drawLine(g:Graphics, p1:Point, p2:Point):void{
			g.moveTo(p1.x, p1.y);
			g.lineTo(p2.x, p2.y);
		}
		public static function drawDashedLine(g:Graphics, p1:Point, p2:Point, dashLen:Number = 3, spaceLen:Number = 2):void{
			var diffX:Number = p2.x-p1.x;
			var diffY:Number = p2.y-p1.y;
			var len:Number  = Math.sqrt(diffX*diffX + diffY*diffY);
			var normX:Number = diffX*(1/len);
			var normY:Number = diffY*(1/len);
			
			var startPt:Point = new Point();
			var endPt:Point   = new Point();
			startPt.x	= p1.x; startPt.y	= p1.y;
			var drawDash:Boolean 	= true;	
			var totalLen:Number 	= 0;	
			while(totalLen < len){
				totalLen += dashLen;	
				var step:Number = totalLen>len? (dashLen - (totalLen-len)) : dashLen;
				endPt.x = startPt.x + step*normX;
				endPt.y = startPt.y + step*normY;					
				g.moveTo(startPt.x, startPt.y);	
				g.lineTo(endPt.x, endPt.y);	
				startPt.x = endPt.x + spaceLen*normX;
				startPt.y = endPt.y + spaceLen*normY;
				totalLen += spaceLen;		
			}
			
			
		}
		public static function drawArrow(g:Graphics, p1:Point, p2:Point, width:Number = 20, height:Number = 10, shaftWidth:Number = 10):void{
			var diffX:Number = p2.x-p1.x;
			var diffY:Number = p2.y-p1.y;
			var len:Number  = Math.sqrt(diffX*diffX + diffY*diffY);
			var normX:Number = diffX*(1/len);
			var normY:Number = diffY*(1/len);
			
			g.moveTo(p1.x, p1.y);
			g.lineTo(p2.x, p2.y);
			//draw arrow cap
			g.moveTo(p2.x, p2.y);//head
			g.lineTo(p2.x-normX*width-normY*height, p2.y-normY*width+normX*height);//head
			g.lineTo(p2.x-normX*(width-shaftWidth), p2.y-normY*(width-shaftWidth));//head
			g.lineTo(p2.x-normX*width+normY*height, p2.y-normY*width-normX*height);//head
			g.lineTo(p2.x, p2.y);//head
		}
		public static function drawDashedArrow(g:Graphics, p1:Point, p2:Point, gradient:Boolean = false, options:Object = null, dashLen:Number = 3, spaceLen:Number = 3, width:Number = 5, height:Number = 5, shaftWidth:Number = 5):void{
			var diffX:Number = p2.x-p1.x;
			var diffY:Number = p2.y-p1.y;
			var len:Number  = Math.sqrt(diffX*diffX + diffY*diffY);
			var normX:Number = diffX*(1/len);
			var normY:Number = diffY*(1/len);
			
			var startPt:Point, endPt:Point;
			var numDash:uint  = 0;
			var startPts:Array  = new Array();
			var endPts:Array	= new Array();
			startPt = new Point(p1.x, p1.y);
			startPts.push();
			var drawDash:Boolean 	= true;	
			var totalLen:Number 	= 0;	
			while(totalLen < (len)){
				totalLen += dashLen;	
				var step:Number = totalLen>len? (dashLen - (totalLen-len)) : dashLen;
				endPt = new Point(startPt.x + step*normX, startPt.y + step*normY);
				endPts.push(endPt);					
//				g.moveTo(startPt.x, startPt.y);	
//				g.lineTo(endPt.x, endPt.y);	
				startPt = new Point(endPt.x + spaceLen*normX, endPt.y + spaceLen*normY);
				startPts.push(startPt);
				totalLen += spaceLen;
				numDash++;		
			}			
			var alpha:Number;			
			for (var i:uint=0; i<(numDash-1); i++){
				startPt = startPts[i];	endPt = endPts[i];
				if (gradient){
					alpha = options["alpha"]*((numDash-i)/numDash);
					g.lineStyle(options["thickness"], options["color"], alpha, false, LineScaleMode.NONE, CapsStyle.NONE);
					g.beginFill(options["color"], options["alpha"]);
				}
				g.moveTo(startPt.x, startPt.y);	
				g.lineTo(endPt.x, endPt.y);		
				if (gradient) g.endFill();	
			}
			if (gradient) {
				g.lineStyle(options["thickness"], options["color"], options["alpha"], false, LineScaleMode.NONE, CapsStyle.NONE);
				g.beginFill(options["color"], options["alpha"]);
				
			}
			
//			g.moveTo(p2.x, p2.y);//head
//			g.lineTo(p2.x-normX*width-normY*height, p2.y-normY*width+normX*height);//head
//			g.lineTo(p2.x-normX*(width-shaftWidth), p2.y-normY*(width-shaftWidth));//head
//			g.lineTo(p2.x-normX*width+normY*height, p2.y-normY*width-normX*height);//head
//			g.lineTo(p2.x, p2.y);//head
			g.moveTo(p1.x + normX*height, p1.y + normY*height);//head
			g.lineTo(p1.x-normY*width/2, p1.y+normX*width/2);
			g.lineTo(p1.x+normY*width/2, p1.y-normX*width/2);
			g.lineTo(p1.x + normX*height, p1.y + normY*height);
			if (gradient) g.endFill();
		}
		/**
		 * Draws an upward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleUp(g:Graphics, x:Number, y:Number, width:Number=5, height:Number=5):void
		{
			g.moveTo(x, y+height);
			g.lineTo(x-width/2, y);
			g.lineTo(x+width/2, y);
			g.lineTo(x, y+height);
		}
		
		/**
		 * Draws a downward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleDown(g:Graphics, x:Number, y:Number, size:Number):void
		{
			g.moveTo(x, y);
			g.lineTo(x-size/2, y+size);
			g.lineTo(x+size/2, y+size);
			g.lineTo(x, y);
		}
	}
}