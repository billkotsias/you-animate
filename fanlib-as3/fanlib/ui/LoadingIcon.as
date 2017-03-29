package fanlib.ui {
	
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Align;
	import fanlib.gfx.TBitmap;
	import fanlib.gfx.TSprite;
	import fanlib.io.MLoader;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class LoadingIcon extends TSprite {

		static public const ICON_LOADING_SPEED:Number = 1;
		
		static private const EVENTS:EventDispatcher = new EventDispatcher();
		static private var Data:BitmapData;
		
		static public function SetBitmapDataFile(file:String):void {
			new MLoader(file, function (l:MLoader):void { SetBitmapData(l.files[0].bitmapData); });
		}
		static public function SetBitmapData(data:BitmapData):void {
			Data = data;
			EVENTS.dispatchEvent(new Event(Event.CHANGE));
		}
		
		static private const Instances:Dictionary = new Dictionary(true);
		static public function Create(owner:*):LoadingIcon {
			Kill(owner);
			var loading:LoadingIcon = new LoadingIcon(Private.PRIVE);
			Instances[owner] = loading;
			return loading;
		}
		static public function Kill(owner:*):void {
			var loading:LoadingIcon = Instances[owner];
			if (!loading) return;
			loading.kill();
			delete Instances[owner];
		}
		
		// static
		
		private const iconAnim:TList = new TList();
		private const bmp:TBitmap = new TBitmap(null, Align.CENTER, Align.CENTER);
		
		// can't touch me!
		public function LoadingIcon(prive:Private) {
			invisible();
			bmp.bitmapData = Data;
			addChild(bmp);
			EVENTS.addEventListener(Event.CHANGE, dataChanged, false, 0, true);
			iconAnim.addEventListener(TList.TLIST_COMPLETE, addIconAnim, false, 0, true);
		}
		private function dataChanged(e:Event):void {
			bmp.bitmapData = Data;
		}
		
		private function addIconAnim(e:Event = null):void {
			rotation %= 360;
			iconAnim.add(new TLinear(new TVector1(rotation + 360), getRot, setRot, ICON_LOADING_SPEED));
			TPlayer.DEFAULT.addPlaylist(iconAnim);
		}

		public function show():LoadingIcon {
			addIconAnim();
			fadein(0.5, 0, true);
			return this;
		}
		
		private function kill():void {
			fadeout(0.5, 0).addEventListener(TList.TLIST_COMPLETE, kill2, false, 0, true);
		}
		private function kill2(e:ObjEvent):void {
			(e.getObj() as TList).removeEventListener(TList.TLIST_COMPLETE, kill2);
			EVENTS.removeEventListener(Event.CHANGE, dataChanged);
			iconAnim.removeEventListener(TList.TLIST_COMPLETE, addIconAnim);
			parent = null;
		}
	}
	
}

class Private {
	static public const PRIVE:Private = new Private();
}