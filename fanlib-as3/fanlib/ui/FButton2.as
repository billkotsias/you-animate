package fanlib.ui {
	
	import fanlib.event.GroupEventDispatcher;
	import fanlib.event.ObjEvent;
	import fanlib.gfx.TSprite;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * DisplayObject based Button
	 */
	public class FButton2 extends GroupEventDispatcher
	{
		
		static public const CLICKED:String = "CLICKED";
		static public const MOUSE_DOWN:String = "MOUSE_DOWN";

		static public const NORMAL:String = "normalState";
		static public const OVER:String = "overState";
		static public const DOWN:String = "downState";
		static public const DISABLED:String = "disabledState";
		
		// end of static
		
		private var overThis:Boolean;
		
		protected var _enabled:Boolean;
		protected var _buttonMode:Boolean;
		protected const states:Array = [NORMAL, OVER, DOWN, DISABLED];
		
		/**
		 * Setting to <b>true</b> solves a bug when button is in a "ScrollArea", but area won't scroll if dragging started from this button
		 */
		public var stopClickPropagation:Boolean = false;
		
		/**
		 * Set 'enabled' after having added all children states
		 */
		public function FButton2()
		{
		}
		
		// register a new button state (beyond 4 default ones) 
		public function set addState(state:String):void {
			states.push(state);
		}
		
		public function set state(state:String):void {
			var obj:DisplayObject = getChildByName(state);
			if (!obj) return;
			
			for each (var i:String in states) {
				var obj2:DisplayObject = getChildByName(i); 
				if (obj2) obj2.visible = false;
			}
			obj.visible = true;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(e:Boolean):void {
			_enabled = e;
			if (_enabled) {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
				addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, setStateOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
				setStateNormal();
				super.buttonMode = _buttonMode;
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				removeEventListener(MouseEvent.ROLL_OVER, setStateOver);
				removeEventListener(MouseEvent.ROLL_OUT, rollOut);
				setStateDisabled();
				super.buttonMode = false;
			}
		}
		
		// overcome Flash's stupid CLICK handler
		protected function mouseDown(e:MouseEvent):void {
			overThis = true;
			setStateDown(e);
			dispatchMouseEvent(e, MOUSE_DOWN);
			if (stopClickPropagation) e.stopPropagation();
		}
		protected function rollOut(e:MouseEvent):void {
			overThis = false;
			setStateNormal(e);
		}
		protected function mouseUp(e:MouseEvent):void {
			setStateOver(e);
			if (overThis) dispatchMouseEvent(e, CLICKED);
		}
		
		// seems like an overkill, but may be easily overriden... hell
		public function setStateDown(e:MouseEvent = null):void { state = DOWN }
		public function setStateOver(e:MouseEvent = null):void { state = OVER }
		public function setStateNormal(e:MouseEvent = null):void { state = NORMAL }
		public function setStateDisabled(e:MouseEvent = null):void { state = DISABLED }
		
		override public function get buttonMode():Boolean { return _buttonMode; }
		override public function set buttonMode(b:Boolean):void {
			_buttonMode = b;
			if (enabled) super.buttonMode = b;
		}
		public function set originalButtonMode(b:Boolean):void { // fuck AS3
			super.buttonMode = b;
		}
		
		protected function dispatchMouseEvent(e:MouseEvent, type:String):void {
			var mEvent:MouseEvent = new MouseEvent(type, e.bubbles, e.cancelable, e.localX, e.localY,
												   e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey,
												   e.buttonDown, e.delta); 
			dispatchEvent(mEvent);
			dispatchGroupEvent(new ObjEvent(e, type, e.bubbles, e.cancelable));
		}
		
		// create copy : useful for templates
		override public function copy(baseClass:Class = null):* {
			var obj:FButton2 = super.copy(baseClass);
			obj.enabled = this.enabled;
			obj.stopClickPropagation = this.stopClickPropagation;
			return obj;
		}
	}
}