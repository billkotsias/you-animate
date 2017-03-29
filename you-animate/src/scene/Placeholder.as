package scene
{
	import flare.core.Mesh3D;
	import flare.core.Texture3D;
	import flare.flsl.FLSLFilter;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	
	public class Placeholder
	{
		[Embed(source='D:/Projects/Flash/Walk3D/embedded/outline.png')]
		static public const BMP_OUTLINE:Class;
		static public const SIZE:Number = 4.9;
		
		static public function CreateMesh(_class:Class, channel:int = 0, blendMode:String = BlendMode.MULTIPLY, alpha:Number = 1):Mesh3D {
			var bmp:Bitmap = new _class();
			
			var texFilter:TextureMapFilter = new TextureMapFilter(new Texture3D(bmp.bitmapData, false,  Texture3D.FORMAT_RGBA), channel, blendMode, alpha);
			var mat:Shader3D = new Shader3D("", [texFilter], false);
			mat.transparent = true;
			mat.twoSided = true;
			mat.depthWrite = false;
			mat.enableLights = false;
			
			var sizeX:Number = SIZE*bmp.width/bmp.height;
			var mesh:Mesh3D = new Plane("", sizeX, SIZE, 1, mat, "+xy");
			mesh.setLayer(Walk3D.LAYER_PLACEHOLDER);
			mesh.y = SIZE / 2;
			mesh.castShadows = mesh.receiveShadows = false;
			return mesh;
		};
		
		static private const PLACEHOLDER_MESH:Mesh3D = CreateMesh(BMP_OUTLINE);
		static public function Mesh():Mesh3D { return PLACEHOLDER_MESH.clone() as Mesh3D; }
	}
}