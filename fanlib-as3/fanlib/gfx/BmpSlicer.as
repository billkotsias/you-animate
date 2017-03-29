package fanlib.gfx {
	
	import fanlib.containers.Array2D;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
		
	public class BmpSlicer {

		// static
		
		// cache created BitmapData
		static private var DataToGeom:Dictionary = new Dictionary(false); // BitmapData -> BmpGeometry Array
		
		// draw rectangle from 'BitmapData' to 'BitmapData'; auto-scales to fit source
		static public function autoFitRect(dest:BitmapData, source:BitmapData, rect:Rectangle):void {
			var mat:Matrix = new Matrix();
			mat.translate(-rect.x, -rect.y);
			mat.scale(dest.width / rect.width, dest.height / rect.height);
			dest.draw(source, mat, null, null, null, true);
		}

		static public function copyRect(dest:BitmapData, source:BitmapData, rect:Rectangle, pos:Point = null):void {
			if (!pos) pos = new Point();
			dest.copyPixels(source, rect, pos, null, null, true);
		}
		
		static public function pieces(src:BitmapData, x:uint, y:uint):Array2D {
			var result:Array2D = new Array2D(x, y);
			
			var width:Number = src.width / x;
			var height:Number = src.height / y;
			var rect:Rectangle = new Rectangle(0, 0, width, height);
			var destPos:Point = new Point();
			
			for (var k:int = 0; k < y; ++k) {
				rect.y = k * height;
				for (var i:int = 0; i < x; ++i) {
					rect.x = i * width;
					var dest:BitmapData = new BitmapData(width, height, true, 0);
					dest.copyPixels(src, rect, destPos, null, null, true);
					result.set(dest, i, k);
				}
			}
			return result;
		}
		// static

	}
	
}

import fanlib.utils.ICompare;
import flash.geom.Rectangle;
import flash.geom.Point;

class BmpGeomerty implements ICompare {
	
	private var rect:Rectangle;
	private var pos:Point;
	
	public function BmpGeomerty(r:Rectangle, p:Point = null) {
		rect = r.clone();
		if (p) pos = p.clone();
	}

	public function equal(obj:ICompare):Boolean {
		var other:BmpGeomerty = obj as BmpGeomerty;
		if (rect.equals(other.rect)) {
			if (pos == null && other.pos == null) return true;
			if (pos != null && other.pos != null && pos.equals(other.pos)) return true;
		}
		return false;
	}
	
	// unimplemented
	public function lessThan(obj:ICompare):Boolean {
		return false;
	}
}