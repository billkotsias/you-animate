package tools.photo
{
	import fanlib.containers.List;
	import fanlib.event.GroupEventDispatcher;
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.ui.FButton2;
	import fanlib.utils.FArray;
	
	import flare.basic.Scene3D;
	import flare.core.Mesh3D;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import scene.Scene;
	import scene.layers.Layer;
	import scene.layers.LayerUI;
	import scene.sobjects.InfinitePlane;
	
	import ui.ContextIcons;

	public class PhotoTools extends ContextIcons
	{
		static public const LAYERUI_INDEX_MIN:int = 2;
		
		private const layersUI:List = new List();
		private var addNewLayerBut:FButton2;
		private var darkInfinitePlane:Mesh3D;
		
		public function PhotoTools()
		{
			super();
			Scene.INSTANCE.addEventListener(Scene.LAYER_ADDED, layerAdded, false, 0, true);
			Scene.INSTANCE.addEventListener(Scene.LAYER_REMOVED, layerRemoved, false, 0, true);
		}
		
		override protected function contextSelected(e:Event):void {
			super.contextSelected(e);
			if (!addNewLayerBut) {
				// 1st time here
				addNewLayerBut = findChild("addNewLayer");
				addNewLayerBut.addEventListener(FButton2.CLICKED, addNewLayer, false, 0, true);
				
				darkInfinitePlane = InfinitePlane.MESH_DARK.clone() as Mesh3D;
				(Scene.INSTANCE.iScene3D as Scene3D).addChild(darkInfinitePlane);
				darkInfinitePlane.z = InfinitePlane.DEFAULT_Z;
			}
			
			checkDarkVisible();
		}
		
		override protected function contextDeselected(e:Event):void {
			super.contextDeselected(e);
			darkInfinitePlane.hide();
		}
		
		private function checkDarkVisible():void {
			if (!darkInfinitePlane) return;
			if (visible && Scene.INSTANCE.layers.length) {
				darkInfinitePlane.show(); // show!
			} else {
				darkInfinitePlane.hide();
			}
		}
		
		private function addNewLayer(e:MouseEvent):void {
			const layer:Layer = new Layer();
			layer.addEventListener(Event.CHANGE, layerZchanged, false, 0, true);
			Scene.INSTANCE.addLayer(layer);
		}
		private function layerAdded(e:ObjEvent):void {
			const layer:Layer = e.getObj();
			const layerUI:LayerUI = FSprite.FromTemplate("layerTemp") as LayerUI;
			layerUI.trackChanges = false;
			layerUI.layer = layer;
			addChild(layerUI);
			
			if (!layer.getBytes()) { // all new!
				var zz:Number = (layersUI.length) ? ((layersUI.last as LayerUI).layer.z - 2) : 25;
				if (zz <= 0) zz = 1;
				layer.z = zz;
				layerUI.updateNumTextFromLayer();
				layerUI.browseForTexture();
			}
			
			layersUI.push(layerUI);
			updateLayerList();
			checkDarkVisible();
		}
		
		private function layerZchanged(e:Event):void {
			updateLayerList();	
		}
		
		private function layerRemoved(e:ObjEvent):void {
			const layer:Layer = e.getObj();
			layer.removeEventListener(Event.CHANGE, layerZchanged);
			
			const layerUI:LayerUI = layersUI.forEachBreakable(
				function(layerUI:LayerUI):LayerUI {
					if (layerUI.layer === layer) return layerUI;
					return null;
				});
			layersUI.remove(layerUI);
			removeChild(layerUI);
			updateLayerList();
			checkDarkVisible();
		}
		
		private function updateLayerList(/*e:Event = null*/):void {
			const arr:Array = layersUI.toArray();
			arr.sortOn("layerZ", Array.NUMERIC|Array.DESCENDING);
			for (var i:int = 0; i < arr.length; ++i) {
				setChildIndex(arr[i], i + LAYERUI_INDEX_MIN);
			}
			rearrange();
		}
		
	}
}