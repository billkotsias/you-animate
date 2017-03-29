package scene.action
{
	import fanlib.gfx.FSprite;
	import fanlib.math.FVector3D;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.NullMaterial;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import scene.Scene;
	import scene.serialize.ISerialize;
	import scene.serialize.Serialize;
	import scene.sobjects.SObject;

	public class AbstractNode implements ISerialize
	{
		static public const OFFSET_MIN:Number = 0.1;
		
		static public const SELECT_FILTERS:Array = [new GlowFilter(0xffffff,0.85,4,4,4,1,true)];
		static public const HIGHLIGHT_FILTERS:Array = [new GlowFilter(0xffffff,0.5,4,4,4,1,true)];
		static public const BMP_RADIUS:Number = 20;
		
		protected var _mesh3D:Mesh3D;
		protected var _point2D:SpriteNode;
		protected var _offsetY:Number = 0; // 3D
		
		/**
		 * Quick reference to the SObject this Node is "on" 
		 */
		public var sobject:SObject;
		
		public function AbstractNode(parent3D:Pivot3D, parent2D:FSprite, meshTemplate:Mesh3D, spriteClass:Class)
		{
			_mesh3D = meshTemplate.clone() as Mesh3D;
//			trace(this,"rotations",_mesh3D.getDir(false),FVector3D.Z_Axis());
			_point2D = new spriteClass();
			setParents(parent3D, parent2D);
		}
		
		public function update2D():void {
			const pos3D:Vector3D = _mesh3D.getScreenCoords();
			var pnt2D:Point = new Point(pos3D.x, pos3D.y);
			pnt2D = _point2D.parent.globalToLocal(pnt2D);
				
			const dobj:DisplayObject = _point2D.main;
			dobj.x = pnt2D.x;
			dobj.y = pnt2D.y;
			
			//
			
			if (Math.abs(_offsetY) >= OFFSET_MIN) {
				getPosition(pos3D);
				pnt2D = Scene.INSTANCE.iScene3D.getPointScreenCoordsRelative(pos3D, _point2D, pos3D); // recycle pos3D
				_point2D.setOffsetPos(pnt2D.x, pnt2D.y);
			} else {
				_point2D.unsetOffset();
			}
		}
		
		public function setParents(parent3D:Pivot3D, parent2D:FSprite):void {
			parent3D.addChild(_mesh3D);
			parent2D.addChild(_point2D);
		}
		
		/**
		 * @param mouseCollision
		 * @return True if still over "parent" SObject, false : we have a problem
		 */
		public function setPositionFrom2D(mouseCollision:MouseCollision):Boolean {
			if (mouseCollision.test(_point2D.main.x, _point2D.main.y, true, false, false)) { // check against invisible too!!
				const colInfo:CollisionInfo = mouseCollision.data[0];
				sobject = SObject.GetFromMesh(colInfo.mesh);
				setPosition(colInfo.point);
				return true;
			}
			return false;
		}
		
		public function setOffsetPositionFrom2D(stgX:Number, stgY:Number):void {
			const pos:Vector3D = Scene.INSTANCE.iScene3D.getPointOnXYPlane(getPosition().z, stgX, stgY);
			offsetY = pos.y - _mesh3D.y;
		}
		
		/**
		 * @param stageX
		 * @param stageY
		 * @return NodeTouchInfo
		 */
		public function isUnderPoint2D(rootX:Number, rootY:Number):NodeTouchInfo {
			if (_point2D.main.hitTestPoint(rootX, rootY, true)) return new NodeTouchInfo(this as Node, this);
			return null;
		}
		
		public function isOffsetUnderPoint2D(rootX:Number, rootY:Number):NodeTouchInfo {
			if (_point2D.hitTestPoint(rootX, rootY, true)) return new NodeTouchInfo(this as Node, this);
			return null;
		}
		
		internal function dispose():void {
			_mesh3D.parent = null;
			_point2D.parent = null;
		}
		
		public function setPosition(pos:Vector3D):void {
			_mesh3D.setPosition(pos.x, pos.y, pos.z, 1, false);
			update2D();
		}
		
		public function setPositionLocal(pos:Vector3D):void {
			_mesh3D.setPosition(pos.x, pos.y, pos.z);
			update2D();
		}
		
		/**
		 * @return Global coordinates
		 */
		public function getPosition(out:Vector3D = null):Vector3D {
			out = _mesh3D.getPosition(false, out);
			out.y += _offsetY;
			return out;
		}
		public function getPositionLocal(out:Vector3D = null):Vector3D {
			out = _mesh3D.getPosition(true, out);
			out.y += _offsetY;
			return out;
		}
		
		public function get mesh3D():Mesh3D { return _mesh3D; }
//		internal function get point2D():FSprite { return _point2D; }
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
			update2D();
		}
		
		// save
		public function serialize(dat:* = undefined):Object {
			const sobjects:Array = dat;
			
			const obj:Object = {};
			obj.t = getQualifiedClassName(this); // used by Factory
			obj.p = Serialize.ToByteArray( _mesh3D.getPosition(false) );
			obj.s = sobjects.indexOf(sobject);
			obj.of = _offsetY;
			return obj;
		}
		public function deserialize(obj:Object):void {
			const vecObj:Object = Serialize.FromByteArray(obj.p);
			const vec:Vector3D = new Vector3D(vecObj.x, vecObj.y, vecObj.z);
			setPosition(vec);
			if (obj.of) offsetY = obj.of;
		}
		
		// static
		
		static public function CreateNodeMesh(size:Number, color:uint, alpha:Number):Mesh3D {
			var shape:Shape = new Shape();
			var gfx:Graphics = shape.graphics;
			gfx.beginFill(color, alpha);
			gfx.drawCircle(BMP_RADIUS+1, BMP_RADIUS+1, BMP_RADIUS);
			var shapeBmp:BitmapData = new BitmapData(BMP_RADIUS*2+2, BMP_RADIUS*2+2, true, 0);
			shapeBmp.draw(shape, null, null, null, null, true);
			
			var texFilter:TextureMapFilter = new TextureMapFilter(new Texture3D(shapeBmp));
			var mat:Shader3D = new Shader3D("", [texFilter], false);
			mat.transparent = true;
			mat.twoSided = true;
			mat.depthWrite = false;
			
			const mesh:Mesh3D = new Plane("", size, size, 1, mat, "+xz");
			mesh.setLayer(Walk3D.LAYER_NODE);
			return mesh;
		}
	}
}