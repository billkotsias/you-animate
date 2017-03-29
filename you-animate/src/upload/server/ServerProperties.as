package upload.server
{
	import fanlib.io.MPart;
	import fanlib.io.URLLoaderListener;
	import fanlib.utils.Utils;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import upload.CharEdit;

	public class ServerProperties extends ServerRequest
	{
		public function ServerProperties() {
		}
		
		public function send(charEdit:CharEdit, callback:Function):ServerProperties {
			
			QueueMessage( new QueuedURLLoader("Upload changes", function():URLLoader {
				
				// info may be altered (YESH!) after returning this function (and before executing it!)
				// only things that won't change are charEdit & callback
				const data:Object = {};
				const charInfo:CharInfo = charEdit.charInfo;
				const animations:Array = charEdit.animations;
				
				if (charInfo.character) data["UploadCharacterForm[character]"] = charInfo.character;
				data["UploadCharacterForm[hide]"] = charInfo.hide;
				if (charInfo.model) data["UploadCharacterForm[model]"] = charInfo.model;
				data["UploadCharacterForm[title]"] = charInfo.title;
				data["UploadCharacterForm[description]"] = charInfo.description || "";
				data["UploadCharacterForm[tags]"] = charInfo.tags || "";
				data["UploadCharacterForm[type]"] = "2";
				data["UploadCharacterForm[geometry]"] = charInfo.geometry;
				data["UploadCharacterForm[polygons]"] = charInfo.polygons;
				data["UploadCharacterForm[body_rigged]"] = charInfo.body_rigged ? "y" : "n";
				data["UploadCharacterForm[facial_rigged]"] = charInfo.facial_rigged ? "y" : "n";
				data["UploadCharacterForm[textures]"] = charInfo.textures;
				data["UploadCharacterForm[materials]"] = charInfo.materials;
				data["UploadCharacterForm[uv_mapped]"] = charInfo.uv_mapped ? "y" : "n";
				data["UploadCharacterForm[uv_unwrapped]"] = charInfo.uv_unwrapped ? "y" : "n";
				data["UploadCharacterForm[animated]"] = Boolean(charEdit.animations.length) ? "y" : "n";
				data["UploadCharacterForm[units]"] = charInfo.units ? "y" : "n";
				data["UploadCharacterForm[scale]"] = charInfo.scale;
				
				const moves:Array = [];
				const fixed:Array = [];
				// Hint : split moves with fixed
				for each (var anim:AnimInfo in animations) {
					if (anim.speed || anim._class === "DriveAction" || anim._class === "BezierPropMove") {
						moves.push(anim);
					} else {
						fixed.push(anim);
					}
				}
				data["UploadCharacterForm[fixed]"] = JSON.stringify(fixed);
				data["UploadCharacterForm[moves]"] = JSON.stringify(moves);
				
				trace("[ServerProperties] send",Utils.PrettyString(data));
				
				const mpart:MPart = new MPart( URLUpload() );
				mpart.addFields(data);
				return mpart.loadRequest(callback, null); // custom headers not required!
			}) );
			
			return this;
		}
		
		//
		
		public function request(charEdit:CharEdit, callback:Function):ServerProperties {
			
			QueueMessage( new QueuedURLLoader("Get character data", function():URLLoader {
				
				const loader:URLLoader = new URLLoader( new URLRequest(ServerRequest.URLCharDetails(charEdit)) );
				loader.dataFormat = URLLoaderDataFormat.BINARY; // returns ByteArray data!
				new URLLoaderListener(loader, callback);
				
				return loader;
			}) );
				
			return this;
		}
	}
}