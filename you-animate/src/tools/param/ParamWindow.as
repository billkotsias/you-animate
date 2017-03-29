package tools.param
{
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.utils.Utils;
	
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import scene.IParam;
	
	import ui.BasicWindow;
	import ui.LabelInput;
	
	public class ParamWindow extends BasicWindow
	{
		static private const ParamsToWindow:Dictionary = new Dictionary();
		static public const Y_SPACE:Number = 40;
		
		private const inputs:Array = [];
		private const defaults:Array = [];
		private var _iParamObj:IParam;
		
		public function ParamWindow()
		{
			super();
		}
		
		public function set iParamObj(i:IParam):void {
			_iParamObj = i;
			(findChild("title") as FTextField).htmlText = _iParamObj.paramsTitle;
			updateInputs();
			updateDefaults();
		}
		
		private function updateInputs():void {
			for each (var input:FTextField in inputs) {
				input.htmlText = _iParamObj[input.name];
			}
		}
		
		private function updateDefaults():void {
			for each (var value:FTextField in defaults) {
				value.htmlText = _iParamObj[value.name];
			}
		}
		
		private function inputKeyDown(e:KeyboardEvent):void {
			if (e.keyCode === 13) setParam(e.currentTarget as FTextField);
		}
		private function inputUnfocus(e:FocusEvent):void {
			setParam(e.currentTarget as FTextField);
		}
		
		private function setParam(input:FTextField):void {
			_iParamObj[input.name] = input.text;
			updateInputs();
		}
		
		// static
		
		static public function GetWindow(params:Vector.<Param>):ParamWindow {
			return Utils.GetGuaranteedByFunction(ParamsToWindow, params, NewWindow, params);
		}
		
		static private function NewWindow(params:Vector.<Param>):ParamWindow {
			const window:ParamWindow = FSprite.FromTemplate("paramWindow") as ParamWindow;
			const vars:FSprite = window.findChild("vars");
			const defs:FSprite = window.findChild("defs");
			vars.trackChanges = false;
			defs.trackChanges = false;
			
			var yy:Number = 0;
			var tabIndex:int = 1;
			for (var i:int = 0; i < params.length; ++i) {
				const param:Param = params[i];
				// get/set parameter
				if (param.getSetName) {
					const getSet:LabelInput = FSprite.FromTemplate("labelInput") as LabelInput;
					const input:FTextField = getSet.getChildByName("input") as FTextField;
					getSet.tip = "param" + (input.name = getSet.label = param.getSetName);
					getSet.y = yy;
					vars.addChild(getSet);
					
					// listen to input
					input.addEventListener(KeyboardEvent.KEY_DOWN, window.inputKeyDown, false, 0, true);
					input.addEventListener(FocusEvent.FOCUS_OUT, window.inputUnfocus, false, 0, true);
					input.tabIndex = tabIndex++; // OK, Flash rocks here, have to admit once in a while, does good to moral
					window.inputs.push(input); // easy access
				}
				// get default
				if (param.defaultGetName) {
					const defGet:LabelInput = FSprite.FromTemplate("defaultParam") as LabelInput;
					defGet.tip = null;
					defGet.y = yy;
					defs.addChild(defGet);
					const defValue:FTextField = defGet.getChildByName("input") as FTextField;
					defValue.name = param.defaultGetName;
					window.defaults.push(defValue);
				}
				yy += Y_SPACE;
			}
			
			vars.trackChanges = true;
			defs.trackChanges = true;
			vars.childChanged(vars);
			defs.childChanged(defs);
			return window;
		}
	}
}