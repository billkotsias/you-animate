package ui.report
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.utils.DelayedCall;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	public class ProgressTracker extends FSprite
	{
		static public const EVENT_DISPATCHER_DISPOSED:String = "EVENT_DISPATCHER_DISPOSED";
		static public const MIN_PERCENT:Number = 0.05;
		static public const MIN_TIME_UPDATE:Number = 100; // msecs
		
		public var progressPerCent:FTextField;
		public var progressBar:FSprite;
		private var maskGfx:Graphics;
		
		private var unlistener:Unlistener = new Unlistener();
		private var timer:int;
		
		public function ProgressTracker()
		{
			super();
		}
		
		public function setup(dispatcher:EventDispatcher, message:String):void {
			timer = getTimer();
			
			(findChild("progressText") as FTextField).htmlText = message;
			assignChildren = ["progressBar","progressPerCent"];
			
			const _mask:Shape = new Shape();
			maskGfx = _mask.graphics;
			progressBar.addChild(_mask);
			progressBar.mask = _mask;
			
			progressEvent();
			
			unlistener.addListener(dispatcher, ProgressEvent.PROGRESS, progressEvent, false, 0, true);
			unlistener.addListener(dispatcher, Event.COMPLETE, completeEvent, false, 0, true);
			unlistener.addListener(dispatcher, EVENT_DISPATCHER_DISPOSED, completeEvent, false, 0, true);
		}
		
		private function progressEvent(e:ProgressEvent = null):void {
			const curTime:int = getTimer();
			if (curTime - timer < MIN_TIME_UPDATE) return;
			timer = curTime;
			
			const rect:Rectangle = progressBar.getBounds(this);
			var percent:Number = (e) ? ( MIN_PERCENT + (e.bytesLoaded / e.bytesTotal) * (1 - MIN_PERCENT) ) : MIN_PERCENT;
			if (percent !== percent) percent = 0.5; // in case our server is arsed-up
			
			progressPerCent.htmlText = Math.round(percent * 100) + "%";
			maskGfx.clear();
			maskGfx.beginFill(0);
			maskGfx.drawRect(0,0, rect.width * percent, rect.height);
		}
		
		private function completeEvent(e:Event):void {
			unlistener.removeAll();
			unlistener = null;
			if (parent && parent.parent) parent.parent.removeChild(this); // UGH!
			removeChildren();
			progressPerCent = null;
			progressBar.mask = null;
			progressBar = null;
			maskGfx = null;
		}
	}
}