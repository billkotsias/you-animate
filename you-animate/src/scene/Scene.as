package scene
{
	import fanlib.containers.List;
	import fanlib.event.ObjEvent;
	import fanlib.event.PausableEventDispatcher;
	import fanlib.filters.Color;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.starling.TSprite;
	import fanlib.ui.BrowseLocal;
	import fanlib.utils.Utils;
	import fanlib.utils.js.PreventClose;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.core.ShadowProjector3D;
	import flare.primitives.DebugLight;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.getDefinitionByName;
	
	import scene.action.AbstractMoveAction;
	import scene.action.Action;
	import scene.action.ActionManager;
	import scene.action.Node;
	import scene.action.special.Properties;
	import scene.camera.Camera;
	import scene.camera.anim.AbstractZoomKey;
	import scene.camera.anim.ZoomManager;
	import scene.layers.Layer;
	import scene.serialize.CharsSerializer;
	import scene.serialize.ISerialize;
	import scene.serialize.Serialize;
	import scene.sobjects.InfinitePlane;
	import scene.sobjects.SObject;
	
	import tools.lights.LightsOptions;
	import tools.lights.LightsWindow;
	
	public class Scene extends PausableEventDispatcher
	{
		static public const INITIALIZED:String = "INITIALIZED";
		static public const LAYER_ADDED:String = "LAYER_ADDED";
		static public const LAYER_REMOVED:String = "LAYER_REMOVED";
		static public const TO_BE_CLEARED:String = "SCENE_TO_BE_CLEARED";
		static public const SCENE_OBJECTS_CHANGED:String = "SCENE_OBJECTS_CHANGED";
		static public const CHARACTER_ADDED:String = "CHARACTER_ADDED";
		static public const CHARACTER_TO_BE_REMOVED:String = "CHARACTER_TO_BE_REMOVED";
		static public const CHARACTER_REMOVED_BY_ID:String = "CHARACTER_REMOVED_BY_ID";
		static public const BACKGROUND_CHANGE:String = "BACKGROUND_CHANGE";
		
		static public const INSTANCE:Scene = new Scene();
		/**
		 * Returns only essential methods. Violatable if casted to Scene3D, but don't do it, ASS.
		 * @return IScene3D
		 */
		public var iScene3D:IScene3D;
		public var camera3D:Camera;
		public var viewport:DisplayObject;
		public var viewportHitArea:Sprite;
		public var zoomMan:ZoomManager;
		public var mouseZoom:MouseZoom;
		
		public var lights:LightsWindow;
		private var defaultLight:Light3D;
		private var shadowsLightParent:Pivot3D;
		private var shadowsLight:ShadowProjector3D;
		private var shadowsReceivers:Pivot3D;
		private var postRenderListener:Function;
		
		// save-able
		private const _characters:List = new List();
		private const _crowds:List = new List();
		private const _sobjects:List = new List();
		private const _layers:List = new List();
		private var _background:Back;
		private var _scene3D:Viewer;
		private var _globalScale:Number = 1;
		
		private var fileReference:FileReference;
		private var sceneName:String;
		private var _history:HistoryGlobal = new HistoryGlobal(30);
		
		private var _backCont:TSprite;
		private var _nodesParent:FSprite;
		
		private var _initialized:Boolean;
		
		private var _isSaved:Boolean = true;
		
		public function Scene() {
		}

		public function whenInitialized(func:Function):void {
			if (_initialized) {
				func();
			} else {
				addEventListener(INITIALIZED, function(e:Event):void {
					removeEventListener(INITIALIZED, arguments.callee); // without 'this', 'removeEventListener' works FINE!!!
					func();
				});
			}
		}
		
		/**
		 * 
		 * @param scene3D
		 * @param backCont
		 * @param nodesParent
		 * @param viewport
		 * @param viewportHitArea
		 * @param zoomMan
		 * 
		 */
		public function init(scene3D:Viewer, backCont:TSprite, nodesParent:FSprite, viewport:DisplayObject, viewportHitArea:Sprite,
							 zoomMan:ZoomManager, mouseZoom:MouseZoom, lights:LightsWindow):void {
			// 3D
			_scene3D = scene3D;
			iScene3D = scene3D;
			camera3D = scene3D.camera as Camera;
			camera3D.addEventListener(Camera.ZOOM_2D_CHANGED, zoom2DChanged);
			this.viewport = viewport;
			this.viewportHitArea = viewportHitArea;
			
			this.zoomMan = zoomMan;
			zoomMan.scene = this;
			
			this.mouseZoom = mouseZoom;
			mouseZoom.unpause(undefined);
			
			// lights
			this.lights = lights;
			lights.addEventListener(LightsWindow.LIGHTS_CHANGED, lightsChanged);
			_scene3D.lights.maxPointLights = 1;
			_scene3D.lights.maxDirectionalLights = 1;
			defaultLight = _scene3D.lights.defaultLight;
			shadowsLight = new ShadowProjector3D("",4096,3);
			shadowsLight.setParams(0xffffff, 0, 1, 1, true);
			shadowsLight.near = 0.2;
			shadowsLight.far = 200;
			shadowsLight.filter = 0;
			shadowsLight.depth = 1000; // default 5000
//			const debugLight:DebugLight = new DebugLight(shadowsLight);
//			debugLight.setScale(0.5,0.5,0.5);
//			shadowsLight.addChild(debugLight);
//			shadowsLight.debug = false;
			
			shadowsReceivers = new Pivot3D();
			_scene3D.addChild(shadowsReceivers);
			
			shadowsLightParent = new Pivot3D();
			shadowsLightParent.y = 0;
			shadowsLightParent.z = shadowsLight.far / 2;
			shadowsLightParent.addChild(shadowsLight);
			shadowsLight.z = -shadowsLightParent.z;
			shadowsReceivers.addChild( shadowsLightParent ); // the only non-shadow-receiver allowed in here!
			
			// Starling
			_backCont = backCont;
			background = new Back();
			// 2D
			_nodesParent = nodesParent;
			
			newScene();
			
			dispatchEvent(new Event(INITIALIZED));
		}
		
		// Industrial Light & Magic
		
		public function addShadowsReceiver(p:Pivot3D):Pivot3D {
			return shadowsReceivers.addChild(p);
		}
		
		private function lightsChanged(o:ObjEvent):void { setLightsOptions( o.getObj() ) }
		private function setLightsOptions(opt:LightsOptions):void {
			if (opt.shadows) {
				_scene3D.lights.defaultLight = null;
				const ambiVector:Vector3D = Color.HEXtoVector3D( opt.ambienceColor );
				_scene3D.lights.ambientColor = ambiVector;
				_scene3D.addChild(shadowsReceivers);
				setShadowParams(opt);
			} else {
				_scene3D.lights.defaultLight = defaultLight;
				_scene3D.lights.ambientColor = Color.HEXtoVector3D( Color.CombineRGBA(59,59,59,0) ); // ambience we are all fused to
				shadowsReceivers.parent = null;
			}
			shadowsLightParent.setRotation(-opt.elevation,opt.direction - 90,0,false);
		}
		private function setShadowParams(opt:LightsOptions):void {
			if (postRenderListener !== null) {
				_scene3D.removeEventListener(Scene3D.POSTRENDER_EVENT, postRenderListener);
				postRenderListener = null;
			}
			const matValue:* = SObject.SHADOWS_ONLY_FILTER.params.color.value;
			if (!matValue) {
				postRenderListener = function(e:Event):void { setShadowParams(opt) };
				_scene3D.addEventListener(Scene3D.POSTRENDER_EVENT, postRenderListener);
				return;
			}
			
			const factor:Number = 0.5 + 0.5 * (1 + opt.elevation/90); // maybe change to 0.6 + 0.4 ("safer", lighter)
			const ambiVector:Vector3D = _scene3D.lights.ambientColor;
			//trace(ambiVector.x, factor/ambiVector.x, opt.elevation);
			matValue[0] = factor/ambiVector.x;
			matValue[1] = factor/ambiVector.y;
			matValue[2] = factor/ambiVector.z;
			matValue[3] = 1;
			// Not even a material "rebuild" is needed. God damn you Ariel for being such a psy.
		}
		
		//
		
		private function zoom2DChanged(e:Event):void {
			_scene3D.addEventListener(Scene3D.RENDER_EVENT, function (e:Event):void {
				_scene3D.removeEventListener(Scene3D.RENDER_EVENT, arguments.callee);
				updateCharPaths();
			});
//			_nodesParent.visible = !camera3D.zoom2DEnabled;
		}
		
		public function addLayer(layer:Layer):void {
			if (_layers.push(layer)) {
				camera3D.addChild(layer.pivot3D);
				dispatchEvent(new ObjEvent(layer, LAYER_ADDED));
			}
		}
		
		public function removeLayer(layer:Layer):void {
			if (_layers.remove(layer)) {
				layer.dispose();
				dispatchEvent(new ObjEvent(layer, LAYER_REMOVED));
			}
		}
		
		public function addSObject(so:SObject):SObject {
			if (_sobjects.push(so)) {
				so.pivot3D.parent = _scene3D;
				dispatchEvent(new ObjEvent(so, SCENE_OBJECTS_CHANGED));
			}
			return so; // convenience
		}
		
		public function removeSObject(so:SObject):void {
			if (_sobjects.remove(so)) {
				so.dispose();
				dispatchEvent(new ObjEvent(so, SCENE_OBJECTS_CHANGED));
			}
		}
		
		public function addCrowd(crowd:Crowd):void {
			crowd.setParents(_scene3D, _nodesParent);
			_crowds.push(crowd);
		}
		
		public function removeCrowd(crowd:Crowd):void {
			if (_crowds.remove(crowd)) {
				crowd.dispose();
			}
		}
		public function removeCrowdByID(crowdID:String):void {
			removeCrowd( crowds.getByValue("id", crowdID) );
		}
		
		public function addCharacter(info:CharacterInfo):Character {
			const char:Character = CharManager.INSTANCE.requestCharacter(info, _scene3D, _scene3D, _nodesParent);
			char.setScale(_globalScale);
			_characters.push(char);
			char.addEventListener(ActionManager.CHANGE, charChanged, false, 0, true);
			dispatchEvent(new ObjEvent(char, CHARACTER_ADDED));
			dispatchEvent(new ObjEvent(char, SCENE_OBJECTS_CHANGED));
			return char;
		}
		private function charChanged(e:Event):void {
			dispatchEvent(new ObjEvent(e.target, SCENE_OBJECTS_CHANGED));
		}
		
		public function removeCharacterByID(id:String):void {
			removeCharacter( _characters.getByValue( "id", id ) );
			dispatchEvent( new ObjEvent( id, CHARACTER_REMOVED_BY_ID ) );
		}
		
		public function removeCharacter(char:Character):void {
			if (_characters.remove(char)) {
				dispatchEvent(new ObjEvent(char, CHARACTER_TO_BE_REMOVED));
				char.dispose();
				CharManager.INSTANCE.forgetCharacter(char);
				dispatchEvent(new ObjEvent(char, SCENE_OBJECTS_CHANGED));
			}
		}
		
		public function forEachNode(func:Function):void {
			characters.forEach(function (char:Character):void {
				char.forEachNode(func);
			});
		}
		
		public function forEachAction(_class:Class, func:Function):void {
			characters.forEach(function (char:Character):void {
				char.forEachAction(_class, func);
			});
		}
		
		// TODO : update and redraw only selected Character. Will then have to do it for every re-selection, of course.
		// NOTE : After doing Crowd, I saw what an idiot I have been with Character in general. What an as-ole.
		public function updateCharPaths():void {
			characters.forEach(function (char:Character):void {
				char.forEachNode(function (node:Node):void { node.update2D() });
				char.forEachAction(AbstractMoveAction, function (action:AbstractMoveAction):void { action.drawPath(0, int.MAX_VALUE) });
			});
			crowds.forEach(function (crowd:Crowd):void {
				crowd.forEachNode(function (node:Node):void { node.update2D() });
			});
		}
		
		public function set background(back:Back):void {
			if (_background) _background.removeFromParent(true);
			_background = back;
			_backCont.addChild(_background);
			mouseZoom.reset();
			camera3D.setZoom2D2(0,0,1);
		}
		public function get background():Back { return _background }
		public function get sobjects():List { return _sobjects }
		public function get characters():List { return _characters }
		public function get crowds():List { return _crowds }
		public function get layers():List { return _layers }
		public function get history():HistoryGlobal { return _history }

		public function add2DOverlay(obj:DisplayObject):void {
			_nodesParent.addChild(obj);
		}
		
		public function get globalScale():Number { return _globalScale; } 
		public function set globalScale(value:Number):void {
			_globalScale = value;
			_characters.forEach(function(char:Character):void {
				char.setScale(_globalScale);
			});
		}
		
		// save/load
		
		/**
		 * Clear Scene. <i>TO_BE_CLEARED</i> is dispatched before clearance.
		 */
		public function clear():void
		{	
			dispatchEvent(new Event(TO_BE_CLEARED));
			
			eventsPauser.pause( clear /* function! */ );
			_characters.forEach(removeCharacter);
			_sobjects.forEach(removeSObject);
			_crowds.forEach(removeCrowd);
			eventsPauser.unpause(clear);
			dispatchEvent(new ObjEvent(null, SCENE_OBJECTS_CHANGED)); // a single Event for all removed
			
			_layers.forEach(removeLayer); // an Event for EACH layer removed
			
			zoomMan.removeAll();
			_background.fileName = null;
			_background.setBytes(null, false);
			lights.reset();
		}
		
		public function newScene():void {
			_history.reset(); // preserve any history made in "clear" (none?)
			clear();
			camera3D.setZoom2D2(0,0,1);
			
			// default stuff
			sceneName = "scene.wd3";
			addSObject(new InfinitePlane()).setPosition(NaN, NaN, InfinitePlane.DEFAULT_Z);
		}
		
		/**
		 * Save Scene
		 */
		public function save():void {
			const arr:Array = [];
			
			// Back
			arr.push(_background.serialize());
			
			// Camera
			arr.push((_scene3D.camera as Camera).serialize());
			
			// SObjects - NOTE : MUST COME BEFORE Characters (because of '_sobjects')
			_sobjects.forEach(function(so:SObject):void {
				arr.push(so.serialize());
			});
			
			// Characters
			const sobjectsArray:Array = _sobjects.toArray();
			arr.push(new CharsSerializer().serialize([_characters, sobjectsArray]));
			
			// Crowds
			crowds.forEach(function(crowd:Crowd):void {
				arr.push( crowd.serialize(sobjectsArray) );
			});
			
			// Layers
			_layers.forEach(function(l:Layer):void {
				arr.push(l.serialize());
			});
			
			// ZoomAnims
			zoomMan.forEachKey(function(key:AbstractZoomKey):void {
				arr.push(key.serialize()); // NOTE : characters will be needed to register char ID for each ZoomTracking
			});
			
			// Lights
			arr.push( lights.options.serialize() );
			
			// save bytes
			const bytes:ByteArray = new ByteArray();
			bytes.writeObject(arr);
			bytes.compress(CompressionAlgorithm.ZLIB);
			fileReference = new FileReference();
			fileReference.addEventListener(Event.COMPLETE, fileRefComplete);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileRefError);
			fileReference.save(bytes, sceneName);
		}
		private function fileRefComplete(e:Event):void {
			sceneName = fileReference.name;
			fileReference = null;
			isSaved = true;
		}
		private function fileRefError(e:IOErrorEvent):void {
			fileReference = null;
		}
		
		// load new scene
		
		public function load():void {
			new BrowseLocal(null, loadBytes, fileSelected);
		}
		public function fileSelected(fileRef:FileReference):void {
			sceneName = fileRef.name;
		}
		public function loadBytes(bytes:ByteArray):void {
			clear();
			_history.reset(); // DON'T preserve any history made in "clear"
			
			bytes.uncompress(CompressionAlgorithm.ZLIB);
			const arr:Array = Serialize.FromByteArray(bytes) as Array;
			for (var i:int = 0; i < arr.length; ++i) {
				const obj:Object = arr[i];
				try {
					var deserialized:ISerialize = new (Class(getDefinitionByName(obj.t)));
					deserialized.deserialize(obj);
				} catch (e:Error) { trace(e,e.getStackTrace()) }
			}
			
			// -- UNDO
			// set initial state for all characters in scene
			characters.forEach(function(char:Character):void {
				history.newStateList( char.id, char.getHistoryState() );
			});
			// UNDO --
			
			isSaved = true;
		}

		// check if saved
		
		public function get isSaved():Boolean { return _isSaved }
		public function set isSaved(value:Boolean):void {
			if (_isSaved === value) return;
			
			_isSaved = value;
			if (value) {
				PreventClose.Show(null);
			} else {
				PreventClose.Show(Walk3D.LEXICON.getCurrentRef("preventClose"));
			}
		}

	}
}