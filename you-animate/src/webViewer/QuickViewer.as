package webViewer
{
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.mouse.MouseWheelEnabler;
	import fanlib.text.FTextField;
	import fanlib.ui.BrowseLocal;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	import fanlib.utils.FPS;
	import fanlib.utils.Utils;
	import fanlib.utils.XMLParser2;
	
	import flare.basic.Scene3D;
	import flare.core.Boundings3D;
	import flare.utils.Pivot3DUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.Security;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	[SWF(width='1280',height='800',backgroundColor='#333333',frameRate='60')]
	public class QuickViewer extends FANApp
	{
		[Embed(source='../embedded/Viewer.xml')]
		static public const VIEWER_XML:Class;
		
		private var reportProgress:FTextField;
		private var _scene:Scene3D;
		private var model:FlareLoader;
		
		public function QuickViewer()
		{
			Security.allowDomain("*");
			super();
		}
		
		override protected function stageInitialized():void
		{
			Debug.field.defaultTextFormat = new TextFormat(null,24,0xffffff);
			Debug.field.background = true;
			Debug.field.backgroundColor = 0;
			Debug.field.htmlText = "";
			
			FPS.start();
			MouseWheelEnabler.init(stage);
			new XMLParser2().buildObjectTree(VIEWER_XML.data, null, "", this);
			reportProgress = findChild("reportProgress");
			findChild("info").y = 300;
			
			//
			
			_scene = new Scene3D( this, "" );
			_scene.autoResize = true;
			
			//
			
			const loaders:MFlareLoader = new MFlareLoader();
			loaders.addEventListener(MFlareLoader.PROGRESS, totalProgress);
			loaders.addEventListener(MFlareLoader.ALL_COMPLETE, function allComplete(e:Event):void {
				loaders.removeEventListener(MFlareLoader.ALL_COMPLETE, allComplete);
				loaders.removeEventListener(MFlareLoader.PROGRESS, totalProgress);
				allLoaded();
			});
			
			const browseFunc:Function = function(e:* = undefined):void {
				const browse:BrowseLocal = new BrowseLocal(new FileFilter("Flare 3D", "*.zf3d"), function(bytes:ByteArray):void {
					try {
						loaders.track( model = new FlareLoader( bytes, null, _scene ) );
					} catch (e:Error) {
						Debug.appendLine(e.message);
						Debug.appendLine(e.getStackTrace());
					}
				});
			};
			
			try {
				browseFunc();
			} catch (e:Error) {
				Debug.appendLine("Click inside the window to browse for a .ZF3D file");
				stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, arguments.callee); 
					browseFunc();
					Debug.field.htmlText = "";
				});
			}
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
			
			// add shit
			_scene.addChild(model);
			
			// rescale
			const bounds:Boundings3D = Pivot3DUtils.getBounds(_scene, null, _scene);
			const scaleTo:Number = 200 / bounds.length.y;
			model.setScale(scaleTo,scaleTo,scaleTo);
			Debug.appendLineMulti(",",bounds.min,bounds.max);
			Debug.appendLine("Scaled to fit:"+scaleTo);
			
			// play shit
			_scene.gotoAndPlay(0);
			
			// orbit camera
			const orbit:Orbit = new Orbit(new Vector3D(0, 200 / 2, 0));
			_scene.addChild(orbit);
			_scene.camera = orbit.camera;
		}
	}
}