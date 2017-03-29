package fanlib.text {
	
	import fanlib.gfx.FSprite;
	import fanlib.utils.IChange;
	
	import fl.controls.TextInput;
	import fl.events.ComponentEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class TInput extends TextInput implements ITextComponent, IChange {

		static public const ENTER:String = "TInput_ENTER";
		
		static public const EmptySkin:Sprite = new Sprite();
		
		private var message:String = "";
		public var normalFormat:TextFormat;
		public var emptyFormat:TextFormat;
		public var errorFormat:TextFormat;
		
		private var actualText:String;
		private var pass:Boolean;
		private var focus:Boolean;
		private var focusMan:FocusMan;
		
		public function TInput() {
			setStyle("upSkin", EmptySkin);
			setStyle("focusRectSkin", EmptySkin);
			actualText = textField.text;
			
			addEventListener(FocusEvent.FOCUS_IN, focusIn);
			addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			addEventListener(Event.CHANGE, change);
		}
		private function change(e:Event):void {
			text = super.text;
		}
		private function focusIn(e:FocusEvent):void {
			focus = true;
			text = text;
		}
		private function focusOut(e:FocusEvent):void {
			if (focus) {
				focus = false;
				text = super.text;
			} else {
				text = text;
			}
		}
		private function keyDown(e:KeyboardEvent):void {
			if (e.keyCode == 9 || e.keyCode == 13) {
				//setNextFocus(); // problem in Flash CS
				var timer:Timer = new Timer(10, 1);
				timer.addEventListener(TimerEvent.TIMER, setNextFocus, false, 0, true);
				timer.start();
				dispatchEvent(new Event(ENTER));
			}
		}
		private function setNextFocus(e:* = null):void {
			if (!focusMan) return;
			
			focus = false;
			text = text;
			focusManager.setFocus(null);
			focusMan.setNextFocus(this);
		}
		
		public function set size(arr:Array):void {
			setSize(arr[0], arr[1]);
		}
		
		public function set focusGroup(name:String):void {
			focusMan = FocusMan.AddFocusable(name, this);
		}
		
		public function set emptyMessage(m:String):void {
			message = m;
			text = text;
		}
		
		override public function set displayAsPassword(p:Boolean):void {
			pass = p;
			text = text;
		}
		
		public function markAsError():void {
			setStyle("textFormat", errorFormat);
		}
		
		public function set quickFormat(dummy:*):void {
			try {
				format = ["normal","normal"];
				format = ["empty","empty"];
				format = ["error","error"];
			} catch(e:Error) { trace(e); }
		}
		public function set format(arr:Array):void {
			var varname:String = arr[0];
			var formatName:String = arr[1];
			this[varname+"Format"] = TextStyle.GetFormat(formatName);
			text = text;
		}
		
		override public function set text(txt:String):void {
			//trace(name, txt, focus);
			actualText = txt;
			if (actualText || focus) {
				super.displayAsPassword = pass;
				setStyle("textFormat", normalFormat);
				super.text = actualText;
			} else {
				super.displayAsPassword = false;
				setStyle("textFormat", emptyFormat);
				super.text = message;
			}
			childChanged(this);
		}
		override public function get text():String {
			return actualText;
		}
		
		public function set embedFonts(b:Boolean):void {
			setStyle("embedFonts", b);
		}
		
		public function childChanged(obj:IChange):void {
			if (parent is IChange) (parent as IChange).childChanged(obj);
		}

	}
	
}
