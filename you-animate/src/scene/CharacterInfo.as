package scene
{
	import fanlib.containers.List;
	import fanlib.utils.Debug;
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import scene.action.AbstractMoveAction;
	import scene.action.Action;
	import scene.action.ActionInfo;
	import scene.action.ExtraLayerInfo;
	import scene.action.FixedAction;

	// these should be unique!
	public class CharacterInfo
	{
		internal var data:Object;
		private var _fixed:Array;
		private var _moves:Array;
		private var _noBounds:Array;
		private var _animThumbs:Object = {};
		private var _layers:Array; // extra animation layers for this character
		
		public function CharacterInfo(data:Object)
		{
			if (data.title) data = ConvertServerCharData(data); // needs conversion from San-Andreas format
			if (!data) return; // bug in friggin' server!
			
			this.data = data;
			
			if (!(_fixed = data.fixed)) _fixed = [];
			dataToActionInfo(_fixed);
			
			if (!(_moves = data.moves)) _moves = [];
			dataToActionInfo(_moves);
			
			if (!(_noBounds = data.noBounds)) _noBounds = [];
			
			for each (var animThumb:Object in data.animThumbs) {
				_animThumbs[ animThumb["i"] ] = animThumb["url"];
			}
			
			// character animation layers
			const layersFound:List = new List();
			for each ( var action:ActionInfo in _fixed.concat(_moves) ) {
				for each (var layerInfo:ExtraLayerInfo in action.layers) {
					layersFound.push(layerInfo.bone);
				}
			}
			if (!layersFound.isEmpty()) {
				_layers = layersFound.toArray();
			}
		}
		
		private function dataToActionInfo(arr:Array):void {
			for (var i:int = arr.length - 1; i >= 0; --i) {
				arr[i] = new ActionInfo(arr[i]);
			}
		}
		
		// character
		public function get name():String { return data.name }
		public function get url():String { return data.url }
		public function get thumb():String { return data.thumb }
		public function get scale():Number { return data.scale }
		public function get hide():Boolean { return data.hide }
		public function get noBounds():Array { return _noBounds }
		// actions
		public function get moves():Array { return _moves }
		public function get fixed():Array { return _fixed }
		public function get animThumbs():Object { return _animThumbs }
		public function get defaultAnimThumb():String { return data.defAnimThumb }
		
		public function getFixedByID(id:String):ActionInfo {
			return FArray.FindByValue(_fixed, "id", id);
		}
		public function getMoveByID(id:String):ActionInfo {
			return FArray.FindByValue(_moves, "id", id);
		}
		
		public function get layers():Array {
			return _layers;
		}
		
		/**
		 * @param action May be an action of a totally different character
		 * @return What it says on the box; <b>BUT!</b> if no similar <b>moving</b> action found, return <b>first available</b>
		 */
		public function getSimilarActionInfo(action:Action):ActionInfo {
			const origID:String = action.id.toLowerCase();
			var newInfo:ActionInfo;
			var array:Array;
			if (action is FixedAction) array = this.fixed; else array = this.moves;
			
			for each (newInfo in array) {
				if (newInfo.id.toLowerCase() === origID) return newInfo;
			}
			
			if (action is AbstractMoveAction /*and none found, then...*/) {
				return this.moves[0];
			}
			
			// TODO (very soon, as in never, but never say never): implement more complex name comparisons
			return null;
		}
		
		/**
		 * For now, returns non-matching Actions. Is useful only right before <b>Character.copy(other:Character)</b>. 
		 * @param other
		 * @return What it says on the box...NOT!
		 */
		public function compare(other:Character):Array {
			const desimilar:Array = [];
			for (var i:int = 0; i < other.getActionNum(); ++i) {
				const otherAction:Action = other.getAction(i);
				const newInfo:ActionInfo = getSimilarActionInfo( otherAction );
				if (!newInfo) desimilar.push(otherAction);
			}
			return desimilar;
		}
		
		public function toString():String {
			return Utils.PrettyString(data);
		}
		
		//
		
		static public function ConvertServerCharData(obj:Object):Object {
			const data:Object = {};
			
			try {
				data.name = obj.title;
				data.thumb = obj.thumbnail;
				
				const model:Object = FArray.FindByValue(obj.models, "type", 2);
				if (!model) return null;
				
				data.url = model.url;
				data.scale = model.scale;
				data.hide = model.hide;
				data.moves = model.moves;
				data.fixed = model.fixed;
				data.animThumbs = model.animThumbs;
				data.noBounds = model.noBounds; // TODO : IMPLEMENT!!!
			
			} catch (e:Error) {
//				Debug.appendLineMulti("\n", "[CharacterInfo]", e.message, e.getStackTrace());
				return null;
			}
			
			return data;
		}
	}
}