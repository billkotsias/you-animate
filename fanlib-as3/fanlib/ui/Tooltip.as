package fanlib.ui
{
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.text.FTextField;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.IInit;
	import fanlib.utils.Pausable;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class Tooltip extends TSprite implements IInit
	{
		static public const INSTANCES:Object = {};
		static public var DefaultTooltipName:String;
		
		// internals
		private var currentTool:IToolTip;
		private var paused:Pausable = new Pausable();
		private var delayed:DelayedCall = new DelayedCall();
		
		// children
		public var text:FTextField;
		
		// variables
		private const _position:Vector.<Number> = new Vector.<Number>; // position relative to tool's "Rect"
		private const _offset:Vector.<Number> = new Vector.<Number>; // extra pixels offset
		public var timeToShow:Number = 0.5;
		
		public function Tooltip()
		{
			super();
			_position.push(1,0); // default 
			_offset.push(10,0); // default 
		}
		
		override public function set name(value:String):void {
			if (INSTANCES[name] === this) delete INSTANCES[name]; // in case it's changed
			super.name = value;
			INSTANCES[name] = this;
		}
		
		public function initLast():void {
			assignChildren = "text";
			parent = null;
		}
		
		public function disable(pauser:*):void {
			paused.pause(pauser);
			show(false);
		}
		
		public function enable(pauser:*):void {
			if (!paused.unpause(pauser)) {
				if (text.text) show(true); // show immediately, since there's something to show
			}
		}
		
		public function register(obj:IToolTip):void {
			obj.addEventListener(MouseEvent.MOUSE_OVER, mOver, false, 0, true);
			obj.addEventListener(MouseEvent.MOUSE_OUT, mOut, false, 0, true);
		}
		
		public function unregister(obj:IToolTip):void {
			obj.removeEventListener(MouseEvent.MOUSE_OVER, mOver);
			obj.removeEventListener(MouseEvent.MOUSE_OUT, mOut);
		}
		
		private function mOver(e:MouseEvent):void {
			currentTool = e.currentTarget as IToolTip;
			if (!paused.paused) {
				delayed.dismiss();
				delayed = new DelayedCall(show, timeToShow, true);
			}
		}
		
		private function mOut(e:MouseEvent):void {
			if (currentTool !== e.currentTarget) return;
			currentTool = null;
			delayed.dismiss();
			show(false);
		}
		
		public function setText(string:String):void {
			text.htmlText = string;
		}
		public function clearText():void {
			text.htmlText = "";
		}
		
		public function show(v:Boolean):void {
			const tip:String = (currentTool) ? currentTool.tip : null;
			
			if (v && tip) {
				const stg:Stage = Stg.Get();
				stg.addChild(this);
				setText(tip);
				
				const pos:Vector.<Number> = this._position.concat();
				const off:Vector.<Number> = this._offset.concat();
				const dobj:DisplayObject = currentTool as DisplayObject;
				const dobjRect:Rectangle = dobj.getRect(stg);
				setAbsolutePosition(dobjRect, pos[0], pos[1], off[0], off[1]);
				
				// don't go off-screen; take over full control!
				var resetPos:Boolean;
				if (x < 0) {
					pos[0] = 1;
					off[0] = Math.abs(off[0]);
					resetPos = true;
				} else if  (x + width >= stg.stageWidth) {
					pos[0] = 0;
					off[0] = - Math.abs(off[0]);
					resetPos = true;
				}
				if (y < 0) {
					pos[1] = 1;
					off[1] = Math.abs(off[1]);
					resetPos = true;
				} else if (y + height >= stg.stageHeight) {
					pos[1] = 0;
					off[1] = - Math.abs(off[1]);
					resetPos = true;
				}	
				if (resetPos) setAbsolutePosition(dobjRect, pos[0], pos[1], off[0], off[1]);
				
			} else {
				parent = null;
				clearText();
			}
		}
		
		private function setAbsolutePosition(dobjRect:Rectangle, posX:Number, posY:Number, offX:Number, offY:Number):void {
			x = dobjRect.x + dobjRect.width * posX - width * (1 - posX) + offX;
			y = dobjRect.y + dobjRect.height * posY - height * (1 - posY) + offY;
		}

		// getters & setters
		public function set offset(value:Array):void {
			for (var i:* in value) _offset[i] = value[i];
		}

		public function set position(value:Array):void {
			for (var i:* in value) _position[i] = value[i];
		}
	}
}