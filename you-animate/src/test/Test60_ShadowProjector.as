package test
{
	import fanlib.io.MLoader;
	import fanlib.math.FVector3D;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	
	import flare.Flare3D;
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.ShadowProjector3D;
	import flare.core.Texture3D;
	import flare.flsl.FLSLMaterial;
	import flare.primitives.DebugLight;
	import flare.primitives.Quad;
	import flare.primitives.SkyBox;
	import flare.system.Input3D;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextFormat;
	
	import scene.Back;

	/**
	 * @author Ariel Nehmad
	 */
	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class Test60_ShadowProjector extends FANApp 
	{
		private var _scene:Scene3D;
		private var proj:ShadowProjector3D;
		private var proj2:ShadowProjector3D;
		private var camera:Camera3D;
		
		static private const Zero:Vector3D = FVector3D.Zero();
		
		// Bloom fx
		[Embed(source = "../Flare3D2.8.5/bin/bloom2.flsl.compiled", mimeType = "application/octet-stream")]
		private var Bloom:Class;
		private var bloomTexture:Texture3D;
		private var bloomMaterial:FLSLMaterial;
		
		[Embed(source = "../Flare3D2.8.5/bin/blurQuad.flsl.compiled", mimeType = "application/octet-stream")]
		private var MotionBlur:Class;
		private var motionBlurMaterial:FLSLMaterial;
		private var bufferA:Texture3D;
		private var bufferB:Texture3D;
		private var bufferCount:int;
		
		private const text:String = "Flare3D.version = " + Flare3D.version + " - Loading, please wait : ";
		
		public function Test60_ShadowProjector() 
		{
			_scene = new Viewer3D( this, "", 0.25 );
			_scene.autoResize = true;
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			_scene.addChildFromFile( "test/chess2_noLightmaps.zf3d" );
			_scene.addChildFromFile( "test/walk.zf3d" );
			_scene.addEventListener( Scene3D.PROGRESS_EVENT, progress);
			new MLoader(["test/right.jpg","test/left.jpg","test/top.jpg","test/bottom.jpg","test/front.jpg","test/back.jpg"], function(l:MLoader):void {
				CONFIG::newFlare { const sky:SkyBox = new SkyBox([l.files[0], l.files[1], l.files[2], l.files[3], l.files[4], l.files[5]], _scene, 0.8); }
				CONFIG::oldFlare { const sky:SkyBox = new SkyBox([l.files[0], l.files[1], l.files[2], l.files[3], l.files[4], l.files[5]], null, _scene, 0.8); }
				_scene.addChild(sky);
			});
		}
		
		private function progress(e:ProgressEvent):void {
			Debug.field.htmlText = text + (100 * e.bytesLoaded / e.bytesTotal).toFixed(1) + "%";
		}
		
		override protected function stageInitialized():void {
			Debug.field.defaultTextFormat = new TextFormat(null,32,0xaaaaaa);
			Debug.field.filters = [new DropShadowFilter()];
			Debug.field.htmlText = text;
		}
		
		private function completeEvent(e:Event):void {
			_scene.forEach(
				function(mesh:Mesh3D):void {
					trace(mesh,mesh.name);
//					mesh.receiveShadows = false;
//					mesh.castShadows = false;
				}, Mesh3D);
			
			Debug.field.htmlText = "";
			// remove original lights
			var lights:Vector.<Pivot3D> = _scene.getChildrenByClass( Light3D );
			for each ( var l:Light3D in lights ) {
				l.parent = null;
			}
			
			// SHADOWS
//			proj2 = new ShadowProjector3D( "proj 1", ShadowProjector3D.QUALITY_BEST, 3 );
//			proj2.setPosition(0,0,600);
//			proj2.rotateX(-25,false,Zero);
//			proj2.lookAt(0,0,0);
//			proj2.far = 2000;
//			proj2.filter = 1000; 
//			proj2.setParams(0xffaa40, 0, 1, 1.5, false);
//			proj2.debug = false;
//			proj2.addChild(new DebugLight(proj2));
//			_scene.addChild(proj2);
			
			proj = new ShadowProjector3D( "proj 2", ShadowProjector3D.QUALITY_BEST, 3 );
			proj.type = Light3D.DIRECTIONAL;
			proj.setPosition(0,500,0);
//			proj.setPosition(0,0,-600);
			proj.rotateX(25,false,Zero);
			proj.lookAt(0,0,0);
			proj.far = 2000;
			proj.filter = 1000; 
			proj.setParams(0xffffff, 0, 1, 1, false);
//			proj.setParams(0xffaa40, 0, 1, 1.5, false);
			proj.debug = false;
			proj.addChild(new DebugLight(proj));
			_scene.addChild(proj);
			
			// disable the default light, we want to use the projector instead.
			_scene.lights.defaultLight = null;
			_scene.lights.ambientColor.setTo(0,0,0);
//			_scene.lights.ambientColor.setTo(0.1,0.2,0.4);
			
			// BLOOM
			// creates a dynamic 256x256 texture.
			// we'll render this texture by our own, letting Flare render
			// the scene normally.
			bloomTexture  = new Texture3D( new Point(256,256), true );
			
			// creates the flsl bloom material..
			bloomMaterial = new FLSLMaterial( "bloom", new Bloom );
			bloomMaterial.params.bloomTexture.value = bloomTexture;
			bloomMaterial.params.intensity.value[0] = 2;
			bloomMaterial.params.power.value[0] = 1.5;
			
			// MOTION BLUR
			motionBlurMaterial = new FLSLMaterial( "blur", new MotionBlur );
			
			bufferA = new Texture3D( new Rectangle( 0, 0, 2048, 1024 ) );
			bufferA.upload( _scene );
			bufferB = new Texture3D( new Rectangle( 0, 0, 2048, 1024 ) );
			bufferB.upload( _scene );

			// do ALL pre-post-render stuff
			_scene.addEventListener( Scene3D.RENDER_EVENT, renderEvent );
			_scene.addEventListener(Scene3D.POSTRENDER_EVENT, postRenderEvent);
		}
		
		private function renderEvent(e:Event):void 
		{
			// MOTION BLUR
			e.preventDefault();
			
			var front:Texture3D;
			var back:Texture3D;
			
//			if ( bufferCount++ % 2 == 0 ) {
			if ( (bufferCount = 1 - bufferCount) ) {
				front = bufferA;
				back = bufferB;
			} else {
				front = bufferB;
				back = bufferA;
			}
			
			_scene.context.setRenderToTexture( front.texture, true );
//			_scene.context.clear( 0,0,0 );
			_scene.render();
			
			motionBlurMaterial.params.texture.value = back;
			motionBlurMaterial.params.alpha.value[0] = 0.5; // <-- higer values results in more blur (0 to 1)
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, motionBlurMaterial );
			
			motionBlurMaterial.params.texture.value = front;
			motionBlurMaterial.params.alpha.value[0] = 1;
			_scene.context.setRenderToBackBuffer();
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, motionBlurMaterial );
		}
		
		private function postRenderEvent(e:Event):void 
		{
			// SHADOW
			if (proj) proj.rotateY(0.5, false, Zero);
			if (proj2) proj2.rotateY(0.5, false, Zero);
			
			// BLOOM
			// after the scene has been rendered, render the scene again into the small bloom texture.
			_scene.render( _scene.camera, false, bloomTexture );
			_scene.drawQuadTexture( null, 0, 0, stage.stageWidth, stage.stageHeight, bloomMaterial);
//			quad.draw(); // draw and sum the result with the already rendered scene.
		}
	}
}