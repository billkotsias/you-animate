package fanlib.io {
	
	import fanlib.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	public class MLCached {

		private var groups:Dictionary = new Dictionary(false);
		private var _data:DisplayObject = null;
		
		public function MLCached(dat:DisplayObject, group:*) {
			insertGroup(group);
			_data = dat;
		}
		
		internal function get data():DisplayObject { return _data; };
		internal function set data(d:DisplayObject):void { _data = d; };
		
		public function insertGroup(group:*):void {
			groups[group] = true;
		}
		
		public function removeGroup(group:*):Boolean {
			delete groups[group];
			if (Utils.IsEmpty(groups)) {
				erase();
				return true; // delete me!
			}
			return false;
		}
		
		public function erase():void {
			if (_data is Bitmap) (_data as Bitmap).bitmapData.dispose();
			_data = null;
			
			groups = null;
		}

	}
	
}
