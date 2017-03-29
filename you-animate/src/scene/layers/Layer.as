package scene.layers
{
	import fanlib.containers.Array2D;
	import fanlib.utils.Pair;
	import fanlib.utils.Pausable;
	import fanlib.utils.Utils;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.core.Texture3D;
	import flare.materials.Material3D;
	import flare.materials.NullMaterial;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Cube;
	import flare.primitives.Plane;
	import flare.utils.Mesh3DUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import scene.Scene;
	import scene.camera.Camera;
	import scene.serialize.ISerialize;
	import scene.sobjects.SObject;
	
	public class Layer extends EventDispatcher implements ISerialize
	{
		[Embed(source='D:/Projects/Flash/Walk3D/embedded/checkers-layer.png')]
		static public const BMP_LAYER_CHECKERS:Class;
		[Embed(source='D:/Projects/Flash/Walk3D/embedded/layer-default.png')]
		static public const BMP_LAYER_DEFAULT:Class;
		
		private var _pivot3D:Pivot3D = new Pivot3D();
		private const originalBmpSize:Point = new Point(1,1);
		
		private var _bytes:ByteArray;
		private var loader:Loader;
		
		internal var layerUI:LayerUI;
		
		private const pauseVisible:Pausable = new Pausable();
		
		public function Layer() {
			_pivot3D.addChild( NewLayerPlane( NewLayerMaterial() ) );
			Scene.INSTANCE.camera3D.addEventListener(Camera.ZOOM_CHANGED, update, false, 0, true);
		}
		
		public function getBytes():ByteArray { return _bytes; }
		public function setBytes(b:ByteArray):void {
			if (_bytes) _bytes.clear();
			if (loader) {
				loader.close();
				loader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, bytesLoaded);
				loader = null;
			}
			
			_bytes = b;
			if (_bytes) {
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, bytesLoaded, false, 0, true);
				loader.loadBytes(_bytes);
			}
		}
		protected function bytesLoaded(e:flash.events.Event):void {
			loader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, bytesLoaded);
			const bitmapData:BitmapData = ((loader.getChildAt(0) as Bitmap).bitmapData); // get yer bitmapData
			loader = null;
			originalBmpSize.setTo(bitmapData.width, bitmapData.height);
			
			disposeCurrentPlanes();
			const planes:Array = ComplexPlane( Utils3D.SplitOversizedBmpData( bitmapData, true ), originalBmpSize ).table;
			for (var i:int = planes.length - 1; i >= 0; --i) {
				var plane:Mesh3D = planes[i];
				_pivot3D.addChild( plane );
			}
			
			// update UI thumbnail
			layerUI.setThumbnail(bitmapData);
			
			update();
		}
		
		public function get z():Number { return _pivot3D.z }
		public function set z(_z:Number):void {
			_pivot3D.z = _z;
			update();
			dispatchEvent(new Event(Event.CHANGE)); // allow it, ain't FSprite
		}
		
		public function update(e:* = undefined):void {
			const viewport:Rectangle = Scene.INSTANCE.viewport.getRect(Scene.INSTANCE.viewport);
			const scaleX:Number = viewport.width / originalBmpSize.x;
			const scaleY:Number = viewport.height / originalBmpSize.y;
			const finalScale:Number = (scaleX < scaleY) ? scaleX : scaleY;
			const finalWidth:Number = originalBmpSize.x * finalScale;
			const finalHeight:Number = originalBmpSize.y * finalScale;
			
			const scale:Number = Scene.INSTANCE.camera3D.getPixelScaleAt(_pivot3D.z, viewport.width);
			if (scale <= 0) {
				_pivot3D.hide();
			} else {
				_pivot3D.show();
				_pivot3D.setScale(scale * finalWidth, scale * finalHeight, 1);
			}
		}
		
		private function disposeCurrentPlanes():void {
			// get custom materials
			for each ( var mat:Material3D in _pivot3D.getMaterials() ) {
				mat.dispose();
			}
			_pivot3D.forEach( function(p:Pivot3D):void { p.parent = null } );
		}
		
		public function dispose():void {
			Scene.INSTANCE.camera3D.removeEventListener(Camera.ZOOM_CHANGED, update);
			disposeCurrentPlanes();
			_pivot3D.parent = null;
			_pivot3D = null;
			setBytes(null);
		}
		
		public function get pivot3D():Pivot3D { return _pivot3D; }
		
		// visibility
		public function setInvisible(setter:*):void {
			pauseVisible.pause(setter);
			_pivot3D.hide();
		}
		public function unsetInvisible(setter:*):void {
			if (!pauseVisible.unpause(setter)) _pivot3D.show();
		}
		
		// save
		
		public function serialize(dat:* = undefined):Object
		{
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.z = z;
			obj.b = _bytes;
			obj.n = layerUI.layerName;
			return obj;
		}
		
		public function deserialize(obj:Object):void {
			setBytes(obj.b);
			z = obj.z;
			Scene.INSTANCE.addLayer(this);
			// by this time, layerUI has been set by 'PhotoTools'
			layerUI.layerName = obj.n;
			layerUI.updateNumTextFromLayer();
		}
		
		//
		
		static public function ComplexPlane(bmpDataTable:Array2D, originalBmpSize:Point):Array2D {
			
			var posY:Number = 0.5 - 1 / originalBmpSize.y;
			
			for (var j:uint = 0; j < bmpDataTable.height; ++j) {
				
				var posX:Number = - 0.5 + 1 / originalBmpSize.x;
				
				for (var i:uint = 0; i < bmpDataTable.width; ++i) {
					
					const pair:Pair = bmpDataTable.get(i, j);
					const bmpData:BitmapData = pair.key; // bitmapData
					const uvData:Point = pair.value;
					
					const planeSizeX:Number = (bmpData.width * uvData.x - 1) / originalBmpSize.x;
					const planeSizeY:Number = (bmpData.height * uvData.y - 1) / originalBmpSize.y; // normally the same for every row!!!
					
					const texture:Texture3D = new Texture3D( bmpData );
					texture.mipMode = Texture3D.MIP_NONE; // NOTE : more seams with "better" modes
					texture.filterMode = Texture3D.FILTER_LINEAR;
					const textureMap:TextureMapFilter = new TextureMapFilter( texture );
					CONFIG::newFlare { texture.releaseBitmapData = true; }
					
					const fuckMask:Vector.<Number> = new Vector.<Number>;
					fuckMask.push(0.5);
					textureMap.params.mask.value = fuckMask;
					
					// AlphaMaskFilter is shit, use TextureMapFilter "mask" param instead, cool no?
//					const material:Shader3D = new Shader3D("", [textureMap, new AlphaMaskFilter(0)], false);
					const material:Shader3D = new Shader3D("", [textureMap], false);
					material.transparent = true;
					material.twoSided = true;
					material.depthWrite = true;
					
					const plane:Plane = new Plane("", planeSizeX, planeSizeY, 1, material, "+xy");
					plane.x = posX + planeSizeX / 2;
					plane.y = posY - planeSizeY / 2;
					plane.castShadows = false;		// } don't do shit anyway
					plane.receiveShadows = false;	// }
					plane.setLayer(Walk3D.LAYER_LAYERS);
					
					posX += planeSizeX - 0 / originalBmpSize.x;
					
					bmpDataTable.set(plane, i, j);
					
					// modify UVs
					if (uvData.x === 1 && uvData.y === 1) continue;
					
					const surface:Surface3D = plane.surfaces[0];
					const uv:int = surface.offset[Surface3D.UV0];
					const vector:Vector.<Number> = surface.vertexVector;
					const length:int = vector.length;
					const sizePerVertex:int = surface.sizePerVertex;
					// UVs are originally either 0 or 1, so that's a quick trick:
					var off:uint;
					for ( var k:uint = 0; k < length; k += sizePerVertex ) {
						off = k + uv; // u
						vector[off] = vector[off] * uvData.x + (1 - vector[off]) / bmpData.width;
						++off; // v
						vector[off] = vector[off] * uvData.y + (1 - vector[off]) / bmpData.height;
					}
					if (surface.vertexBuffer) surface.vertexBuffer.uploadFromVector(vector, 0, length/sizePerVertex);
				}
				
				posY -= planeSizeY - 0 / originalBmpSize.y;
			}
			
			return bmpDataTable; // cheat
		}
		
		static public function NewLayerMaterial():Shader3D {
			const texture:Texture3D = new Texture3D(new BMP_LAYER_DEFAULT().bitmapData);
			texture.mipMode = Texture3D.MIP_NONE;
			texture.filterMode = Texture3D.FILTER_NEAREST;
			const texFilter:TextureMapFilter = new TextureMapFilter(texture);
			// AlphaMaskFilter is shit, use TextureMapFilter "mask" param instead, cool no?
//			const material:Shader3D = new Shader3D("", [texFilter, new AlphaMaskFilter(0)], false);
			const material:Shader3D = new Shader3D("", [texFilter], false);
			material.transparent = true;
			material.twoSided = true;
			material.depthWrite = true;
			return material;
		}
		
		static public function NewLayerPlane(material:Material3D):Mesh3D {
			const plane:Plane = new Plane("", 1, 1, 1, material, "+xy");
			plane.setLayer(Walk3D.LAYER_LAYERS);
			return plane;
		};
	}
}