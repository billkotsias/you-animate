package fanlib.ui
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;

	public class BrowseImg extends BrowseLocal
	{
		static public const DEFAULT:FileFilter = new FileFilter("JPEG, PNG, GIF files", "*.jpg;*.jpeg;*.gif;*.png");
		
		private var _loader:Loader;
		private var _callbackBitmapData:Function;
		
		public function BrowseImg(callbackBitmapData:Function, fileFilters:* = undefined, callbackFileSelected:Function = null,
								  callbackBytesLoaded:Function = null, callbackCancel:Function = null)
		{
			if (!fileFilters) fileFilters = DEFAULT;
			_callbackBitmapData = callbackBitmapData;
			super(fileFilters, callbackBytesLoaded, callbackFileSelected, callbackCancel);
		}
		
		public function isImageLoaded():Boolean {
			return !Boolean(NO_GC[this]);
		}
		
		override protected function fileLoaded(e:flash.events.Event):void {
			const bytes:ByteArray = e.target.data;
			if (_callbackData != null) {
				_callbackData(bytes); // get yer bytes
				_callbackData = null;
			}
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, bytesLoaded, false, 0, true);
			_loader.loadBytes(bytes);
		}
		protected function bytesLoaded(e:flash.events.Event):void {
			_callbackBitmapData((_loader.getChildAt(0) as Bitmap).bitmapData); // get yer bitmapData
			
			_callbackBitmapData = null;
			_loader = null;
			delete NO_GC[this];
		}
	}
}