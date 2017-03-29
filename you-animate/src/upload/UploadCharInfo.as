package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Distributor2;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.FShape;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.io.Server;
	import fanlib.mouse.MouseWheel;
	import fanlib.mouse.MouseWheelEnabler;
	import fanlib.text.FTextField;
	import fanlib.tween.TPlayer;
	import fanlib.ui.BrowseLocal;
	import fanlib.ui.CheckButton;
	import fanlib.ui.Tooltip;
	import fanlib.utils.DFXML2;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	import fanlib.utils.JobsToGo;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Boundings3D;
	import flare.core.Camera3D;
	import flare.core.Mesh3D;
	import flare.loaders.Flare3DLoader;
	import flare.utils.Pivot3DUtils;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	
	import scene.CharManager;
	import scene.Placeholder;
	import scene.action.ActionInfo;
	import scene.sobjects.InfinitePlane;
	
	import tools.CheckButtonTool;
	import tools.ToolButton;
	
	import ui.LabelButton;
	import ui.LabelCheck;
	import ui.LabelInputNum;
	import ui.LabelRadio;
	import ui.LabelThumb;
	import ui.report.Reporter;
	
	import upload.buttons.MiscParams;
	import upload.server.AnimInfo;
	import upload.server.EditModeVars;
	import upload.server.Headers;
	import upload.server.ServerF3DFile;
	import upload.server.ServerObjectFile;
	import upload.server.ServerRequest;
	import upload.server.ServerThumb;
	
	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class UploadCharInfo extends FANApp
	{
		Distributor2; LabelThumb; CheckButton; LabelCheck; Animline; AnimPlay; Tooltip; AnimThumbs; ScaleInput; LabelInputNum; CheckButtonTool;
		ServerF3DFile; ServerThumb; PropInput; GrabThumb; MiscParams; LabelButton; LabelRadio; ObjectList; ServerObjectFile;
		MeasureHeightMesh;
		
		private var scene3D:ModelViewer;
		private var jobs:JobsToGo = new JobsToGo(context3DAndUIReady);
		private var nameToObject:Object;
//		private var dummyLoader:Flare3DLoader;
		
		private var charEdit:CharEdit;
		private var _measure:Mesh3D;
		
		public function UploadCharInfo(appDir:String = "data/") {
			const flashvars:Object = loaderInfo.parameters;
			
			// set-up dirs
			const externallySetDir:String = flashvars["rootDir"];
			if (externallySetDir) appDir = externallySetDir;
			Walk3D.SetDirs(appDir);
			Tooltip.DefaultTooltipName = "TOOL_TIP";
			ToolButton.IconsFolder = Walk3D.UI_DIR;
			
			ServerRequest.SetDomainPaths( loaderInfo );
//			ServerRequest.SetDomain(flashvars["host"]);
			Security.allowDomain("*");
			Security.loadPolicyFile(ServerRequest.GetDomain()+"/crossdomain.xml");
			
			// Server headers - required by 'FileReference' !!!
			trace(this, flashvars["session"]);
			ServerRequest.SessionID = flashvars["session"];
			Headers.AddHeader("Cookie", "PHPSESSID=" + ServerRequest.SessionID); // NOTE : not used, nowhere, ever
			
			super(); // must come AFTER dirs
		}
		
		override protected function stageInitialized():void {
			autoShowAll(true);
//			MouseWheel.capture();
			MouseWheelEnabler.init(stage);
			trace("\n","Security settings",Security.pageDomain,Security.sandboxType);
			trace(":","PHPSESSID",(Headers.Get()[0].name,Headers.Get()[0].value));
			trace("HOST SET:"+ServerRequest.GetDomain());
			
			Server.UncacheScripts = true;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Flare3D
			scene3D = new ModelViewer(this);
			scene3D.antialias = 2;
			jobs.newJob();
			scene3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreated, false, 0, true);
			
			jobs.newJob( new DFXML2(Walk3D.APP_DIR + "upload/upload.xml", this, uiLoaded, null, Walk3D.UI_DIR) );
			jobs.newJob( CharManager.INSTANCE.addInfoList(Walk3D.APP_DIR + "characterInfo.txt", jobs.jobDone) );
			jobs.newJob( CharManager.INSTANCE.defaultSanAndreasList(jobs.jobDone) );
			
			jobs.allJobsSet(); // as soon as new jobs are added BEFORE old jobs are closed, we are OK! GET IT?
		}
		
		private function uiLoaded(o:ObjEvent):void {
			nameToObject = (o.currentTarget as DFXML2).nameToObject;
			Reporter.SetField(nameToObject["log"]);
			ServerRequest.Report = nameToObject["progressReport"];
			scene3D.viewportDO = nameToObject["viewport"];
			scene3D.viewportInteractive = nameToObject["viewportHitArea"];
			for each (var gt:GrabThumb in [ nameToObject["grabMainThumb"], nameToObject["grabAnimThumb"] ]) {
				gt.scene3D = scene3D;
				gt.hideStuff.push( _measure );
			}
			jobs.jobDone();
		}
		
		private function context3DCreated(e:Event):void {
//			dummyLoader = new Flare3DLoader(APP_DIR+"dummy.zf3d", null, scene3D);
//			dummyLoader.addEventListener(Event.COMPLETE, dummyLoaded, false, 0, true);
//			jobs.newJob();
//			dummyLoader.load();
//			
//			jobs.jobDone();
//		}
//		private function dummyLoaded(e:Event):void {
//			dummyLoader.removeEventListener(Event.COMPLETE, dummyLoaded);
//			dummyLoader = null;
			
			// set-up camera
			scene3D.camera = new Camera3D();
			scene3D.camera.setPosition( 0, 2.2, -7 );
//			scene3D.camera.lookAt( 0, 0, 0 );
			scene3D.camera.near = 0;
			scene3D.addChild(scene3D.camera); // must be added in the scene to be rendered!
			
			// grid floor
			scene3D.addChild(InfinitePlane.MESH);
			
			// scale reference
			_measure = MeasureHeightMesh.Mesh();
			scene3D.addChild(_measure);
			_measure.hide();
			
			jobs.jobDone();
		}
		
		protected function context3DAndUIReady():void {
			stage.dispatchEvent(new Event(Event.RESIZE)); // trigger resize now, after all viewports are set
			
			const topLayer:TopLayer = FSprite.FromTemplate("TOP_LOAD_F3D") as TopLayer;
			const txt:FTextField = topLayer.getChildAt(0) as FTextField;
			
			// topLayer clicked
			const topLayerDown:Function = function(e:MouseEvent):void {
				var fileRef:FileReference;
				topLayer.removeEventListener(MouseEvent.MOUSE_DOWN, topLayerDown);
				
				new BrowseLocal(
					new FileFilter("Flare3D files (.f3d, .zf3d)", "*.f3d;*.zf3d;"),
					function bytesLoaded(data:ByteArray):void {
						
						try {
							charEdit = new CharEdit(fileRef, scene3D, nameToObject);
							charEdit.whenModelLoaded(charEditLoaded);
						} catch (err:Error) {
							Reporter.AddError(String(this),err.message,err.getStackTrace());
							txt.htmlText = "<grey>File</grey> " + fileRef.name + " <grey>is unreadable</grey>";
							topLayer.addEventListener(MouseEvent.MOUSE_DOWN, topLayerDown);
						}
					},
					function fileSelected(ref:FileReference):void {
						fileRef = ref;
						txt.htmlText = "<grey>Processing</grey> " + fileRef.name + " <grey>file</grey>";
					},
					function cancel():void {
						topLayer.addEventListener(MouseEvent.MOUSE_DOWN, topLayerDown);
					}
				);
			}

			// final function: charEdit loaded succesfully
			const charEditLoaded:Function = function():void {
				(nameToObject["timeline"] as Animline).charEdit = charEdit;
				(nameToObject["propWindow"] as PropWindow).charEdit = charEdit;
				topLayer.fadeAway();
				
				const bounds:Boundings3D = Pivot3DUtils.getBounds(charEdit, null, scene3D);
				_measure.x = _measure.bounds.min.x + bounds.min.x;
				_measure.show();
			}
			
			// load character
			jobs.newJob();
			const flashvars:Object = loaderInfo.parameters;
			const editModeVars:EditModeVars = EditModeVars.Get(flashvars);
			if (editModeVars) {
				CONFIG::debug {Debug.appendLineMulti(",","EDIT MODE:",Utils.PrettyStringND(editModeVars)); }
				
				// - download from server
				var timer:int;
				charEdit = new CharEdit(
					editModeVars, scene3D, nameToObject,
					function(e:ProgressEvent):void {
						if (getTimer() - timer < 50) return;
						timer = getTimer();
						if (e.bytesLoaded < e.bytesTotal) {
							txt.htmlText = "<grey>Download in progress:</grey> " + (e.bytesLoaded/e.bytesTotal*100).toFixed(1) + "%";
						} else {
							txt.htmlText = "<grey>Download in progress:</grey> " + (e.bytesLoaded/1024).toFixed(0) + " KB";
						}
					}
				);
				charEdit.whenModelLoaded(charEditLoaded);
				
			} else {
								
				// - load from filesystem
				txt.htmlText = "<grey>Click to browse for a</grey> Flare3D <grey>file</grey>";
				topLayer.addEventListener(MouseEvent.MOUSE_DOWN, topLayerDown);
			}
		}
	}
}