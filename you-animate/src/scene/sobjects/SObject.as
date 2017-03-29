package scene.sobjects
{
	import fanlib.utils.Utils;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.flsl.FLSLFilter;
	import flare.materials.Material3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	import flare.materials.filters.SelfColorFilter;
	import flare.materials.filters.TextureMapFilter;
	
	import flash.display.BlendMode;
	import flash.display3D.Context3DBlendFactor;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import scene.ISObject;
	import scene.Scene;
	import scene.serialize.ISerialize;
	import scene.serialize.Serialize;

	public class SObject implements ISerialize, ISObject
	{
		static protected const MeshToSO:Dictionary = new Dictionary(true);
		static public function GetFromMesh(mesh:Mesh3D):SObject {
			return MeshToSO[mesh];
		}
		
//		[Embed(source='D:/Projects/Flash/Walk3D/embedded/logError.png')]
		[Embed(source='/../embedded/checkers-board.png')]
		static public const BMP_CHECKERS:Class;
		
		[Embed(source="/../embedded/onlyShadows.flsl.compiled", mimeType="application/octet-stream")]
		private static const ONLY_SHADOWS_FLSL:Class;
		
		/**
		 * Mesh container 
		 */
		protected var _pivot3D:Pivot3D = new Pivot3D();
		
		/**
		 * Shadows-receiver (optional) 
		 */
		protected var _shadowsReceiver:Pivot3D;
		
		public function SObject() {
		}
		
		/**
		 * Use this instead of directly positioning 'pivot3D' 
		 * @param x
		 * @param y
		 * @param z
		 * 
		 */
		public function setPosition(x:Number = NaN, y:Number = NaN, z:Number = NaN):void {
			if (x === x) _pivot3D.x = x;
			if (y === y) _pivot3D.y = y;
			if (z === z) _pivot3D.z = z;
			if (_shadowsReceiver) {
				if (x === x) _shadowsReceiver.x = x;
				if (y === y) _shadowsReceiver.y = y;
				if (z === z) _shadowsReceiver.z = z;
			}
		}
		
		public function dispose():void {
			_pivot3D.parent = null;
			_pivot3D = null;
			if (_shadowsReceiver) {
				_shadowsReceiver.parent = null;
				_shadowsReceiver = null;
			}
		}

		public function get pivot3D():Pivot3D { return _pivot3D }
		public function get shadowsReceiver():Pivot3D { return _shadowsReceiver }
		
		public function get visible():Boolean { return _pivot3D.visible; }
		public function set visible(v:Boolean):void { if (v) _pivot3D.show(); else _pivot3D.hide(); }
		public function get name():String { return _pivot3D.name; }
		public function set name(n:String):void { _pivot3D.name = n; }

		public function toString():String {
			return getQualifiedClassName(this)+":"+_pivot3D.name;
		}
		
		// save/load
		
		public function serialize(dat:* = undefined):Object {
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.p = Serialize.Pivot3D_(_pivot3D);
			return obj;
		}
		public function deserialize(obj:Object):void {
			Serialize._Pivot3D(obj.p, _pivot3D);
			Scene.INSTANCE.addSObject(this);
		}
		
		//
		static public const SHADOWS_ONLY_FILTER:FLSLFilter = new FLSLFilter( new ONLY_SHADOWS_FLSL() );
		static public const SHADOWS_ONLY_MATERIAL:Shader3D = function():Shader3D {
			const mat:Shader3D = new Shader3D("", [SHADOWS_ONLY_FILTER], true);
			mat.twoSided = true;
			mat.depthWrite = true;
			mat.blendMode = Material3D.BLEND_MULTIPLY;
//			mat.sourceFactor = Context3DBlendFactor.DESTINATION_COLOR;
//			mat.destFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			return mat;
		}();
		
		static public const CHECKERS_MATERIAL:Shader3D = function():Shader3D {
//			const colorFilter:ColorFilter = new ColorFilter(0xffffff,1);
//			colorFilter.r = colorFilter.g = colorFilter.b = 3;
//			colorFilter.a = -50;
//			const colorFilter:SelfColorFilter = new SelfColorFilter(0xffffff,0.5);
//			const mat2:Shader3D = new Shader3D("", [colorFilter], false);
//			mat2.transparent = false; // true
//			mat2.twoSided = true;
//			mat2.depthWrite = false;
//			mat2.enableLights = true;
////			mat2.blendMode = Material3D.BLEND_MULTIPLY;
//			mat2.sourceFactor = Context3DBlendFactor.DESTINATION_COLOR;
//			mat2.destFactor = Context3DBlendFactor.ZERO;
//			trace(mat2.transparent,mat2.twoSided,mat2.depthWrite,mat2.enableLights);
//			return mat2;
			
			const texture:Texture3D = new Texture3D(new BMP_CHECKERS().bitmapData, false,  Texture3D.FORMAT_RGBA);
			texture.filterMode = Texture3D.FILTER_ANISOTROPIC8X;
			const texFilter:TextureMapFilter = new TextureMapFilter(texture, 0, BlendMode.MULTIPLY, 0.75);
			//texFilter.repeatX = PLANE_TEXTURE_REPEAT*2;
			//texFilter.repeatY = PLANE_TEXTURE_REPEAT;
			const fuckMask:Vector.<Number> = new Vector.<Number>;
			fuckMask.push(1/255);
			texFilter.params.mask.value = fuckMask;
			const mat:Shader3D = new Shader3D("", [texFilter], false);
//			const mat:Shader3D = new Shader3D("", [texFilter, new AlphaMaskFilter(0)], false);
			mat.transparent = true; // true
			mat.twoSided = true;
			mat.depthWrite = false; // false
			mat.enableLights = false;
			return mat;
		}();
		
		static public const DARK_MATERIAL:Shader3D = function():Shader3D {
			const colorFilter:ColorFilter = new ColorFilter(0x202020,0.5);
			const mat:Shader3D = new Shader3D("", [colorFilter], false);
			mat.transparent = true;
			mat.twoSided = true;
			mat.depthWrite = false;
			mat.enableLights = false;
			return mat;
		}();
	}
}