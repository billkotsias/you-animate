package fanlib.io
{	
	import fanlib.utils.Debug;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class URLLoaderListener {
		
		private var _callback:Function;
		
		static public function NewURLLoader(urlRequest:URLRequest, callback:Function):void {
			new URLLoaderListener(new URLLoader(), callback, urlRequest);
		}
		
		public function URLLoaderListener(loader:URLLoader, callback:Function, urlRequest:URLRequest = null) {
			_callback = callback;
			loader.addEventListener(Event.COMPLETE, requestComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, requestIOError);
			if (urlRequest) loader.load(urlRequest);
		}
		
		//
		
		protected function requestComplete(e:Event):void {
			const loader:URLLoader = e.currentTarget as URLLoader;
			_callback(loader.data);
			cleanup(loader);
		}
		protected function requestIOError(e:IOErrorEvent):void {
			Debug.appendLine(this+" "+e.text);
			const loader:URLLoader = e.currentTarget as URLLoader;
			_callback(null);
			cleanup(loader);
		}
		
		private function cleanup(loader:URLLoader):void {
			_callback = null;
			loader.removeEventListener(Event.COMPLETE, requestComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, requestIOError);
		}
	}
}