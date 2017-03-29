package scene
{
	import fanlib.containers.List;
	import fanlib.gfx.FSprite;
	import fanlib.utils.Debug;
	import fanlib.utils.FArray;
	import fanlib.utils.JobsToGo;
	import fanlib.utils.QuickLoad;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import scene.action.special.Prop;
	import scene.action.special.PropInfo;
	import scene.action.special.Properties;
	
	import skinning.CustomModifier3;
	
	import ui.report.ProgressTracker;
	import ui.report.ProgressWindow;
	
	import upload.server.ServerRequest;

	public class CharManager
	{
		static public const INSTANCE:CharManager = new CharManager();
		
		private const infoToInstances:Dictionary = new Dictionary();
		private const infoToLoader:Dictionary = new Dictionary();
		private const infoList:Array = [];
		private const propList:Array = [];
		private const sanAndreasPropList:Dictionary = new Dictionary(); // Andreas-san, the haunter
		
		private const infoToDispose:List = new List();
		
		public function CharManager()
		{ if (INSTANCE) throw this + " is singleton"; }
		
		public function addInfoList(url:String, func:Function):void {
			CONFIG::debug { Debug.appendLine("addInfoList :"+url+"\n"); }
			new QuickLoad(url, function (json:String):void {
				
				CONFIG::debug { Debug.appendLineMulti(",","CharManager",json); }
				const jsonObj:Object = JSON.parse(json);
				
				var data:Object;
				const props:Array = jsonObj["props"];
				for each (data in props) {
					propList.push(new PropInfo(data));
				}
				
				
				const chars:Array = jsonObj["characters"];
				for each (data in chars) {
					var charInfo:CharacterInfo = new CharacterInfo(data);
					if (charInfo.data !== null) infoList.push(charInfo);
				}
				
				CONFIG::debug { Debug.appendLine("[CharManager] loaded\n"); }
				func();
			});
		}
		
		public function sanAndreasList(url:String, func:Function):void {
			new QuickLoad(url, function (json:String):void {
				const jsonObj:Object = JSON.parse(json);
				
				var data:Object;
				const props:Array = jsonObj["objects"];
				// NOTE : MAYBE add a 'Utils.Clear(sanAndreasPropList);' if objects may be deleted (no API for that, yet, san-mastan)
				for each (data in props) {
					if (!data.data) continue;
					data.data.url = data.url; // copy url from outside to inside. Cool eh?
					sanAndreasPropList[ data.id ] = new PropInfo( data.data );
				}
				
//				trace(this,"\n"+Utils.PrettyString(sanAndreasPropList));
				func();
			});
		}
		
		public function defaultSanAndreasList(func:Function):void {
			sanAndreasList(ServerRequest.URLAllObjects(), func);
		}
		
		/**
		 * Be kind with it, it's very sensitive
		 */
		public function get characterInfos():Array { return infoList.concat() }
		
		public function getCharacterInfoByName(name:String):CharacterInfo {
			return FArray.FindByValue(infoList, "name", name);
		}
		public function getPropInfoByID(id:String):PropInfo {
			var propInfo:* = FArray.FindByValue(propList, "id", id);
//			trace(this,"getPropInfoByID",id,propInfo,sanAndreasPropList[ id ]);
			if (propInfo === undefined) propInfo = sanAndreasPropList[ id ];
			return propInfo;
		}
		
		/**
		 * @return Character gets immediately created but mesh may take some time to load
		 */
		public function requestCharacter(info:CharacterInfo, sceneContext:Scene3D, parent3D:Pivot3D, nodesParent:FSprite):Character {
			// is there a model loader?
			var loader:FlareLoader = infoToLoader[info];
			if (loader) {
				
				infoToDispose.remove(info); // make sure it's not "to be disposed"
				
			} else {
				
				disposeOldLoaders(); // make room (ram!) for the newcomer
				
				loader = new FlareLoader( Walk3D.AppendToPathIfRelative(Walk3D.CHARS_DIR, info.url), null, sceneContext );
				loader.setScale(info.scale,info.scale,info.scale);
				infoToLoader[info] = loader;
				ProgressWindow.NewProgress(loader, "Loading character " + info.name);
				loader.addEventListener(Event.COMPLETE, function(e:Event):void {
					loader.removeEventListener(Event.COMPLETE, arguments.callee);
					loader.gotoAndPlay(0);
					loader.gotoAndStop(0);
					loader.forEach(function(mesh:Mesh3D):void {
						mesh.modifier = CustomModifier3.CloneToCustom( mesh.modifier, info.layers ); // split skeleton to layers
					}, Mesh3D);
				}, false, int.MAX_VALUE, false); // if weak-ref, God is Sucked in
				loader.load();
			}
			
			// character name (given to 'pivot3D')
			var sameChars:List = Utils.GetGuaranteed(infoToInstances, info, List);
			var charName:String = info.name;
			if (sameChars.length) {
				// get number of last one added and increase
				var number:uint = uint( (sameChars.last as Character).name.slice( charName.length ) ) + 1;
				if (number === 1) number = 2;
				if (number <= sameChars.length) number = sameChars.length + 1;
				charName += number.toString();
			}
			
			var charPivot:Pivot3D = new Pivot3D(charName); // loader clone will be added here
			charPivot.x = Math.random() * 5;
			charPivot.z = 25 - Math.random() * 5;
			charPivot.parent = parent3D;
			var char:Character = new Character(info, charPivot, parent3D, nodesParent, loader);
			sameChars.push(char, true);
			
			return char;
		}
		
//		internal function forgetCharacterByID(id:String):void {
//			forgetCharacter( Scene.INSTANCE.characters.getByValue("id", id) );
//		}
		
		internal function forgetCharacter(char:Character):void {
			const charInfo:CharacterInfo = char.info;
			const sameChars:List = infoToInstances[charInfo];
			sameChars.remove(char);
			if (sameChars.isEmpty()) {
				// no more characters of this type!
				delete infoToInstances[charInfo]; // delete "sameChars" reference; not a big deal, just a 'List' removal
				infoToDispose.push(charInfo);
			}
		}
		
		private function disposeOldLoaders():void {
			const toDispose:Array = infoToDispose.toArray();
			infoToDispose.clear(true);
			
			for each (var charInfo:CharacterInfo in toDispose) {
				var loader:FlareLoader = infoToLoader[charInfo];
				delete infoToLoader[charInfo]; // delete "loader" reference
				loader.close();
				loader.dispose();
				loader.dispatchEvent(new Event(ProgressTracker.EVENT_DISPATCHER_DISPOSED)); // for ProgressTracker, only!
			}
		}

	}
}