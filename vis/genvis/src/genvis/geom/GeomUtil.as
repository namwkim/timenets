package genvis.geom
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class GeomUtil
	{

    	
		public static function intersect(obj1:Object, obj2:Object):int {
			//1. line and line
			if (obj1 is Line && obj2 is Line){
				
			}
			//2. box and box
			if (obj1 is Box && obj2 is Box){
				
			}
			return (0);
		}
		
		/** Indicates no intersection between shapes */
    	public static const NO_INTERSECTION:int = 0;
    	/** Indicates intersection between shapes */
    	public static const COINCIDENT:int      = -1;
    	/** Indicates two lines are parallel */
    	public static const PARALLEL:int        = -2;
    	public static function intersectLineX(line:Line, x:Number):Number{
    		var xt:Number = ((x-line.x1)/(line.x2 - line.x1));
			if (xt > 1 || xt <0 ) return NaN;
			var y:Number = ((line.y2 - line.y1)/(line.x2 - line.x1))*(x-line.x1)+line.y1;
			return (y);
    	}
	    public static function intersectLines(a1x:Number, a1y:Number,
	    	a2x:Number, a2y:Number, b1x:Number, b1y:Number, b2x:Number,
	    	b2y:Number, intersect:Point):int
	    {
	        var ua_t:Number = (b2x-b1x)*(a1y-b1y)-(b2y-b1y)*(a1x-b1x);
	        var ub_t:Number = (a2x-a1x)*(a1y-b1y)-(a2y-a1y)*(a1x-b1x);
	        var u_b :Number = (b2y-b1y)*(a2x-a1x)-(b2x-b1x)*(a2y-a1y);
	
	        if (u_b != 0) {
	            var ua:Number = ua_t / u_b;
	            var ub:Number = ub_t / u_b;
	
	            if (0 <= ua && ua <= 1 && 0 <= ub && ub <= 1) {
	            	intersect.x = a1x+ua*(a2x-a1x);
	            	intersect.y = a1y+ua*(a2y-a1y);
	                return 1;
	            } else {
	                return NO_INTERSECTION;
	            }
	        } else {
	            return (ua_t == 0 || ub_t == 0 ? COINCIDENT : PARALLEL);
	        }
	    }
	   	public static function intersectLineRect(a1x:Number, a1y:Number,
	    	a2x:Number, a2y:Number, r:Rectangle, p0:Point, p1:Point):int
	    {
	        var xMax:Number = r.right, yMax:Number = r.bottom;
	        var xMin:Number = r.left,  yMin:Number = r.top;
	        
	        var i:int = 0, p:Point = p0;
	        if (intersectLines(xMin,yMin,xMax,yMin, a1x,a1y,a2x,a2y, p) > 0) {
	        	++i; p = p1;
	        }
	        if (intersectLines(xMax,yMin,xMax,yMax, a1x,a1y,a2x,a2y, p) > 0) {
	        	++i; p = p1;
	        }
	        if (i == 2) return i;
	        if (intersectLines(xMax,yMax,xMin,yMax, a1x,a1y,a2x,a2y, p) > 0) {
	        	++i; p = p1;
	        }
	        if (i == 2) return i;
	        if (intersectLines(xMin,yMax,xMin,yMin, a1x,a1y,a2x,a2y, p) > 0) {
	        	++i; p = p1;
	        }
	        return i;
	    }
	}
}