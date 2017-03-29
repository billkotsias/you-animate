package fanlib.fx.emitters
{
	import fanlib.gfx.TSprite;
	import fanlib.math.Maths;
	import fanlib.tween.ITween;
	import fanlib.tween.TCos;
	import fanlib.tween.TCubic;
	import fanlib.tween.TDelay;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TPoly;
	import fanlib.tween.TPow;
	import fanlib.tween.TSin;
	import fanlib.tween.TVector1;
	import fanlib.tween.TVector2;
	import fanlib.tween.Tween;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	public class EBasic extends TSprite
	{
		public var particleTemplate:IParticle;
		public var addParticlesAsChildren:Boolean = true;
		public var derivePositionFromEmitter:Boolean = true; // taken into account if above is false
		
		// [min,max] random values
		public var burstEvery:Array = [1,1];
		public var burstDuration:Array = [0,0];
		public var burstDistribution:Number = 0.8; // 0 = 100% random, 1 = evenly distributed
		public var particlesPerBurst:Array = [10,10];
		public var particleTTL:Array = [1,1];
		public var repeat:Array = [0,0]; // aka number of bursts; 0 = infinite
		public var particleRot:Array = [0,360];
		public var particleRotSpeed:Array = [0,720]; // per sec
		
		// [start,...,end]
		public var particleAlpha:Array = [1,0];
		public var particleScale:Array = [1,0];
		
		public var autoDestroy:Boolean; // when repeats are complete
		private var particleCount:uint;
		
		public var initDelay:Number = 0;
		private var delay:DelayedCall = new DelayedCall();
		
		private var tClass:Class;
		private var tData:Array;
		private var tFactory:Function;
		
		private var burstTimer:Timer = new Timer(0);
		
		public function EBasic()
		{
			super();
			tween = ["TSin"];
		}
		
		// => [0] = name, rest = data
		public function set tween(arr:Array):void {
			tData = arr;
			tClass = Class(getDefinitionByName("fanlib.tween." + tData.shift()));
			switch (tClass) {
				case TLinear:
				case TSin:
				case TCos:
				default:
					tFactory = tweenNoParams;
					break;
				case TPow:
					tFactory = tweenPow;
					break;
				case TCubic:
					tFactory = tweenCubic;
					break;
				case TPoly:
					tFactory = tweenPoly;
					break;
			}
		}
		
		public function start():void {
			if (initDelay) {
				delay.dismiss();
				delay = new DelayedCall(delayedStart, initDelay);
			} else {
				delayedStart();
			}
		}
		private function delayedStart():void {
			burstTimer.reset();
			burstTimer.delay = Maths.random(burstEvery[0], burstEvery[1]) * 1000;
			burstTimer.repeatCount = Maths.random(repeat[0], repeat[1]);
			burstTimer.addEventListener(TimerEvent.TIMER, burstNow, false, 0, true);
			burstTimer.addEventListener(TimerEvent.TIMER_COMPLETE, burstComplete, false, 0, true);
			burstTimer.start();
		}
		
		public function stop():void {
			burstTimer.removeEventListener(TimerEvent.TIMER, burstNow);
			burstTimer.stop();
			delay.dismiss();
		}
		
		private function burstComplete(e:TimerEvent):void {
			dispatchEvent(new Event(Event.COMPLETE)); // in case you wanna do things to me
			if (autoDestroy) {
				// don't even think of reusing me!
				burstTimer = null;
				particleTemplate = null;
				tClass = null;
				tData = null;
				tFactory = null;
				// will be removed from parent when all particles have vanished, but...
				if (!particleCount) parent = null; // in case no particles where burst during last burst
			}
		}
		
		private function burstNow(e:TimerEvent):void {
			burstTimer.delay = Maths.random(burstEvery[0], burstEvery[1]) * 1000;
			
			// prepare fodder for emitter's cannon
			var num:uint = Maths.random(particlesPerBurst[0], particlesPerBurst[1]);
			for (var i:int = num - 1; i >= 0; --i) {
				var data:ParticleData = new ParticleData();
				var part:IParticle = particleTemplate.copy();
				data.particle = part;
				data.delay = Maths.random(burstDuration[0], burstDuration[1]) * (1 - burstDistribution) + (burstDuration[1] * i / num) * burstDistribution;
				data.ttl = Maths.random(particleTTL[0], particleTTL[1]);
				data.index = i / num;
				
				// off-screen till "delay" is consumed!
				var list:TList = TPlayer.DEFAULT.addTween(new TDelay(data.delay), true);
				list.data = data;
				list.addEventListener(TList.TLIST_COMPLETE, addParticleNow, false, 0, true);
				++particleCount; // count particle as "active", even though not on-screen yet
				
				// alpha fading
				tweenMultipleValues(data, part.getAlpha, part.setAlpha, TVector1.FromArray(particleAlpha));
				
				// scaling
				tweenMultipleValues(data, part.getScale, part.setScale, TVector2.FromUniformArray(particleScale));
				
				// position
				data.initPos = initPosition(data);
				data.finalPos = finalPosition(data);
				if (!addParticlesAsChildren && particleTemplate.parent !== this && derivePositionFromEmitter) {
					makeRelativeToEmitter(data.initPos);
					makeRelativeToEmitter(data.finalPos);
				}
				if (!data.initPos.equals(data.finalPos)) TPlayer.DEFAULT.addTween(tFactory(data), true);
				
				// rotation
				part.setRot(new TVector1(Maths.random(particleRot[0], particleRot[1])));
				var rotSpeed:Number = Maths.random(particleRotSpeed[0], particleRotSpeed[1]);
				if (rotSpeed) {
					TPlayer.DEFAULT.addTween(new TLinear(new TVector1(rotSpeed * data.ttl), part.getRot, part.setRot, data.ttl, data.delay));
				}
			}
		}
		private function tweenMultipleValues(data:ParticleData, getF:Function, setF:Function, arr:Array):void {
			setF(arr[0]);
			if (arr.length < 2) return;
			
			var segmentsDur:Number = data.ttl / (arr.length - 1);
			var list:TList = new TList();
			list.add(new TDelay(data.delay));
			for (var i:int = 1; i < arr.length; ++i) {
				list.add(new TLinear(arr[i], getF, setF, i * segmentsDur));
			}
			TPlayer.DEFAULT.addPlaylist(list, true);
		}
		private function makeRelativeToEmitter(t:TVector2):void {
			var newPos:Point = particleTemplate.parent.globalToLocal(this.localToGlobal(TVector2.ToPoint(t)));
			t.x = newPos.x;
			t.y = newPos.y;
		}
		private function addParticleNow(e:Event):void {
			// add on-screen
			var list:TList = e.currentTarget as TList;
			list.removeEventListener(TList.TLIST_COMPLETE, addParticleNow);
			var data:ParticleData = list.data;
			var partParent:DisplayObjectContainer = (addParticlesAsChildren) ? this : particleTemplate.parent;
			partParent.addChild(data.particle.displayObject);
			// time-to-live
			list.add(new TDelay(data.ttl)); // already inside TPlayer!
			list.addEventListener(TList.TLIST_COMPLETE, particleComplete, false, 0, true);
		}
		private function particleComplete(e:Event):void {
			var list:TList = e.currentTarget as TList;
			list.removeEventListener(TList.TLIST_COMPLETE, particleComplete);
			var data:ParticleData = list.data;
			data.particle.parent = null;
			list.data = undefined;
			if (!burstTimer && --particleCount == 0) {
				parent = null; // time to "die"
			}
		}
		
		// override
		protected function initPosition(data:ParticleData):TVector2 { return null; }
		protected function finalPosition(data:ParticleData):TVector2 { return null; }
		
		// tween factories
		private function tweenNoParams(data:ParticleData):Tween {
			return new tClass(data.finalPos, data.particle.getPos, data.particle.setPos, data.ttl, data.delay);
		}
		private function tweenPow(data:ParticleData):Tween {
			return new TPow(data.finalPos, data.particle.getPos, data.particle.setPos, tData[0], data.ttl, data.delay);
		}
		private function tweenCubic(data:ParticleData):Tween {
			return new TCubic(data.finalPos, data.particle.getPos, data.particle.setPos, data.ttl, tData[0], data.delay);
		}
		private function tweenPoly(data:ParticleData):Tween {
			return new TPoly(data.finalPos, data.particle.getPos, data.particle.setPos, data.ttl, tData, data.delay);
		}
		
		// to emit emitters
		override public function copy(baseClass:Class = null):* {
			var obj:EBasic = super.copy(baseClass);
			obj.particleTemplate = this.particleTemplate;
			obj.derivePositionFromEmitter = this.derivePositionFromEmitter;
			obj.burstEvery = this.burstEvery;
			obj.burstDuration = this.burstDuration;
			obj.particlesPerBurst = this.particlesPerBurst;
			obj.particleTTL = this.particleTTL;
			obj.repeat = this.repeat;
			obj.particleRot = this.particleRot;
			obj.particleRotSpeed = this.particleRotSpeed;
			obj.particleAlpha = this.particleAlpha;
			obj.particleScale = this.particleScale;
			obj.tClass = this.tClass;
			obj.autoDestroy = this.autoDestroy;
			return obj;
		}
	}
}