package
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.StagedSprite;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.FShape;
	import fanlib.security.Dated;
	import fanlib.text.FTextField;
	import fanlib.text.TInput;
	import fanlib.text.TextStyle;
	import fanlib.utils.XMLParser2;
	
	import flash.events.Event;

	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class AnimatePhotos extends Walk3D
	{
		TextStyle; TInput; StagedSprite;
		
		static public const PLEASE:String = "Please enter access code";
		static public const WRONG:String = "Wrong access code entered";
		
		private var contCodeInput:TSprite;
		private var title:FTextField;
		private var dated:Dated;
		private var input:TInput;
		
		public function AnimatePhotos()
		{
			super();
			new Dated(datesLoaded, ShowDatedCodes.RANDOM_SEED, ShowDatedCodes.ADDRESS, ShowDatedCodes.CHANGE_EVERY_DAYS);
		}
		
		override protected function removeFromDevVersion():void {}

		private function datesLoaded(d:Dated):void {
			dated = d;
			if (title) title.htmlText = PLEASE;
		}
		
		override protected function allInitialized():void {
			super.allInitialized();
			const xml:XML = XML('' +
				'<contCodeInput class="fanlib.gfx.vector.FShape" vars="vAlpha=0.8|color=0x0|rect=0,0,'+stage.stageWidth+','+stage.stageHeight+'">' +
					'<defaultStyle class="fanlib.text.TextStyle" format=",48,0xffffff,,,,,,center,,,,0"/>' +
					'<title class="fanlib.text.FTextField" format=",48,0xffffff,,,,,,center" alignX="center" alignY="center"' +
					' vars="x='+stage.stageWidth/2+'|y='+(stage.stageHeight/2-100)+'|autoSize=left|htmlText=Loading server data..."/>' +
					'<codeInput class="fanlib.text.TInput" alignX="center" alignY="center" vars="size=400,70|x='+stage.stageWidth/2+'|y='+stage.stageHeight/2+'|format=normal,defaultStyle|text=000000"/>' +
				'</contCodeInput>');
			new XMLParser2().buildObjectTree(xml, overlayLoaded, Walk3D.UI_DIR, this);
		}
		
		private function overlayLoaded(o:TSprite):void {
			contCodeInput = o;
			
			title = contCodeInput.findChild("title");
			if (dated) title.htmlText = PLEASE;
			
			input = contCodeInput.findChild("codeInput");
			input.addEventListener(TInput.ENTER, codeEntered, false, 0, true);
			input.setFocus();
			input.setSelection(0,input.text.length);
		}
		
		private function codeEntered(e:Event):void {
			if (!dated) return;
			if (dated.dates.indexOf(int(input.text)) >= 0) {
				contCodeInput.fadeout(0.5, 0, TSprite.FADE_REMOVE);
			} else {
				title.htmlText = WRONG;
			}
		}
	}
}