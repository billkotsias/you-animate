package scene.camera.anim
{
	import fanlib.gfx.Distributor;
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	
	public class AbstractZoomKeyUI extends Distributor
	{
		static public const DRAG_END:String = "DRAG_END";
		
		static public const BULLET_NAME:String = "bullet";

		protected var _zoomKey:AbstractZoomKey;
		
		public var userDeleted:Boolean; // FOR UNDO CHECKING!!!
		
		public function AbstractZoomKeyUI()
		{
			super();
		}
		
		public function setTabIndices(tab:uint):uint {
			return tab;
		}
		
		public function set bullet(num:int):void {
			(getChildByName(BULLET_NAME) as FTextField).htmlText = num.toString();
		}
		
		public function get keyTime():Number { return _zoomKey.time }
		
		public function get zoomKey():AbstractZoomKey { return _zoomKey }
		public function set zoomKey(value:AbstractZoomKey):void {
			_zoomKey = value;
			_zoomKey.ui = this;
		}
	}
}