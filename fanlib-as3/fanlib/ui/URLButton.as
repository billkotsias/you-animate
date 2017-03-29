package fanlib.ui {
	
	import fanlib.gfx.TSprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class URLButton extends TSprite {

		public var href:String;
		public var target:String = "_blank";
		
		public function URLButton() {
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		private function mouseDown(e:MouseEvent):void {
			if (href && href.length) navigateToURL(new URLRequest(href), target);
		}

	}
	
}
