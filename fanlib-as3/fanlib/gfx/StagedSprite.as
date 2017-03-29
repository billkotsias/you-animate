package fanlib.gfx {
	
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TVector2;
	import fanlib.utils.IChange;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	// a 'TSprite' that is automatically stage-aligned
	public class StagedSprite extends TSprite {
		
		private var sax:Number = 0;
		private var say:Number = 0;
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		
		private var _boundAlignx:Boolean = true; // automatically adjust to stage x bounds
		private var _boundAligny:Boolean = true; // automatically adjust to stage y bounds
		
		public function StagedSprite() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		protected function addedToStage(e:Event = null):void {
			Stg.Get().addEventListener(Event.RESIZE, stageResized, false, 0, true);
			stageResized();
		}
		protected function removedFromStage(e:Event = null):void {
			Stg.Get().removeEventListener(Event.RESIZE, stageResized);
		}
		
		public function get stageX():Number { return _x; }
		public function get stageY():Number { return _y; }
		public function set stageX(n:Number):void { _x = n; stageAlign(null, "x"); }
		public function set stageY(n:Number):void { _y = n; stageAlign(null, "y"); }
		
		public function getStagePos():ITweenedData {
			return new TVector2(stageX, stageY);
		}
		
		public function setStagePos(_pos:ITweenedData):void {
			var pos:TVector2 = (_pos as TVector2);
			stageX = pos.x;
			stageY = pos.y;
		}
		
		public function set boundAlignX(b:Boolean):void {
			_boundAlignx = b;
			stageAlign(null, "x");
		}
		public function set boundAlignY(b:Boolean):void {
			_boundAligny = b;
			stageAlign(null, "y");
		}

		public function stageResized(e:* = undefined):void {
			stageAlign(null, "x");
			stageAlign(null, "y");
		}
		
		//public function get stageAlignX():String { return sax; }
		//public function get stageAlignY():String { return say; }
		
		public function set stageAlignX(a:String):void {
			stageAlign(a, "x");
		}
		
		public function set stageAlignY(a:String):void {
			stageAlign(a, "y");
		}
		
		private function stageAlign(a:String, v:String):void {
			if (a != null) {
				if (isNaN(Number(a))) {
					switch (a) {
						case Align.ALIGN_LEFT:
						case Align.ALIGN_TOP:
							this["sa"+v] = 0;
							break;
						case Align.ALIGN_CENTER:
							this["sa"+v] = 0.5;
							break;
						case Align.ALIGN_RIGHT:
						case Align.ALIGN_BOTTOM:
							this["sa"+v] = 1;
							break;
					}
				} else {
					this["sa"+v] = Number(a);
				}
			}
			if (stage == null) return;

			var rect:Rectangle;
			
			if (this["_boundAlign"+v]) {
				rect = this.getRect(this); // get local bounds, since aligning is "aggressive"
			} else {
				rect = new Rectangle();
			}
			
			var stageDim:Number;
			var rectDim:Number;
			if (v == "x") {
				stageDim = Stg.Width();
				rectDim = rect.width;
			} else if (v == "y") {
				stageDim = Stg.Height();
				rectDim = rect.height;
			}
			
			var p:Point = new Point();
			p[v] = stageDim * this["sa"+v] + this["_"+v];
			p = this.parent.globalToLocal(p);
			this[v] = p[v] - rect[v] - rectDim * this["sa"+v];
			
			super.childChanged(this);
		}
		
		// track children changes
		override public function childChanged(obj:IChange):void {
			var temp:Boolean = trackChanges;
			trackChanges = false;
			stageResized();
			trackChanges = temp;
			
			super.childChanged(obj);
		}
	}
	
}
