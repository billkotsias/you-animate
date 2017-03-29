package fanlib.box2d {
	
	import Box2D.Dynamics.b2World;
	import flash.events.Event;
	import flash.utils.getTimer;
	import Box2D.Common.Math.b2Vec2;
	import fanlib.gfx.TSprite;
	import flash.display.DisplayObject;
	import Box2D.Dynamics.b2DebugDraw;
	import flash.display.Sprite;
	import Box2D.Dynamics.b2Body;
	import flash.geom.Point;
	
	// use this container as reference; move/scale it to move/rotate world-to-screen camera
	public class WorldDoc extends TSprite {
		
		protected var _world:b2World;
		public function get world():b2World { return _world; }
		static public const iterations:int = 10;
		
		private var _worldScale:Number; // screen-to-world scaling
		private var _screenScale:Number; // world-to-screen scaling
		public function get worldScale():Number { return _worldScale; }
		public function get screenScale():Number { return _screenScale; }
		public function set worldScale(s:Number):void { _worldScale = s; _screenScale = 1 / s; }	// don't touch?
		public function set screenScale(s:Number):void { _screenScale = s; _worldScale = 1 / s; }	// don't touch?
		
		// misc
		private var running:Boolean = false;
		private var currentTime:int;
		private var _timeSinceLastFrame:int;
		public function get timeSinceLastFrame():int { return _timeSinceLastFrame; }
		
		public function WorldDoc(scale:Number = 30, allowSleep:Boolean = true) {
			_world = new b2World(new b2Vec2(), allowSleep); // no gravity by default
			_world.SetWarmStarting(true);
			screenScale = scale;
		}
		
		public function startWorld():void {
			if (running) return;
			running = true;
			
			addEventListener(Event.ENTER_FRAME, updateWorld, false, 0, true);
			currentTime = getTimer();
		}
		
		public function stopWorld():void {
			if (!running) return;
			running = false;
			
			removeEventListener(Event.ENTER_FRAME, updateWorld);
		}
		
		public function updateWorld(e:Event = null):void {
			_timeSinceLastFrame = getTimer() - currentTime;
			currentTime += _timeSinceLastFrame;
			
			_world.Step(_timeSinceLastFrame / 1000, iterations, iterations);
			_world.ClearForces();
			_world.DrawDebugData();
			
			// update 'WorldSprite's
			for (var i:int = numChildren - 1; i >= 0; --i) {
				var spr:WorldSprite = getChildAt(i) as WorldSprite;
				if (spr) spr.updateFromBody();
			}
		}
		
		public function debugDraw(e:Boolean):void {
			
			var dbgDraw:b2DebugDraw;
			if (e) {
				dbgDraw = new b2DebugDraw();
				dbgDraw.SetSprite(this);
				dbgDraw.SetDrawScale(screenScale);
				dbgDraw.SetFillAlpha(0.85);
				dbgDraw.SetLineThickness(4);
				dbgDraw.SetFlags(b2DebugDraw.e_jointBit);
			}
			_world.SetDebugDraw(dbgDraw);
		}
		
		// overrides
		override public function addChild(spr:DisplayObject):DisplayObject {
			if (spr is WorldSprite) (spr as WorldSprite)._worldDoc = this;
			return super.addChild(spr);
		}
		override public function addChildAt(spr:DisplayObject, i:int):DisplayObject {
			var returnObj:DisplayObject = super.addChildAt(spr, i);
			if (spr is WorldSprite) (spr as WorldSprite)._worldDoc = this;
			return returnObj;
		}
		override public function removeChildAt(i:int):DisplayObject {
			var spr:WorldSprite = getChildAt(i) as WorldSprite;
			if (spr) spr._worldDoc = null;
			return super.removeChildAt(i);
		}
		override public function removeChild(spr:DisplayObject):DisplayObject {
			var returnObj:DisplayObject = super.removeChild(spr);
			if (spr is WorldSprite) (spr as WorldSprite)._worldDoc = null;
			return returnObj;
		}
		
		// utils
		// => Stage to 'world' local
		public function globalToLocalWorld(p:Point):Point {
			p = globalToLocal(p);
			p.x *= worldScale;
			p.y *= worldScale;
			return p;
		}
	}
	
}
