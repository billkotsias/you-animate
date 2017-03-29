package fanlib.gfx {
	
	import fanlib.fx.emitters.IParticle;
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	import fanlib.tween.TVector2;
	import fanlib.utils.Enum;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class TBitmap extends FBitmap implements IParticle {

		static public const OPTIMIZE_VISIBLE:Enum = new Enum();
		static public const OPTIMIZE_REMOVE:Enum = new Enum();
		
		public function TBitmap(bitmapData:BitmapData = null, alignX:Enum = null, alignY:Enum = null,
								smoothing:Boolean = true, pixelSnapping:String = "auto") {
			super(bitmapData, alignX, alignY, smoothing, pixelSnapping);
		}
		
		static protected var _stage:Stage = null;
		
		protected var fadeList:TList = null;	// handle fading "collisions"
		
		// misc
		private function addedToStage(e:Event):void {
			_stage = stage;
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		public function getStage():Stage { return _stage; }
		
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
		
		public function get displayObject():DisplayObject { return this; }
		
		// ready-made tweens
		public function fade(finAlpha:Number, time:Number, delay:Number = 0):TList {
			TPlayer.DEFAULT.removePlaylist(fadeList, false);
			fadeList = TPlayer.DEFAULT.addTween( new TLinear(new TVector1(finAlpha),
				this.getAlpha,this.setAlpha,
				Math.abs(time*(finAlpha-this.alpha)),delay) );
			return fadeList;
		}
		public function fadein(time:Number, delay:Number = 0, optimize:Enum = null):TList {
			if (optimize) visible = true;
			return fade(1, time, delay);
		}
		public function fadeout(time:Number, delay:Number = 0, optimize:Enum = null):TList {
			fade(0, time, delay);
			if (optimize) {
				if (optimize == OPTIMIZE_VISIBLE) {
					fadeList.addEventListener(TList.TLIST_COMPLETE, fadeOutCompleteInvisible);
				} else if (optimize == OPTIMIZE_REMOVE) {
					fadeList.addEventListener(TList.TLIST_COMPLETE, fadeOutCompleteRemove);
				}
			}
			return fadeList;
		}
		
		private function fadeOutCompleteInvisible(e:Event):void {
			e.currentTarget.removeEventListener(TList.TLIST_COMPLETE, fadeOutCompleteInvisible);
			visible = false; // optimize
		}
		private function fadeOutCompleteRemove(e:Event):void {
			e.currentTarget.removeEventListener(TList.TLIST_COMPLETE, fadeOutCompleteRemove);
			if (parent) parent.removeChild(this); // "optimize"
		}


	}
	
}
