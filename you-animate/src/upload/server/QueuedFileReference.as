package upload.server
{
	import fanlib.utils.FStr;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.utils.describeType;
	
	import ui.report.Reporter;

	public class QueuedFileReference extends QueuedServerRequest
	{
		public function QueuedFileReference(title:String, messageFunction:Function)
		{
			super(title, messageFunction);
		}
		
		override protected function _execute():void {
			const fileReference:FileReference = messageFunction();
			
			unlistener.addListener(fileReference, DataEvent.UPLOAD_COMPLETE_DATA, completeEvent);
			unlistener.addListener(fileReference, ProgressEvent.PROGRESS, progressEvent);
			unlistener.addListener(fileReference, IOErrorEvent.IO_ERROR, errorEvent);
			unlistener.addListener(fileReference, SecurityErrorEvent.SECURITY_ERROR, errorEvent);
		}
		
		private function completeEvent(e:DataEvent):void {
			completeCallback( e.data );
			cleanup();
		}
	}
}