package fanlib.ui {
	
	import fanlib.gfx.TSprite;
	import flash.events.MouseEvent;
	import fanlib.event.ObjEvent;
	import flash.events.Event;
	import fanlib.gfx.VectorLayer;
	
	public class Panel extends TSprite {

		static private const Panels:Array = new Array();
		static public function getByName(n:String):Panel { return Panels[n]; }
		
		static public const CLOSE_ID:String = "close";
		
		private var back:VectorLayer = new VectorLayer();
		private var closed:Boolean = true;
		
		public var openOnTop:Boolean = true;
		
		public function Panel() {
			visible = false;
			addChild(back); // bottom
			back.name = CLOSE_ID;
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		override public function set name(v:String):void {
			delete Panels[name];
			super.name = v;
			Panels[name] = this;
		}
		
		private function mouseDown(e:MouseEvent):void {
			if (e.target.name == CLOSE_ID) close();
		}
		
		public function set background(p:Array):void {
			back.vAlpha = p[0];
			back.color = p[1];
		}
		
		// to be overriden...
		public function close():void {
			if (closed) return;
			closed = true;
			transOut.addEventListener(Event.COMPLETE, closeFinished, false, 0, true);
			transOut.start();
			dispatchEvent(new ObjEvent(this, Event.CLOSE));
		}
		
		public function open():void {
			if (!closed) return;
			closed = false;
			visible = true;
			if (openOnTop) parent.setChildIndex(this, parent.numChildren - 1);
			transIn.start();
			dispatchEvent(new ObjEvent(this, Event.OPEN));
		}
		
		private function closeFinished(e:Event):void {
			visible = false;
		}

	}
	
}
