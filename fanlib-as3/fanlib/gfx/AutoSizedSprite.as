package fanlib.gfx {
	
	import fanlib.utils.IChange;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class AutoSizedSprite extends TSprite {

		public var disableResize:Boolean = false;
		public var keepAspectRatio:Boolean = false;
		public var crop:Boolean = true; // respect aspect ratio by cropping image or having borders?
		
		private var _scale:Number = 1;
		public function set scale(s:Number):void {
			_scale = s;
			stageResized();
		}
		public function get scale():Number { return _scale; }
		
		public function AutoSizedSprite() {
		}
		
		override public function childChanged(obj:IChange):void {
			stageResized();
			super.childChanged(obj);
		}

		protected function addedToStage(e:Event = null):void {
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
			Stg.Get().addEventListener(Event.RESIZE, stageResized);
			stageResized();
		}

		private function removedFromStage(e:Event):void {
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			
			Stg.Get().removeEventListener(Event.RESIZE, stageResized);
		}
		
		public function stageResized(e:* = undefined):void {
			if (parent == null) return; // in case it's called externally
			if (disableResize) return;
			
			// set to fullscreen
			// TODO : allow other types of resizing
			var p:Point = new Point();
			
			// is this correct?
/*			p.x = _stage.stageWidth;
			p.y = _stage.stageHeight;
			p = this.parent.globalToLocal(p);
			this.width = p.x;
			this.height = p.y;*/
			this.width = Stg.Get().stageWidth;
			this.height = Stg.Get().stageHeight;
			
			if (keepAspectRatio) {
				
				var newScale:Number;
				if (crop) {
					newScale = Math.max(scaleX, scaleY);
				} else {
					newScale = Math.min(scaleX, scaleY);
				}
				scaleX = newScale * _scale;
				scaleY = newScale * _scale;
				
				// center to screen
				x = (Stg.Get().stageWidth - width) / 2;
				y = (Stg.Get().stageHeight - height) / 2;
				//trace(this,name,getScale(),getPos(),new Error().getStackTrace());
				
			} else {
				
				p.x = - Stg.Get().x; // ????
				p.y = - Stg.Get().y;
				p = this.parent.globalToLocal(p);
				this.x = p.x;
				this.y = p.y;
			}
		}
		
		// create copy : usefull for templates
		override public function copy(baseClass:Class = null):* {
			var obj:* = super.copy(baseClass);
			obj.keepAspectRatio = this.keepAspectRatio;
			obj.crop = this.crop;
			obj.disableResize = this.disableResize;
			obj.scale = this._scale;
			return obj;
		}
		
	}
	
}
