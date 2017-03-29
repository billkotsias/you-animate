package tools.misc
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.math.Maths;
	import fanlib.utils.IInit;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.AbstractMoveAction;
	import scene.action.Action;
	import scene.action.Node;
	import scene.layers.Layer;
	
	import tools.CheckButtonTool;
	import scene.camera.Camera;
	
	public class TopDownView extends CheckButtonTool implements IInit
	{
		static public const WHEEL_MOVE_UP:Number = 1.03;
		static public const WHEEL_MOVE_DOWN:Number = 1 / WHEEL_MOVE_UP;
		
//		/**
//		 * Defined relatively to total z depth 
//		 */
//		public var maxMinZ:Number = 0.05;
//		private var maxZ:Number;
//		private var minZ:Number;
		
		public var viewportHitArea:FSprite;
		public var initY:Number = 100;
		
		private var cameraCalibration:Object;
		private const unlistener:Unlistener = new Unlistener();
		private const panning:Point = new Point();
		
		public function TopDownView()
		{
			super();
		}
		
		public function initLast():void {
			Scene.INSTANCE.whenInitialized(function ():void {
				enabled = true;
				if (selected) selected = true;
			});
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			if (!enabled) return;
			
			const sceneCam:Camera = Scene.INSTANCE.camera3D as Camera;
			
			if (select) {
				Scene.INSTANCE.mouseZoom.pause(this);
				
				cameraCalibration = sceneCam.serialize();
				
//				// get total z depth
//				minZ = Infinity;
//				maxZ = -Infinity;
//				const out:Vector3D = new Vector3D();
//				Scene.INSTANCE.characters.forEach(function (char:Character):void {
//					const nodes:Array = char.getNodesArray();
//					for (var i:int = nodes.length - 1; i >= 0; --i) {
//						const node:Node = nodes[i];
//						node.getPosition(out);
//						if (minZ > out.z) minZ = out.z;
//						if (maxZ < out.z) maxZ = out.z;
//					}
//				});
				
				// prohibit layers
				Scene.INSTANCE.background.setInvisible(this);
				Scene.INSTANCE.layers.forEach(function (layer:Layer):void { layer.setInvisible(this) });
				
				// top-down camera settings
//				trace(this,"fieldOfView",sceneCam.fieldOfView);
				sceneCam.setRotation(90,0,0);
				sceneCam.fieldOfView = 75;
				sceneCam.y = initY;
				
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_WHEEL, mWheel);
				unlistener.addListener(viewportHitArea, MouseEvent.RIGHT_MOUSE_DOWN, mRightDown);
				
			} else {
				Scene.INSTANCE.mouseZoom.unpause(this);
				
				// re-allow layers
				Scene.INSTANCE.background.unsetInvisible(this);
				Scene.INSTANCE.layers.forEach(function (layer:Layer):void { layer.unsetInvisible(this) });
				
				initY = sceneCam.y; // save Y
				sceneCam.deserialize(cameraCalibration); // reset calibration
				unlistener.removeAll();
			}
			
			redrawPaths();
		}
		
		private function mWheel(e:MouseEvent):void {
			const newY:Number = Scene.INSTANCE.camera3D.y * Math.pow(WHEEL_MOVE_DOWN, e.delta);
			if (newY >= 5000 || newY < 10) return;
			Scene.INSTANCE.camera3D.y = newY;
			redrawPaths();
//			trace(this,"Scene.camera3D",Scene.camera3D.getPosition(false));
		}
		
		private function mRightDown(e:MouseEvent):void {
			unlistener.addListener(Stg.Get(), MouseEvent.MOUSE_MOVE, mMove);
			unlistener.addListener(Stg.Get(), MouseEvent.RIGHT_MOUSE_UP, mRightUp);
			panning.setTo(e.stageX, e.stageY);
		}
		private function mRightUp(e:MouseEvent):void {
			unlistener.removeListener(Stg.Get(), MouseEvent.MOUSE_MOVE, mMove);
			unlistener.removeListener(Stg.Get(), MouseEvent.RIGHT_MOUSE_UP, mRightUp);
		}
		private function mMove(e:MouseEvent):void {
			const camera:Camera = Scene.INSTANCE.camera3D;
			const viewport:DisplayObject = Scene.INSTANCE.viewport;
			const scale:Number = camera.getPixelScaleAt(camera.y, viewport.getRect(viewport).width);
			
			var delta:Number;
			delta = e.stageX - panning.x;
			Scene.INSTANCE.camera3D.x -= scale * delta;
			delta = e.stageY - panning.y;
			Scene.INSTANCE.camera3D.z += scale * delta;
			
			panning.setTo(e.stageX, e.stageY);
			redrawPaths();
		}
		
		private function redrawPaths():void {
			Scene.INSTANCE.updateCharPaths();
		}
	}
}