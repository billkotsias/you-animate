package fanlib.fx.emitters
{
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TList;
	import fanlib.tween.TVector2;
	import fanlib.utils.ICopy;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public interface IParticle extends ICopy
	{
		function getPos():TVector2;
		function setPos(_pos:ITweenedData):void;
		function getScale():ITweenedData;
		function setScale(_scl:ITweenedData):void;
		function getRot():ITweenedData;
		function setRot(_r:ITweenedData):void;
		function getAlpha():ITweenedData;
		function setAlpha(_a:ITweenedData):void;
		
		function get x():Number;
		function get y():Number;
		function get z():Number;
		function get displayObject():DisplayObject;
		function get parent():DisplayObjectContainer;
		function set parent(par:DisplayObjectContainer):void;
	}
}