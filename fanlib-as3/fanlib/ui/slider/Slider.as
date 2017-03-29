package fanlib.ui.slider
{
	import fanlib.gfx.TSprite;
	import fanlib.ui.IToolTip;
	import fanlib.ui.Tooltip;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Slider extends TSprite implements IToolTip
	{
		static public const STOPPED_CHANGING:String = "SLIDER_STOPPED_CHANGING";
		
		private var slideArea:Sprite = new Sprite();
		private var slideAreaRect:Sprite = new Sprite();
		private var _slideRect:Rectangle = new Rectangle();
		
		protected var _value:Number;
		
		protected var _knob:DisplayObject;
		
		// IToolTip
		protected var _tip:String;
		protected var _toolTipName:String;
		
		public function Slider()
		{
			super();
			slideArea.addChild(slideAreaRect);
			slideArea.hitArea = slideAreaRect;
			slideArea.addEventListener(MouseEvent.MOUSE_DOWN, startSlide, false, 0, true);
			//TODO : slideArea.addEventListener(MouseEvent.MOUSE_OVER, mouseOver, false, 0, true);
			//TODO : slideArea.addEventListener(MouseEvent.ROLL_OUT, mouseOut, false, 0, true);
		}
		
		/**
		 * Slider knob-sliding area
		 * @param a Array of [x, y, width, height, visible (DEBUG)]
		 */
		public function set slideRect(a:Array):void {
			_slideRect.setTo(a[0],a[1],a[2],a[3]);
			slideAreaRect.visible = a[4];
			slideAreaRect.graphics.clear();
			if (!_knob) return;
			
			slideAreaRect.graphics.beginFill(0xff0000,0.8);
			slideAreaRect.graphics.drawRect(_slideRect.x - _knob.width/2, _slideRect.y, _slideRect.width + _knob.width, _slideRect.height);
			addChild(slideArea); // bring to top
		}
		public function get slideRect():Array {
			return [_slideRect.x,_slideRect.y,_slideRect.width,_slideRect.height];
		}
		
		private function startSlide(e:MouseEvent):void {
			slideArea.addEventListener(MouseEvent.MOUSE_MOVE, sliding, false, 0, true);
			slideArea.addEventListener(MouseEvent.MOUSE_UP, stopSlide, false, 0, true);
			slideArea.addEventListener(MouseEvent.ROLL_OUT, stopSlide, false, 0, true);
			sliding(e);
		}
		
		private function sliding(e:MouseEvent):void {
			value = (e.localX - _slideRect.x) / _slideRect.width;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function stopSlide(e:MouseEvent):void {
//			sliding(e);
			slideArea.removeEventListener(MouseEvent.MOUSE_MOVE, sliding);
			slideArea.removeEventListener(MouseEvent.MOUSE_UP, stopSlide);
			slideArea.removeEventListener(MouseEvent.ROLL_OUT, stopSlide);
			dispatchEvent(new Event(STOPPED_CHANGING));
		}

		public function get value():Number { return _value; }
		public function set value(val:Number):void {
			_value = val;
			if (_value < 0)
				_value = 0;
			else if (_value > 1) {
				_value = 1;
			}
			if (_knob) _knob.x = _slideRect.x + _value * _slideRect.width;
		}

		override public function copy(baseClass:Class = null):* {
			var obj:Slider = super.copy(baseClass);
			obj.slideRect = slideRect;
			return obj;
		}

		public function get knob():DisplayObject
		{
			return _knob;
		}
		public function set knob(value:DisplayObject):void
		{
			_knob = value;
			slideRect = slideRect;
		}

		// IToolTip
		
		public function set toolTipName(tName:String):void {
			const previousTooltip:Tooltip = Tooltip.INSTANCES[_toolTipName];
			if (previousTooltip) previousTooltip.unregister(this);
			
			_toolTipName = tName;
			if (_toolTipName !== null) {
				const toolTip:Tooltip = Tooltip.INSTANCES[_toolTipName];
				if (toolTip) toolTip.register(this);
			}
		}
		
		public function set tip(value:String):void {
			_tip = value;
			if (!_tip) {
				toolTipName = null;
			} else {
				if (!_toolTipName) toolTipName = Tooltip.DefaultTooltipName; // set if not
			}
		}
		
		public function get tip():String { return _tip }
	}
}