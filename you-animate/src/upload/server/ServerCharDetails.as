package upload.server
{
	import fanlib.utils.FArray;
	import fanlib.utils.Parser;

	public class ServerCharDetails
	{
		private var _data:Object;
		
		public function ServerCharDetails(data:Object)
		{
			_data = data;
		}
		
		public function getModel(modelID:String):Object {
			const models:Array = _data["models"];
			return FArray.FindByValue(models, "id", modelID);
		}
		
		public function getModelURL(modelID:String):String {
			return getModel(modelID)["url"];
		}
		
		public function getModelThumbnail(modelID:String):String {
			return getModel(modelID)["thumbnail"];
		}
		
		public function getAnimations(modelID:String):Array {
			const model:Object = getModel(modelID);
			return (model["fixed"] as Array).concat(model["moves"]);
		}
		
		public function getAnimThumbs(modelID:String):Array {
			return getModel(modelID)["animThumbs"]; 
		}
		
		//
		
		public function copyToCharInfo(c:CharInfo):void {
			c.title			= _data["title"];
			c.description	= _data["description"];
			c.tags			= _data["tags"];
			
			const modelID:String = c.model;
			const models:Array = _data["models"];
			const model:Object = FArray.FindByValue(models, "id", modelID);
			c.scale = model["scale"];
			c.hide = Parser.toBool(model["hide"]); // NOTE : don't seem right to be in "model"
			
			c.polygons = model["polygons"];
			c.geometry = model["geometry"];
			c.textures = model["textures"];
			
			c.body_rigged	= Parser.toBool(model["body_rigged"]);
			c.facial_rigged	= Parser.toBool(model["facial_rigged"]);
			c.materials		= Parser.toBool(model["materials"]);
			c.uv_mapped		= Parser.toBool(model["uv_mapped"]);
			c.uv_unwrapped	= Parser.toBool(model["uv_unwrapped"]);
			c.units			= Parser.toBool(model["units"]);
		}
	}
}