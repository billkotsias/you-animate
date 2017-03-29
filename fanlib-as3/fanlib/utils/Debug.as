package fanlib.utils {
	
	import fanlib.gfx.Stg;
	import fanlib.text.FTextField;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.text.TextFieldType;
	
	public class Debug {

		static public var AutoCopyToClipboard:Boolean = false;
		
		static private const _field:FTextField = new FTextField();
		static public var num:uint = 0;
		
		static private const dummy:* = constructor();
		static private function constructor():* {
			
			// field
			_field.textColor = 0;
			_field.autoSize = "left";
			field.text = "Debug on screen\n";
			field.type = TextFieldType.INPUT;
			
			return undefined;
		}

		static public function appendLineMulti(separator:String = ",", ...params):void {
			var string:String = "\n{"+(num++).toString()+"}"+(params as Array).join(separator);
			trace("[Debug]",string);
//			field.appendText( string );
			field.text += string;
			if (AutoCopyToClipboard) Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, field.text, false);
		}
		static public function appendLine(str:*):void {
			var string:String = ("\n{"+(num++).toString()+"}"+str);
			trace("[Debug]",string);
			field.text += string;
		}
		
		static public function get field():FTextField {
			Stg.Get().addChild(_field);
			return _field;
		}

	}
	
}
