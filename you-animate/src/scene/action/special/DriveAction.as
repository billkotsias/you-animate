package scene.action.special
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.math.Maths;
	import fanlib.utils.FStr;
	import fanlib.utils.Pair;
	
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import scene.CharManager;
	import scene.Character;
	import scene.Scene;
	import scene.action.Action;
	import scene.action.ActionInfo;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.ExtraLayerInfo;
	
	public class DriveAction extends BezierMove implements IPropAction
	{
		static public const DRIVER_PIVOT_NAME:String = "CTRL_driver_seat";
		static public const SCALE_DEFAULT:Number = 0.07;
		
		// TODO : 	"Free Props" are gonna be a separate type of Scene Objects. Character can "drive car" if close to according Vehicle!
		//			For now, to finish frigging M2, I am attaching the Free Props to their respected Chars. Quick solution, good!
		private var _prop:PropVehicle; // this may go away in next Milestone!
		private var driverSeat:Pivot3D;
		private var steeringWheel:Pivot3D;
		private const wheels:Array = [];
		private const dirWheels:Array = [];
		private const wheelSpeed:Vector3D = new Vector3D();
		private var vehicleLength:Number;
		
		private var idleFramesTime:Number = 0;
		private var idleFrom:Number;
		private var idleTo:Number;
		private var extraCharLayers:Vector.<ExtraLayerInfo>;
		
		private var defaultParent:Pivot3D;
		
		private var seizedChar:Boolean;
		
		public function DriveAction(_character:Character, data:ActionInfo, node0:BNode, node1:BNode, referencePivot:Pivot3D, parent2D:FSprite)
		{
			super(_character, data, node0, node1, referencePivot, parent2D);
			
			idleFrom = data.idleFrom;
			idleTo = data.idleTo;
			extraCharLayers = data.layers;
			
			const wSpeed:Array = propInfo.wheelSpeed;
			wheelSpeed.setTo(wSpeed[0] * data.speed, wSpeed[1] * data.speed, wSpeed[2] * data.speed);
			
			defaultParent = character.charPivot.scene;
			
			_prop = Properties.INSTANCE.requestProp(this, PropVehicle, _character, Scene.INSTANCE.iScene3D) as PropVehicle;
			const propPivot:Pivot3D = _prop.pivot3D;
			if (!propPivot.parent) defaultParent.addChild(propPivot);
			_prop.whenInitialized(getPropPivots);
			
			unlistener.addListener(character, Character.SCALE_CHANGED, charScaleChanged, false, 0, true);
			
			charScaleChanged();
		}
		private function getPropPivots():void {
			const propPivot:Pivot3D = _prop.pivot3D;
			
			// model default scale
			var scale:Number = propInfo.scale;
			if (!scale) scale = SCALE_DEFAULT;
			propPivot.children[0].setScale(scale,scale,scale);
			charScaleChanged(); // apply global scale on top
			
			// assign pivots
			driverSeat = propPivot.getChildByName(DRIVER_PIVOT_NAME);
			steeringWheel = propPivot.getChildByName(propInfo.steerParent);
			var wheel:String;
			for each (wheel in propInfo.wheels) {
				wheels.push(propPivot.getChildByName(wheel));
			}
			for each (wheel in propInfo.dirWheels) {
				dirWheels.push(propPivot.getChildByName(wheel));
			}
			
			if (seizedChar) seizeCharacter();
		}
		
		override public function seizeCharacter():void {
			if (!seizedChar) super.seizeCharacter();
			seizedChar = true;
			if (!driverSeat) return;
			const charPivot:Pivot3D = _character.charPivot;
			charPivot.setPosition(0,0,0);
			charPivot.setRotation(0,0,0);
			const charScale:Number = 1 / _character.info.scale;
			charPivot.setScale(charScale,charScale,charScale);
			_character.setMeshesFrame(from);
			driverSeat.addChild(charPivot);
			idleFramesTime = 0;
		}
		
		override public function surrenderCharacter(endOfAction:Boolean = false):void {
			seizedChar = false;
			if (!driverSeat) return;
			const charPivot:Pivot3D = _character.charPivot;
			defaultParent.addChild(charPivot);
			const scale:Number = Scene.INSTANCE.globalScale;
			charPivot.setScale(scale,scale,scale);
			
			// position vehicle
			var pos:Vector3D;
			if (endOfAction) {
				setCoordination(duration);
			} else {
				setCoordination(0);
			}
		}
		
		override protected function charScaleChanged(e:Event = null):void {
			const scale:Number = Scene.INSTANCE.globalScale;
			_prop.pivot3D.setScale(scale,scale,scale);
			vehicleLength = - propInfo.vLength * scale; // normally negative
			if (seizedChar) seizeCharacter();
			super.charScaleChanged(e);
		}
		
		override public function getFrame(time:Number):Number {
			return 0;
		}
		
		public function temp(v:Vector3D):String {
			return "Vector3D("+v.x.toFixed(2)+","+v.y.toFixed(2)+","+v.z.toFixed(2)+")";
		}
		override public function setCoordination(time:Number):void {
			var elinfo:ExtraLayerInfo;
			
//			getCoordination(time);
			const position:Vector3D = getPosition(time);
			const direction:Vector3D = getDirection(time);
			
			const orientationPivot:Pivot3D = _prop.pivot3D;
			orientationPivot.setPosition(position.x, position.y, position.z, 1, false);
			orientationPivot.setOrientation(direction.clone()); // NOTE : clone !!! We don't want it normalized !!!
			
			// - prop layers
			for each (elinfo in propInfo.layers) {
				const pivotLayer:Pivot3D = orientationPivot.getChildByName( elinfo.bone );
				const pivotLayerFrame:Number = Action.CalcLinearFrame(time, elinfo.from, elinfo.to, elinfo.mode, elinfo.rate);
				if (pivotLayer) {
					pivotLayer.gotoAndPlay( pivotLayerFrame );
					pivotLayer.gotoAndStop( pivotLayerFrame );
				}
			}
			
			// - wheels
			var wheel:Pivot3D;
			for each (wheel in wheels) {
				wheel.setRotation(0,0,0); // reset wheels rotation
			}
			
			// - direction
			const dirDer:Vector3D = cachedBezier.getDirectionDerivativeAt(cachedFactorNormalized).clone();
			dirDer.normalize();
			dirDer.scaleBy(vehicleLength);
			const wheelDirection:Vector3D = dirDer.add(direction); // = global wheel direction
//			trace(this,temp(dirDer));
			for each (wheel in dirWheels) {
				if (!wheel) continue; // BUG?
				wheel.setRotation(0,0,0); // dirWheels != wheels !!!
				const localWheelDirection:Vector3D = wheel.globalToLocalVector(wheelDirection);
				wheel.setOrientation(localWheelDirection); 
			}
			
			// - animation
			const wheelAngle:Number = Math.atan2(wheelDirection.z,wheelDirection.x);
			const carAngle:Number = Math.atan2(direction.z,direction.x);
			var diffAngle:Number = (wheelAngle - carAngle) * 180/Math.PI; // [-360...360]
//			trace(this,
//				"wheels",Math.round(wheelAngle* 180/Math.PI),"car",Math.round(carAngle* 180/Math.PI),
//				"diff",Math.round(diffAngle));
			if (diffAngle > 180) diffAngle -= 360; // [-360...180]
			if (diffAngle < -180) diffAngle += 360; // [-180...180]
			const steerAngle:Number = propInfo.steerAngle;
			if (diffAngle > steerAngle) diffAngle = steerAngle;
			if (diffAngle < -steerAngle) diffAngle = -steerAngle; // [-steerAngle...steerAngle]
			
			const frameFactor:Number = 0.5 + diffAngle / (steerAngle*2); // [0...1]
			
			// - character frame...
			var charFrame:Number;
//			trace(this,Maths.roundTo(frameFactor, 0.025));
			if (time === 0) idleFramesTime = 0;
			if (idleFrom === idleFrom && Maths.roundTo(frameFactor, 0.025) === 0.5) {
				charFrame = Action.CalcLinearFrame(idleFramesTime, data.idleFrom, data.idleTo, Action.LOOP, _rate);
				idleFramesTime += 1/60;
//				trace(1,charFrame, diffAngle, frameFactor);
			} else {
				idleFramesTime = 0; // reset to 0 to start over when "idle" again
				charFrame = Maths.LERP(from, to, frameFactor);
//				trace(2,charFrame, diffAngle, frameFactor);
			}
			
			if (extraCharLayers) {
				const frames:Vector.<Pair> = new Vector.<Pair>;
				frames.push( new Pair("", charFrame) ); // default
				for each (elinfo in extraCharLayers) {
					frames.push( new Pair(elinfo.bone, Action.CalcLinearFrame(time, elinfo.from, elinfo.to, elinfo.mode, elinfo.rate)) );
				}
				_character.setMeshesFrames(frames);
			} else {
				_character.setMeshesFrame(charFrame);
			}
			// ...character frame
			
			// - timoni
			if (steeringWheel) {
				const steerFrame:Number = Maths.LERP(propInfo.steerAnimFrom, propInfo.steerAnimTo, frameFactor);
				steeringWheel.gotoAndStop(steerFrame); // was : int(steerFrame)
			}
			
			// - rotation (must be last or will be cancelled by "wheels" and "direction" sections above)
			const wSpeed:Vector3D = wheelSpeed.clone();
			wSpeed.scaleBy(time);
			const wheelRot:Vector3D = new Vector3D();
			for each (wheel in wheels) { 
				wheel.getRotation(true, wheelRot).incrementBy(wSpeed);
				wheel.setRotation(wheelRot.x, wheelRot.y, wheelRot.z);
			}
		}
		
		override public function _dispose():void {
			super._dispose();
			Properties.INSTANCE.forgetActionProp(this);
		}
		
		public function get prop():Prop { return _prop }
	}
}