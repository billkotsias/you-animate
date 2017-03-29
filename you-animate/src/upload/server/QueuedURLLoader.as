package upload.server
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;

	public class QueuedURLLoader extends QueuedServerRequest
	{
		public function QueuedURLLoader(title:String, messageFunction:Function)
		{
			super(title, messageFunction);
		}
		
		override protected function _execute():void {
			const urlloader:URLLoader = messageFunction();
			unlistener.addListener(urlloader, Event.COMPLETE, completeEvent);
			unlistener.addListener(urlloader, ProgressEvent.PROGRESS, progressEvent);
			unlistener.addListener(urlloader, IOErrorEvent.IO_ERROR, errorEvent);
			unlistener.addListener(urlloader, SecurityErrorEvent.SECURITY_ERROR, errorEvent);
		}
		
		private function completeEvent(e:Event):void {
			completeCallback( (e.target as URLLoader).data );
			cleanup();
		}
	}
}