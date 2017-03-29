package fanlib.ui.numText
{
	import fanlib.event.GroupEventDispatcher;
	import fanlib.event.ObjEvent;
	import fanlib.event.Unlistener;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.IToolTip;
	import fanlib.ui.Tooltip;
	import fanlib.utils.FStr;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * Numeric textfield that can be changed with dragging..!
	 * @author BillWork
	 */
	public class NumTextDrag extends GroupEventDispatcher implements IToolTip
	{
		static public const UPDATED:String = "UPDATED";
		static public const DRAG_END:String = "DRAG_END";
		
		private const startPos:Point = new Point();
		private const newPos:Point = new Point();
		private var oldDist:Number;
		private const unlistener:Unlistener = new Unlistener();
		
		private var _fieldChildName:String; // be kind to the scripter (ME!)
		
		private var _enabled:Boolean;
		private var _field:FTextField;
		private var _num:Number; // default = NaN : get from field
		public var allowX:Boolean = true;
		public var allowY:Boolean = true;
		public var factor:Number = -1;
		public var digitsAfterDecimal:uint = 2;
		public var numScale:Number = 1;
		
		// IToolTip
		protected var _tip:String;
		protected var _toolTipName:String;
		
		public function NumTextDrag()
		{
			super();
		}
		
		public function get enabled():Boolean { return _enabled }
		public function set enabled(e:Boolean):void {
			_enabled = e;
			if (e) {
				addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				unlistener.removeAll();
			}
		}
		
		private function mDown(e:MouseEvent):void {
			const stg:Stage = Stg.Get();
			unlistener.addListener(stg, MouseEvent.MOUSE_MOVE, mMove, false, 0, true);
			unlistener.addListener(stg, MouseEvent.RELEASE_OUTSIDE, mUp, false, 0, true);
			unlistener.addListener(stg, MouseEvent.ROLL_OUT, mUp, false, 0, true); // redundant?
			unlistener.addListener(stg, MouseEvent.MOUSE_UP, mUp, false, 0, true);
			unlistener.addListener(stg, Event.MOUSE_LEAVE, mUp, false, 0, true);
			unlistener.addListener(stg, Event.DEACTIVATE, mUp, false, 0, true);
			startPos.setTo(e.stageX, e.stageY);
			oldDist = 0;
		}
		
		private function mMove(e:MouseEvent):void {
			var dist:Number = 0;
			if (allowX) dist = e.stageX - startPos.x;
			if (allowY) dist += e.stageY - startPos.y;
			_num += (dist - oldDist) * factor/numScale;
			oldDist = dist; // set before hell breaks loose
			if (stage.focus === field) stage.focus = null; // NOTE : override Flash bug (text moves to left if "dragged" & focused)
			num = _num;
		}
		
		private function mUp(e:Event):void {
			unlistener.removeAll();
			dispatchEvent(new Event(DRAG_END));
		}
		
		public function get fieldChildName():String { return _fieldChildName; }
		public function set fieldChildName(value:String):void {
			_fieldChildName = value;
			field = findChild(fieldChildName);
		}

		public function get field():FTextField { return _field; }
		public function set field(value:FTextField):void {
			if (_field) _field.removeEventListener(Event.CHANGE, fieldChanged); // old
			_field = value;
			_field.addEventListener(Event.CHANGE, fieldChanged, false, 0, true);
			if (_num === _num)
				num = _num; // set previously defined number to TextField
			else {
				num = Number(_field.text)/numScale; // get TextField's (hopefully) number
			}
		}
		
		private function fieldChanged(e:Event):void {
			const newNum:Number = Number(_field.text)/numScale;
			// not a Number!
			if (newNum !== newNum) {
				if (_num === _num)
					num = _num;
				else
					num = 0; // zero if nothing else works
			} else {
				_num = newNum; // twice set, but it's OK, man
				dispatchEvent(new Event(UPDATED));
				dispatchGroupEvent(new ObjEvent(this, UPDATED, e.bubbles, e.cancelable));
			}
		}

		public function get num():Number { return _num; }
		public function set num(value:Number):void {
			_num = value;
			if (_field) _field.htmlText = FStr.RoundToString(_num*numScale, digitsAfterDecimal);
		}

		override public function copy(baseClass:Class = null):* {
			const obj:NumTextDrag = super.copy(baseClass);
			obj.allowX = this.allowX;
			obj.allowY = this.allowY;
			obj.factor = this.factor;
			obj.digitsAfterDecimal = this.digitsAfterDecimal;
			obj.numScale = this.numScale;
			obj._num = this._num;
			obj.fieldChildName = this.fieldChildName;
			obj.enabled = this._enabled;
			
			obj.tip = this.tip;
			return obj;
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