package test 
{ 
	import fanlib.utils.Debug;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.FANApp;
	import fanlib.utils.FStr;
	
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Camera3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.modifiers.Modifier;
	import flare.modifiers.SkinModifier;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Vector3D;
	import flash.text.TextFormat;
	
	import scene.action.Action;
	
	import skinning.BoneSet;
	import skinning.CustomModifier2;
	import skinning.CustomModifier3;
	import skinning.Frame;
	import skinning.SkinModifierNew;
	
	import webViewer.Orbit;

	[SWF(width='800',height='480',backgroundColor='#cccccc',frameRate='60')]
	public class TestSkinModifier extends FANApp
	{
		CustomModifier3;
		
		private var _scene:Scene3D;
		private var bike:Pivot3D;
		private var vasilis:Pivot3D;
		private var skin:SkinModifierNew;
		
		private var f:Number = 0;
		
		public function TestSkinModifier() {
			super();
			
//			_scene = new Viewer3D(this);
			_scene = new Scene3D(this);
			_scene.autoResize = true;
			_scene.camera = new Camera3D();
			_scene.camera.setPosition( 50, 75, -75 );
			_scene.camera.lookAt( 0, 40, 0 );
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			Debug.field.defaultTextFormat = new TextFormat(null,26,0xffffff);
			_scene.addEventListener( ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				Debug.field.htmlText = "Loading..."+FStr.RoundToString(100 * e.bytesLoaded / e.bytesTotal, 2);
			});
			
			bike = _scene.addChildFromFile("data/props/bike.zf3d");
			bike.x = 0;
			vasilis = _scene.addChildFromFile("data/chars/Vasilis_all_anim_22-6.zf3d");
			vasilis.x = - 0;
			vasilis.scaleX = vasilis.scaleY = vasilis.scaleZ = 1;//0.04;
		}
		
		override protected function stageInitialized():void {
		}
		
		private function completeEvent(e:Event):void
		{
			Debug.field.htmlText = "";
			
			// orbit camera
			const orbit:Orbit = new Orbit(new Vector3D(0, 30, 0));
			_scene.addChild(orbit);
			_scene.camera = orbit.camera;
			orbit.setTargetDistance(-130);
			
//			if (spyros) {
//				spyros.forEach(function(mesh:Mesh3D):void {
//					mesh.modifier = CustomModifier2.CloneToCustom(mesh.modifier);
//					//mesh.modifier = new CustomModifier2(mesh.modifier);
//				}, Mesh3D);
//				spyros.gotoAndPlay(0);
//			}
			bike.getChildByName("CTRL_driver_seat").addChild(vasilis);
			
			const mariaMeshes:Array = [];
			vasilis.forEach(function(mesh:Mesh3D):void {
				mariaMeshes.push( mesh );
			}, Mesh3D);
			
			vasilis.gotoAndPlay(0);
			vasilis.gotoAndStop(0);
			var modifier:CustomModifier3;
			var mesh:Mesh3D;
			var framakia:Vector.<Frame>;
			
			for (var i:int = mariaMeshes.length - 1; i >= 0; --i) {
				mesh = mariaMeshes[i];
				modifier = ( mesh.modifier = CustomModifier3.CloneToCustom( mesh.modifier, ["Bip001 R Thigh","Bip001 L Thigh"] ) ) as CustomModifier3;
//				modifier = ( mesh.modifier = CustomModifier3.CloneToCustom( mesh.modifier, ["Bip001 Spine1"] ) ) as CustomModifier3;
				if (modifier) {
					trace(mesh.name,"is SKINNED");
				}
			}
			
			framakia = CustomModifier3.GetFramesPerSkeleton(vasilis);
			trace("framakia",framakia.length,"===",framakia);
			
			const wheel1:Pivot3D = bike.getChildByName("OBJ_wheel_FR01");
			const wheel2:Pivot3D = bike.getChildByName("OBJ_wheel_B01");
			
			const pedals:Pivot3D = bike.getChildByName("CTRL_Pedals_Rot01");
			const wheel:Pivot3D = bike.getChildByName("CTRL_Wheel_Rot01");
			
			const vWheelStart:Number = 3101, vWheelEnd:Number = 3180;
			const wheelStart:Number = 100, wheelEnd:Number = 179;
			
			const vBikeStart:Number = 3001, vBikeEnd:Number = 3100;
			const bikeStart:Number = 0, bikeEnd:Number = 99;
			
			var time:Number = 0, time2:Number = 0;
			
			const loop1:Function = function (e:Event):void {
				
				// upper body - turn wheel
				framakia[0].endFrame = Action.CalcLinearFrame(time2, vWheelStart, vWheelEnd, Action.LOOP, 15);
//				framakia[1].endFrame = Action.CalcLinearFrame(time2, vWheelStart, vWheelEnd, Action.LOOP, 15);
				wheel.gotoAndStop( Action.CalcLinearFrame(time2, wheelStart, wheelEnd, Action.LOOP, 15) );
				time2 += 1/60;
				if (Math.abs(framakia[0].endFrame-vWheelEnd) <= 0.001) {
					time2 = 0;
					stage.removeEventListener(Event.ENTER_FRAME, loop1);
					stage.addEventListener(Event.ENTER_FRAME, loop2);
				}
				
				// legs
				framakia[1].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
				framakia[2].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
//				framakia[0].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
				pedals.gotoAndStop( Action.CalcLinearFrame(time, bikeStart, bikeEnd, Action.LOOP, 30) );
				time += 1/60;
				
				wheel1.setRotation(-time*85,0,0);
				wheel2.setRotation(-time*85,0,0);
			};
			
			const loop2:Function = function (e:Event):void {
				
				// upper body - facial expressions
				framakia[0].endFrame = Action.CalcLinearFrame(time2, vBikeStart, vBikeEnd, Action.LOOP, 30);
//				framakia[1].endFrame = Action.CalcLinearFrame(time2, vBikeStart, vBikeEnd, Action.LOOP, 30);
				wheel.gotoAndStop( 100 );
				time2 += 1/60;
				if (Math.abs(framakia[0].endFrame-vBikeEnd) <= 0.001) {
					time2 = 0;
					stage.removeEventListener(Event.ENTER_FRAME, loop2);
					stage.addEventListener(Event.ENTER_FRAME, loop1);
				}
				
				// legs
				framakia[1].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
				framakia[2].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
//				framakia[0].endFrame = Action.CalcLinearFrame(time, vBikeStart, vBikeEnd, Action.LOOP, 30);
				pedals.gotoAndStop( Action.CalcLinearFrame(time, bikeStart, bikeEnd, Action.LOOP, 30) );
				time += 1/60;
				
				wheel1.setRotation(-time*85,0,0);
				wheel2.setRotation(-time*85,0,0);
			};
			
			stage.addEventListener(Event.ENTER_FRAME, loop1);
		}
	} 
}