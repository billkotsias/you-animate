package fanlib.fx {
	
	import fanlib.event.ObjEvent;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.display.DisplayObject;
	
	public class AlphaGlow {
		
		public var period:Number; // secs
		public var min:Number;
		public var max:Number;
		public var alpha:Number;
		
		public var numOfHalfPeriods:int = int.MAX_VALUE; 
		public var clearObjectsAtEnd:Boolean;
		
		private var objs:Array = [];
		private var list:TList = new TList();
		private var start:Number;
		private var end:Number;
		
		public function AlphaGlow(_period:Number = 1, _min:Number = 0.5, _max:Number = 1, _clearObjectsAtEnd:Boolean = true) {
			period = _period;
			min = _min;
			max = _max;
			clearObjectsAtEnd = _clearObjectsAtEnd;
		}

		public function addObject(o:DisplayObject):AlphaGlow {
			objs.push(o);
			return this; // for 1-line glow effects
		}
		
		public function clearObjects():void {
			objs.length = 0;
		}
		
		public function glow(halfPeriods:int = int.MAX_VALUE):void {
			numOfHalfPeriods = halfPeriods;
			if (list.isEmpty) {
				start = max;
				end = min;
				alpha = max;
				list.add(new TLinear(new TVector1(end), getAlpha, setAlpha, period / 2));
				list.addEventListener(TList.TLIST_COMPLETE, phaseEnded);
				TPlayer.DEFAULT.addPlaylist(list);
			}
		}
		
		public function stop(finalAlpha:Number = -1, _clearObjects:Boolean = true):void {
			if (finalAlpha >= 0) {
				for (var i:int = 0; i < objs.length; ++i) {
					(objs[i] as DisplayObject).alpha = finalAlpha;
				}
			}
			
			if (_clearObjects) clearObjects();
			
			list.removeEventListener(TList.TLIST_COMPLETE, phaseEnded);
			TPlayer.DEFAULT.removePlaylist(list, true);
		}
		
		private function phaseEnded(e:ObjEvent):void {
			if (--numOfHalfPeriods <= 0) {
				stop(-1, clearObjectsAtEnd);
				return;
			}
			
			var temp:Number = start;
			start = end;
			end = temp;
			list.add(new TLinear(new TVector1(end), getAlpha, setAlpha, period / 2));
		}
		
		private function setAlpha(a:TVector1):void {
			alpha = a.x;
			for (var i:int = objs.length - 1; i >= 0; --i) {
				(objs[i] as DisplayObject).alpha = alpha;
			}
		}
		private function getAlpha():TVector1 {
			return new TVector1(alpha);
		}
	}
	
}
