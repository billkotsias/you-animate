package upload.server
{
	import fanlib.event.Unlistener;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.utils.describeType;
	
	import ui.report.Reporter;

	public class QueuedServerRequest
	{
		protected var _title:String;
		protected var messageFunction:Function;
		
		// events
		protected var completeCallback:Function;
		protected var progressCallback:Function;
		
		protected const unlistener:Unlistener = new Unlistener();
		
		public function QueuedServerRequest(title:String, messageFunction:Function)
		{
			this._title = title;
			this.messageFunction = messageFunction;
		}
		
		public function execute(completeCallback:Function, progressCallback:Function):void {
			this.completeCallback = completeCallback;
			this.progressCallback = progressCallback;
			_execute();
		}
		
		// to be overriden...
		
		protected function _execute():void {
			throw this + ":must be overriden";
		}
		
		protected function cleanup():void {
			unlistener.removeAll();
			completeCallback = null;
			progressCallback = null;
		}
		
		//
		
		protected function errorEvent(e:ErrorEvent):void {
			Reporter.AddError(this, title, e.text);
			completeCallback(null);
			cleanup();
		}
		
		protected function progressEvent(e:ProgressEvent):void {
			if (progressCallback !== null) progressCallback(e);
		}

		public function get title():String { return _title }
	}
}