package ui.thumbs
{
	import fanlib.gfx.DragDObj;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.gfx.Stg;
	import fanlib.text.FTextField;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import scene.Character;
	import scene.CharacterInfo;
	import scene.action.ActionInfo;
	import scene.action.Node;
	import scene.action.NodeTouchInfo;
	
	import ui.CharContext;
	import ui.list.ListActions;

	public class ThumbsAnim extends CharContext
	{
		static public const BMP:String = "bmp";
		static public const TEXT:String = "txt";
		
		protected var animGroup:String;
		
		public var spaceY:Number = 96;
		public var listActions:ListActions;
		public var viewportHitArea:FSprite;
		
		protected var selectedChar:Character;
		private var dragCopy:FSprite;
		private var overNode:NodeTouchInfo;
		
		public function ThumbsAnim()
		{
			super();
			mouseWheel = 20;
		}
		
		public function update(e:* = undefined):void {
			removeChildren();
			if (!selectedChar) return;
			
			const characterInfo:CharacterInfo = selectedChar.info;
			const animThumbs:Object = characterInfo.animThumbs;
			for each (var actionInfo:ActionInfo in characterInfo[animGroup]) {
				
				const cont:FSprite = FSprite.FromTemplate("animThumbTemp");
				var thumbURL:String = animThumbs[ actionInfo.i ];
				if (!thumbURL) {
					if (characterInfo.defaultAnimThumb) {
						thumbURL = Walk3D.CHARS_DIR + characterInfo.defaultAnimThumb;
					} else {
						thumbURL = Walk3D.CHARS_DIR + "thumb.png"; // not likely...
					}
				}
				
				(cont.getChildByName(BMP) as FBitmap).lazyBitmapData = thumbURL;
				const animTitle:String = actionInfo.id;
				(cont.getChildByName(TEXT) as FTextField).htmlText = animTitle;
				cont.name = animTitle;
				addChild(cont);
				cont.addEventListener(MouseEvent.MOUSE_DOWN, childDown, false, 0, true);
			}
			
			if (cont) {
				Gfx.SortChildrenByName(cont.parent);
				for (var i:int = 0; i < numChildren; ++i) {
					getChildAt(i).y = spaceY * i;
				}
			}
		}
		
		protected function childDown(e:MouseEvent):void {
			_selectChar.selected = true;
			
			const child:FSprite = e.target as FSprite;
			dragCopy = child.copy();
			const rect:Rectangle = child.getRect(Stg.Get());
			Stg.Get().addChild(dragCopy);
			dragCopy.x = rect.x;
			dragCopy.y = rect.y;
			dragCopy.mouseEnabled = false;
			dragCopy.filters = [new GlowFilter(0xffffff,1,6,6,2,1,true), new DropShadowFilter()];
			dragCopy.alpha = 0.5;
			new DragDObj(dragCopy);
			
			listActions.enableDragAndDrop(true);
			viewportHitArea.addEventListener(MouseEvent.MOUSE_MOVE, mVPortMove, false, 0, true);
			Stg.Get().addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
		}
		private function mVPortMove(e:MouseEvent):void {
			const newOverNode:NodeTouchInfo = selectedChar.getNodeUnderPoint2D(root, e.stageX, e.stageY);
			
			var oldNode:Node, newNode:Node;
			if (overNode) oldNode = overNode.node;
			if (newOverNode) newNode = newOverNode.node;
			
			if (oldNode !== newNode) {
				if (oldNode) oldNode.unhighlight();
				if (newNode) newNode.highlight();
			}
			overNode = newOverNode; // the "abstract node" (abNode) may have changed!
		}
		private function mouseUp(e:MouseEvent):void {
			viewportHitArea.removeEventListener(MouseEvent.MOUSE_MOVE, mVPortMove);
			Stg.Get().removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			var nodeDrag:Node;
			if (listActions.dropIndex >= 0) {
				dragNDrop(dragCopy.name, listActions.dropIndex);
			} else if (e.target === viewportHitArea) {
				if (overNode) {
					nodeDrag = overNode.node;
				} else if (selectedChar.selectedNodes.length) {
					nodeDrag = selectedChar.selectedNodes[0];
				}
				if (nodeDrag) dragNDropNode(dragCopy.name, nodeDrag);
			}
			
			listActions.enableDragAndDrop(false);
			dragCopy.parent = null;
			dragCopy = null;
		}
		
		protected function dragNDrop(animName:String, index:int):void {
			// override
		}
		protected function dragNDropNode(animName:String, node:Node):void {
			// override
		}
		
		override protected function charSelected(e:Event = null):void {
			selectedChar = _selectChar.selectedCharacter;
			update();
		}
		override protected function charDeselected(e:Event = null):void {
			selectedChar = null;
			update();
		}
	}
}