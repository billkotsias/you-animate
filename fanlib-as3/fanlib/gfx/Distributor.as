package fanlib.gfx {
	
	import fanlib.utils.IChange;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class Distributor extends TSprite {

		// ways of distribution of children
		static public const CENTERS:String = "centers";			// equal distance of children centers
		static public const CENTERS_FULL:String = "centersfull";// like above but no space left/right of children
		static public const SPACES:String = "spaces";			// equal spaces between children
		static public const SPACES_FULL:String = "spacesfull";	// like above, but no space left/right of children
		
		protected var distX:String = CENTERS;
		protected var distY:String = CENTERS;
		private var sizex:Number = 250;
		private var sizey:Number = 0;
		public function get sizeX():Number { return sizex; }
		public function set sizeX(n:Number):void {
			sizex = n;
			distribute(distX, "x");
		}
		public function get sizeY():Number { return sizey; }
		public function set sizeY(n:Number):void {
			sizey = n;
			distribute(distY, "y");
		}
		
		public function Distributor() {
			// constructor code
		}
		
		public function set distributeX(d:String):void {
			distX = d;
			distribute(d, "x");
		}
		public function set distributeY(d:String):void {
			distY = d;
			distribute(d, "y");
		}
		
		override public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			trackChanges = false;
			distributeX = distX;
			distributeY = distY;
			trackChanges = true;
			super.childChanged(obj);
		}
		
		private function distribute(d:String, v:String):void {
			switch (d) {
				case CENTERS:
					distCenters(v, numChildren);
					break;
				case CENTERS_FULL:
					distCenters(v, numChildren - 1);
					break;
				case SPACES:
					distSpaces(v, numChildren, 0.5);
					break;
				case SPACES_FULL:
					distSpaces(v, numChildren - 1, 0);
					break;
				default:
					// do nothing
					return;
			}
			childChanged(this);
		}
		
		private function distCenters(v:String, num:int):void {
			var centerFactor:Number = (numChildren - 1) / 2;
			
			for (var i:int = numChildren - 1; i >= 0; --i) {
				var obj:DisplayObject = getChildAt(i);
				obj[v] = (i - centerFactor) * this["size"+v] / num;
			}
		}
		
		private function distSpaces(v:String, numSpaces:int, startSpace:Number):void {
			var dim:String;
			if (v == "x") {
				dim = "width";
			} else if (v == "y") {
				dim = "height";
			}
			
			var i:int;
			var obj:DisplayObject;
			
			var fullDim:Number = 0;
			for (i = numChildren - 1; i >= 0; --i) {
				obj = getChildAt(i);
				fullDim += obj[dim];
			}
			
			var spaceFull:Number = this["size"+v] - fullDim;
			var space:Number = spaceFull / numSpaces;
			
			var startPos:Number = - this["size"+v] / 2 + space * startSpace;
			for (i = 0; i < numChildren; ++i) {
				obj = getChildAt(i);
				var rect:Rectangle = obj.getBounds(obj);
				//var rect:Rectangle = obj.getBounds(obj.parent);
				obj[v] = startPos - rect[v] * obj["scale"+v.toUpperCase()];
				startPos += rect[dim] * obj["scale"+v.toUpperCase()] + space;
			}
		}
		
		// create copy : usefull for templates
		override public function copy(baseClass:Class = null):* {
			var obj:* = super.copy(baseClass);
			obj.distX = this.distX;
			obj.distY = this.distY;
			obj.sizeX = this.sizeX;
			obj.sizeY = this.sizeY;
			return obj;
		}
	}
	
}
