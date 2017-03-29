package fanlib.ui
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.Dictionary;

	public class BrowseLocal
	{
		static protected const NO_GC:Dictionary = new Dictionary(false);
		
		protected var _fileReference:FileReference;
		protected var _callbackData:Function;
		private var _callbackFileSelected:Function;
		private var _callbackCancel:Function;
		
		public function BrowseLocal(fileFilters:*, callbackData:Function, callbackFileSelected:Function = null, callbackCancel:Function = null)
		{
			NO_GC[this] = this;
			
			if (fileFilters is FileFilter) fileFilters = [fileFilters]; // make into Array if single-one passed
			_callbackData = callbackData;
			_callbackFileSelected = callbackFileSelected;
			
			_fileReference = new FileReference();
			_fileReference.addEventListener(Event.SELECT, fileSelected, false, 0, true);
			_fileReference.browse(fileFilters);
			
			if (callbackCancel !== null) {
				_callbackCancel = callbackCancel;
				_fileReference.addEventListener(Event.CANCEL, cancelled);
			}
		}
		
		public function cancel():void {
			_fileReference.cancel();
			delete NO_GC[this];
		}
		
		public function get areBytesLoaded():Boolean {
			return _fileReference === null;
		}
		
		//
		
		private function cancelled(e:Event):void {
			_callbackCancel();
			_callbackCancel = null;
			delete NO_GC[this];
		}
		
		private function fileSelected(e:Event):void {
			_callbackCancel = null;
			_fileReference.removeEventListener(Event.CANCEL, cancelled);
			_fileReference.removeEventListener(Event.SELECT, fileSelected);
			if (_callbackFileSelected !== null) {
				_callbackFileSelected(_fileReference);
				_callbackFileSelected = null;
			}
			
			_fileReference.addEventListener(Event.COMPLETE, _fileLoaded, false, 0, true);
			_fileReference.load();
		}
		
		private function _fileLoaded(e:flash.events.Event):void {
			_fileReference.removeEventListener(Event.COMPLETE, _fileLoaded);
			_fileReference = null;
			fileLoaded(e);
		}
		protected function fileLoaded(e:flash.events.Event):void {
			_callbackData(e.target.data); // get yer bytes
			_callbackData = null;
			
			delete NO_GC[this];
		}
	}
}