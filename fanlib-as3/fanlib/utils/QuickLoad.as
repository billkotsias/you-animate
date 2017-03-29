package fanlib.utils
{
	import fanlib.io.Server;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.Dictionary;

	public class QuickLoad
	{
		static private const DONT_GC:Dictionary = new Dictionary();
		
		private var funcLoaded:Function;
		
		public function QuickLoad(file:*, funcLoaded:Function, format:String = URLLoaderDataFormat.TEXT, skipCache:Boolean = true)
		{
			DONT_GC[this] = this;
			
			this.funcLoaded = funcLoaded;
			const loader:URLLoader = new URLLoader();
			loader.dataFormat = format;
			loader.addEventListener(Event.COMPLETE, loadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, error);
			
			const request:URLRequest = (file is URLRequest) ? file : new URLRequest(file);
			request.url = Server.UncacheURL(request.url);
			
			if (skipCache) {
				const header:URLRequestHeader = new URLRequestHeader("pragma", "no-cache");
//				request.data = new URLVariables("cache=no+cache");
				request.method = URLRequestMethod.POST;
				request.requestHeaders.push(header);
			}
			
			loader.load(request);
		}
		
		private function loadComplete(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, loadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, error);
			funcLoaded(loader.data);
			delete DONT_GC[this]; // get me now
			funcLoaded = null;
		}
		
		private function error(e:IOErrorEvent):void {
			trace(this, e.text);
		}
	}
}