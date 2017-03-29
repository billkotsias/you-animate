package fanlib.ui.loading {
	
	import fanlib.gfx.Align;
	import fanlib.gfx.StagedSprite;
	import fanlib.gfx.TSprite;
	import fanlib.text.TTextField;
	import fanlib.tween.TVector2;
	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SMLTrackerBar extends MLTrackerBar {
		
		static private const Cont:TSprite = new TSprite();
		static private const Bar:SMLTrackerBar = new SMLTrackerBar();
		static private const Text:TTextField = new TTextField();
		static private const Dummy:* = Init();
		static private function Init():* {
			Bar.stageAlignX = Align.ALIGN_CENTER;
			Bar.stageAlignY = Align.ALIGN_CENTER;
			Cont.addChild(Bar);
			
			Text.autoSize = TextFieldAutoSize.CENTER;
			var textCont:StagedSprite = new StagedSprite();
			textCont.stageAlignX = Align.ALIGN_CENTER;
			textCont.stageAlignY = Align.ALIGN_CENTER;
			textCont.addChild(Text);
			Cont.addChild(textCont);
			
			Cont.alpha = 0;
		}
		static public function get Get():TSprite { return Cont; }
		static public function get GetText():TTextField { return Text; }
		
		static public function SetBarScale(xx:Number, yy:Number):void {
			Bar.scaleX = xx;
			Bar.scaleY = yy;
		}
		static public function SetTextPos(xx:Number, yy:Number):void {
			var cont:StagedSprite = Text.parent as StagedSprite;
			cont.stageX = xx;
			cont.stageY = yy;
		}
		static public function SetTextFormat(f:TextFormat):void {
			Text.defaultTextFormat = f;
			Text.setTextFormat(f);
		}
		
		static public function ShowProgress(txt:String = null):void {
			Bar.resetProgress();
			if (txt) Text.text = txt; else Text.text = "";
			Cont.fadein(1, 0, true);
		}
		static public function HideProgress():void {
			Cont.fadeout(1, 0, TSprite.FADE_INVISIBLE);
		}

	}
	
}
