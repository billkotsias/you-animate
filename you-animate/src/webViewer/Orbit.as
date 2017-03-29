package webViewer
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.Stg;
	import fanlib.math.FVector3D;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class Orbit extends Pivot3D
	{
		static private const ZERO:Vector3D = FVector3D.Zero();
		
		public var stopUpdateThreshold:Number = Math.pow(0.05, 2);
		
		public var smooth:Number;
		public var orbitFactor:Number;
		public var speedFactor:Number;
		public var zoomFactor:Number;
		public var forceMouseLeave:Boolean;
		
		protected var stg:Stage;
		
		private var oldMouseX:Number;
		private var oldMouseY:Number;
		private var time:uint;
		private var draggingLeft:Boolean;
		private var draggingRight:Boolean;
		private var _camera:Camera3D;
		private const targetRot:Vector3D = new Vector3D();
		private const currentRot:Vector3D = new Vector3D();
		private var targetDistance:Number;
		private var targetPos:Vector3D = new Vector3D();
		
		private var currentPos:Vector3D = new Vector3D();
		private var _maxDistance:Number = -5000; // max negative that is
		private var _minCameraFar:Number = 5000;
		
		public function Orbit(initPos:Vector3D = null, smooth:Number = 0.25, orbitFactor:Number = 0.5, speedFactor:Number = 0.5, zoomFactor:Number = 0.1, forceMouseLeave:Boolean = false)
		{
			super("orbit");
			
			if (initPos) {
				x = initPos.x;
				y = initPos.y;
				z = initPos.z;
			}
			
			_camera = new Camera3D();
			addChild(_camera);
			_camera.setPosition( 0,0,-400, 1, true );
			_camera.lookAt(0,0,0);
			this.orbitFactor = orbitFactor;
			this.speedFactor = speedFactor;
			this.zoomFactor = zoomFactor;
			this.smooth = smooth;
			this.forceMouseLeave = forceMouseLeave;
			
			stg = Stg.Get();
			stg.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stg.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseDown);
			
			stg.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void { _stopDrag(true, false) });
			stg.addEventListener(MouseEvent.RELEASE_OUTSIDE, function(e:MouseEvent):void { _stopDrag(true, false) });
			stg.addEventListener(MouseEvent.RIGHT_MOUSE_UP, function(e:MouseEvent):void { _stopDrag(false, true) });
			// TODO : add panning with right-mouse or shift-left-drag
			
			stg.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			getRotation(true, currentRot);
			targetRot.copyFrom(currentRot);
			targetDistance = _camera.z;
			targetPos.setTo(x,y,z);
			startTransition();
		}
		
		//
		
		public function setTargetPos(pos:Vector3D):void {
			targetPos.copyFrom(pos);
			startTransition();
		}
		
		public function setTargetRotation(rot:Vector3D):void {
			targetRot.copyFrom(rot);
			startTransition();
		}
		
		/**
		 * Should be <b>negative!</b> 
		 * @param val
		 */
		public function setTargetDistance(val:Number):void {
			if (val < _maxDistance) targetDistance = _maxDistance; else targetDistance = val;
			startTransition();
		}
		
		//
		
		public function alterCameraDistance(factor:Number):void {
			setTargetDistance( targetDistance * Math.pow( 1 - zoomFactor * (factor > 0 ? 1 : -1), Math.abs(factor) ) );
		}
		
		public function setView(pos:Vector3D, rot:Vector3D, distance:Number):void {
			setTargetPos(pos);
			setTargetRotation(rot);
			setTargetDistance(distance);
		}
		
		public function getView():Object {
			return { pos:{"x":x, "y":y, "z":z}, rot:currentRot, dist:targetDistance }
		}
		//
		
		private function startTransition():void {
			time = getTimer();
			stg.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		protected function mouseWheel(e:MouseEvent):void {
			alterCameraDistance( e.delta / 3 );
		}
		
		protected function mouseDown(e:MouseEvent):void {
			if (e.type === MouseEvent.MOUSE_DOWN) {
				draggingLeft = true;
			} else if (e.type === MouseEvent.RIGHT_MOUSE_DOWN) {
				draggingRight = true;
			}
			
			oldMouseX = stg.mouseX;
			oldMouseY = stg.mouseY;
			stg.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			startTransition();
		}
		
		public function _stopDrag(left:Boolean, right:Boolean):void {
			if (left) draggingLeft = false;
			if (right) draggingRight = false;
			if (!(left || right)) stg.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
		
		protected function enterFrame(e:Event):void {
			const timeSinceLast:uint = -time + (time = getTimer());
			var smoothFactor:Number = this.smooth * timeSinceLast * 0.0625; // 0.0625 = 1/16
			if (smoothFactor > 1) smoothFactor = 1;
			var diffX:Number, diffY:Number, diffZ:Number, diffX1:Number, diffY1:Number, diffZ1:Number;
			
			// orbit rotation
			currentRot.x += (diffX = targetRot.x - currentRot.x) * smoothFactor;
			currentRot.y += (diffY = targetRot.y - currentRot.y) * smoothFactor;
			CONFIG::newFlare { setRotation(currentRot.x, currentRot.y, currentRot.z, true); }
			CONFIG::oldFlare { setRotation(currentRot.x, currentRot.y, currentRot.z); }
			
			// camera distance
			_camera.z += (diffZ = targetDistance - _camera.z) * smoothFactor;
			if (_camera.z < _maxDistance) {
				targetDistance = _maxDistance;
			}
			_camera.far = -_camera.z + _minCameraFar + Vector3D.distance(getPosition(false, currentPos), ZERO);
			
			// orbit position
			x += (diffX1 = targetPos.x - x) * smoothFactor;
			y += (diffY1 = targetPos.y - y) * smoothFactor;
			z += (diffZ1 = targetPos.z - z) * smoothFactor;
			
			if (!draggingLeft && !draggingRight &&
				(diffX*diffX) < stopUpdateThreshold && (diffY*diffY) < stopUpdateThreshold && (diffZ*diffZ) < stopUpdateThreshold &&
				(diffX1*diffX1) < stopUpdateThreshold && (diffY1*diffY1) < stopUpdateThreshold && (diffZ1*diffZ1) < stopUpdateThreshold) {
				stg.removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
		
		protected function mouseMove(e:MouseEvent):Boolean {
			if (forceMouseLeave && (
				stg.mouseX <= 0 ||
				stg.mouseY <= 0 ||
				stg.mouseX >= stg.stageWidth ||
				stg.mouseY >= stg.stageHeight)) {
				_stopDrag(true, true);
				return false;
			}
			
			const dX:Number = (-oldMouseX + (oldMouseX = stg.mouseX) );
			const dY:Number = (-oldMouseY + (oldMouseY = stg.mouseY) );
			
			if (draggingLeft) {
				targetRot.y += dX * orbitFactor;
				targetRot.x += dY * orbitFactor;
			}
			
			if (draggingRight) {
				const rad:Number = currentRot.y * Math.PI / 180;
				const sinRot:Number = Math.sin(rad);
				const cosRot:Number = Math.cos(rad);
				if (e.shiftKey) {
					targetPos.x -= dX * speedFactor * cosRot - dY * speedFactor * sinRot;
					targetPos.z += dY * speedFactor * cosRot + dX * speedFactor * sinRot;
				} else {
					targetPos.y += dY * speedFactor;
				}
			}
			
			return true;
		}

		public function get camera():Camera3D
		{
			return _camera;
		}

		public function set maxDistance(value:Number):void
		{
			_maxDistance = value;
			startTransition();
		}

		public function set minCameraFar(value:Number):void
		{
			_minCameraFar = value;
			startTransition();
		}


	}
}