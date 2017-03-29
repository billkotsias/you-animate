package
{
	import fanlib.io.MLoader;
	import fanlib.utils.Utils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.Dictionary;
	
	public class MFlareLoader extends EventDispatcher
	{
		static public const PROGRESS:String = "PROGRESS";
		static public const ALL_COMPLETE:String = "ALL_COMPLETE";
		
		private const loadersProgress:Dictionary = new Dictionary();
		private const loaders:Dictionary = new Dictionary();
		
		private var _trackMLoader:Boolean = false;
		
		public var bytesLoaded:Number;
		public var bytesTotal:Number;
		
		public function MFlareLoader(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function track(loader:FlareLoader, loadNow:Boolean = true):void {
			if (!loader) return;
			
			loaders[loader] = loader;
			loadersProgress[loader] = new ProgressEvent("");
			
			loader.addEventListener(ProgressEvent.PROGRESS, loaderProgressEvent)
			loader.whenComplete(function():void {
				loaderComplete(loader);
			});
			
			if (loadNow) loader.load();
		}
		
		private function loaderProgressEvent(e:ProgressEvent):void {
			loadersProgress[e.target] = e;
			reportTotalProgress();
		}
		
		public function reportTotalProgress(e:* = undefined):void {
			if (trackMLoader) {
				bytesLoaded = MLoader.bytesLoaded;
				bytesTotal = MLoader.bytesTotal;
			} else {
				bytesLoaded = 0;
				bytesTotal = 0;
			}
			for (var loader:* in loadersProgress) {
				var progressEvent:ProgressEvent = loadersProgress[loader];
				bytesLoaded += progressEvent.bytesLoaded;
				bytesTotal += progressEvent.bytesTotal;
			}
			dispatchEvent( new Event(PROGRESS) );
		}
		
		private function loaderComplete(loader:FlareLoader):void {
			delete loaders[loader];
			loader.removeEventListener(ProgressEvent.PROGRESS, loaderProgressEvent);
			checkAllComplete();
		}
		
		public function checkAllComplete(e:* = undefined):void {
			if ( Utils.IsEmpty(loaders) && Utils.IsEmpty(MLoader.LoaderInfos) ) {
				trackMLoader = false; // stop tracking
				Utils.Clear( loadersProgress );
				dispatchEvent( new Event(ALL_COMPLETE) );
			}
		}

		public function get trackMLoader():Boolean { return _trackMLoader }
		public function set trackMLoader(value:Boolean):void
		{
			_trackMLoader = value;
			if (value) {
				MLoader.Events.addEventListener(MLoader.PROGRESS, reportTotalProgress);
				MLoader.Events.addEventListener(Event.COMPLETE, checkAllComplete);
			} else {
				MLoader.Events.removeEventListener(MLoader.PROGRESS, reportTotalProgress);
				MLoader.Events.removeEventListener(Event.COMPLETE, checkAllComplete);
			}
		}

	}
}