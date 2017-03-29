package scene.camera
{
	import fanlib.event.ObjEvent;
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.CheckButton;
	import fanlib.utils.Utils;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import scene.Scene;
	import scene.camera.anim.AbstractZoomKey;
	import scene.camera.anim.AbstractZoomKeyUI;
	import scene.camera.anim.ZoomManager;
	import scene.camera.anim.ZoomSpot;
	import scene.camera.anim.ZoomSpotUI;
	import scene.camera.anim.ZoomTracking;
	
	import tools.CheckButtonTool;
	
	import ui.ContextWindow;
	import ui.play.Timeline;
	
	public class ZoomWindow extends ContextWindow
	{
		static public const ZOOM_FACTOR:Number = 1.02;
		static public const ZOOM_KEY_CLASS_TO_UI:Dictionary = new Dictionary();
		
		private var _gfxZoomRect:Graphics;
		private var gfxText:FTextField;
		public var viewportHitArea:FSprite;
		public var viewport:FSprite;
		public var timeline:Timeline;
		public var keysCont:FSprite;
		private var _zoomMan:ZoomManager;
		private var _enableZoom2DBut:CheckButtonTool;
		
		public var zoom:Number = 2;
		
		private const rect:Rectangle = new Rectangle();
		private const unlistenerViewport:Unlistener = new Unlistener();
		private const unlistenerKeyUI:Unlistener = new Unlistener();
		
		public function ZoomWindow()
		{
			super();
			
			if (!ZOOM_KEY_CLASS_TO_UI.length) {
				ZOOM_KEY_CLASS_TO_UI[ZoomSpot] = "zoomSpotUI";
				ZOOM_KEY_CLASS_TO_UI[ZoomTracking] = "zoomTrackingUI";
			}
		}
		
		public function set zoomMan(value:ZoomManager):void
		{
			_zoomMan = value;
			_zoomMan.addEventListener(ZoomManager.ZOOM_KEY_ADDED, keyAdded);
			_zoomMan.addEventListener(ZoomManager.ZOOM_KEY_REMOVED, keyRemoved);
			_zoomMan.addEventListener(ZoomManager.ZOOM_KEY_ALL_REMOVED, keysRemoved);
		}
		
		private function keyAdded(o:ObjEvent):void {
			// TODO : Support ZoomTracking
			const key:AbstractZoomKey = o.getObj();
			const keyUI:AbstractZoomKeyUI = FSprite.FromTemplate( ZOOM_KEY_CLASS_TO_UI[Utils.GetClass(key)] ) as AbstractZoomKeyUI;
			unlistenerKeyUI.addListener( keyUI, AbstractZoomKeyUI.DRAG_END, userActionEnd, false, 0, false );
			keyUI.zoomKey = key; // cross-references set
			keysCont.addChild(keyUI);
			updateKeysList();
		}
		
		private function keyRemoved(e:ObjEvent):void {
			const key:AbstractZoomKey = e.getObj();
			keysCont.removeChild(key.ui);
			unlistenerKeyUI.removeListener( key.ui, AbstractZoomKeyUI.DRAG_END, userActionEnd);
			updateKeysList();
			
			if (key.ui.userDeleted) userActionEnd();
		}
		
		private function keysRemoved(e:Event):void {
			keysCont.removeChildren();
			unlistenerKeyUI.removeAll();
			updateKeysList();
		}
		
		private function userActionEnd(e:Event = null):void {
			Scene.INSTANCE.history.addState( this, _zoomMan.getHistoryState() );
		}
		
		public function updateKeysList(/*e:Event = null*/):void {
			const arr:Array = [];
			for (var i:int = keysCont.numChildren - 1; i >= 0; --i) {
				arr.push(keysCont.getChildAt(i));
			}
			arr.sortOn("keyTime", Array.NUMERIC);
			var yy:Number = 0;
			var tabindex:uint = 1;
			for (i = 0; i < arr.length; ++i) {
				const keyUI:AbstractZoomKeyUI = arr[i];
				keyUI.bullet = i+1;
				tabindex = keyUI.setTabIndices(tabindex);
				keyUI.y = yy;
				yy += keyUI.height + 10;
			}
			updateWindow();
		}
		
		override protected function contextSelected(e:Event):void {
			super.contextSelected(e);
			Scene.INSTANCE.mouseZoom.pause(this);
			
			setZoomFromButton();
			_enableZoom2DBut.addEventListener(CheckButton.CHANGE, setZoomFromButton);
			_zoomMan.updateZoomRect();
			
			// UNDO
			if (!Scene.INSTANCE.history.hasStateList( this )) {
				Scene.INSTANCE.history.newStateList( this, _zoomMan.getHistoryState() );
			}
		}
		
		override protected function contextDeselected(e:Event):void {
			super.contextDeselected(e);
			unlistenerViewport.removeAll();
			_enableZoom2DBut.removeEventListener(CheckButton.CHANGE, setZoomFromButton);
			Scene.INSTANCE.camera3D.zoom2DEnabled = false;
			
			Scene.INSTANCE.mouseZoom.unpause(this);
		}
		
		private function rollOut(e:MouseEvent):void {
			_gfxZoomRect.clear();
			gfxText.visible = false;
		}
		
		private function updateZoomRect():void {
			var temp:Number;
			
			const vRect:Rectangle = viewport.getRect(stage);
			rect.width = vRect.width / zoom;
			rect.height = vRect.height / zoom;
			
			rect.x = stage.mouseX - rect.width/2;
			if (rect.x < vRect.x)
				rect.x = vRect.x;
			else if (rect.x > (temp = vRect.x + vRect.width - rect.width))
				rect.x = temp;
			
			rect.y = stage.mouseY - rect.height/2;
			if (rect.y < vRect.y)
				rect.y = vRect.y;
			else if (rect.y > (temp = vRect.y + vRect.height - rect.height))
				rect.y = temp;
			
			_gfxZoomRect.clear();
			_gfxZoomRect.beginFill(0, 0.6);
			_gfxZoomRect.drawRect(vRect.x, vRect.y, vRect.width, vRect.height);
			_gfxZoomRect.lineStyle(1, 0xff0000, 1);
			_gfxZoomRect.drawRect(rect.x, rect.y, rect.width, rect.height);
			_gfxZoomRect.endFill();
			gfxText.visible = true;
			gfxText.x = rect.x;
			gfxText.y = rect.y;
		}
		
		private function mMove(e:MouseEvent):void {
			updateZoomRect();
		}
		private function mWheel(e:MouseEvent):void {
			zoom *= Math.pow(ZOOM_FACTOR, e.delta);
			if (zoom < 1) zoom = 1;
			updateZoomRect();
		}
		private function mDown(e:MouseEvent):void {
			const key:ZoomSpot = new ZoomSpot();
			key.time = timeline.time;
			const viewportCenterRelative:Point = viewportHitArea.globalToLocal(new Point(rect.x + rect.width/2, rect.y + rect.height/2));
//			trace(viewportCenterRelative);
//			key.x = rect.x;
//			key.y = rect.y;
			key.x = viewportCenterRelative.x / viewport.width;
			key.y = viewportCenterRelative.y / viewport.height;
			key.zoom = zoom;
			_zoomMan.addKey(key);
			Scene.INSTANCE.history.addState( this, _zoomMan.getHistoryState() );
		}

		// getters / setters
		
		public function set gfxCont(value:FSprite):void {
			gfxText = value.findChild("text");
			gfxText.visible = false;
			_gfxZoomRect = value.graphics;
		}

		public function get enableZoom2DBut():CheckButtonTool { return _enableZoom2DBut }
		public function set enableZoom2DBut(but:CheckButtonTool):void {
			_enableZoom2DBut = but;
		}
		private function setZoomFromButton(e:Event = null):void {
			Scene.INSTANCE.camera3D.zoom2DEnabled = _enableZoom2DBut.state;
			if (!_enableZoom2DBut.state) {
				unlistenerViewport.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mMove);
				unlistenerViewport.addListener(viewportHitArea, MouseEvent.ROLL_OUT, rollOut);
				unlistenerViewport.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mDown);
				unlistenerViewport.addListener(viewportHitArea, MouseEvent.MOUSE_WHEEL, mWheel);
//				unlistener.addListener(_enableZoom2DBut, Event.CHANGE, setZoomFromButton);
			} else {
				unlistenerViewport.removeAll();
			}
		}

//		private function cameraZoom2DChanged(e:Event = null):void {
//			_enableZoom2DBut.state = Scene.camera3D.zoom2DEnabled;
//		}
	}
}