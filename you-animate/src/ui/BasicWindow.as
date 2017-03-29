package ui
{
	import fanlib.gfx.DragDObj;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.utils.IChange;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class BasicWindow extends TSprite
	{
		public var backColor:uint = 0xaaaaaa;
		public var backAlpha:Number = 1;
		public var backMargin:Number = 8;
		
		private var background:TopLayer;
		
		public function BasicWindow()
		{
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, false);
		}
		
		private function mouseDown(e:MouseEvent):void {
//			trace(e.currentTarget.name, e.target.name);
			if (e.currentTarget !== e.target) return;
			new DragDObj(this);
		}
		
		public function updateWindow():void {			
			const gfx:Graphics = this.graphics;
			gfx.clear();
			gfx.beginFill(backColor, backAlpha);
			gfx.lineStyle(1);
			const rect:Rectangle = getRect(this);
//			trace("updateWindow",rect);
			gfx.drawRect(rect.x - backMargin, rect.y - backMargin, rect.width + backMargin*2, rect.height + backMargin*2);
		}
		
		override public function childChanged(obj:IChange):void {
			if (!trackChanges) return; // duplicate, but what can one fuck?
			updateWindow();
			super.childChanged(obj);
		}
		
		public function setSingleTask(color32:uint = 0x80000000):void {
			unsetSingleTask();
			background = new TopLayer();
			background.color32 = color32;
			parent.addChild(background);
			parent.setChildIndex(background, parent.getChildIndex(this));
		}
		
		public function unsetSingleTask():void {
			if (!background) return;
			background.parent = null;
			background = null;
		}
	}
}