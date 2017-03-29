package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.text.FTextField;
	import fanlib.tween.TVector1;
	import fanlib.ui.slider.Slider;
	import fanlib.utils.Enum;
	import fanlib.utils.FStr;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	
	import scene.CharManager;
	import scene.Character;
	import scene.Scene;
	import scene.action.Action;
	import scene.action.ActionInfo;
	import scene.action.special.PropInfo;
	
	import tools.CheckButtonTool;
	
	import upload.server.AnimInfo;
	
	public class Animline extends Slider
	{
		static public const MOVING_LOOPS:Number = 4;
		
		public var text:FTextField;
		
		private var _duration:Number = 0;
		private var _time:Number;
		private var currentFrame:Number = 0;
		private var lastFrame:uint;
		private var totalRate:Number;
		private var actionInfo:ActionInfo;
		
		private var speed:Number;
		private var moveLength:Number;
		
		private var _charEdit:CharEdit;
		internal var animPlay:AnimPlay;
		
		public function Animline()
		{
			super();
		}
		
		override public function set value(val:Number):void {
			super.value = val;
			_time = _value * _duration;
			updateText();
			
			if (_charEdit) {
				
				if (actionInfo) {
					
					var loopType:Enum = Action.STOP;
					if (speed) {
						_charEdit.setPosition(0,0, moveLength - _time * speed);
						loopType = Action.LOOP;
					}
					currentFrame = Action.CalcLinearFrame(_time, actionInfo.from, actionInfo.to, loopType, actionInfo.rate);
					
				} else {
					currentFrame = Action.CalcLinearFrame(_time, 0, lastFrame, Action.STOP, totalRate);
				}
				
				_charEdit.gotoAndStop(currentFrame);
//				trace(value,_time,currentFrame);
				
			}
		}
		
		public function set charEdit(ce:CharEdit):void {
			if (_charEdit) _charEdit.removeEventListener(CharEdit.CURRENT_ANIMATION_CHANGED, animChanged);
			_charEdit = ce;
			_charEdit.addEventListener(CharEdit.CURRENT_ANIMATION_CHANGED, animChanged, false, 0, true);
			_charEdit.addEventListener(CharEdit.MODEL_CHANGED, modelChanged, false, 0, true);
			modelChanged();
		}
		private function modelChanged(e:Event = null):void {
			totalRate = lastFrame = 0;
			for each (var mesh:Mesh3D in _charEdit.getChildrenByClass(Mesh3D)) {
				if (!mesh.frames) continue;
				
				var frNum:uint = mesh.frames.length - 1;
				if (frNum > lastFrame) lastFrame = frNum;
				
				var frSpeed:Number = mesh.frameSpeed * 60;
				if (totalRate < frSpeed) totalRate = frSpeed; 
			}
			animChanged();
		}
		private function animChanged(e:Event = null):void {
			const currentAnimObj:AnimInfo = _charEdit.currentAnimation;
			_charEdit.setPosition(0,0,0);
			
			var propInfo:PropInfo;
			if (currentAnimObj && (propInfo = CharManager.INSTANCE.getPropInfoByID(currentAnimObj.prop)) && propInfo.data.type === "vehicleData") {
				
				actionInfo = new ActionInfo(currentAnimObj);
				_duration = (actionInfo.to - actionInfo.from + 1) / actionInfo.rate;
				speed = 0;
				
			} else if (currentAnimObj) {
				
				actionInfo = new ActionInfo(currentAnimObj);
				const numFrames:Number = actionInfo.to - actionInfo.from + 1;
				_duration = numFrames / actionInfo.rate;
				speed = actionInfo.speed;
				if (speed) {
					_duration *= MOVING_LOOPS;
					moveLength = speed * _duration / 2; // half the length the character will travel (also, starting point!)
				}
				
			} else {
				
				actionInfo = null;
				_duration = lastFrame / totalRate;
			}
			animPlay.selected = false;
			time = 0;
			updateText();
		}
		
		public function updateText():void {
			text.htmlText = currentFrame.toFixed(2) + 'f'; //  + _durationTotal.toFixed(2) + 's';
		}
		
		public function get durationTotal():Number
		{
			return _duration;
		}
		
		public function get time():Number { return _time }
		public function set time(t:Number):void {
			value = t / _duration;
		}
		
		// tweening
		public function getValue():TVector1 { return new TVector1(_value) }
		public function setValue(t:TVector1):void { value = t.x }
	}
}