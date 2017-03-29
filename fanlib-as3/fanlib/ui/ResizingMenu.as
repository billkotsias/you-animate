package fanlib.ui {
	
	import fanlib.gfx.Distributor;
	import fanlib.gfx.Stg;
	
	import flash.display.Sprite;
	import flash.events.Event;

	//import fanlib.utils.Debug;
	
	public class ResizingMenu extends Distributor {
		
		private var _backColor:uint = 0x555555;
		public function set backColor(c:uint):void {
			_backColor = c;
			update();
		}
		
		private var _backAlpha:Number = 0.5;
		public function set backAlpha(c:Number):void {
			_backAlpha = c;
			update();
		}
		
		private var _spreadFactor:Number = 0.7;
		public function set spreadFactor(s:Number):void {
			_spreadFactor = s;
			update();
		}
		
		private var _backHeight:uint = 86;
		public function set backHeight(h:Number):void {
			_backHeight = h;
			update();
		}
		
		public function ResizingMenu() {
		}
		protected function addedToStage(e:Event = null):void {
			// debug
			//_stage.addChild(Debug.field);
			//Debug.field.textColor = 0xffffff;
			// debug
			
			Stg.Get().addEventListener(Event.RESIZE, update, false, 0, true);
			update();
		}
		
		public function update(e:Event = null):void {
			sizeX = Stg.Get().stageWidth * _spreadFactor;
			
			graphics.clear();
			graphics.beginFill(_backColor, _backAlpha);
			graphics.drawRect(-Stg.Get().stageWidth/2, -_backHeight/2, Stg.Get().stageWidth, _backHeight);
			graphics.endFill();
			
			//Debug.field.text = _stage.stageWidth.toString() + " x " + _stage.stageHeight.toString();
		}

	}
	
}
