package fanlib.gfx
{
	import fanlib.utils.Enum;
	import fanlib.utils.IChange;
	import fanlib.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	// useful with GPU-accelerated mobile apps... shitty Flash
	public class CacheToBmp
	{
		static public const BEHIND:Enum = new Enum();
		static public const HIDE:Enum = new Enum();
		static public const HIDE_TWEEN:Enum = new Enum();
		static public const REMOVE:Enum = new Enum();
		
		static private const Cached:Dictionary = new Dictionary(true);
		static public function GetCached(obj:DisplayObject):Bitmap { return Cached[obj]; }
		
		static public function SuggestClass(type:Enum):Class {
			var toClass:Class;
			switch (type) {
				case REMOVE:
				case HIDE_TWEEN:
					toClass = TBitmap; // copyable & tweenable
					break;
				default:
					toClass = Bitmap; // non-copyable, very useful in DFXML
					break;
			}
			return toClass;
		}
		
		static public function Cache(obj:DisplayObject, put:Enum, bmpClass:Class = null):Bitmap {
			if (obj is ICacheToBmp) (obj as ICacheToBmp).cacheToBitmap = put;
			
			if (!bmpClass) bmpClass = SuggestClass(put);
			var bmp:Bitmap = Utils.GetGuaranteed(Cached, obj, bmpClass);
			Update(obj, bmp);
			
			if (obj.parent) {
				obj.parent.addChildAt(bmp, obj.parent.getChildIndex(obj));
				switch (put) {
				case REMOVE:
					bmp.name = obj.name; // capture id!
					obj.parent.removeChild(obj);
					break;
				
				case HIDE:
				case HIDE_TWEEN:
					obj.visible = false;
				case BEHIND:
					if (obj is IChange) obj.addEventListener(Event.CHANGE, cachedObjChanged, false, 0, true); // gotcha
					break;
				}
			}
			return bmp;
		}
		
		// => 'bitmap' must belong to the same parent as 'obj'. 'obj' should be invisible.
		static public function Update(obj:DisplayObject, bitmap:Bitmap):void {
			//trace("CacheToBmp",obj.name);
			
			// Remember the transform matrix of the text field
			var offset:Matrix = obj.transform.matrix;
			// Get the bounds of just the textfield (does not include filters)
			var bounds:Rectangle = obj.getBounds(obj);
			// Create a bitmapData that is used just to calculate the size of the filters
			if (bounds.width == 0) bounds.width = 1;
			if (bounds.height == 0) bounds.height = 1;
			var tempBD:BitmapData = new BitmapData( Math.ceil(bounds.width), Math.ceil(bounds.height), false );
			bounds.width = obj.width;
			bounds.height = obj.height;
			// Make a copy of the textField bounds. We'll adjust this with the filters
			var finalBounds:Rectangle = new Rectangle(0,0,bounds.width,bounds.height);
			
			// Step through each filter in the textField and adjust our bounds to include them all
			var filterBounds:Rectangle;
			for each (var filter:BitmapFilter in obj.filters) {
				filterBounds = tempBD.generateFilterRect( tempBD.rect, filter );
				finalBounds = finalBounds.union(filterBounds);
			}
			finalBounds.offset(bounds.x,bounds.y);
			finalBounds.x = Math.floor(finalBounds.x);
			finalBounds.y = Math.floor(finalBounds.y);
			finalBounds.width = Math.ceil(finalBounds.width);
			finalBounds.height = Math.ceil(finalBounds.height);
			
			// Now draw the textfield to a new bitmpaData
			var data:BitmapData = new BitmapData( finalBounds.width, finalBounds.height, true, 0x0 );
			offset.tx = -finalBounds.x;
			offset.ty = -finalBounds.y;
			data.drawWithQuality( obj, offset, obj.transform.colorTransform, obj.blendMode, null, true, StageQuality.HIGH );
			if (bitmap.bitmapData) bitmap.bitmapData.dispose(); // !!!
			bitmap.bitmapData = data;
			bitmap.smoothing = true; // fuck Flash
			
			// Position the bitmap in same place as 'obj'
			bitmap.x = obj.transform.matrix.tx + finalBounds.x;
			bitmap.y = obj.transform.matrix.ty + finalBounds.y;
		}
		
		static private function cachedObjChanged(e:Event):void {
			//trace("cachedObjChanged",e.currentTarget,e.currentTarget.name,e.currentTarget.parent.name,e.currentTarget.htmlText);
			var obj:DisplayObject = e.currentTarget as DisplayObject;
			Update(obj, Cached[obj]);
		}
	}
}