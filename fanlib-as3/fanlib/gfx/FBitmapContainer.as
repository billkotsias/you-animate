package fanlib.gfx {
	
	import flash.geom.Point;
	
	public class FBitmapContainer extends TSprite implements IAlpha {

		public function FBitmapContainer() {
			
		}

		public function getAlphaGlobal(p:Point, minMask:int = 0):int {
			for (var i:int = numChildren - 1; i >= 0; --i) {
				var bmp:IAlpha = getChildAt(i) as IAlpha;
				if (bmp == null) continue;
				
				var alfa:int = bmp.getAlphaGlobal(p, minMask);
				if (alfa > minMask) return alfa;
			}
			
			return -1;
		}
		
		// NOTE : 'Local' as in 'local to 'this''
		public function getAlphaLocal(p:Point, minMask:int = 0):int {
			return getAlphaGlobal(this.localToGlobal(p), minMask);
		}
	}
	
}
