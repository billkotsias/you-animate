package tools.lights
{
	import fanlib.event.ObjEvent;
	import fanlib.filters.Color;
	import fanlib.gfx.FSprite;
	import fanlib.ui.CheckButton;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.IInit;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	import scene.HistoryState;
	import scene.Scene;
	
	import tools.CheckButtonTool;
	import tools.MouseActions;
	import tools.misc.ColorPicker;
	
	import ui.BasicWindow;
	import ui.ContextWindow;
	
	public class LightsWindow extends ContextWindow implements IInit
	{
		static public const LIGHTS_CHANGED:String = "LIGHTS_CHANGED";
		
		public var dirCont:FSprite;
		public var dirArrowCont:FSprite;
		public var elevCont:FSprite;
		public var elevArrowCont:FSprite;
		public var ambienceColor:ColorPicker;
		public var enableLightsBut:CheckButtonTool;
		
		public function LightsWindow()
		{
			super();
		}
		
		public function initLast():void {
			MouseActions.ListenToTouchDrag(findChild("dirCircle"), dirMouseAction, userActionEnded);
			MouseActions.ListenToTouchDrag(findChild("elevSemi"), elevMouseAction, userActionEnded);
			ambienceColor.addEventListener(ColorPicker.PICKED, miscChanged);
			ambienceColor.addEventListener(ColorPicker.PICKED_END, userActionEnded);
			enableLightsBut.addEventListener( CheckButton.CHANGE, function(e:Event):void { miscChanged(e); userActionEnded(e) } );
			
			// dirCont
			const pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = new Point(0,0);
			dirCont.transform.perspectiveProjection = pp;
			
			
			updateWindow();
		}
		
		override protected function contextSelected(e:Event):void {
			super.contextSelected(e);
			if ( !Scene.INSTANCE.history.hasStateList( this ) ) {
				Scene.INSTANCE.history.newStateList( this, getHistoryState() );
			}
		}
		
		public function reset():void {
			ambienceColor.color = Color.CombineRGBA(59,59,59,0); // was : Color.CombineRGBA(59,59,59,0);
			dirArrowCont.rotation = 0;
			checkElevScale();
			elevArrowCont.rotation = -45;
			enableLightsBut.state = false;
			
			dispatchChanges();
		}
		
		private function miscChanged(e:Event):void {
			dispatchChanges();
		}
		
		private function dirMouseAction(e:MouseEvent):void {
			dirArrowCont.rotation = Math.atan2(e.localY,e.localX) * 180 / Math.PI;
			checkElevScale();
			dispatchChanges();
		}
		
		private function elevMouseAction(e:MouseEvent):void {
			const angle:Number = Math.atan2(e.localY,e.localX) * 180 / Math.PI;
			elevArrowCont.rotation = angle + 90;
			//trace(angle+90);
			dispatchChanges();
		}
		
		private function checkElevScale():void {
			const angle:Number = dirArrowCont.rotation;
			elevCont.scaleX = Math.abs(elevCont.scaleX) * ((angle > 90 || angle < -90) ? -1 : 1);
		}
		
		/**
		 * Change event DISPATCHED when options set!!!
		 * @param opt
		 */
		public function set options(opt:LightsOptions):void {
//			trace(this,opt.direction,opt.elevation);
			ambienceColor.color = opt.ambienceColor;
			dirArrowCont.rotation = opt.direction;
			checkElevScale();
			elevArrowCont.rotation = opt.elevation;
			enableLightsBut.state = opt.shadows;
			dispatchChanges(opt);
		}
		public function get options():LightsOptions {
			const opt:LightsOptions = new LightsOptions();
			opt.ambienceColor = ambienceColor.color;
			opt.direction = dirArrowCont.rotation;
			opt.elevation = elevArrowCont.rotation;
			opt.shadows = enableLightsBut.state;
			return opt;
		}
		
		private function dispatchChanges( customOptions:LightsOptions = null /* silly optimization */ ):void {
			dispatchEvent(new ObjEvent(customOptions || options, LIGHTS_CHANGED));
		}
		
		private function getHistoryState():HistoryState {
			const opts:Object = options.serialize();
			return new HistoryState(function():void {
				new LightsOptions().deserialize( opts );
			});
		}
		
		private function userActionEnded(e:Event = null):void {
			Scene.INSTANCE.history.addState( this, getHistoryState() );
		}
	}
}