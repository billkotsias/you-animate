package fanlib.ui
{
	import fanlib.utils.ILexiRef;
	import fanlib.utils.ILexicon;

	public class TooltipLexicon extends Tooltip implements ILexiRef
	{
		private var lexicon:ILexicon;
		
		public function TooltipLexicon(lexicon:ILexicon)
		{
			super();
			this.lexicon = lexicon;
		}
		
		override public function clearText():void {
			super.clearText();
			lexicon.autoUpdateRefs(this);
		}
		
		/**
		 * Set text <b>ref</b> actually, not actual text 
		 * @param ref Lexicon reference
		 */
		override public function setText(ref:String):void {
			if (!ref) return;
			
			lexicon.autoUpdateRefs(this, ref); // I am crazy, I know
			setText2( lexicon.getCurrentRef(ref) );
		}
		
		public function languageChanged(newRefValue:*):void {
			setText2( newRefValue );
		}
		
		/**
		 * You'll probably need to override this, cause YOUR Lexicon may return anything as ref value
		 * @param refValue
		 */
		protected function setText2(refValue:*):void {
			super.setText( String(refValue) );
		}
	}
}