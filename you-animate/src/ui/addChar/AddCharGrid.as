package ui.addChar
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Grid;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import scene.CharManager;
	import scene.CharacterInfo;
	
	import tools.IContext;
	import tools.Tool;
	import tools.main.AddChar;
	
	import ui.ContextWindow;
	
	public class AddCharGrid extends Grid implements IContext
	{
		static public const ITEM_SELECTED:String = "AddCharGrid_ITEM_SELECTED";
		
		public function AddCharGrid()
		{
			super();
		}
		
		public function contextSelected(tool:Tool):void {
			update();
		}
		
		private function itemSelected(e:MouseEvent):void {
			dispatchEvent(new ObjEvent((e.currentTarget as GridItem).getInfo(), ITEM_SELECTED));
		}
		
		public function contextDeselected():void {
		}
		
		override public function update():void {
			trackChanges = false;
			
			removeChildren();
			for each (var info:CharacterInfo in CharManager.INSTANCE.characterInfos) {
				if (info.hide) continue;
				
				const item:GridItem = FSprite.FromTemplate("addCharGridItemTemp") as GridItem;
				item.setInfo(info, info.name, "Fixed: " + info.fixed.length + "\nMoves: " + info.moves.length);
				item.addEventListener(MouseEvent.CLICK, itemSelected, false, 0, true);
				addChild(item);
			}
			trackChanges = true;
			super.update();
		}
	}
}