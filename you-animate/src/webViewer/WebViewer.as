package webViewer
{
	import com.quasimondo.geom.ColorMatrix;
	
	import fanlib.filters.Color;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.io.MLoader;
	import fanlib.math.LogScale;
	import fanlib.math.Maths;
	import fanlib.mouse.MouseWheelEnabler;
	import fanlib.text.FTextField;
	import fanlib.ui.URLButton;
	import fanlib.utils.Debug;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.FANApp;
	import fanlib.utils.FArray;
	import fanlib.utils.FPS;
	import fanlib.utils.Utils;
	import fanlib.utils.XMLParser2;
	
	import filters.Color;
	
	import flare.Flare3D;
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Boundings3D;
	import flare.core.Camera3D;
	import flare.core.Label3D;
	import flare.core.Light3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.ShadowProjector3D;
	import flare.loaders.Flare3DLoader;
	import flare.primitives.DebugWireframe;
	import flare.primitives.SkyBox;
	import flare.system.Device3D;
	import flare.utils.Pivot3DUtils;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.system.Security;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import fx.Bloom;
	import fx.MotionBlur;
	
	import scene.sobjects.InfinitePlane;
	import scene.sobjects.SObject;
	
	[SWF(width='1280',height='800',backgroundColor='#333333',frameRate='60')]
	public class WebViewer extends FANApp
	{
		TopLayer; Orbit; fanlib.filters.Color; filters.Color, PivotAnimator;
		
		[Embed(source='../embedded/logo.png')]
		static public const LOGO:Class;
		
		[Embed(source='../embedded/Viewer.xml')]
		static public const VIEWER_XML:Class;
		
		// flashvars
		static public const CHAR_URL:String = "characterURL";
		static public const SCENERY_URL:String = "sceneURL";
		static public const SKYBOX_URLS_ARRAY:String = "skybox";
		static public const SKYBOX_URLS_SEPARATOR:String = "|";
		
		static public const ORBIT_INERTIA:Number = 0.1; // (0...1]
		static public const ORBIT_SPEED:Number = 0.5; // (0...1]
		
		// UI
		private var reportProgress:FTextField;
		
		// scene
		private var _scene:Scene3D;
		private const character:Pivot3D = new Pivot3D();
		private const scenery:Pivot3D = new Pivot3D();
		private var sceneryLoader:FlareLoader;
		private const cameraRoot:Pivot3D = new Pivot3D();
		private const skybox:DSkybox = new DSkybox();
		private var orbit:Orbit;
		
		private var sillyScaleBug:Number;
		private const logScaling:LogScale = new LogScale(0.01, 100);
		
		private var characterAnimation:PlayingPivot;
		
		// lights
		private var proj:ShadowProjector3D;
		
		// fx
		private var motionBlur:MotionBlur;
		private var bloom:Bloom;
		private var color:filters.Color;
		private var lights:Lights;
		
		public function WebViewer()
		{
			Security.allowDomain("*");
			super();
		}
		
		override protected function stageInitialized():void
		{
			const flashvars:Object = loaderInfo.parameters;
			
			FPS.start();
			MouseWheelEnabler.init(stage);
			new XMLParser2().buildObjectTree(VIEWER_XML.data, null, "", this);
			reportProgress = findChild("reportProgress");
			const logoURL:URLButton = findChild("logoURL");
			var logohref:String = flashvars["motherURL"];// = "asfd";
			if (logohref)
				logoURL.href = logohref;
			else
				logoURL.visible = false;
			
			//
			
			_scene = new Scene3D( this, "" );
			_scene.autoResize = true;
			orbit = new Orbit();
			_scene.addChild(orbit);
			_scene.camera = orbit.camera;
			
			//
			
			const loaders:MFlareLoader = new MFlareLoader();
			loaders.addEventListener(MFlareLoader.PROGRESS, totalProgress);
			loaders.addEventListener(MFlareLoader.ALL_COMPLETE, function allComplete(e:Event):void {
				loaders.removeEventListener(MFlareLoader.ALL_COMPLETE, allComplete);
				loaders.removeEventListener(MFlareLoader.PROGRESS, totalProgress);
				allLoaded();
			});
			loaders.trackMLoader = true;
			
			loaders.track( new FlareLoader( flashvars[CHAR_URL] || "test/4.zf3d", character, _scene ) );
			
			set3DViewerScenery( flashvars[SCENERY_URL] /*"test/infinitePlane.zf3d"*//*chess2_noLightmaps.zf3d"*/ );
			loaders.track( sceneryLoader, false );
			
			var skyboxArray:String = flashvars[SKYBOX_URLS_ARRAY];
			CONFIG::debug {
				Debug.field.defaultTextFormat = new TextFormat(null, 16, 0xffffff);
				Debug.appendLineMulti("\n","Flash Vars:",Utils.PrettyString(flashvars));
				stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, Utils.PrettyString(flashvars), false);
				});
				
//				skyboxArray ||= FArray.AddPrefix(["right.jpg","left.jpg","top.jpg","bottom.jpg","front.jpg","back.jpg"], "test/").join(SKYBOX_URLS_SEPARATOR);
			}
			skybox.context = _scene;
			set3DViewerSkybox(skyboxArray);
		}
		
		private function totalProgress(e:Event):void {
			// TODO : better gfx
			const mfl:MFlareLoader = e.currentTarget as MFlareLoader;
			if (mfl.bytesLoaded <= mfl.bytesTotal) {
				reportProgress.htmlText = "<grey>Download in progress:</grey> " + (mfl.bytesLoaded/mfl.bytesTotal*100).toFixed(1) + "%";
			} else {
				reportProgress.htmlText = "<grey>Download in progress:</grey> " + (mfl.bytesLoaded/1024).toFixed(0) + " KB";
			}
		}
		
		private function allLoaded():void
		{
			// fade-out loading screen
			(findChild("topLayer") as TopLayer).fadeAway();
			
			// set-up 3D
			_scene.addChild( character );
			_scene.addChild( scenery );
			_scene.addChild( skybox );
			
			// start animations
			var frameNum:uint = 0;
			character.forEach(function(pivot:Pivot3D):void {
				if (pivot.frames) {
					var temp:uint = pivot.frames.length - 1;
					if (temp > frameNum) frameNum = temp;
				}
			});
			
			_scene.gotoAndPlay(0);
			_scene.gotoAndStop(0);
			sillyScaleBug = Utils3D.SetWorkaroundBugScale(character);
			set3DViewerScalingLog(1);
			
			scenery.gotoAndPlay(0);
			characterAnimation = new PlayingPivot(0, frameNum, 1);
			PivotAnimator.INSTANCE.addAnimation(character, characterAnimation);
//			character.gotoAndPlay(new Label3D("",0,frameNum,1));
			
			// find logical bounds
			const max:Number = 300;
			const min:Number = 250;
			const bounds:Boundings3D = Pivot3DUtils.getBounds(character, null, _scene);
			var charHeight:Number = bounds.length.y;
			if (charHeight > max) {
				set3DViewerScalingLog(max/charHeight);
				charHeight = max;
			} else if (charHeight < min) {
				set3DViewerScalingLog(min/charHeight);
				charHeight = min;
			}
			orbit.setTargetPos( new Vector3D(0, charHeight / 2, 0) );
			
			// disable character culling due to Flare3D .bounds bugs (after all that scale doing)
			character.forEach(function(mesh:Mesh3D):void { mesh.bounds = null }, Mesh3D);
			
			// lights
			// - remove original
			 _scene.forEach(function(l:Light3D):void { l.parent = null }, Light3D);
			// - add custom
			_scene.addChild( lights = new Lights() );
			
			//CONFIG::debug { Debug.field.defaultTextFormat = new TextFormat(null, 24, 0xffffff); }
			 
			// allow JavaScript calls now
			const callBacks:Array = [
				"get3DViewerSnapshotPNGBase64",
				"get3DViewerView",
				"set3DViewerAnimSpeed",
				"set3DViewerBloom",
				"set3DViewerColor",
				"set3DViewerHSL",
				"set3DViewerLight",
				"set3DViewerMotionBlur",
				"set3DViewerScaling",
				"set3DViewerScenery",
				"set3DViewerShading",
				"set3DViewerSkybox",
				"set3DViewerView"
			];
			if (ExternalInterface.available) {
				for each (var funcName:String in callBacks) {
					try {
						ExternalInterface.addCallback(funcName, this[funcName]);
						CONFIG::debug { Debug.appendLine("Succesfully registered ExternalInterface function: "+funcName); }
					} catch (e:Error) { Debug.appendLine("EXIN:"+e.message) }
				}
				
				ExternalInterface.call("window.webViewerReady", { polygons:Utils3D.CountTriangles(character) } );
			}
			
			get3DViewerView();
			
			CONFIG::debug {
				var moveTo:String;
				var motion:Boolean = false;
				var _scale:Number = 1;
				var change:Number = 0;
				var lightOptions:Array = [Lights.FRONT, Lights.ANIMATED, Lights.SURROUND];
				stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
					switch (String.fromCharCode(e.keyCode)) {
					case "A":
						set3DViewerAnimSpeed(Math.random()*2);
						break;
					case "B":
						set3DViewerBloom(Math.random());
						break;
					case "C":
						set3DViewerColor(0xffffff*Math.random());
						break;
					case "H":
						skybox.randomHSBC();
						break;
					case "L":
						lightOptions.unshift(lightOptions.pop());
						set3DViewerLight(lightOptions[0]);
						break;
					case "M":
						set3DViewerMotionBlur(motion = !motion);
						break;
					case "S":
						_scale += 0.05;
						if (_scale > 1) _scale = 0;
						trace(_scale);
						set3DViewerScaling(_scale);
						break;
					case "X":
						change+=0.1;
						trace(change);
						set3DViewerHSL(0, 0, 0, change);
						break;
					case "Z":
						change-=0.1;
						trace(change);
						set3DViewerHSL(0, 0, 0, change);
						break;
					case "R":
						moveTo = get3DViewerView();
						trace("moveTo",moveTo);
						break;
					case "T":
						set3DViewerView(moveTo);
						break;
					}
				});
			}
		}
		
		//
		
		private function get3DViewerView():String {
			return JSON.stringify(orbit.getView());
		}
		
		private function set3DViewerView(json:String):void {
//			Debug.appendLine(json);
			return;
			const view:Object = JSON.parse(json);
			const rot:Object = view.rot;
			const pos:Object = view.pos;
			orbit.setView(new Vector3D(pos.x,pos.y,pos.z), new Vector3D(rot.x,rot.y,rot.z), view.dist);
		}
		
		private function get3DViewerSnapshotPNGBase64(_width:Number, _height:Number):String {
			return Utils3D.GetScene3DSnapshotPNGBase64(_scene, _width, _height);
		}
		
		private function set3DViewerScenery(sceneURL:String):void {
			CONFIG::debug { Debug.appendLine("set3DViewerScenery called:" + sceneURL); }
			if (sceneryLoader) {
				sceneryLoader.removeEventListener(Event.COMPLETE, sceneryLoaderComplete);
				sceneryLoader.close();
				if (color) color.destroy();
			}
			scenery.forEach( function (p:Pivot3D):void { scenery.removeChild(p) } );
			
			if (sceneURL) {
				sceneryLoader = new FlareLoader(sceneURL, null, _scene);
				scenery.addChild(sceneryLoader);
				sceneryLoader.addEventListener(Event.COMPLETE, sceneryLoaderComplete, false, 0, true);
				sceneryLoader.load();
			} else {
				// CUSTOM
				const grid:Pivot3D = new Pivot3D();
				grid.addChild(InfinitePlane.MESH).castShadows = false;
				grid.addChild(InfinitePlane.MESH_SHADOWS).castShadows = false;
				grid.setScale(10,10,10);
				scenery.addChild( grid );
			}
		}
		private function sceneryLoaderComplete(e:Event):void {
			if (!sceneryLoader.parent) return; // I am already dead!!
			sceneryLoader.removeEventListener(Event.COMPLETE, sceneryLoaderComplete);
			
			const b:Boundings3D = Pivot3DUtils.getBounds(scenery, null, _scene);
			const max:Number = Maths.maxAbs(b.min.x, b.min.y, b.min.z, b.max.x, b.max.y, b.max.z);
			if (max > 10) {
				orbit.maxDistance = -max * 3;
				orbit.minCameraFar = max;
			}
			
			// fx
			color = new filters.Color(sceneryLoader);
		}
		
		private function set3DViewerMotionBlur(bool:Boolean):void {
			CONFIG::debug { Debug.appendLine("set3DViewerMotionBlur called:" + bool); }
			if (!motionBlur && bool) {
				motionBlur = new MotionBlur(_scene);
			}
			if (motionBlur) motionBlur.amount = (bool) ? 0.5 : 0;
		}
		
		private function set3DViewerBloom(num:Number):void {
			CONFIG::debug { Debug.field.htmlText = "set3DViewerBloom called:" + num; }
			if (!bloom) bloom = new Bloom(_scene);
			bloom.setParams(3 * num, 1.5);
		}
		
		private function set3DViewerColor(num:*):void {
			var number:uint;
			if (num is String) {
				number = parseInt( (num as String).slice(1), 16);
			} else {
				number = uint(num);
			}
			CONFIG::debug { Debug.field.htmlText = "set3DViewerColor called:" + num + ", parsed:" + number; }
			if (color) color.setParams(number, BlendMode.OVERLAY, 1);
		}
		
		private function set3DViewerShading(mode:String):void {
			//CONFIG::debug { Debug.field.htmlText = "set3DViewerShading called:" + mode; }
			// TODO
		}
		
		private function set3DViewerLight(mode:String):void {
			CONFIG::debug { Debug.field.htmlText = "set3DViewerLight called:" + mode; }
			lights.setting(mode);
		}
		/**
		 * Change character scale 
		 * @param scale [0 ... 1], is converted to logarithmic scale [0.01 ... 100]
		 */
		private function set3DViewerScaling(scale:Number):void {
			//			CONFIG::debug { Debug.appendLine("set3DViewerScaling called: "+scale); }
			scale = logScaling.getLogValue(scale);
			scale *= sillyScaleBug;
			character.setScale(scale,scale,scale);
		}
		
		private function set3DViewerScalingLog(scale:Number):void {
			//			CONFIG::debug { Debug.appendLine("set3DViewerScaling called: "+scale); }
			set3DViewerScaling(logScaling.getFactorFromLog(scale));
		}
		
		private function set3DViewerAnimSpeed(speed:Number):void {
			CONFIG::debug { Debug.appendLine("set3DViewerAnimSpeed called: "+speed); }
			characterAnimation.speed = speed;
//			character.frameSpeed = speed;
		}
		
		/**
		 * Change Skybox
		 * @param str 6 URIs in a single String, "|" separated!
		 */
		private function set3DViewerSkybox(str:String):void {
			CONFIG::debug { Debug.appendLine("set3DViewerSkybox called: "+str) ; }
			if (!str) return;
			
			const arr:Array = str.split(SKYBOX_URLS_SEPARATOR);
			if (arr.length !== 6) return;
			CONFIG::debug { Debug.appendLine("set3DViewerSkybox -> "+arr); }
			skybox.setTextures(arr);
		}
		
		private function set3DViewerHSL(hue:Number, sat:Number, bright:Number, contr:Number):void {
			skybox.setHSBC(hue, sat, bright, contr);
		}
	}
}