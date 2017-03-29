package
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Distributor;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TouchWindow;
	import fanlib.gfx.vector.FShape;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.io.Server;
	import fanlib.math.BezierCubic3D;
	import fanlib.math.Maths;
	import fanlib.mouse.MouseWheel;
	import fanlib.mouse.MouseWheelEnabler;
	import fanlib.security.Dated;
	import fanlib.starling.FSprite;
	import fanlib.starling.TSprite;
	import fanlib.tween.TPlayer;
	import fanlib.ui.Keys;
	import fanlib.ui.Tooltip;
	import fanlib.ui.numText.NumTextDrag;
	import fanlib.ui.slider.SliderText;
	import fanlib.ui.slider.SliderTextLog;
	import fanlib.utils.DFXML2;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	import fanlib.utils.FStr;
	import fanlib.utils.JobsToGo;
	import fanlib.utils.Lexicon2;
	import fanlib.utils.Utils;
	import fanlib.utils.js.PreventClose;
	
	import flare.basic.Scene3D;
	import flare.loaders.Flare3DLoader;
	import flare.materials.Material3D;
	
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.display3D.Context3DClearMask;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import scene.CharManager;
	import scene.Crowd;
	import scene.MouseZoom;
	import scene.Scene;
	import scene.action.AbstractMoveAction;
	import scene.action.Action;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.CtrlNode;
	import scene.action.FixedAction;
	import scene.action.LinearMove;
	import scene.action.Node;
	import scene.action.TurnAction;
	import scene.action.special.BezierPropMove;
	import scene.action.special.DriveAction;
	import scene.action.special.FixedPropAction;
	import scene.action.special.FixedPropOnNode;
	import scene.action.special.PropAttached;
	import scene.action.special.Properties;
	import scene.camera.Camera;
	import scene.camera.ZoomWindow;
	import scene.camera.anim.ZoomSpot;
	import scene.camera.anim.ZoomSpotUI;
	import scene.layers.LayerUI;
	import scene.sobjects.SObject;
	
	import skinning.SkinModifierNew;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.ResizeEvent;
	
	import test.BoneController;
	
	import tools.Tool;
	import tools.ToolButton;
	import tools.lights.LightsWindow;
	import tools.main.AddChar;
	import tools.main.AddCrowd;
	import tools.main.Calibration;
	import tools.main.Load;
	import tools.main.NewScene;
	import tools.main.Rec;
	import tools.main.Save;
	import tools.main._PlayAll;
	import tools.misc.Redo;
	import tools.misc.TopDownView;
	import tools.misc.Undo;
	import tools.param.Param;
	import tools.param.ParamTool;
	import tools.photo.Photo;
	import tools.photo.PhotoTools;
	import tools.photo.PhotoViewport;
	import tools.selectChar.AddBezierMove;
	import tools.selectChar.AddLinearMove;
	import tools.selectChar.DeleteSelected;
	import tools.selectChar.NodeHeight;
	import tools.selectChar.SelectChar;
	
	import ui.ButtonText;
	import ui.ContextIcons;
	import ui.ContextWindow;
	import ui.Icons;
	import ui.LabelCheck;
	import ui.LabelInput;
	import ui.WTooltip;
	import ui.addChar.AddCharGrid;
	import ui.addChar.AddCharWindow;
	import ui.addChar.AddCrowdWindow;
	import ui.addChar.CrowdEditor;
	import ui.list.ListActions;
	import ui.list.ListObjects;
	import ui.play.PlayPause;
	import ui.play.Timeline;
	import ui.report.ProgressTracker;
	import ui.report.ProgressWindow;
	import ui.thumbs.ThumbsAnim;
	import ui.thumbs.ThumbsFixed;
	import ui.thumbs.ThumbsMove;
	
	import upload.server.ServerRequest;
	
	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class Walk3D extends FANApp
	{
		Scene.INSTANCE; SkinModifierNew;
		ContextIcons; FShape; TurnAction; SObject; BNode; CtrlNode; BezierMove; AddBezierMove; _PlayAll; SliderText; SliderTextLog;
		Tool; Icons; Photo; PhotoViewport; AddChar; LinearMove; SelectChar; DeleteSelected; AddLinearMove; Calibration; FlareLoader;
		Save; Load; NodeHeight; BoneController; TouchWindow; ListObjects; ListActions; ThumbsAnim; ThumbsFixed; ThumbsMove;
		Properties; FixedPropOnNode; NewScene; NumTextDrag; PhotoTools; Distributor; LayerUI; PlayPause; Timeline; DriveAction;
		BezierPropMove; PropAttached; FixedPropAction; TopDownView; AddCharGrid; ContextWindow; ButtonText; Rec;
		LabelInput; TopLayer; ParamTool; ZoomSpotUI; ZoomWindow; WTooltip; MouseZoom; LightsWindow; Undo; Redo;
		AddCrowd; ProgressTracker; ProgressWindow; LabelCheck; AddCharWindow; AddCrowdWindow; Crowd; CrowdEditor;
		
		static public const LAYER_TRANSPARENT:int = 50;
		static public const LAYER_LAYERS:int = LAYER_TRANSPARENT;
		static public const LAYER_SURFACE:int = LAYER_LAYERS + 10; // only used for DARK
		static public const LAYER_NODE:int = LAYER_SURFACE + 10;
		static public const LAYER_PLACEHOLDER:int = LAYER_NODE + 10;
		static public const LAYER_SHADOWS:int = LAYER_PLACEHOLDER + 10;
		
		//
		static public function AppendToPathIfRelative(append:String, path:String):String {
			if (path) {
				if ( path.indexOf("://") < 0 ) path = append + path; // path is probably relative!
//				if ( path.slice(0, 7) !== "http://" && path.slice(0, 8) !== "https://" ) path = append + path;
			}
			return path;
		}
		
		static public var APP_DIR:String;
		static public var UI_DIR:String;
		static public var CHARS_DIR:String;
		static public var PROPS_DIR:String;
		
		static private var FILE_TOOLTIP_LEXICON:String;
		static private var FILE_UI_XML:String;
		static private var FILE_TEMP_CHARACTERINFO:String;
		static private var FILE_DUMMY_ZF3D:String;
		
		static public function SetDirs(appDir:String):void {
			APP_DIR = appDir;
			UI_DIR = APP_DIR + "ui/";
			CHARS_DIR = APP_DIR + "chars/";
			PROPS_DIR = APP_DIR + "props/";
			
			FILE_TOOLTIP_LEXICON = UI_DIR + "wtooltip.json";
			FILE_UI_XML = UI_DIR + "stg_walk3D.xml";
			FILE_TEMP_CHARACTERINFO = APP_DIR + "characterInfo.txt";
			FILE_DUMMY_ZF3D = APP_DIR+"dummy.zf3d";
		}
		
		//

		static public const KEYS:Keys = new Keys();
		static public const LEXICON:Lexicon2 = new Lexicon2();
		
		static public var starlingBack:Starling;
		private var scene3D:Viewer;
		private var viewport:FShape;
		
		private var jobs:JobsToGo = new JobsToGo(allInitialized);
		private var dummyLoader:Flare3DLoader;
		
		public function Walk3D(appDir:String = "data/") {
			// set-up dirs
			appDir = loaderInfo.parameters["rootDir"] || appDir;
			SetDirs(appDir);
			Tooltip.DefaultTooltipName = "WTOOLTIP";
			ToolButton.IconsFolder = UI_DIR;
			
			ServerRequest.SetDomainPaths( loaderInfo );
			
			// Lexicon
			LEXICON.load(FILE_TOOLTIP_LEXICON);
			WTooltip.LEXICON = LEXICON;
			
			super(); // must come AFTER dirs
		}
		
		override protected function stageInitialized():void {
			Lexicon2.SetDefaultLanguage("en");
			// DEBUG:
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void {
				if (e.keyCode === Keyboard.R) {
					LEXICON.load(FILE_TOOLTIP_LEXICON); // reload lexicon references
				}
			});
			
			autoShowAll(true);
//			MouseWheel.capture(); // Windows only solution
			MouseWheelEnabler.init(stage);
			
			CONFIG::debug {
				Debug.field.defaultTextFormat = new TextFormat(null, 14, 0xffffff);
				Debug.field.filters = [new DropShadowFilter(2)];
				Debug.field.text = "";
				Debug.appendLine("Domain:" + ServerRequest.GetDomain());
				Debug.appendLine("APIRoot:" + ServerRequest.GetAPIRoot());
				Debug.field.background = true;
				Debug.field.backgroundColor = 0;
				Debug.field.appendText("stageInitialized"+jobs.unfinishedJobs+"\n");
			}
			Server.UncacheScripts = true;
			KEYS.enable = true;
			
			// Flare3D
			scene3D = new Viewer(this);
			scene3D.antialias = 2;
			scene3D.setLayerSortMode(LAYER_LAYERS, Scene3D.SORT_BACK_TO_FRONT);
			scene3D.setLayerSortMode(LAYER_SURFACE, Scene3D.SORT_BACK_TO_FRONT);
			scene3D.setLayerSortMode(LAYER_NODE, Scene3D.SORT_BACK_TO_FRONT);
			scene3D.setLayerSortMode(LAYER_PLACEHOLDER, Scene3D.SORT_BACK_TO_FRONT);
			scene3D.setLayerSortMode(LAYER_SHADOWS, Scene3D.SORT_BACK_TO_FRONT);
			
			jobs.newJob();
			scene3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreated, false, 0, true);
			
