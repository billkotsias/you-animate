package scene.serialize
{
	import fanlib.containers.List;
	import fanlib.event.ObjEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import scene.CharManager;
	import scene.Character;
	import scene.Scene;

	public class CharsSerializer implements ISerialize
	{
		static public const CHAR_DESERIALIZED:String = "CHAR_DESERIALIZED";
		static public const EVENTS:EventDispatcher = new EventDispatcher();
		
		public function CharsSerializer()
		{
		}
		
		public function serialize(dat:* = undefined):Object {
			const _characters:List = dat[0];
			const sobjs:Array = dat[1];
			
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			
			obj.s = Scene.INSTANCE.globalScale;
			
			const charsArr:Array = [];
			_characters.forEach(function(char:Character):void {
				if (char.crowdID) return; // NOTE! Yeah!
				charsArr.push(char.serialize(sobjs));
			});
			obj.a = charsArr;
			
			return obj;
		}
		public function deserialize(obj:Object):void {
			const sobjects:Array = Scene.INSTANCE.sobjects.toArray();
			
			Scene.INSTANCE.globalScale = obj.s;
			
			const charsArr:Array = obj.a;
			for (var i:int = 0; i < charsArr.length; ++i) {
				DeserializeChar(charsArr[i], sobjects, 0);
			}
		}
		
		static public function DeserializeChar(charObj:Object, sobjects:Array, time:Number):void {
			const char:Character = Scene.INSTANCE.addCharacter(CharManager.INSTANCE.getCharacterInfoByName(charObj.i));
			char.deserialize(charObj, sobjects);
			EVENTS.dispatchEvent(new ObjEvent(char, CHAR_DESERIALIZED));
			char.setTime(time);
			if (!char.boundingBoxColor) char.pathVisible = false;
		}
	}
}