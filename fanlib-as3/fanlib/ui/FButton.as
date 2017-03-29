package fanlib.ui {
	
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.TSprite;
	import fanlib.io.BackLoader;
	import fanlib.io.MLoader;
	import fanlib.utils.Enum;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	/**
	 * BitmapData based Button
	 */
	public class FButton extends TSprite {
		
		static public const CLICKED:String = "CLICKED";
		
		static public const NORMAL:String = "normalData";
		static public const OVER:String = "overData";
		static public const DOWN:String = "downData";
		static public const DISABLED:String = "disabledData";
		
		public const bmp:FBitmap = new FBitmap();
		private const changes:Array = new Array(); // track changes
		
		protected var normalData:BitmapData = new BitmapData(1,1,false); // placeholder
		protected var overData:BitmapData;
		protected var downData:BitmapData;
		protected var disabledData:BitmapData;
		
		public function get normalBitmapData():BitmapData { return normalData; }
		public function get overBitmapData():BitmapData { return overData; }
		public function get downBitmapData():BitmapData { return downData; }
		public function get disabledBitmapData():BitmapData { return disabledData; }
		
		private var _enabled:Boolean;
		private var _buttonMode:Boolean;
		
		public function FButton() {
			addChild(bmp);
			enabled = true;
		}
		
		// => state = one of class's static Strings
		public function setStateBitmapData(state:String, data:BitmapData):void {
			if (bmp.bitmapData == this[state]) {
				bmp.bitmapData = data;
			}
			this[state] = data;
		}
		
		override public function align(idX:Enum = null, idY:Enum = null):void {
			bmp.align(idX, idY); // allow myself to rotate freely
		}
		
		override public function get buttonMode():Boolean { return _buttonMode; }
		override public function set buttonMode(b:Boolean):void {
			_buttonMode = b;
			if (enabled) super.buttonMode = b;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(e:Boolean):void {
			_enabled = e;
			if (_enabled) {
				addEventListener(MouseEvent.CLICK, buttonClicked, false, 0, true);
				addEventListener(MouseEvent.MOUSE_DOWN, setStateDown, false, 0, true);
				addEventListener(MouseEvent.MOUSE_UP, setStateOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, setStateOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, setStateNormal, false, 0, true);
				_setBitmapData(normalData);
				super.buttonMode = _buttonMode;
			} else {
				removeEventListener(MouseEvent.CLICK, buttonClicked);
				removeEventListener(MouseEvent.MOUSE_DOWN, setStateDown);
				removeEventListener(MouseEvent.MOUSE_UP, setStateOver);
				removeEventListener(MouseEvent.ROLL_OVER, setStateOver);
				removeEventListener(MouseEvent.ROLL_OUT, setStateNormal);
				_setBitmapData(disabledData, true);
				super.buttonMode = false;
			}
		}

		public function setStateDown(e:MouseEvent = null):void { _setBitmapData(downData); }
		public function setStateOver(e:MouseEvent = null):void { _setBitmapData(overData); }
		public function setStateNormal(e:MouseEvent = null):void { _setBitmapData(normalData); }
		
		public function set normal(file:String):void {
			changes[NORMAL] = file;
			new MLoader(file, newStateLoaded, NORMAL);
		}
		public function set over(file:String):void {
			changes[OVER] = file;
			new MLoader(file, newStateLoaded, OVER);
		}
		public function set down(file:String):void {
			changes[DOWN] = file;
			new MLoader(file, newStateLoaded, DOWN);
		}
		public function set disabled(file:String):void {
			changes[DISABLED] = file;
			new MLoader(file, newStateLoaded, DISABLED);
		}
		private function newStateLoaded(l:MLoader):void {
			var ref:String = l.data as String;
			if (l.names[0] != changes[ref]) return; // changed again in the meantime; will ya make up ya mind
			try {
				var update:Boolean = (bmp.bitmapData == this[ref] && bmp.bitmapData != null) ? true : false;
				
				this[ref] = l.files[0].bitmapData;
				if (update) {
					bmp.bitmapData = this[ref];
					align(bmp.alignX, bmp.alignY);
				}
				enabled = enabled;
			} catch(e:Error) { trace(e); }
		}
		
		private function _setBitmapData(data:BitmapData, force:Boolean = false):void {
			if (!(force || _enabled)) return;
			//if (data == null) data = normalData;
			//bmp.bitmapData = data;
			if (data != null) bmp.bitmapData = data;
		}
		
		private function buttonClicked(e:MouseEvent):void {
			dispatchEvent(new MouseEvent(CLICKED, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey,
										 e.buttonDown, e.delta));
		}
	}
	
}
