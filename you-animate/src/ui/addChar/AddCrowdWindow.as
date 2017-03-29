package ui.addChar
{
	import fanlib.event.GroupEventDispatcher;
	import fanlib.event.ObjEvent;
	import fanlib.event.Unlistener;
	import fanlib.gfx.Align;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Grid;
	import fanlib.gfx.Stg;
	import fanlib.gfx.vector.FShape;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	import fanlib.ui.TouchMenu;
	import fanlib.utils.IInit;
	
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import scene.CharManager;
	import scene.Character;
	import scene.CharacterInfo;
	import scene.Crowd;
	
	import tools.Tool;
	
	import ui.BasicWindow;
	import ui.ButtonText;
	import ui.ContextWindow;
	import ui.LabelCheck;
	import ui.LabelInput;
	import ui.LabelInputNum;
	
	public class AddCrowdWindow extends ContextWindow
	{
		static public const THUMB_SPACE_RATIO:Number = 0.7; // actually, thumb-to-thumb+space
		static public const DIRECTION_STR:String = "direction";
		
		// set directly
		public var selectedGrid:Grid;
		public var availableGrid:Grid;
		// assigned
		public var radius:LabelInputNum;
		public var speed:LabelInputNum;
		public var newCrowd:ButtonText;
		public var updateCrowd:ButtonText;
		public var rerandomize:LabelCheck;
		private var _crowdTools:BasicWindow;
		
		private var crowdEditor:CrowdEditor;
		private const unlistener:Unlistener = new Unlistener();
		
		public function AddCrowdWindow()
		{
			super();
			crowdEditor = new CrowdEditor(this);
			crowdEditor.addEventListener(CrowdEditor.NO_CURRENT_CROWD, noCurrentCrowd);
			GroupEventDispatcher.GroupEvents("mainTools").addEventListener(Tool.SELECTED, mainToolSelected); // baha-lo
		}
		private function mainToolSelected(e:ObjEvent):void {
			if (e.getObj() !== contextTool) {
				crowdUnselected();
			}
		}
		
		public function set viewportHitArea(vArea:FSprite):void {
			crowdEditor.viewportHitArea = vArea;
		}
		
		override protected function contextSelected(e:Event):void {
			super.contextSelected(e);
			
			_crowdTools.visible = false;
			newCrowd.enabled = false;
			unlistener.addListener(newCrowd, FButton2.CLICKED, newCrowdClicked);
			
			trackChanges = false;
			availableGrid.removeChildren();
			selectedGrid.removeChildren();
			for each (var info:CharacterInfo in CharManager.INSTANCE.characterInfos) {
				if (info.hide || !info.moves.length) continue;
				
				var item:GridItem = FSprite.FromTemplate("addCharGridItemTemp") as GridItem;
				item.setInfo(info);
				item.scaleX = item.scaleY = selectedGrid.sizeX / selectedGrid.columns * THUMB_SPACE_RATIO / 200;
				unlistener.addListener(item, MouseEvent.CLICK, itemSelected);
				availableGrid.addChild(item);
			}
			trackChanges = true;
			childChanged(this);
			
			const currentCrowd:Crowd = crowdEditor.currentCrowd;
			if (currentCrowd)
			{
				rerandomize.enabled = updateCrowd.enabled = rerandomize.enabled = true;
				rerandomize.state = false;
				unlistener.addListener(updateCrowd, FButton2.CLICKED, updateCrowdClicked);
				
				// copy current crowd's properties
				radius.result = currentCrowd.radius;
				speed.result = currentCrowd.speed;
				for (var k:uint = 0; k < currentCrowd.characters.length; ++k) {
					const char:Character = currentCrowd.characters[k];
					for (var i:int = 0; i < availableGrid.numChildren; ++i) {
						item = availableGrid.getChildAt(i) as GridItem;
						if (char.info === item.getInfo()) {
							moveItemToSelected(item);
							if (currentCrowd.getCharDir(k)) {
								const dir:FSprite = item.getChildByName(DIRECTION_STR) as FSprite;
								dir.invertContent = true;
								dir.rotation = 180;
							}
							break;
						}
					}
				}
				availableGrid.update();
				
			} else {
				rerandomize.enabled = updateCrowd.enabled = rerandomize.enabled = false;
				rerandomize.state = true;
			}
			
			if (crowdEditor.editParams) newCrowd.enabled = false;
		}
		
		override protected function contextDeselected(e:Event):void {
			unlistener.removeAll();
			super.contextDeselected(e);
		}
		
		private function itemSelected(e:MouseEvent):void {
			moveItemToSelected(e.currentTarget as GridItem);
		}
		
		private function moveItemToSelected(item:GridItem):void {
			unlistener.removeListener(item, MouseEvent.CLICK, itemSelected);
			unlistener.addListener(item, MouseEvent.CLICK, itemUnselected);
			
			selectedGrid.addChild(item);
			
			const dir:FSprite = FSprite.FromTemplate(DIRECTION_STR);
			dir.width = dir.height = 100;
			dir.align(Align.CENTER, Align.CENTER);
			const rect:Rectangle = item.getRect(item);
			dir.x = rect.x + rect.width;
			dir.y = rect.y + rect.height;
			item.addChild(dir);
			
			selectedGrid.update();
			newCrowd.enabled = true;
		}
		
		// Truly unselected or direction change? Eh?
		private function itemUnselected(e:MouseEvent):void {
			// direction clicked?
			var dir:FSprite;
			if ( (dir = e.target as FSprite).name === DIRECTION_STR ) {
				dir.invertContent = ( (dir.rotation = (dir.rotation + 180) % 360) > 0 );
				return;
			}
			
			// truly unselect
			const item:GridItem = e.currentTarget as GridItem;
			unlistener.addListener(item, MouseEvent.CLICK, itemSelected);
			unlistener.removeListener(item, MouseEvent.CLICK, itemUnselected);
			
			(item.getChildByName(DIRECTION_STR) as FSprite).parent = null;
			
			availableGrid.addChild(item);
			availableGrid.update();
			if (!selectedGrid.numChildren) newCrowd.enabled = false;
		}
		
		// Take actual action
		
		internal function getDirs():Vector.<Boolean> {
			const dirs:Vector.<Boolean> = new Vector.<Boolean>;
			for (var i:int = 0; i < selectedGrid.numChildren; ++i) {
				var item:GridItem = selectedGrid.getChildAt(i) as GridItem;
				dirs.push( (item.getChildByName(DIRECTION_STR) as FSprite).invertContent );
			}
			return dirs;
		}
		
		internal function getCharNames():Array {
			const names:Array = []
			for (var i:int = 0; i < selectedGrid.numChildren; ++i) {
				var item:GridItem = selectedGrid.getChildAt(i) as GridItem;
				names.push( item.getInfo().name );
			}
			return names;
		}
		
		//
		
		private function newCrowdClicked(e:Event):void {
			crowdEditor.createNew();
			_crowdTools.visible = true;
			contextTool.selected = false;
			visible = false;
		}
		
		private function updateCrowdClicked(e:Event):void {
			crowdEditor.updateCurrent();
			_crowdTools.visible = true;
			contextTool.selected = false;
			visible = false;
		}
		
		//
		
		public function crowdSelected(crowd:Crowd):void {
			crowdEditor.currentCrowd = crowd;
			contextTool.selected = true;
			contextTool.selected = false;
			_crowdTools.visible = true;
			visible = false;
		}
		
		public function crowdUnselected():void {
			if (!crowdEditor.currentCrowd) return;
			crowdEditor.currentCrowd = null;
			noCurrentCrowd();
		}
		
		public function getSelectedCrowd():Crowd {
			return crowdEditor.currentCrowd;
		}
		
		// helpers
		
		private function noCurrentCrowd(e:Event = null):void {
			_crowdTools.visible = false;
			contextTool.selected = false;
			dispatchEvent(new Event(CrowdEditor.NO_CURRENT_CROWD));
		}
		
		public function set crowdTools(ctools:BasicWindow):void {
			_crowdTools = ctools;
			crowdEditor.setTools(ctools);
		}
	}
}