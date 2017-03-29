package scene.action
{
	import fanlib.gfx.FSprite;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;

	public class CtrlNode extends AbstractNode
	{
		static public const MESH:Mesh3D = AbstractNode.CreateNodeMesh(1.5, SpriteCtrlNode.COLOR, SpriteCtrlNode.ALPHA);
		
		private var parentNode:BNode;
		private var parentNode2D:FSprite;
		
		public function CtrlNode(parent3D:Pivot3D, parent2D:FSprite, parentNode:BNode, parentNode2D:FSprite)
		{
			super(parent3D, parent2D, MESH, SpriteCtrlNode);
			this.parentNode = parentNode;
			this.parentNode2D = parentNode2D;
		}
		
		override public function update2D():void {
			super.update2D();
			(_point2D as SpriteCtrlNode).linkToParent(parentNode2D);
		}
		
		override public function isUnderPoint2D(stageX:Number, stageY:Number):NodeTouchInfo {
			if (!_point2D.visible) return null;
			if (_point2D.main.hitTestPoint(stageX, stageY, true)) return new NodeTouchInfo(parentNode, this);
			return null;
		}
		override public function isOffsetUnderPoint2D(stageX:Number, stageY:Number):NodeTouchInfo {
			if (!_point2D.visible) return null;
			if (_point2D.hitTestPoint(stageX, stageY, true)) return new NodeTouchInfo(parentNode, this);
			return null;
		}

		internal function set offsetYAlone(value:Number):void {
			super.offsetY = value;
		}
		
		override public function set offsetY(value:Number):void {
			super.offsetY = value;
			parentNode.mirrorCtrlNode(this, false, true);
		}
		
		override public function setPosition(pos:Vector3D):void {
			super.setPosition(pos);
			parentNode.mirrorCtrlNode(this, true, false);
		}
		
		override public function setPositionLocal(pos:Vector3D):void {
			super.setPositionLocal(pos);
			parentNode.mirrorCtrlNode(this, true, false);
		}
		
		/**
		 * @param ctrl CtrlNode to mirror position from
		 * @param retainLength Keep current length of this CtrlNode and mirror direction only
		 */
		public function mirrorPositionFrom(ctrl:CtrlNode, retainLength:Boolean):void {
			var pos:Vector3D = ctrl._mesh3D.getPosition(true); // pos = local
			if (retainLength) {
				pos.normalize(); // make into direction
				pos.scaleBy(this._mesh3D.getPosition().length);
			}
			this._mesh3D.setPosition(-pos.x, -pos.y, -pos.z, 1, true);
		}
		
		internal function set visible(v:Boolean):void {
			_point2D.visible = v;
			_mesh3D.visible = v;
		}
	}
}