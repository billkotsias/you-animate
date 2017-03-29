package ui
{
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.io.MLoader;
	import fanlib.text.FTextField;
	import fanlib.ui.BrowseImg;
	import fanlib.utils.IInit;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	public class LabelThumb extends LabeledUI
	{
		[Embed(source='../embedded/layer-default.png')]
		static public const BMP_CHECKERS:Class;
		
		static private const PrerenderedCheckersData:Object = {};
		static public function GetCheckersData(width:Number, height:Number):BitmapData {
			const id:String = width.toString() + "*" + height.toString();
			const prerendered:BitmapData = PrerenderedCheckersData[id];
			if (prerendered) return prerendered;
			
			const spr:FSprite = new FSprite();
			const gfx:Graphics = spr.graphics;
			gfx.beginBitmapFill(new BMP_CHECKERS().bitmapData, new Matrix(), true, false);
			gfx.drawRect(0, 0, width, height);
			gfx.endFill();
			const data:BitmapData = new BitmapData(width, height, false, 0);
			data.draw(spr);
			PrerenderedCheckersData[id] = data;
			
			return data;
		}
		
		//
		static public const THUMB_NAME:String = "thumb";
		private var _bmp:FBitmap;
		
		private var maxWidth:Number = 100;
		private var maxHeight:Number = 100;
		private var maxThumbWidth:Number = 100;
		private var maxThumbHeight:Number = 100;
		private var fixAspect:Boolean = true;
		
		private var _bytes:ByteArray;
		private var _data:BitmapData;
		
//		public var qualityJPG:uint = 80;
		
		private var browseImg:BrowseImg;
		
		public function LabelThumb()
		{
			super();
			
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);
		}
		
		private function mDown(e:MouseEvent):void {
			if (browseImg) return;
			_bytes = null;
			browseImg = new BrowseImg(
				function (data:BitmapData):void {
					setBitmapData(data, true);
					browseImg = null;
				},
				null, null,
				function (bytes:ByteArray):void { _bytes = bytes },
				function ():void { browseImg = null }
			);
		}
		
		//
		
		override public function initLast():void {
			super.initLast();
			_bmp = findChild(THUMB_NAME);
		}

		public function get maxDims():Array { return [maxWidth, maxHeight, maxThumbWidth, maxThumbHeight, fixAspect] }
		public function set maxDims(arr:Array):void {
			maxWidth = arr[0];
			maxHeight = arr[1];
			maxThumbWidth = arr[2];
			maxThumbHeight = arr[3];
			if (arr[4] === undefined) fixAspect = true; else fixAspect = arr[4];
			setBitmapData(getBitmapData(), true);
		}
		
		/**
		 * The BitmapData set by the user (null if not set) 
		 */
		public function getBitmapData():BitmapData { return _data }
		public function setBitmapData(data:BitmapData, dispatchEvent:Boolean = true):void {
			if (data) {
				_data = Gfx.NewResized(data, maxWidth, maxHeight, true, false, 0xbbbbbb);
				if ( dispatchEvent && (!_bytes || _data !== data) ) { // we are interested in updated '_bytes' as long as 'dispatchEvent' = true
					_bytes = _data.encode(_data.rect, new PNGEncoderOptions(false)); // resize occured, create new bytes
				}
				_bmp.bitmapData = _data;
				if (dispatchEvent) this.dispatchEvent(new Event(CHANGE));
			} else {
				_data = null;
				_bytes = null;
				_bmp.bitmapData = getDefaultCheckersData();
			}
			Gfx.SetMaxSize(_bmp, maxThumbWidth, maxThumbHeight, fixAspect);
			_bmp.align(_bmp.alignX,_bmp.alignY);
			childChanged(this);
		}
		
		public function get thumbnailBytes():ByteArray {
			return _bytes;
		}
		
		
		/**
		 * The BitmapData shown on screen
		 */
		public function get thumbnailData():BitmapData {
			return _bmp.bitmapData;
		}
		
		public function getDefaultCheckersData():BitmapData {
			return GetCheckersData(maxThumbWidth, maxThumbHeight);
		}
		
		//
		
		public function setLazyBitmapData(file:String, dispatchEvent:Boolean):void {
			if (file === null) return;
			new MLoader(file, function(l:MLoader):void {
				setBitmapData(l.files[0].bitmapData, dispatchEvent);
			});
		}
		
		//
		
		override public function copy(baseClass:Class = null):* {
			const lt:LabelThumb = super.copy(baseClass);
			lt.maxDims = maxDims;
			return lt;
		}
	}
}