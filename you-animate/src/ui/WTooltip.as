package ui
{
	import fanlib.ui.TooltipLexicon;
	import fanlib.utils.Debug;
	import fanlib.utils.ILexiRef;
	import fanlib.utils.ILexicon;
	import fanlib.utils.Lexicon2;
	
	import flash.events.Event;
	
	public class WTooltip extends TooltipLexicon
	{
		static public var LEXICON:ILexicon;
		
		public function WTooltip()
		{
			super(LEXICON);
		}
		
		override protected function setText2(refValue:*):void {
			const arr:Array = (refValue is Array) ? refValue : [refValue];
			
			var string:String = arr[0];
			if (string) string = "<title>"+string+"</title>";
			if (arr.length > 1) string += arr[1];
			super.setText2( string );
		}
	}
}