package fanlib.io {
	
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	public class MLoader {
		
		// static
		
		static public function WRONG_FILE_PARAM():void { throw "Wrong filename parameter"; }
		static public var PROGRESS:String = "MLoaderProgress";
		
		static public var bytesLoaded:int = 0;
		static public var bytesTotal:int = 0;
		static public const LoaderInfos:Dictionary = new Dictionary();
		static public const Events:EventDispatcher = new EventDispatcher();
		
		static private const Loading:Array = new Array();
		static private const Cache:Array = new Array(); // loaded and cached
		
		static public var GlobalContext:LoaderContext;
		
		// static
		
		public var names:Array;	// filenames
		private var callback:Function;
		public var data:*;		// external info passed to this object
		public var group:*;
		
		public var files:Array;
		private var loaders:Array;
		private var remainLoaders:int;
		
		// => names = single String or Array of String filepaths
		//	  func = callback function when everything has loaded; must accept a single parameter (MLoader)
		public function MLoader(__names:* = null, func:Function = null, _data:* = undefined, _group:* = "",
								context:LoaderContext = null):void {
			load(__names, func, _data, _group, context);
		}
		
		private function load(__names:*, func:Function, _data:* = undefined, _group:* = "", context:LoaderContext = null):void {
			
			var _names:Array;
			if (__names is String) {
				names = new Array(__names as String);
				_names = new Array(__names as String);
			} else if (__names is Array) {
				names = (__names as Array).concat(); // i.e copy
				_names = (__names as Array);
			} else {
				WRONG_FILE_PARAM();
			}
			
			callback = func;
			data = _data;
			group = _group;
			
			loaders = new Array();
			files = new Array();
			remainLoaders = 0;
			
			// find cached
			for (var i:int = 0; i < _names.length; ++i) {
				var registry:* = Cache[ _names[i] ];
				if (registry != undefined) {
					var cached:MLCached = registry;
					cached.insertGroup(group);
					files[i] = cached.data;
					
					delete _names[i];
				}
			}
			
			// load rest
			for (i = 0; i < _names.length; ++i) {
				var name:* = _names[i];
				if (name == undefined) continue;
				
				var loader:Loader = null;
				var loaderInfo:LoaderInfo = null;
				
				// is already loading?
				loaderInfo = Loading[name];
				if (!loaderInfo) {
					// not loading yet
					loader = new Loader();
					loaderInfo = loader.contentLoaderInfo;
					Loading[name] = loaderInfo;
				}
				loaderInfo.addEventListener(Event.COMPLETE, fileLoaded);
				loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, fileLoaded);
				loaders[i] = loaderInfo.loader; // mark loader (taken from "loaderInfo" in case "loader" is null)
				++remainLoaders;
				
				if (loader) {
					// static
					loaderInfo.addEventListener(ProgressEvent.PROGRESS, infoInit); // called only once! (1st time)
					loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
					LoaderInfos[loaderInfo] = new LITrack(loaderInfo);
					
					if (!context) context = GlobalContext;
					loader.load( new URLRequest(name),  context );
				}
			}
			
			checkLoadersFinished();
		}
		
		static public function get isBytesTotalStable():Boolean {
			for each (var obj:Object in LoaderInfos) {
				if (!(obj as LITrack).initialized) return false; // someone not initialized yet
			}
			return true;
		}
		
		static private function infoInit(e:Event):void {
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, infoInit);
			bytesTotal += loaderInfo.bytesTotal;
			
			var track:LITrack = LoaderInfos[loaderInfo] as LITrack;
			track.initialized = true;
			
			Events.dispatchEvent(new Event(PROGRESS));
		}
		
		static private function progress(e:ProgressEvent):void {
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var track:LITrack = LoaderInfos[loaderInfo] as LITrack;
			var addedBytes:uint = loaderInfo.bytesLoaded - track.previousLevel;
			if (addedBytes) {
				bytesLoaded += addedBytes;
				track.previousLevel = loaderInfo.bytesLoaded;
				Events.dispatchEvent(new Event(PROGRESS));
			}
		}
		
		private function fileLoaded(e:Event):void {
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			
			loaderInfo.removeEventListener(Event.COMPLETE, fileLoaded);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, fileLoaded);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			var loadedObj:DisplayObject = loaderInfo.content;
			
			// find which of the loaders report
			var index:int;
			
			for (var i:int = loaders.length - 1; i >= 0; --i) {
				if (loaders[i] == loaderInfo.loader) {
					index = i; // keep last good index for use out of this loop
					
					files[i] = loadedObj; // register loaded Bitmap/SWF (may be null)
					delete loaders[i];
					--remainLoaders;
				}
			}
			
			var name:String = names[index];
			
			switch (e.type) {
				case Event.COMPLETE:
					// cached in the meantime?
					var cacheEntry:MLCached = Cache[name] as MLCached;
					if (cacheEntry) {
						cacheEntry.insertGroup(group); // cacheEntry.data === loadedObj
					} else {
						Cache[name] = new MLCached(loadedObj, group); // cache now!
					}
					break;
				default:
				case IOErrorEvent.IO_ERROR:
					break;
			}
			
			//if (!loaderInfo.hasEventListener(Event.COMPLETE)) loaderInfo.loader.unload();
			
			// static
			delete LoaderInfos[loaderInfo];
			delete Loading[name];
			
			checkLoadersFinished();
		}
		
		private function checkLoadersFinished():void {
			if (remainLoaders == 0) {
				callback(this); // all loaders finished
				callback = null;
				
				// globally finished?
				//trace(Utils.PrettyString(loaderInfos));
				if (Utils.IsEmpty(LoaderInfos)) Events.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		static public function UnloadGroup(group:*):void {
			for (var s:String in Cache) {
				if ( (Cache[s] as MLCached).removeGroup(group) ) delete Cache[s]; // uncache!
			}
			System.gc();
		}
		
		static public function UnloadAll():void {
			for (var s:String in Cache) {
				(Cache[s] as MLCached).erase();
				delete Cache[s];
			}
			System.gc();
		}
	}
}

import flash.display.LoaderInfo;

class LITrack {
	
	public var previousLevel:uint; // previous 'bytesLoaded' of 'info'
	public var initialized:Boolean = false;
	
	public function LITrack(i:LoaderInfo) {
		previousLevel = i.bytesLoaded; // should be 0
	}
}