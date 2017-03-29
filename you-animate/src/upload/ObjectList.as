package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Gfx;
	import fanlib.gfx.TouchWindow;
	import fanlib.io.URLLoaderListener;
	import fanlib.text.FTextField;
	import fanlib.ui.TouchMenu;
	import fanlib.utils.FArray;
	import fanlib.utils.FStr;
	import fanlib.utils.IInit;
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import ui.report.Reporter;
	
	import upload.server.ServerRequest;
	
	public class ObjectList extends TouchMenu implements IInit
	{
		static public const SELECTED_CHANGED:String = "SELECTED_CHANGE";
		
		private const objects:Vector.<ObjData> = new Vector.<ObjData>;
		private var _selected:ObjData;
		
		public function ObjectList()
		{
			super();
			mouseWheel = 10;
			addEventListener(TouchMenu.CHILD_SELECTED, childSelected);
		}
		
		public function initLast():void {
			update();
		}
		
		//
		
		private function childSelected(e:ObjEvent):void {
			const entry:FTextField = e.getObj() as FTextField;
			if (entry) selectByID(entry.name);
		}
		
		public function selectByID(id:String):void {
			if (!id) {
				selectObject(null);
			} else {
				var objData:ObjData = FArray.FindByValue(objects, "id", id);
				selectObject(objData);
			}
		}
		
		private function selectObject(obj:ObjData):void {
			// - deselect previous
			highlightEntry(_selected, false);
			// - select new
			_selected = obj;
			highlightEntry(_selected, true);
			dispatchEvent(new Event(SELECTED_CHANGED));
		}
		
		private function highlightEntry(objData:ObjData, yes:Boolean):void {
			const objDataID:String = (objData && objData.id) || "";
			const field:FTextField = getChildByName(objDataID) as FTextField;
			if (field) field.background = field.border = yes; // in case the selection has been deleted
		}
		
		public function update(e:* = undefined):void {
			// TODO : automatically select an object that its id didn't exist prior to this update!
			
			// request "my objects"
			const loader:URLLoader = new URLLoader( new URLRequest(ServerRequest.URLMyObjects()) );
			loader.dataFormat = URLLoaderDataFormat.BINARY; // returns ByteArray data!
			new URLLoaderListener(loader, function(serverData:ByteArray):void {
				try {
					const json:Object = JSON.parse(FStr.BytesToString(serverData));
					const objArr:Array = json["objects"];
					objects.length = 0; // reset all object data
					
					// <none> option
					var obj:Object;
					obj = { "id":"", "name":"&lt;none&gt;" };
					obj.data = {};
					objArr.unshift(obj);
					
					// DEBUG
//					obj = { "id":"asdfsdaf","type":"vehicleData","name":"briefcase mothafuasvvsad fsa", "url":Walk3D.PROPS_DIR+"briefcase.zf3d" };
//					obj.data = Utils.Clone(obj);
//					objArr.push(obj);
//					obj = { "id":"asdfsdaf2","type":"simpleData","name":"stroll", "url":Walk3D.PROPS_DIR+"stroll.zf3d", "from":0, "to":200, "rate":100, "rest":true };
//					obj.data = Utils.Clone(obj);
//					objArr.push(obj);
//					obj = {"id":"asdfsdaf2er1","type":"vehicleData",
//						"!comment":"scale 0 => 0.07",
//						"name":"bmw", "url":Walk3D.PROPS_DIR+"car2.zf3d", "scale":0, "vLength":-8.2712,
//						"steerAnim":[160,200], "steerPar":"CTRL_SteerWheel01", "steerAngle":60,
//						"wheelSpeed":[-50,0,0], "wheels":["OBJ_Wheel_Back_L01","OBJ_Wheel_Front_L01","OBJ_Wheel_Back_R01","OBJ_Wheel_Front_R01"],
//						"dirWheels":["CTRL_Wheel_Front_L01","CTRL_Wheel_Front_R01"]
//					};
//					obj.data = Utils.Clone(obj);
//					objArr.push(obj);
					// DEBUG
					
					for (var i:int = objArr.length - 1; i >= 0; --i) {
						objects.push(new ObjData(objArr[i]));
					}
				} catch (e:Error) {
					Reporter.AddError(this,"Can't load objects", e.message, FStr.BytesToString(serverData));
				}
				
				redrawList();
			});
		}
		
		public function redrawList():void {
			removeChildren();
			
			for (var i:int = 0; i < objects.length; ++i) {
				var entry:FTextField = FTextField.FromTemplate("OBJECT_LIST_ENTRY");
				const objData:ObjData = objects[i];
				entry.name = objData.id;
				entry.htmlText = objData.name;
				addChild(entry);
			}
			
			Gfx.SortChildren(container, "htmlText");
			var posY:Number = 0;
			if (numChildren) {
				posY = getChildAt(0).height;
				for (i = 1; i < numChildren; ++i) {
					entry = getChildAt(i) as FTextField;
					entry.y = posY;
					posY += entry.height;
				}
			}
			
			highlightEntry(_selected, true);

		}

		public function get selected():ObjData { return _selected }
		public function set selected(objData:ObjData):void { selectObject(objData) }
	}
}