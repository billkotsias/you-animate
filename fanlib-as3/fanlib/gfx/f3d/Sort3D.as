package fanlib.gfx.f3d
{
	import fanlib.gfx.TSprite;
	
	import flash.display.DisplayObject;
	
	public class Sort3D extends TSprite
	{
		private var _sortBy:DisplayObject;
		
		public function Sort3D()
		{
			super();
		}
		
		public function get sortBy():DisplayObject { return _sortBy; }
		public function set sortBy(obj:DisplayObject):void {
			_sortBy = obj;
			_sortBy.z = _sortBy.z;
		}
		
		override public function copy(baseClass:Class = null):* {
			var obj:Sort3D = super.copy(baseClass);
			if (_sortBy) obj.sortBy = obj.findChild(this._sortBy.name);
			return obj;
		}
	}
}