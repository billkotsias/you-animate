package fx
{
	import fanlib.gfx.Stg;
	
	import flare.basic.Scene3D;
	import flare.core.Texture3D;
	import flare.flsl.FLSLMaterial;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class MotionBlur implements IFX
	{
		[Embed(source = "../Flare3D2.8.5/bin/blurQuad.flsl.compiled", mimeType = "application/octet-stream")]
		private var MotionBlurFLSL:Class;
		private var motionBlurMaterial:FLSLMaterial;
		private var bufferA:Texture3D;
		private var bufferB:Texture3D;
		private var bufferCount:int;
		
		private var _scene:Scene3D;
		private var stage:Stage;
		
		private var _amount:Number = 0;
		
		public function MotionBlur(_scene:Scene3D)
		{
			motionBlurMaterial = new FLSLMaterial( "blur", new MotionBlurFLSL );
			
			bufferA = new Texture3D( new Rectangle( 0, 0, 2048, 1024 ) );
			bufferA.upload( _scene );
			bufferB = new Texture3D( new Rectangle( 0, 0, 2048, 1024 ) );
			bufferB.upload( _scene );
			
			this._scene = _scene;
			stage = Stg.Get();
			
			enable = true;
		}
		
		public function set enable(e:Boolean):void
		{
			if (e) {
				_scene.addEventListener( Scene3D.RENDER_EVENT, prerenderEvent );
			} else {
				_scene.removeEventListener( Scene3D.RENDER_EVENT, prerenderEvent );
			}
		}
		
		private function prerenderEvent(e:Event):void 
		{
			if (!amount) return; // optimization
			
			e.preventDefault();
			
			var front:Texture3D;
			var back:Texture3D;
			
			if ( (bufferCount = 1 - bufferCount) ) {
				front = bufferA;
				back = bufferB;
			} else {
				front = bufferB;
				back = bufferA;
			}
			
			_scene.context.setRenderToTexture( front.texture, true );
			_scene.context.clear();
			_scene.render();
			
			motionBlurMaterial.params.texture.value = back;
			motionBlurMaterial.params.alpha.value[0] = amount; // <-- higer values result in more blur (0 to 1)
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, motionBlurMaterial );
			
			motionBlurMaterial.params.texture.value = front;
			motionBlurMaterial.params.alpha.value[0] = 1;
			_scene.context.setRenderToBackBuffer();
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, motionBlurMaterial );
		}

		/**
		 * 0 (none) to 1 (chaos) 
		 */
		public function get amount():Number
		{
			return _amount;
		}

		/**
		 * @private
		 */
		public function set amount(value:Number):void
		{
			_amount = value;
			if (_amount >= 1) _amount = 0.99;
		}

	}
}