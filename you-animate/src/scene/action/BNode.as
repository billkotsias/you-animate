package scene.action
{
	import fanlib.gfx.FSprite;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.geom.Vector3D;
	
	public class BNode extends Node
	{
		public var control0:CtrlNode;
		public var control1:CtrlNode;
		
		private var _hideCtrlNodes:Boolean; // emulate simple Node
		private var _ctrlNodesVisible:Boolean = true;
		
		public function BNode(parent3D:Pivot3D, parent2D:FSprite)
		{
			super(parent3D, parent2D);
			control0 = new CtrlNode(_mesh3D, parent2D, this, _point2D.main);
			control1 = new CtrlNode(_mesh3D, parent2D, this, _point2D.main);
			ctrlNodesVisible = false;
		}
		
		/**
		 * @param out Optional return Vector3D
		 * @return <b>Unnormalized</b> direction
		 * 
		 */
		public function getControlsDirection(out:Vector3D = null):Vector3D {
			if (!out) out = new Vector3D();
			control0.getPosition(out).decrementBy( control1.getPosition() );
			return out;
		}
		
		override public function setParents(parent3D:Pivot3D, parent2D:FSprite):void {
			super.setParents(parent3D, parent2D);
			if (control0) control0.setParents(_mesh3D, parent2D);
			if (control1) control1.setParents(_mesh3D, parent2D);
		}
		
		override public function set offsetY(value:Number):void {
			control0.offsetYAlone = control0.offsetY + value - _offsetY;
			control1.offsetYAlone = control1.offsetY + value - _offsetY;
			super.offsetY = value;
		}

		override public function update2D():void {
			super.update2D();
			control0.update2D();
			control1.update2D();
		}
		
		override public function isUnderPoint2D(stageX:Number, stageY:Number):NodeTouchInfo {
			var touchInfo:NodeTouchInfo;
			if ((touchInfo = control0.isUnderPoint2D(stageX, stageY)))
				return touchInfo;
			else if ((touchInfo = control1.isUnderPoint2D(stageX, stageY)))
				return touchInfo;
			return super.isUnderPoint2D(stageX, stageY);
		}
		override public function isOffsetUnderPoint2D(stageX:Number, stageY:Number):NodeTouchInfo {
			var touchInfo:NodeTouchInfo;
			if ((touchInfo = control0.isOffsetUnderPoint2D(stageX, stageY)))
				return touchInfo;
			else if ((touchInfo = control1.isOffsetUnderPoint2D(stageX, stageY)))
				return touchInfo;
			return super.isOffsetUnderPoint2D(stageX, stageY);
		}
		
		public function mirrorCtrlNode(ctrl:CtrlNode, mirrorPosition:Boolean, mirrorOffset:Boolean):void {
			var ctrl2:CtrlNode;
			if (ctrl == control1) ctrl2 = control0; else ctrl2 = control1;
			
			if (mirrorPosition) ctrl2.mirrorPositionFrom(ctrl, true);
			if (mirrorOffset) {
				ctrl2.offsetYAlone = 2 * _offsetY - ctrl.offsetY; // ctrl2.update2D() called inside here
			} else {
				ctrl2.update2D();
			}
			
			updateActions();
		}
		
		override public function select():void {
			super.select();
			ctrlNodesVisible = true;
		}
		override public function deselect():void {
			super.deselect();
			ctrlNodesVisible = false;
		}
		
		public function get ctrlNodesVisible():Boolean { return _ctrlNodesVisible; }
		public function set ctrlNodesVisible(v:Boolean):void {
			_ctrlNodesVisible = v;
			v &&= !hideCtrlNodes && _mesh3D.visible;
			control0.visible = v;
			control1.visible = v;
		}
		
		public function get hideCtrlNodes():Boolean { return _hideCtrlNodes; }
		public function set hideCtrlNodes(value:Boolean):void {
			_hideCtrlNodes = value;
			ctrlNodesVisible = _ctrlNodesVisible;
		}
		
		override internal function dispose():void {
			control0.dispose();
			control1.dispose();
			super.dispose();
		}
		
		// save
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.h = _hideCtrlNodes;
			obj.c = _ctrlNodesVisible;
			obj.c0 = control0.serialize(dat);
			obj.c1 = control1.serialize(dat);
			return obj;
		}
		override public function deserialize(obj:Object):void {
			super.deserialize(obj);
			control0.deserialize(obj.c0);
			control1.deserialize(obj.c1);
			_hideCtrlNodes = obj.h;
			ctrlNodesVisible = obj.c;
		}
		
		//
		
		// TODO : get 3 nodes as parameters
		static public function AlignControls(node0:BNode, node1:BNode, affectNode0:Boolean, affectNode1:Boolean):void {
			// diff vector
			const vector:Vector3D = node0.mesh3D.getPosition(false);
			vector.decrementBy(node1.mesh3D.getPosition(false));
			const length:Number = vector.length;
			if (length) vector.scaleBy(0.25/*/referencePivot.getScale(false).x*/); // NOTE : reference not taken into account
			
			if (affectNode0) {
				// node0
				node0.control1.mesh3D.setPosition(vector.x, vector.y, vector.z, 1, true); // local!
				node0.control0.mirrorPositionFrom(node0.control1, false);
				node0.control0.update2D();
				node0.control1.update2D();
			}
			
			if (affectNode1) {
				// node1
				node1.control0.mesh3D.setPosition(-vector.x, -vector.y, -vector.z, 1, true); // local!
				node1.control1.mirrorPositionFrom(node1.control0, false);
				node1.control0.update2D();
				node1.control1.update2D();
			}
		}
		
		override public function set visible(v:Boolean):void {
			super.visible = v;
			ctrlNodesVisible = _ctrlNodesVisible;
		}
	}
}