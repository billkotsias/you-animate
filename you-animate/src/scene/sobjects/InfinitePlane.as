package scene.sobjects
{
	import flare.basic.Scene3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	import flare.materials.filters.SelfColorFilter;
	import flare.primitives.Plane;
	import flare.utils.Surface3DUtils;
	
	import scene.Scene;

	public class InfinitePlane extends SObject
	{
		static public const PLANE_SIZE:Number = 800;
		static public const DEFAULT_Z:Number = PLANE_SIZE / 2 - 50;
		
//		[Embed(source='D:/Projects/Flash/Walk3D/embedded/infinitePlane.zf3d',mimeType="application/octet-stream")]
//		static public const INFINITE_PLANE:Class;
		
		public function InfinitePlane()
		{
			super();
			_pivot3D.name = "Infinite plane";
			
			// grid
			const mesh:Mesh3D = MESH.clone() as Mesh3D;
			_pivot3D.addChild(mesh);
			MeshToSO[mesh] = this;
			
			// shadows
			_shadowsReceiver = MESH_SHADOWS.clone();
			Scene.INSTANCE.addShadowsReceiver(_shadowsReceiver);
		}
		
		static public const MESH:Mesh3D = function():Mesh3D {
			const plane:Plane = new Plane("", PLANE_SIZE*2, PLANE_SIZE, 1, SObject.CHECKERS_MATERIAL, "+xz");
			plane.castShadows = false;
			plane.setLayer(Walk3D.LAYER_TRANSPARENT);
			
			// modify UVs
			const surface:Surface3D = plane.surfaces[0];
			const uv:int = surface.offset[Surface3D.UV0];
			const vector:Vector.<Number> = surface.vertexVector;
			const length:int = vector.length;
			const sizePerVertex:int = surface.sizePerVertex;
			// UVs are either 0 or 1, so that's a quick trick:
			var off:uint;
			for ( var i:uint = 0; i < length; i += sizePerVertex ) {
//				vector[off = i + uv] = vector[off] * PLANE_SIZE/10 * 2;
//				vector[++off] = vector[off] * PLANE_SIZE/10;
				off = i + uv; // u
				vector[off] = vector[off] * PLANE_SIZE/10 * 2;
				++off; // v
				vector[off] = vector[off] * PLANE_SIZE/10;
			}
//			Surface3DUtils.buildTangentsAndBitangents(surface); // useless?
			if (surface.vertexBuffer) surface.vertexBuffer.uploadFromVector(vector, 0, length/sizePerVertex);
			
			return plane;
		}();
		
		static public const MESH_SHADOWS:Mesh3D = function():Mesh3D {
			const mesh:Mesh3D = MESH.clone() as Mesh3D;
			mesh.setMaterial(SObject.SHADOWS_ONLY_MATERIAL);
			mesh.setLayer(Walk3D.LAYER_SHADOWS);
			mesh.castShadows = false;
			return mesh;
		}();
		
		static public const MESH_DARK:Mesh3D = function():Mesh3D {
			const mesh:Mesh3D = MESH.clone() as Mesh3D;
			mesh.setMaterial(SObject.DARK_MATERIAL);
			mesh.setLayer(Walk3D.LAYER_SURFACE);
			mesh.castShadows = false;
			return mesh;
		}();
	}
}