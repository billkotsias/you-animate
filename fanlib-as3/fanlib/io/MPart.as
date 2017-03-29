package fanlib.io
{
	import com.jonas.net.Multipart;
	
	import fanlib.utils.Pair;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	public class MPart extends Multipart
	{
		private var _callback:Function;
		
		public function MPart(url:String=null)
		{
			super(url);
		}
		
		public function loadRequest(callback:Function, customHeaders:Vector.<URLRequestHeader> = null, dataFormat:String = URLLoaderDataFormat.BINARY):URLLoader {
			_callback = callback;
			
			const loader:URLLoader = new URLLoader();
			loader.dataFormat = dataFormat;
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			try {
				loader.load(getCustomHeadersRequest(customHeaders));
			} catch (error:Error) {
				trace(this,error.message,error.getStackTrace());
				cleanup(loader);
				return null;
			}
			
			return loader;
		}
		
		public function getCustomHeadersRequest(customHeaders:Vector.<URLRequestHeader>):URLRequest {
			const customRequest:URLRequest = request;
			
			if (customHeaders) {
				const customRequestHeaders:Array = customRequest.requestHeaders;
				for (var i:int = 0; i < customHeaders.length; ++i) {
					customRequestHeaders.push( customHeaders[i] );
				}
			}
			return customRequest;
		}
		
		private function cleanup(loader:URLLoader):void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_callback = null;
		}
		
		private function onComplete(e:Event):void {
			const loader:URLLoader = e.currentTarget as URLLoader;
			if (_callback !== null) _callback(loader.data);
			cleanup(loader);
		}
		private function onError(e:IOErrorEvent):void {
			trace(this,e.text);
			const loader:URLLoader = e.currentTarget as URLLoader;
			if (_callback !== null) _callback(null);
			cleanup(loader);
		}
	}
}