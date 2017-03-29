package scene.action
{
	import fanlib.containers.List;
	import fanlib.gfx.FSprite;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Vector3D;
	
	public class Node extends AbstractNode
	{
		static public const MESH:Mesh3D = AbstractNode.CreateNodeMesh(3, SpriteNode.COLOR, SpriteNode.ALPHA);
		
		internal const actions:List = new List();
		
		public function Node(parent3D:Pivot3D, parent2D:FSprite)
		{
			super(parent3D, parent2D, MESH, SpriteNode);
		}
		
		override public function set offsetY(value:Number):void {
			super.offsetY = value;
			updateActions();
		}
		
		/**
		 * @param pos Global coordinates
		 */
		override public function setPosition(pos:Vector3D):void {
			super.setPosition(pos);
			updateActions();
		}
		
		protected function updateActions():void {
			var node:Node = this;
			actions.forEach(function (action:Action):void {
				action.nodeChanged(node); // 'this' doesn't work in anonymous functions
			});
		}
		
		public function getAction(i:int):Action {
			return actions.getByIndex(i);
		}
		public function get actionsNum():int { return actions.length; }
		
		public function getAbstractMoveAction():AbstractMoveAction {
			return actions.forEachBreakable(function (act:Action):AbstractMoveAction { return act as AbstractMoveAction; });
		}
		
		//
		
		public function select():void {
			_point2D.filters = SELECT_FILTERS;
		}
		public function deselect():void {
			_point2D.filters = null;
		}
		public function highlight():void {
			if (_point2D.filters == null) _point2D.filters = HIGHLIGHT_FILTERS;
		}
		public function unhighlight():void {
			if (_point2D.filters == HIGHLIGHT_FILTERS) _point2D.filters = null;
		}
		
		public function set visible(v:Boolean):void {
			_point2D.visible = v;
			_mesh3D.visible = v;
		}
		
//		public function get point2D():FSprite { return _point2D; }
	}
}