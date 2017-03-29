package fanlib.gfx {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import fanlib.math.Maths;
	
	// stage-auto-centering graphics container
	public class Centry extends TSprite {

		public var speed:Number = 1;	// factor/sec
		public var gravity:Number = 2;	// factor acceleration/sec
		public var marginX:Number = 1.1;
		public var marginY:Number = 1.1;
		public var onlyIfBiggerThanStage:Boolean = false;	// do my job only if I am bigger than Stage
		public var normalCenter:Point = new Point(0,0);		// crawl to this center if not bigger and "onlyIfBigger"...
		
		private var acceleration:Number = 0; // accelerating while out-of-center
		
		private var _stage:Stage = null;
		private var currentTime:int;
		
		private var autoCentered:Boolean = false;
		
		public function Centry() {
		}
		
		// must be added in stage FIRST for this to work
		public function startAutoCenter():void {
			if (stage == null) return;
			
			currentTime = getTimer();
			_stage = stage;
			autoCentered = true;
			_stage.addEventListener(Event.ENTER_FRAME, run, false, 0, true);
		}
		
		public function stopAutoCenter():void {
			if (_stage == null) return;
			autoCentered = false;
			_stage.removeEventListener(Event.ENTER_FRAME, run);
		}
		
		public function isAutoCentered():Boolean {
			return autoCentered;
		}
		
		public function run(e:Event):void {
			if (parent == null) return;
			
			var time:int = getTimer() - currentTime; // time since last frame
			currentTime += time;
			
			// container's current bounds & center
			var rect:Rectangle = this.getBounds(_stage);
			if (rect.width == 0 || rect.height == 0) return;
			var center:Point = new Point(rect.x + rect.width / 2, rect.y + rect.height / 2); // stage system
			
			// - if container is bigger than stage, then it will be scrolled/adjusted by mouse position !!!
			var mouse:Point = new Point(this.mouseX, this.mouseY);
			mouse = this.localToGlobal(mouse); // stage mouse co-ords
			mouse.x = Maths.bound2(mouse.x, 0, _stage.stageWidth);
			mouse.y = Maths.bound2(mouse.y, 0, _stage.stageHeight);
			var mscroll:Point = new Point(0,0);
			var smallerThanStage:Boolean = true;
			if (rect.width > _stage.stageWidth) {
				smallerThanStage = false;
				mscroll.x = (rect.width * marginX - _stage.stageWidth) * (mouse.x / _stage.stageWidth - 0.5);
			}
			if (rect.height > _stage.stageHeight) {
				smallerThanStage = false;
				mscroll.y = (rect.height * marginY - _stage.stageHeight) * (mouse.y / _stage.stageHeight - 0.5);
			}
			
			var xDif:Number; // distance to target
			var yDif:Number;
			
			if (onlyIfBiggerThanStage && smallerThanStage) {
				
				// crawl back to your lair
				xDif = normalCenter.x - this.x;
				yDif = normalCenter.y - this.y;
				
			} else {
				
				// business as usual
				center = center.add(mscroll);
				center = this.parent.globalToLocal(center); // parent system
				
				// stage's center
				var stageCenter:Point = new Point(_stage.stageWidth / 2, _stage.stageHeight / 2); // stage system
				//var stageCenter:Point = new Point(_stage.x + _stage.stageWidth / 2, _stage.y + _stage.stageHeight / 2); // stage system
				stageCenter = this.parent.globalToLocal(stageCenter); // parent system
				
				xDif = stageCenter.x - center.x;
				yDif = stageCenter.y - center.y;
			}
			
			// apply "centry" algorithm only if "needed"
			if (Math.abs(xDif) >= 0.5 || Math.abs(yDif) >= 0.5) {
				if (acceleration < speed) acceleration = speed;
				acceleration += gravity * time / 1000.;
				var factor:Number = acceleration * time / 1000.;
				this.x += xDif * factor;
				this.y += yDif * factor;
			} else {
				acceleration = 0; // reached target, zero acceleration
			}
		}
		
		override public function copy(baseClass:Class = null):* {
			var obj:* = super.copy(baseClass);
			obj.speed = this.speed;
			obj.gravity = this.gravity;
			obj.marginX = this.marginX;
			obj.marginY = this.marginY;
			obj.onlyIfBiggerThanStage = this.onlyIfBiggerThanStage;
			obj.normalCenter = this.normalCenter;
			obj.acceleration = this.acceleration;
			obj._stage = this._stage;
			obj.currentTime = this.currentTime;
			obj.autoCentered = this.autoCentered;
			return obj;
		}

	}
	
}
