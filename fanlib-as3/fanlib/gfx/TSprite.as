package fanlib.gfx {
	
	import fanlib.fx.emitters.IParticle;
	import fanlib.gfx.FSprite;
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	import fanlib.tween.TVector2;
	import fanlib.tween.TVector3;
	import fanlib.utils.Enum;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	//import fanlib.physix.IMovingObj;
	
	//public class TSprite extends FSprite implements IMovingObj {
	public class TSprite extends FSprite implements IParticle {
		
		static public const FADE_INVISIBLE:Enum = new Enum();
		static public const FADE_REMOVE:Enum = new Enum();
		
		protected var fadeList:TList = null;	// handle fading "collisions"
		
		public var transIn:Transitions;			// "transitions" concept global support
		public var transOut:Transitions;
		
		public function TSprite() {
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
		public function getPos3D():ITweenedData {
			return new TVector3(x, y, z);
		}
		public function setPos3D(_pos:ITweenedData):void {
			var pos:TVector3 = (_pos as TVector3);
			x = pos.x;
			y = pos.y;
			z = pos.z;
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
		
		public function getDims():ITweenedData {
			return new TVector2(this.width, this.height);
		}
		
		public function setDims(_scl:ITweenedData):void {
			var scl:TVector2 = (_scl as TVector2);
			this.width = scl.x;
			this.height = scl.y;
		}
		
		// alpha
		public function getAlpha():ITweenedData {
			return new TVector1(this.alpha);
		}
		
		public function setAlpha(_a:ITweenedData):void {
			var a:TVector1 = (_a as TVector1);
			this.alpha = a.x;
		}

		// rotation
		public function getRot():ITweenedData {
			return new TVector1(this.rotation);
		}
		
		public function setRot(_r:ITweenedData):void {
			var r:TVector1 = (_r as TVector1);
			this.rotation = r.x;
		}
		public function getRot3D():ITweenedData {
			return new TVector3(rotationX, rotationY, rotationZ);
		}
		
		public function setRot3D(_r:ITweenedData):void {
			var r:TVector3 = (_r as TVector3);
			this.rotationX = r.x;
			this.rotationY = r.y;
			this.rotationZ = r.z;
		}
		
		public function get displayObject():DisplayObject { return this; }
		
		// ready-made tweens
		public function fade(finAlpha:Number, time:Number, delay:Number = 0):TList {
			TPlayer.DEFAULT.removePlaylist(fadeList, false);
			fadeList = TPlayer.DEFAULT.addTween(
				new TLinear(
					new TVector1(finAlpha),
					this.getAlpha, this.setAlpha,
					Math.abs(time*(finAlpha-this.alpha)), delay),
				true); // RUN NOW!
			return fadeList;
		}
		public function fadein(time:Number, delay:Number = 0, makeVisible:Boolean = false):TList {
			if (makeVisible) visible = true;
			return fade(1, time, delay);
		}
		public function fadeout(time:Number, delay:Number = 0, endAction:Enum = null):TList {
			fade(0, time, delay);
			if (endAction === FADE_INVISIBLE) {
				fadeList.addEventListener(TList.TLIST_COMPLETE, fadeOutInvisible, false, 0, true);
			} else if (endAction === FADE_REMOVE) {
				fadeList.addEventListener(TList.TLIST_COMPLETE, fadeOutRemove, false, 0, true);
			}
			return fadeList;
		}
		private function fadeOutInvisible(e:Event):void {
			e.currentTarget.removeEventListener(TList.TLIST_COMPLETE, fadeOutInvisible);
			if (this.alpha == 0) visible = false; // optimization
		}
		private function fadeOutRemove(e:Event):void {
			e.currentTarget.removeEventListener(TList.TLIST_COMPLETE, fadeOutRemove);
			if (this.alpha == 0) parent = null;; // optimization
		}

		// set transitions
		public function set transitionIn(par:Array):void {
			transIn = new Transitions(this, par);
		}
		public function set transitionOut(par:Array):void {
			transOut = new Transitions(this, par);
		}

	}
	
}
