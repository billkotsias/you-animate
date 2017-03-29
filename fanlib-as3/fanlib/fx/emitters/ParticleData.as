package fanlib.fx.emitters
{
	import fanlib.tween.TVector2;

	public class ParticleData
	{
		public var particle:IParticle;
		public var delay:Number;
		public var ttl:Number;
		public var index:Number; // [0...1)
		public var initPos:TVector2;
		public var finalPos:TVector2;
		
		public function ParticleData()
		{
		}
	}
}