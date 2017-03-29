package scene.camera.anim
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.math.Maths;
	import fanlib.utils.FArray;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import scene.HistoryState;
	import scene.Scene;
	import scene.camera.Camera;
	
	public class ZoomManager extends FSprite
	{
		static public const ROUND_TO:Number = 0.01;
		static public const ROUND_TO_HALF:Number = ROUND_TO/2;
		
		static public const ZOOM_KEY_ADDED:String = "ZOOM_KEY_ADDED";
		static public const ZOOM_KEY_REMOVED:String = "ZOOM_KEY_REMOVED";
		static public const ZOOM_KEY_ALL_REMOVED:String = "ZOOM_KEY_ALL_REMOVED";
		
		public var viewport:FSprite;
		
		private const keys:Array = [];
		private const rect:Rectangle = new Rectangle();
		private var timeDiff:Number;
		
		private var curKeyIndex:int = -1;
		private var curTime:Number;
		
		private var _scene:Scene;
		
		public function ZoomManager() {
			super();
		}
		
		public function update():void {
			setTime(curTime);
		}
		
		public function setTime(time:Number):void {
			curTime = time;
			curKeyIndex = keys.length;
			while (--curKeyIndex >= 1) {
				if (time >= (keys[curKeyIndex] as AbstractZoomKey).time) {
					break;
				}
			}
			updateZoomRect();
		}
		
		public function updateZoomRect():void {
			// TODO : support much, much more
			// current key (curKey) is 'ZoomSpot'
			if (curKeyIndex < 0) {
				// no keys
				graphics.clear();
				return;
			} else {
				
				const vRect:Rectangle = _scene.viewport.getRect(Stg.Get());
				const curKey:ZoomSpot = keys[curKeyIndex];
				timeDiff = curTime - curKey.time;
				if (curKeyIndex === keys.length-1) {
					
//					rect.x = curKey.x;
//					rect.y = curKey.y;
					rect.width = vRect.width / curKey.zoom;
					rect.height = vRect.height / curKey.zoom;
					rect.x = vRect.x + vRect.width/2 + curKey.x * vRect.width - rect.width/2;
					rect.y = vRect.y + vRect.height/2 + curKey.y * vRect.height - rect.height/2;
					
				} else {
					
					const nextKey:ZoomSpot = keys[curKeyIndex+1];
					var factor:Number = timeDiff / (nextKey.time - curKey.time);
					if (factor < 0) {
						factor = 0;
						timeDiff = - timeDiff; // make positive (absolute)
					}
					const zoom:Number = Maths.LERP(curKey.zoom, nextKey.zoom, Math.pow(factor, Math.LOG2E));
					rect.width = vRect.width / zoom;
					rect.height = vRect.height / zoom;
					rect.x = Maths.LERP(curKey.x, nextKey.x, factor);
					rect.y = Maths.LERP(curKey.y, nextKey.y, factor);
					rect.x = vRect.x + vRect.width/2 + rect.x * vRect.width - rect.width/2;
					rect.y = vRect.y + vRect.height/2 + rect.y * vRect.height - rect.height/2;
					
					// NOTE : 'timeDiff' meaning changed!
					const timeDiff2:Number = nextKey.time - curTime;
					if (timeDiff > timeDiff2) timeDiff = timeDiff2;
				}
			}
			
			_scene.camera3D.setZoom2D(rect.x + rect.width/2, rect.y + rect.height / 2, rect.width);
			updateGraphics();
		}
		
		public function updateGraphics(e:* = undefined):void {
			graphics.clear();
			if (!_scene.camera3D.zoom2DEnabled) {
				// NOTE : 'ROUND_TO_HALF' works because numbers are already 'ROUND_TO'
				// cause they are read from the NumTextDrag...
//				const vRect:Rectangle = _scene.viewport.getRect(Stg.Get());
				const color:uint = (timeDiff <= ROUND_TO_HALF) ? 0xff0000 : 0xbbbbbb;
//				graphics.beginFill(0, 0.4);
//				graphics.drawRect(vRect.x, vRect.y, vRect.width, vRect.height);
				graphics.lineStyle(0.5, color, 0.85);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
//				graphics.endFill();
			}
		}

		public function addKey(key:AbstractZoomKey):void {
			var old:AbstractZoomKey;
			if (Boolean(old = checkIfKeyExists(key, true))) {
				removeKey(old);
			}
			keys.push(key);
			sortZoomKeys();
			
			curTime = key.time;
			curKeyIndex = keys.indexOf(key);
			updateZoomRect();
			dispatchEvent(new ObjEvent(key, ZOOM_KEY_ADDED));
		}
		
		public function checkIfKeyExists(key:AbstractZoomKey, checkClass:Boolean):AbstractZoomKey {
			const keyRounded:Number = Maths.roundTo(key.time, ROUND_TO);
			for each (var old:AbstractZoomKey in keys) {
//				trace(key.time, old.time, "-", keyRounded, Maths.roundTo(old.time, ROUND_TO));
				if (Maths.roundTo(old.time, ROUND_TO) === keyRounded) {
					break;
				}
				old = null;
			}
			if (old) {
				if (checkClass) {
					if (getQualifiedClassName(key) === getQualifiedClassName(old)) return old;
					return null;
				} else {
					return old;
				}
			}
			return null;
		}
		
		public function removeKey(key:AbstractZoomKey):void {
			FArray.Remove(keys, key, true);
			dispatchEvent(new ObjEvent(key, ZOOM_KEY_REMOVED));
		}
		
		public function removeAll():void {
			keys.length = 0;
			dispatchEvent(new Event(ZOOM_KEY_ALL_REMOVED));
		}
		
		public function sortZoomKeys():void {
			keys.sortOn("time", Array.NUMERIC);
		}
		
		public function forEachKey(func:Function):void {
			for (var i:int = 0; i < keys.length; ++i) {
				func(keys[i]);
			}
		}

		public function set scene(value:Scene):void
		{
			_scene = value;
			_scene.whenInitialized(function():void {
				_scene.camera3D.addEventListener(Camera.ZOOM_2D_CHANGED, updateGraphics);
			});
		}

		// UNDO
		public function getHistoryState():HistoryState {
			const serialKeys:Array = [];
			forEachKey(function(key:AbstractZoomKey):void {
				serialKeys.push(key.serialize()); // NOTE : characters will be needed to register char ID for each ZoomTracking
			});
			
			return new HistoryState(function():void {
				removeAll();
				for (var i:int = 0; i < serialKeys.length; ++i) {
					const obj:Object = serialKeys[i];
					const key:AbstractZoomKey = new (Class(getDefinitionByName(obj.t)));
					key.deserialize( obj );
				}
			});
		}
	}
}