//			stage.addEventListener(MouseEvent.RIGHT_CLICK, function (e:Event):void { }); // remove right-click menu
			
			jobs.newJob( new DFXML2(FILE_UI_XML, this, uiLoaded, LEXICON, UI_DIR) );
			jobs.newJob( CharManager.INSTANCE.addInfoList(FILE_TEMP_CHARACTERINFO, jobs.jobDone) );
			jobs.newJob( CharManager.INSTANCE.addInfoList(ServerRequest.URLAllCharacters(), jobs.jobDone) );
			jobs.newJob( CharManager.INSTANCE.defaultSanAndreasList(jobs.jobDone) );
			
			CONFIG::debug { Debug.field.appendText("jobs.allJobsSet"+jobs.unfinishedJobs+"\n"); }
			jobs.allJobsSet(); // as soon as new jobs are added BEFORE old jobs are closed, we are OK! GET IT?
		}
		
		private function context3DCreated(e:Event):void {
			// Stg.LockPixelDims(); // For TVs!?
			CONFIG::debug { Debug.field.appendText("context3DCreated1 "+jobs.unfinishedJobs+"\n"); }
			starlingBack = new Starling(TSprite, Stg.Get(), null, Stg.Get().stage3Ds[0]); // viewport MUST be null to follow exactly Scene3D's
			starlingBack.antiAliasing = 2;
			jobs.newJob();
			starlingBack.addEventListener( starling.events.Event.ROOT_CREATED, starlingRootCreated );
			starlingBack.start();
			
			dummyLoader = new Flare3DLoader(FILE_DUMMY_ZF3D, null, scene3D);
			dummyLoader.addEventListener(Event.COMPLETE, dummyLoaded, false, 0, true);
			jobs.newJob();
			CONFIG::debug { Debug.field.appendText("context3DCreated2 "+jobs.unfinishedJobs+" "+dummyLoader+"\n"); }
			try {
				dummyLoader.load();
			} catch(err:Error) {Debug.field.appendText(err.message+err.getStackTrace()+"\n");}
			
			CONFIG::debug { Debug.field.appendText("context3DCreated3 "+jobs.unfinishedJobs+"\n"); }
			jobs.jobDone();
		}
		private function starlingRootCreated(e:starling.events.Event):void {
			CONFIG::debug { Debug.field.appendText("starlingRootCreated"+jobs.unfinishedJobs+"\n"); }
			jobs.jobDone();
		}
		private function dummyLoaded(e:Event):void {
			CONFIG::debug { Debug.field.appendText("dummyLoaded1 "+jobs.unfinishedJobs+"\n"); }
			dummyLoader.removeEventListener(Event.COMPLETE, dummyLoaded);
			dummyLoader = null;
			
			const camera:Camera = new Camera();
			scene3D.camera = camera;
			scene3D.addChild(camera); // must be added in the scene to be rendered!
			camera.setPosition( 0, 10, 0 );
			camera.rotateX(30);
			Camera.DefaultSettings = camera.serialize();
				
			jobs.jobDone();
			CONFIG::debug { Debug.field.appendText("dummyLoaded2 "+jobs.unfinishedJobs+"\n"); }
		}
		
		// draw 2D stuff below
		private function renderEvent(e:flash.events.Event):void {
//			trace(starlingBack === Starling.current);
//			starlingBack.context.clear(0, 0, 0, 0, 0, 0, Context3DClearMask.STENCIL);
			starlingBack.nextFrame();
//			starlingBack.context.clear(0, 0, 0, 0, 0, 0, Context3DClearMask.STENCIL);
			return;
		}
		
		private function uiLoaded(o:ObjEvent):void {
			CONFIG::debug { Debug.field.appendText("uiLoaded1"+jobs.unfinishedJobs+"\n"); }
			viewport = findChild("viewport");
			scene3D.viewportDO = viewport;
			removeFromDevVersion();
			jobs.jobDone();
			CONFIG::debug { Debug.field.appendText("uiLoaded2"+jobs.unfinishedJobs+"\n"); }
		}
		protected function removeFromDevVersion():void {
			(findChild("photoViewport") as fanlib.gfx.FSprite).parent = null;
		}
		
		protected function allInitialized():void {
			CONFIG::debug { Debug.field.appendText("allInitialized"+jobs.unfinishedJobs+"\n"); }
			starlingBack.stage.stageWidth = viewport.width;
			starlingBack.stage.stageHeight = viewport.height;
			Scene.INSTANCE.init(
				scene3D, starlingBack.root as TSprite, findChild("nodesParent"),
				viewport, findChild("viewportHitArea"), findChild("zoomMan"), findChild("zoomPan"),
				findChild("lights"));
			
			stage.dispatchEvent(new Event(Event.RESIZE)); // force viewports refresh
			
			scene3D.addEventListener(Scene3D.RENDER_EVENT, renderEvent);
			CONFIG::debug { Debug.field.appendText("allInitialized"+jobs.unfinishedJobs+"\n"); }
			
			//
			
			Calibration.LoadDefaultChar();
		}
	}
}