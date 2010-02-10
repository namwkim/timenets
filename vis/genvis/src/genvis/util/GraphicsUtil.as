package genvis.util
{
	import flash.display.Graphics;
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
		public static function drawDashedArrow(g:Graphics, p1:Point, p2:Point, dashLen:Number = 3, spaceLen:Number = 3, width:Number = 5, height:Number = 5, shaftWidth:Number = 5):void{
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
			while(totalLen < (len)){
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
//			g.moveTo(p2.x, p2.y);//head
//			g.lineTo(p2.x-normX*width-normY*height, p2.y-normY*width+normX*height);//head
//			g.lineTo(p2.x-normX*(width-shaftWidth), p2.y-normY*(width-shaftWidth));//head
//			g.lineTo(p2.x-normX*width+normY*height, p2.y-normY*width-normX*height);//head
//			g.lineTo(p2.x, p2.y);//head
			g.moveTo(p1.x + normX*height, p1.y + normY*height);//head
			g.lineTo(p1.x-normY*width/2, p1.y+normX*width/2);
			g.lineTo(p1.x+normY*width/2, p1.y-normX*width/2);
			g.lineTo(p1.x + normX*height, p1.y + normY*height);
		}
		/**
		 * Draws an upward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleUp(g:Graphics, x:Number, y:Number, size:Number):void
		{
			g.moveTo(x, y);
			g.lineTo(x-size/2, y-size);
			g.lineTo(x+size/2, y-size);
			g.lineTo(x, y);
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