package ui.list
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.TouchMenu;
	import fanlib.utils.FStr;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import scene.Character;
	import scene.action.Action;
	import scene.action.ActionManager;
	import ui.CharContext;

	public class ListActions extends CharContext
	{		
		static public const NUM:String = "num";
		static public const NAME:String = "name";
		static public const DUR:String = "dur";
		
		static public const DD_WIDTH:Number = 2;
		static public const DD_COLOR:uint = 0xffff00;
		
		private var selectedChar:Character;
		
		private const dragDropLine:Sprite = new Sprite();
		private const dragDropRect:Sprite = new Sprite();
		
		public var spaceY:Number;
		
		public var dropIndex:int;
		private var debug:int = 0;
		
		public function ListActions()
		{
			super();
			addEventListener(TouchMenu.CHILD_SELECTED, actionClicked, false, 0, true);
			
			dragDropLine.mouseEnabled = false;
			dragDropLine.mouseChildren = false;
			dragDropLine.filters = [new GlowFilter(0xffff00)];
			
			dragDropRect.mouseEnabled = false;
			dragDropRect.mouseChildren = false;
			dragDropRect.filters = dragDropLine.filters;
		}
		
		override public function set scrollRectangle(arr:Array):void {
			super.scrollRectangle = arr;
			const back:FSprite = new FSprite();
			back.addBackground = [0,0,scrollRect.width,scrollRect.height]; // , true, 0xffff00,1
			rootAddChildAt(back, 0);
		}
		
		private function setupVectorGfx():void {
			var gfx:Graphics = dragDropLine.graphics;
			gfx.clear();
			gfx.lineStyle(DD_WIDTH,DD_COLOR);
			gfx.lineTo(scrollRect.width,0);
			
			gfx = dragDropRect.graphics;
			gfx.clear();
			gfx.lineStyle(DD_WIDTH,DD_COLOR);
			gfx.drawRect(0,0,scrollRect.width,spaceY);
			
			rootAddChild(dragDropLine);
			rootAddChild(dragDropRect);
			dragDropLine.visible = false;
			dragDropRect.visible = false;
		}
		
		// mouseUp is checked by caller
		private function mOut(e:MouseEvent):void {
			dropIndex = -1;
			dragDropLine.visible = false;
			dragDropRect.visible = false;
		}
		private function mMove(e:MouseEvent):void {
			const dobj:DisplayObject = e.target as DisplayObject;
			if (e.target is FSprite) {
				dropIndex = numChildren;
				dragDropRect.visible = false;
				dragDropLine.visible = true;
			} else {
				const txt:FTextField = e.target as FTextField;
				dropIndex = getChildIndex(txt.parent);
				const yy:Number = e.localY - txt.height*0.5;
				//trace(this,yy);
				if (Math.abs(yy) < spaceY * 0.0) { // NOTE : 0.0 = line, 0.25 = both, 0.51 = rect
					dragDropRect.visible = true;
					dragDropLine.visible = false;
				} else {
					dragDropRect.visible = false;
					dragDropLine.visible = true;
					if (yy > 0) ++dropIndex;
				}
			}
			dragDropLine.y = dropIndex * spaceY;
			dragDropRect.y = dropIndex * spaceY;
		}
		
		public function enableDragAndDrop(v:Boolean):void {
			if (v) {
				addEventListener(MouseEvent.MOUSE_MOVE, mMove, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, mOut, false, 0, true);
				dropIndex = -1;
//				addEventListener(MouseEvent.MOUSE_UP, mUp, false, 0, true);
				setupVectorGfx();
			} else {
				removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
				removeEventListener(MouseEvent.ROLL_OUT, mOut);
				rootRemoveChild(dragDropLine);
				rootRemoveChild(dragDropRect);
			}
		}
		
		public function update(e:* = undefined):void {
//			trace(this,"updated",++debug,new Error().getStackTrace());
			// make enough children for every character action
			var cont:FSprite;
			const charActionNum:uint = (selectedChar) ? selectedChar.getActionNum() : 0;
			while (charActionNum > numChildren) {
				cont = addChild(FSprite.FromTemplate("listActionsTemp")) as FSprite;
			}
			while (charActionNum < numChildren) {
				cont = removeChildAt(numChildren-1) as FSprite;
			}
			
			var back:Boolean;
			for (var i:int = 0; i < charActionNum; ++i) {
				const action:Action = selectedChar.getAction(i);
				cont = getChildAt(i) as FSprite;
				cont.y = i * spaceY;
				(cont.getChildByName(NUM) as FTextField).text = (i+1).toString();
				(cont.getChildByName(NAME) as FTextField).text = action.id;
				(cont.getChildByName(DUR) as FTextField).text = FStr.RoundToString(action.duration, 2) + "s";
				
				if (selectedChar.selectedActionIndex === i) back = true; else back = false;
				setBackground(cont, back);
			}
		}
		
		private function actionClicked(e:ObjEvent):void {
			const par:FSprite = e.getObj().parent;
			const newIndex:int = getChildIndex(par);
			
			// deselect previous
			if (selectedChar.selectedActionIndex >= 0) {
				setBackground(getChildAt(selectedChar.selectedActionIndex) as FSprite, false);
			}
			if (selectedChar.selectedActionIndex === newIndex) {
				selectedChar.selectedActionIndex = -1;
			} else {
				selectedChar.selectedActionIndex = newIndex;
				setBackground(par, true);
			}
		}
		
		private function setBackground(par:FSprite, v:Boolean):void {
			for (var i:int = par.numChildren - 1; i >= 0; --i) {
				(par.getChildAt(i) as FTextField).background = v;
			}
		}
		
		override protected function charSelected(e:Event = null):void {
			charDeselected();
			selectedChar = _selectChar.selectedCharacter;
			selectedChar.addEventListener(ActionManager.CHANGE, update, false, 0, true);
			update();
		}
		override protected function charDeselected(e:Event = null):void {
			if (selectedChar) selectedChar.removeEventListener(ActionManager.CHANGE, update);
			selectedChar = null;
			update();
		}
	}
}