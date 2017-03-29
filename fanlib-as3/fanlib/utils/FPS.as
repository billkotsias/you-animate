package fanlib.utils
{
	import fanlib.gfx.Align;
	import fanlib.gfx.StagedSprite;
	import fanlib.gfx.Stg;
	import fanlib.text.FTextField;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class FPS
	{
		static public var updateEvery:uint = 1000; // msecs
		
		static private var framesCount:uint;
		static private var time:uint;
		
		static public const container:StagedSprite = new StagedSprite();
		static public const field:FTextField = new FTextField();
		
		static private const dummy:* = constructor();
		static private function constructor():* {
			// field : default values
			field.textColor = 0xffffff;
			field.autoSize = "right";
			
			container.addChild(field);
			container.stageAlignX = Align.ALIGN_RIGHT;
			container.stageAlignY = Align.ALIGN_TOP;
		}
		
		static public function start():void
		{
			var stg:Stage = Stg.Get(); 
			stg.addChild(container);
			stg.addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			framesCount = 0;
			time = getTimer();
		}
		
		static public function stop():void
		{
			var stg:Stage = Stg.Get(); 
			stg.removeChild(container);
			stg.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		static private function enterFrame(e:Event):void {
			++framesCount;
			var sinceLastUpdate:uint = getTimer() - time;
			if (sinceLastUpdate >= updateEvery) {
				field.text = (framesCount * 1000 / sinceLastUpdate).toFixed(2) + " fps";
				container.stageResized();
				time += sinceLastUpdate;
				framesCount = 0;
				
				var stg:Stage = Stg.Get();
				if (stg.getChildIndex(container) != stg.numChildren - 1) {
					stg.setChildIndex(container, stg.numChildren - 1);
				}
			}
		}
	}
}