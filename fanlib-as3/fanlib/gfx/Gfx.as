package fanlib.gfx {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class Gfx {

		
		/**
		 * 'obj' must be 'DisplayObject' (starling.. or flash..) 
		 * @param obj
		 * @param maxWidth
		 * @param maxHeight
		 * @param fixAspect
		 */
		static public function SetMaxSize(obj:*, maxWidth:Number, maxHeight:Number, fixAspect:Boolean):void {
			obj.width = maxWidth;
			obj.height = maxHeight;
			if (obj.scaleX == 0 && obj.scaleY == 0) { // not what we wanted
				obj.scaleX = 1;
				obj.scaleY = 1;
			} else if (fixAspect) {
				if (obj.scaleX > obj.scaleY) {
					obj.scaleX = obj.scaleY;
				} else {
					obj.scaleY = obj.scaleX;
				}
			}
		}

		static public function NewResized(bmp:IBitmapDrawable, maxWidth:Number, maxHeight:Number, fixAspect:Boolean,
										  transparent:Boolean = true, fillColor:uint = 0):BitmapData {
			// original size
			var rect:Rectangle;
			if (bmp is DisplayObject)
				rect = new Rectangle(0,0,(bmp as DisplayObject).width, (bmp as DisplayObject).height);
			else if (bmp is BitmapData)
				rect = (bmp as BitmapData).rect;
			
			// scaling
			var scaleX:Number = maxWidth / rect.width;
			var scaleY:Number = maxHeight / rect.height;
			if (fixAspect) {
				if (scaleX > scaleY) scaleX = scaleY; else scaleY = scaleX;
			}
			const mat:Matrix = new Matrix();
			mat.scale(scaleX,scaleY);
			
			// check if no resize needed!
			if (bmp is BitmapData) {
				if (scaleX === 1 && scaleY === 1 &&
					transparent === (bmp as BitmapData).transparent &&
					(transparent === false || fillColor === 0)) {
					return bmp as BitmapData;
				}
			}
			// create
			const data:BitmapData = new BitmapData(rect.width * scaleX, rect.height * scaleY, transparent, fillColor);
			data.draw(bmp, mat, null, null, null, true);
			
			return data;
		}
		
		static public function OneChildVisibleByName(cont:DisplayObjectContainer, childName:String):void {
			OneChildVisible(cont, cont.getChildByName(childName));
		}
		static public function OneChildVisible(cont:DisplayObjectContainer, child:DisplayObject):void {
			for (var i:int = cont.numChildren - 1; i >= 0; i--) {
				cont.getChildAt(i).visible = false;
			}
			if (child) child.visible = true;
		}
		
		static public function SortChildren(cont:DisplayObjectContainer, varName:String, sortArrayOptions:uint = Array.CASEINSENSITIVE):void {
			const arr:Array = [];
			// copy to array
			for (var i:int = 0; i < cont.numChildren; ++i) {
				arr.push(cont.getChildAt(i));
			}
			// do array sorting
			arr.sortOn(varName, sortArrayOptions);
			// set indices back
			for (i = 0; i < cont.numChildren; ++i) {
				cont.setChildIndex(arr[i], i);
			}
		}
		
		static public function SortChildrenByName(cont:DisplayObjectContainer, sortArrayOptions:uint = Array.CASEINSENSITIVE):void {
			SortChildren(cont, "name", sortArrayOptions);
		}
	}
	
}
