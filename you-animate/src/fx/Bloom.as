package fx
{
	import fanlib.gfx.Stg;
	
	import flare.basic.Scene3D;
	import flare.core.Texture3D;
	import flare.flsl.FLSLMaterial;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;

	public class Bloom implements IFX
	{
		[Embed(source = "../Flare3D2.8.5/bin/bloom2.flsl.compiled", mimeType = "application/octet-stream")]
		private var BloomFLSL:Class;
		private var bloomTexture:Texture3D;
		private var bloomMaterial:FLSLMaterial;
		
		private var _scene:Scene3D;
		private var stage:Stage;
		private var params:Object;
		
		public function Bloom(_scene:Scene3D)
		{
			bloomTexture  = new Texture3D( new Point(256,256), true );
			
			// creates the flsl bloom material..
			bloomMaterial = new FLSLMaterial( "bloom", new BloomFLSL );
			params = bloomMaterial.params;
			params.bloomTexture.value = bloomTexture;
			setParams(0, 2);
			
			this._scene = _scene;
			stage = Stg.Get();
			
			enable = true;
		}
		
		public function set enable(e:Boolean):void
		{
			if (e) {
				_scene.addEventListener( Scene3D.POSTRENDER_EVENT, postRenderEvent );
			} else {
				_scene.removeEventListener( Scene3D.POSTRENDER_EVENT, postRenderEvent );
			}
		}
		
		public function setParams(intensity:Number, power:Number):void {
			const params:Object = bloomMaterial.params;
			params["intensity"].value[0] = intensity;
			params["power"].value[0] = power;
		}
		
		private function postRenderEvent(e:Event):void 
		{
			if (bloomMaterial.params["intensity"] <= 0) return; // optimization
			
			// after the scene has been rendered, render the scene again into the small bloom texture.
			_scene.render( _scene.camera, false, bloomTexture );
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, bloomMaterial); // draw and sum the result with the already rendered scene
		}
	}
}