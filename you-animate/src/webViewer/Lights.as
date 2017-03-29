package webViewer
{
	import fanlib.event.StgEvent;
	import fanlib.gfx.Stg;
	import fanlib.math.FVector3D;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.core.ShadowProjector3D;
	import flare.materials.filters.LightFilter;
	import flare.primitives.DebugLight;
	import flare.utils.Pivot3DUtils;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import scene.sobjects.SObject;
	
	public class Lights extends Pivot3D
	{
		static public const SURROUND:String = "surround";
		static public const FRONT:String = "front";
		static public const ANIMATED:String = "animated";
		
		private var frontLight:Light3D;
		private var blueLight:Light3D;
		private var redLight:Light3D;
		private var shadowsLight:ShadowProjector3D;
		private const shadowsLightAngle:Vector3D = new Vector3D();
		private const shadowsLightAngle2:Vector3D = new Vector3D();
		public const radToDeg:Number = 180 / Math.PI;
		
		private const frontPosition:Vector3D = new Vector3D(-80,10,0);
		
		public function Lights(name:String="")
		{
			super(name);
			addEventListener(Pivot3D.ADDED_TO_SCENE_EVENT, addedToScene);
		}
		
		private function addedToScene(e:Event):void {
			removeEventListener(Pivot3D.ADDED_TO_SCENE_EVENT, addedToScene);
			
			shadowsLight = new ShadowProjector3D("",4096,3);
			shadowsLight.setParams(0xffffff, 0, 1, 1, true);
			shadowsLight.far = 2000;
			shadowsLight.filter = 1000;
			shadowsLight.autoFade = true;
			shadowsLight.autoFadeStrength = 1;
			const camera:Camera3D = this.scene.camera;
			camera.addChild(shadowsLight);
			shadowsLight.setPosition(frontPosition.x, frontPosition.y, frontPosition.z);
			Pivot3DUtils.lookAtWithReference(shadowsLight,0,0,0,this.scene);
//			trace(shadowsLight.getPosition(false));
//			shadowsLight.addChild(new DebugLight(shadowsLight));
			
			frontLight = new Light3D("", Light3D.DIRECTIONAL);
			frontLight.setPosition(0,300,-600);
			frontLight.lookAt(0,0,0);
			frontLight.setParams(0xffffff);
			frontLight.multiplier = 1;
			
			blueLight = new Light3D("", Light3D.DIRECTIONAL);
			blueLight.setPosition(-300,100,300);
			blueLight.lookAt(0,0,0);
			blueLight.setParams(0x3838E0);
			blueLight.multiplier = 0.7;
			
			redLight = new Light3D("", Light3D.DIRECTIONAL);
			redLight.setPosition(300,0,300);
			redLight.lookAt(0,0,0);
			redLight.setParams(0xff8080);
			redLight.multiplier = 0.6;
			
			const sceneLights:LightFilter = this.scene.lights;
			sceneLights.maxPointLights = 0;
			sceneLights.maxDirectionalLights = 3;
			sceneLights.defaultLight = null;
			
			setting(FRONT);
		}
		
		public function setting(name:String):void {
			Stg.removeEventListener(Event.ENTER_FRAME, enterFrameEvent);
			Stg.removeEventListener(Event.ENTER_FRAME, checkShadowsParams);

			const sceneLights:LightFilter = this.scene.lights;
			const camera:Camera3D = this.scene.camera;

			sceneLights.ambientColor.setTo(0,0,0);
			frontLight.parent = null;
			blueLight.parent = null;
			redLight.parent = null;
			this.setRotation(0,0,0);
			
			const ambient:Number = 0.2;
			
			switch (name) {
				case FRONT:
					camera.addChild(shadowsLight);
					shadowsLight.setPosition(frontPosition.x, frontPosition.y, frontPosition.z);
					Pivot3DUtils.lookAtWithReference(shadowsLight,0,0,0,this.scene);
					sceneLights.ambientColor.setTo(ambient,ambient,ambient);
					
					Stg.addEventListener(Event.ENTER_FRAME, checkShadowsParams);
					break;
				
				case ANIMATED:
					addChild(shadowsLight);
					shadowsLight.setPosition(0,600,-1000, 1, false);
					Pivot3DUtils.lookAtWithReference(shadowsLight,0,0,0,this.scene);
					sceneLights.ambientColor.setTo(ambient,ambient,ambient);
					
					Stg.addEventListener(Event.ENTER_FRAME, enterFrameEvent);
					Stg.addEventListener(Event.ENTER_FRAME, checkShadowsParams);
					break;
				
				case SURROUND:
				default:
					shadowsLight.parent = null;
					addChild(frontLight);//.addChild(new DebugLight(frontLight));
					addChild(blueLight);//.addChild(new DebugLight(blueLight));
					addChild(redLight);//.addChild(new DebugLight(redLight));
					checkShadowsParams(null);
					break;
			}
		}
		
		private function enterFrameEvent(e:StgEvent):void {
			rotateY( 0.2 * (e.timeSinceLast * 0.06) );
		}
		
		private function checkShadowsParams(e:StgEvent):void {
			const matValue:* = SObject.SHADOWS_ONLY_FILTER.params.color.value;
			if (!matValue) return;
			
			if (shadowsLight.parent) {
				const ambiVector:Vector3D = this.scene.lights.ambientColor;
				shadowsLight.getDir(false, shadowsLightAngle);
				shadowsLightAngle2.setTo(shadowsLightAngle.x, 0, shadowsLightAngle.z);
				var angle:Number = Vector3D.angleBetween(shadowsLightAngle, shadowsLightAngle2) * radToDeg;
				if (shadowsLightAngle.y > 0) angle = -angle;
				while (angle > 90) angle -= 180;
				while (angle < -90) angle += 180;
				const factor:Number = 0.05 + 0.95 * (1 - angle/90); // maybe change to 0.6 + 0.4 ("safer", lighter)
				
				matValue[0] = factor/ambiVector.x;
				matValue[1] = factor/ambiVector.y;
				matValue[2] = factor/ambiVector.z;
				matValue[3] = 1;
			} else {
				matValue[0] = 10;
				matValue[1] = 10;
				matValue[2] = 10;
				matValue[3] = 1;
			}
//			trace(angle);
		}
	}
}