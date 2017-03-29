package ui.report
{
	import fanlib.gfx.FSprite;
	import fanlib.ui.TouchMenu;
	import fanlib.utils.IInit;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	public class ProgressWindow extends TouchMenu implements IInit
	{
		static private var INSTANCE:ProgressWindow; // if a need for multiple ProgressWindow arises, this can be made into an array (INSTANCES = []) !
		
		public var spaceY:Number = 2;
		
		static public function NewProgress(eventDispatcher:EventDispatcher, message:String = "Loading essential stuff..."):void {
			if (!INSTANCE) {
				trace("[ProgressWindow] not initialized yet for:" + String(eventDispatcher));
				return;
			}
			INSTANCE.newProgress(eventDispatcher, message);
		}
		
		public function ProgressWindow()
		{
			super();
		}
		
		public function initLast():void {
			if (INSTANCE) throw this + " is already initialized!";
			INSTANCE = this;
		}
		
		private function newProgress(eventDispatcher:EventDispatcher, message:String):void {
			const tracker:ProgressTracker = FSprite.FromTemplate("PROGRESS_TRACKER") as ProgressTracker;
			addChild(tracker); // tracker auto-removes itself from me
			tracker.setup(eventDispatcher, message);
			update();
		}
		
		override public function removeChild(c:DisplayObject):DisplayObject {
			const c:DisplayObject = super.removeChild(c);
			update();
			return c;
		}
		
		private function update():void {
			var posY:Number = 0;
			for (var i:int = 0; i < numChildren; ++i) {
				const tracker:DisplayObject = getChildAt(i);
				tracker.y = posY;
				posY += tracker.getBounds(this).height + spaceY;
			}
		}
	}
}