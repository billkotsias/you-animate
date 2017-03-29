package ui.report
{
	import fanlib.text.FTextField;
	
	import flash.text.TextField;
	import flash.utils.getQualifiedClassName;

	public class Reporter
	{
		static public const INSTANCE:Reporter = new Reporter();
		
		public var field:FTextField;
		public var separator:String = "| ";
		
		private var prefix:String;
		private var postfix:String;
		
		public function Reporter(hspace:Number = 0, vspace:Number = 1)
		{
			setMargins(hspace, vspace);
		}
		
		public function setMargins(hspace:Number, vspace:Number):void {
			prefix = "<img src='" + getQualifiedClassName(RepIcon) + "' id='";
			postfix = "' width='" + RepIcon.DefaultWidth +"' hspace='" + hspace + "' vspace='" + vspace + "'/><";
		}
		
		public function addInfo(...msg):void {
			add(RepIcon.ID_INFO, msg);
		}
		public function addWarning(...msg):void {
			add(RepIcon.ID_WARNING, msg);
		}
		public function addError(...msg):void {
			add(RepIcon.ID_ERROR, msg);
		}
		
		// static shortcuts
		static public function SetField(field:FTextField):void { INSTANCE.field = field }
		static public function AddInfo(...msg):void { INSTANCE.addInfo(msg) }
		static public function AddWarning(...msg):void { INSTANCE.addWarning(msg) }
		static public function AddError(...msg):void { INSTANCE.addError(msg) }
		
		//
		
		private function add(iconID:String, msg:Array):void {
			const date:Date = new Date();
			if (msg.length === 1 && msg[0] is Array) msg = msg[0];
			const timestamp:String = ">{" + addZeroPrefix(date.hours) + ":" + addZeroPrefix(date.minutes) + ":" + addZeroPrefix(date.seconds) + "}";
			field.htmlText = field.originalHTMLText + prefix + iconID + postfix + iconID + timestamp + msg.join(separator) + "</" + iconID + ">\n";
			field.scrollV = int.MAX_VALUE;
		}
		
		//
		
		private function addZeroPrefix(num:Number):String {
			if (num < 10) return "0" + num.toString();
			return num.toString();
		}
	}
}