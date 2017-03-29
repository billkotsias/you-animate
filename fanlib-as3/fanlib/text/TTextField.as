package fanlib.text {
	
	import fanlib.fx.emitters.IParticle;
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	import fanlib.tween.TVector2;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class TTextField extends FTextField implements IParticle {
		
		protected var fadeList:TList = null; // handle fading "collisions"

		public function TTextField() {
			// constructor code
		}
		
		// alpha
		public function getAlpha():ITweenedData {
			return new TVector1(this.alpha);
		}
		
		public function setAlpha(_a:ITweenedData):void {
			var a:TVector1 = (_a as TVector1);
			this.alpha = a.x;
		}
		
		// position
		public function getPos():TVector2 {
			return new TVector2(x, y);
		}
		
		public function setPos(_pos:ITweenedData):void {
			var pos:TVector2 = (_pos as TVector2);
			x = pos.x;
			y = pos.y;
		}
		
		// scale
		public function getScale():ITweenedData {
			return new TVector2(this.scaleX, this.scaleY);
		}
		
		public function setScale(_scl:ITweenedData):void {
			var scl:TVector2 = (_scl as TVector2);
			this.scaleX = scl.x;
			this.scaleY = scl.y;
		}
		
		public function getRot():ITweenedData {
			return new TVector1(this.rotation);
		}
		public function setRot(_r:ITweenedData):void {
			var r:TVector1 = (_r as TVector1);
			this.rotation = r.x;
		}

		// transitions
		public function fade(finAlpha:Number, time:Number, delay:Number = 0):TList {
			TPlayer.DEFAULT.removePlaylist(fadeList, false);
			fadeList = TPlayer.DEFAULT.addTween( new TLinear(new TVector1(finAlpha),
															   this.getAlpha,this.setAlpha,
															   Math.abs(time*(finAlpha-this.alpha)),delay) );
			return fadeList;
		}
		public function fadein(time:Number, delay:Number = 0, optimize:Boolean = false):TList {
			if (optimize) visible = true;
			return fade(1, time, delay);
		}
		public function fadeout(time:Number, delay:Number = 0, optimize:Boolean = false):TList {
			fade(0, time, delay);
			if (optimize) fadeList.addEventListener(TList.TLIST_COMPLETE, fadeOutComplete);
			return fadeList;
		}
		private function fadeOutComplete(e:Event):void {
			e.currentTarget.removeEventListener(TList.TLIST_COMPLETE, fadeOutComplete);
			if (this.alpha == 0) visible = false; // optimize
		}
		
		public function get displayObject():DisplayObject { return this; }
	}
	
}
