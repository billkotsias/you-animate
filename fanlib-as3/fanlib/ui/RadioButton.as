package fanlib.ui
{
	import fanlib.containers.List;
	import fanlib.gfx.TSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class RadioButton extends TSprite
	{
		static public const CHANGE:String = "RadioButtonChange";
		
		private const _items:List = new List();
		
		private var _selected:FButton2;
		
		private var _enabled:Boolean;
		
		public var disabledFilters:Array;
		
		public function RadioButton()
		{
		}
		
		override public function addChild(d:DisplayObject):DisplayObject {
			if (d is FButton2) {
				addItem(d as FButton2);
			}
			return super.addChild(d);
		}
		
		public function addItem(item:FButton2):void {
			_items.push(item);
		}
		
		public function set items(arr:*):void {
			if (arr is FButton2) arr = [arr];
			for each (var item:FButton2 in arr) {
				addItem(item);
			}
		}
		
		public function get enabled():Boolean { return _enabled; }
		/**
		 * Enable only after all items have been set (for my convenience, ok?) 
		 * @param e
		 */
		public function set enabled(e:Boolean):void {
			_enabled = e;
			if (e) {
				_items.forEach(function (item:FButton2):void {
					item.addEventListener(FButton2.MOUSE_DOWN, buttonClicked, false, 0, true);
				});
				filters = null;
			} else {
				_items.forEach(function (item:FButton2):void {
					item.removeEventListener(FButton2.MOUSE_DOWN, buttonClicked);
				});
				filters = disabledFilters;
			}
		}
		
		//
		
		private function buttonClicked(e:MouseEvent):void {
			select(e.currentTarget as FButton2);
			dispatchEvent(new Event(CHANGE)); // issued only by direct user interaction!
		}
		
		public function select(sel:FButton2):FButton2 {
			_selected = null;
			_items.forEach(function (item:FButton2):void {
				if (item === sel) {
					_selected = item;
					item.enabled = false;
				} else {
					item.enabled = true;
				}
			});
			
			return _selected;
		}
		
		public function set selectByIndex(num:uint):void {
			select(_items.getByIndex(num));
		}

		public function set selectByName(name:String):void {
			select( _items.getByValue("name", name) );
		}
		
		public function set selected(sel:FButton2):void { select(sel) }
		public function get selected():FButton2
		{
			return _selected;
		}

		override public function copy(baseClass:Class=null):* {
			const radio:RadioButton = super.copy(baseClass);
			_items.forEach(function (item:FButton2):void {
				radio.addItem( item ); // doesn't hurt to re-add some
			});
			return radio;
		}
	}
}