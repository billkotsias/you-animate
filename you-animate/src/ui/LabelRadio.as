package ui
{
	import fanlib.gfx.Distributor2;
	import fanlib.gfx.FSprite;
	import fanlib.ui.FButton2;
	import fanlib.ui.RadioButton;
	
	import flash.events.Event;
	
	import upload.IUItoObject;

	public class LabelRadio extends LabeledUI implements IUItoObject
	{
		static public const RADIO_NAME:String = "radio";
		
		public var itemTemplate:LabelButton;
		
		private var _radio:RadioButton;
		private var _dist:Distributor2;
		
		public function LabelRadio()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
			_radio = findChild(RADIO_NAME);
			_radio.addEventListener(RadioButton.CHANGE, carryEventOn);
			_dist = _radio.getChildAt(0) as Distributor2;
		}
		private function carryEventOn(e:Event):void {
			dispatchEvent(new Event(CHANGE));
		}
		
		public function get enabled():Boolean { return _radio.enabled }
		public function set enabled(e:Boolean):void { _radio.enabled = e }
		
		public function get radio():RadioButton { return _radio }
		
		/**
		 * @param arr [0 = item 1 name, 1 = item 1 label, 2 = item 2 name, 3 = item 2 label, ...]
		 */
		public function set items(arr:Array):void {
			_dist.trackChanges = false;
			while (arr.length) {
				const item:LabelButton = itemTemplate.copy(); // 'initLast' is called in 'LabeledUI' copy function!
				item.name = arr.shift();
				item.label = arr.shift();
				_radio.addItem( item.button );
				_dist.addChild(item);
				item.button.enabled = true;
			}
			_dist.trackChanges = true;
			_dist.childChanged(_dist);
			
			enabled = enabled;
		}
		
		public function set result(b:*):void {
			const labelButton:LabelButton = findChild(b) as LabelButton;
			_radio.select( (labelButton) ? labelButton.button : null );
		}
		public function get result():* {
			return (_radio.selected) ? _radio.selected.parent.name : ""; // parent of 'FButton2' is 'LabelButton'!
		}
		
		override public function copy(baseClass:Class=null):* {
			const obj:LabelRadio = super.copy(baseClass);
			obj.itemTemplate = this.itemTemplate;
			obj.enabled = this.enabled;
			return obj;
		}
	}
}