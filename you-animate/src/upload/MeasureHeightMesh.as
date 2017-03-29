package upload
{
	import flare.core.Mesh3D;
	
	import flash.display.BlendMode;
	
	import scene.Placeholder;

	public class MeasureHeightMesh
	{
		[Embed(source='D:/Projects/Flash/Walk3D/embedded/measure-height.png')]
		static public const BMP_MEASURE:Class;
		
		static private const MEASURE_MESH:Mesh3D = Placeholder.CreateMesh(BMP_MEASURE, 0, BlendMode.MULTIPLY, 0.66);
		static public function Mesh():Mesh3D { return MEASURE_MESH.clone() as Mesh3D; }
	}
}