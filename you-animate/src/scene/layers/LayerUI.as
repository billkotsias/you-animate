package scene.layers
{
	import fanlib.gfx.Distributor;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.Gfx;
	import fanlib.text.FTextField;
	import fanlib.ui.BrowseLocal;
	import fanlib.ui.CheckButton;
	import fanlib.ui.FButton2;
	import fanlib.ui.numText.NumTextDrag;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import scene.Scene;
	
	import tools.CheckButtonTool;
	
	public class LayerUI extends Distributor
	{
		static public const NAME_DEFAULT:String = "<none>";
		
		internal var _layer:Layer;
		
		static private const ThumbSizeOrig:Array = [];
		private var thumb:FBitmap;
		private var ntd:NumTextDrag;
		private var del:FButton2;
		private var sub:FButton2;
		private var vis:CheckButtonTool;
		
		public function LayerUI()
		{
			super();
		}
		
		public function browseForTexture():void {
			new BrowseLocal(new FileFilter("JPEG, PNG, GIF files", "*.jpg;*.jpeg;*.gif;*.png"), _layer.setBytes, setLayerNameFromFile);
		}
		
		public function setThumbnail(data:BitmapData):void {
			if (!thumb) {
				thumb = findChild("thumb");
				if (!ThumbSizeOrig.length) ThumbSizeOrig.push(thumb.width,thumb.height);
			}
			thumb.bitmapData = data;
			Gfx.SetMaxSize(thumb, ThumbSizeOrig[0], ThumbSizeOrig[1], true);
			thumb.childChanged(thumb);
		}
		
		private function setLayerNameFromFile(fileRef:FileReference):void {
			layerName = fileRef.name;
		}
		public function set layerName(str:String):void {
			if (!str) str = NAME_DEFAULT;
			(findChild("file") as FTextField).htmlText = str;
		}
		public function get layerName():String {
			return (findChild("file") as FTextField).text;
		}
		
		//
		public function get layerZ():Number { return _layer.z; } // required by Array.sortOn !
		public function get layer():Layer { return _layer; }
		public function set layer(value:Layer):void {
			_layer = value;
			value.layerUI = this;
		}
		
		//
		
		public function set deleteBut(str:String):void {
			del = findChild(str);
			del.addEventListener(FButton2.CLICKED, deleteButDown, false, 0, true);
		}
		private function deleteButDown(e:Event):void {
			Scene.INSTANCE.removeLayer(_layer);
		}
		
		public function set visibleBut(str:String):void {
			vis = findChild(str);
			vis.addEventListener(CheckButton.CHANGE, visChange, false, 0, true);
		}
		private function visChange(e:Event):void {
			if (vis.state) {
				_layer.pivot3D.show();
			} else {
				_layer.pivot3D.hide();
			}
		}
		
		public function set substituteBut(str:String):void {
			sub	= findChild(str);
			sub.addEventListener(FButton2.CLICKED, substituteButDown, false, 0, true);
		}
		private function substituteButDown(e:Event):void {
			browseForTexture();
		}
		
		public function set numTextDrag(str:String):void {
			ntd = findChild(str);
			ntd.addEventListener(NumTextDrag.UPDATED, numTextUpdated, false, 0, true);
		}
		private function numTextUpdated(e:Event):void {
			_layer.z = ntd.num;
		}
		
		public function updateNumTextFromLayer():void {
			ntd.num = _layer.z;
		}

		//
		
		override public function copy(baseClass:Class = null):* {
			const obj:LayerUI = super.copy(baseClass);
			obj.substituteBut = sub.name;
			obj.numTextDrag = ntd.name;
			obj.deleteBut = del.name;
			obj.visibleBut = vis.name;
			return obj;
		}
	}
}