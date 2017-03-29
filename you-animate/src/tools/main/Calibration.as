package tools.main
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.ui.slider.Slider;
	import fanlib.ui.slider.SliderText;
	import fanlib.ui.slider.SliderTextLog;
	
	import flare.basic.Scene3D;
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import scene.CharManager;
	import scene.Character;
	import scene.HistoryState;
	import scene.Scene;
	import scene.action.BNode;
	import scene.action.Node;
	import scene.camera.Camera;
	import scene.sobjects.InfinitePlane;
	import scene.sobjects.SObject;
	
	import tools.Tool;
	
	public class Calibration extends Tool
	{
		static private var DefaultChar:Character;
		static public function LoadDefaultChar():void {
			DefaultChar = CharManager.INSTANCE.requestCharacter(CharManager.INSTANCE.getCharacterInfoByName("Player"),
				Scene.INSTANCE.iScene3D as Scene3D, null, null);
		}
		
//		private const infinite:InfinitePlane = new InfinitePlane(new Pivot3D());
		
		public var scaleSlider:SliderTextLog;
		public var zoomSlider:SliderTextLog;
		public var horizonSlider:SliderText;
		
		public var viewportHitArea:FSprite;
		private var mouseCollision:MouseCollision;
		private var unlistener:Unlistener = new Unlistener();
		
		private const chars:Vector.<Character> = new Vector.<Character>;
		private var currentChar:Character;
		
		private const horizon:FSprite = new FSprite();
		private const horPos:Vector3D = new Vector3D(0,0,InfinitePlane.PLANE_SIZE);
		private const horHeight:Vector3D = new Vector3D();
		
		public function Calibration()
		{
			super();
			
//			infinite.pivot3D.z = InfinitePlane.PLANE_SIZE*2;
//			infinite.pivot3D.setRotation(-90,0,0);
			horizon.mouseEnabled = false;
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			
			if (selected) {
				
				if ( !Scene.INSTANCE.history.hasStateList(this) ) {
					Scene.INSTANCE.history.newStateList( this, getHistoryState() );
				}
				
				var gfx:Graphics = horizon.graphics;
				gfx.clear();
				gfx.lineStyle(2,0,0.5);
				var w:Number = viewportHitArea.hitArea.width;
				gfx.moveTo(-w/2,0);
				gfx.lineTo(w/2,0);
				Scene.INSTANCE.add2DOverlay(horizon);
				repositionHorizon();
				
				// sliders
				updateSliderSettings();
				unlistener.addListener(scaleSlider, Event.CHANGE, scaleChange);
				unlistener.addListener(zoomSlider, Event.CHANGE, zoomChange);
				unlistener.addListener(horizonSlider, Event.CHANGE, horizonChange);
				
				unlistener.addListener(scaleSlider, Slider.STOPPED_CHANGING, sliderStopped);
				unlistener.addListener(zoomSlider, Slider.STOPPED_CHANGING, sliderStopped);
				unlistener.addListener(horizonSlider, Slider.STOPPED_CHANGING, sliderStopped);
				
				// add chars
				mouseCollision = new MouseCollision();
				Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_OUT, mVPortOut);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
				
			} else {
				horizon.parent = null;
				
				unlistener.removeAll();
				
				for each (var char:Character in chars) {
					Scene.INSTANCE.removeCharacter(char);
				}
				chars.length = 0;
				mouseCollision = null;
			}
		}
		
		//
		
		private function addChar():void {
			currentChar = Scene.INSTANCE.addCharacter(DefaultChar.info);
			const initNode:Node = currentChar.newNode(null, Node);
			chars.push(currentChar); // Player			
		}
		
		private function mVPortOut(e:MouseEvent):void {
			if (currentChar) {
				Scene.INSTANCE.removeCharacter(currentChar);
				currentChar = null;
				chars.length -= 1;
			}
		}
		
		private function mVPortMove(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true, false)) {
				if (!currentChar) addChar();
				
				var colInfo:CollisionInfo = mouseCollision.data[0];
				var charNode:Node = currentChar.getLastActionNode();
				charNode.sobject = SObject.GetFromMesh(colInfo.mesh);
				charNode.setPosition(colInfo.point);
				currentChar.setTime(0);
			}
		}
		private function mVPortDown(e:MouseEvent = null):void {
			addChar();
		}
		
		//
		
		private function zoomChange(e:Event = null):void {
			const camera:Camera3D = Scene.INSTANCE.camera3D;
			camera.fieldOfView = zoomSlider.valueLog;
//			camera.zoom = zoomSlider.valueLog;
			repositionSceneNodes();
			repositionHorizon();
		}
		private function horizonChange(e:Event = null):void {
			const camera:Camera3D = Scene.INSTANCE.camera3D;
			camera.setRotation(horizonSlider.valueNum,0,0);
			repositionSceneNodes();
			repositionHorizon();
		}
		private function scaleChange(e:Event = null):void {
			Scene.INSTANCE.globalScale = scaleSlider.valueLog;
		}
		
		// -- UNDO
		private function sliderStopped(e:Event):void {
			Scene.INSTANCE.history.addState( this, getHistoryState() );
		}
		
		private function getHistoryState():HistoryState {
			const camObj:Object = Scene.INSTANCE.camera3D.serialize();
			const gScale:Number = Scene.INSTANCE.globalScale;
			return new HistoryState(function():void {
				new Camera().deserialize(camObj);
				Scene.INSTANCE.globalScale = gScale;
				updateSettings();
			});
		}
		// UNDO --
		
		private function repositionHorizon():void {
			Scene.INSTANCE.iScene3D.getPointScreenCoords(horPos, horHeight);
			horizon.x = horHeight.x;
			horizon.y = horHeight.y;
		}
		
		private function repositionSceneNodes():void {
			Scene.INSTANCE.characters.forEach(repositionCharNodes);
		}
		private function repositionCharNodes(char:Character):void {
			const mouseCollision:MouseCollision = new MouseCollision();
			char.forEachNode(function(node:Node):void {
				if (!node.sobject) return;
				mouseCollision.addCollisionWith(node.sobject.pivot3D, true);
				node.setPositionFrom2D(mouseCollision); // TODO : check if no more over SObject... and do something?
				mouseCollision.removeCollisionWith(node.sobject.pivot3D, true);
			});
			char.setTime(char.currentTime); // NOTE : "Strange" effect because time is internally cached
		}
		
		private function updateSliderSettings():void {
			const camera:Camera3D = Scene.INSTANCE.camera3D;
			zoomSlider.valueLog = camera.fieldOfView;
			//zoomSlider.valueLog = camera.zoom;
			horizonSlider.valueNum = camera.getRotation().x;
			scaleSlider.valueLog = Scene.INSTANCE.globalScale;
		}
		
		//
		
		private function updateSettings():void {
			updateSliderSettings();
			repositionHorizon();
			repositionSceneNodes();
		}
	}
}