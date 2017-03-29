package scene
{
	import fanlib.gfx.FSprite;
	
	import flare.core.Pivot3D;
	
	import flash.geom.Vector3D;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;
	
	import scene.action.AbstractMoveAction;
	import scene.action.ActionManager;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.Node;
	import scene.serialize.ISerialize;
	import scene.serialize.Serialize;
	
	import tools.selectChar.AddLinearMove;
	
	public class Crowd extends ActionManager implements ISObject, ISerialize
	{
		static public const CROWD_STR:String = "Crowd";
		static public const RADIUS_MIN:Number = 1;
		
		public var id:String; // for cross-reference with 'Character's
		
		public const characters:Vector.<Character> = new Vector.<Character>;
		public var offsets:Vector.<Vector3D> = new Vector.<Vector3D>;
		private var dirs:Vector.<Boolean> = new Vector.<Boolean>;
		
		private var _speed:Number = 1; // multiplier
		public var radius:Number = 10; // reference for "randomizer" usage, not used in here
		
		private const infos:Vector.<CharacterInfo> = new Vector.<CharacterInfo>; // for saving
		
		private var _name:String = CROWD_STR;
		private var _visible:Boolean = true;
		private var _pathVisible:Boolean = true;
		
		private var currentTime:Number = 0;
		
		public function Crowd()
		{
			super();
			id = UIDUtil.createUID();
		}
		
		public function setParents(nodesCont:Pivot3D, nodesParent:FSprite):void {
			_nodesPivot.parent = nodesCont;
			_nodes2D.parent = nodesParent;
			_nodes2D.mouseEnabled = false;
			_nodes2D.mouseChildren = false;
		}
		
		/**
		 * Must call <b>updateChars()</b> after
		 * @param charNames Character (unique) names
		 */
		public function setChars(charNames:Array):void
		{	
			var char:Character;
			
			for each (char in characters) {
				Scene.INSTANCE.removeCharacter(char);
			}
			characters.length = 0;
			infos.length = 0;
			
			for (var i:int = 0; i < charNames.length; ++i) {
				var charName:String = charNames[i];
				var info:CharacterInfo = CharManager.INSTANCE.getCharacterInfoByName( charName );
				infos.push( info );
				char = Scene.INSTANCE.addCharacter(info);
				characters.push( char );
				char.crowdID = id;
			}
			
			visible = _visible;
		}
		
		/**
		 * Must call <b>updateChars()</b> after
		 * @param off Offsets/character
		 */
		public function setOffsets(off:Vector.<Vector3D>):void {
			offsets = off.concat();
		}
		
		/**
		 * Must call <b>updateChars()</b> after
		 * @param newSpeed Speed multiplier
		 */
		public function set speed(newSpeed:Number):void {
			if (newSpeed) _speed = newSpeed; // f-you
		}
		public function get speed():Number { return _speed }
		
		// You know now what to do after
		public function setDirs(newDirs:Vector.<Boolean>):void {
			dirs = newDirs.concat();
		}
		public function getCharDir(index:uint):Boolean {
			return dirs[index];
		}
		
		public function update():void
		{
			var char:Character;
			var offset:Vector3D;
			var dir:Boolean;
			var action:BezierMove;
			
			// rebuild nodes & path
			for (var k:int = 0; k < characters.length; ++k)
			{
				char = characters[k];
				offset = offsets[k];
				dir = dirs[k];
				
				// create exactly one action if possible
				action = char.getLastAction() as BezierMove;
				if (!action && nodes.length >= 2)
				{
					checkCharNodesNum(char, 2, null, dir);
					action = char.addBezierMove(
						char.getValidMoveActionInfo(AddLinearMove.MOVE_DEFAULT_ID),
						char.getNodeAt(0) as BNode, char.getNodeAt(1) as BNode);
				}
				
				// fill action with (rest of) nodes
				checkCharNodesNum(char, nodes.length, action, dir);
				
				for (var i:uint = 0; i < nodes.length; ++i)
				{
					var crowdNode:BNode;
					if (dir) crowdNode = nodes.getByIndex(nodes.length-i-1); else crowdNode = nodes.getByIndex(i);
					
					var crowdNodePosition:Vector3D = crowdNode.getPosition();
					var crowCPos0:Vector3D = crowdNode.control0.getPositionLocal();
					var crowCPos1:Vector3D = crowdNode.control1.getPositionLocal();
					
					var charNode:BNode = char.getNodeAt(i) as BNode;
					charNode.visible = false;
					charNode.sobject = crowdNode.sobject;
					charNode.setPosition( crowdNodePosition.add(offset) ); // this is b*llshit math, but real shit needs much much munchies
					if (dir) {
						charNode.control0.setPositionLocal( crowCPos1 );
						charNode.control1.setPositionLocal( crowCPos0 );
					} else {
						charNode.control0.setPositionLocal( crowCPos0 );
						charNode.control1.setPositionLocal( crowCPos1 );
					}
				}
				
				// update their speed
				if (action) action.speed = action.defSpeed * _speed;
			}
		}
		private function checkCharNodesNum(char:Character, requiredNum:uint, action:BezierMove, dir:Boolean):void {
			var charNode:BNode;
			while (char.getNodesNum() < requiredNum) {
				charNode = char.newNode() as BNode;
				if (action) {
					action.pushNode(charNode);
				}
			}
			while (char.getNodesNum() > requiredNum) {
				char.deleteNode( char.getLastActionNode() );
			}
		}
		//
		
		public function setTime(time:Number = NaN):void {
			for each (var char:Character in characters) {
				if (time === time) {
					currentTime = time;
					char.setTime(time);
				} else {
					char.setTime(currentTime);
				}
			}
		}
		
		public function getCharsNum():uint {
			return characters.length;
		}
		
		// ISObject
		public function get name():String { return _name }
		public function set name(n:String):void { _name = n }
		
		public function get pathVisible():Boolean { return _pathVisible; }
		public function set pathVisible(v:Boolean):void {
			_pathVisible = v;
			v &&= visible;
			_nodes2D.visible = v;
			nodes.forEach(function(node:Node):void { node.visible = v; });
			
			// there can be only one highlanderisha
			for each (var char:Character in characters) {
				char.pathVisible = false;
				char.forEachNode(function(node:Node):void { node.visible = false }); // DEBUG NOTE: false!
			}
			for each (char in characters) {
				char.pathVisible = _pathVisible;
				char.forEachNode(function(node:Node):void { node.visible = false });
				break; // just one, I said
			}
		}
		
		public function get visible():Boolean { return _visible }
		public function set visible(v:Boolean):void {
			_visible = v;
			for each (var char:Character in characters) {
				char.visible = v;
			}
			pathVisible = _pathVisible;
		}
		
		internal function dispose():void {
			// delete Characters
			setChars([]);
			// delete Nodes
			while (nodes.length) {
				deleteNode(nodes.pop());
			}
			// remove from 'Scene3D'
			_nodesPivot.parent = null;
			_nodes2D.parent = null;
		}
		
		// save - load
		
		public function getHistoryState():HistoryState {
			const serial:Object = serialize(Scene.INSTANCE.sobjects.toArray());
			return new HistoryState(function():void {
				Scene.INSTANCE.removeCrowdByID(id);
				const crowd:Crowd = new Crowd();
				crowd.deserialize(serial);
				crowd.setTime(Infinity);
			});
		}
		public function getNoState():HistoryState {
			return new HistoryState(function():void { Scene.INSTANCE.removeCrowdByID(id) });
		}
		
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.t = getQualifiedClassName(this);
			obj.id = id;
			obj.sp = _speed;
			obj.ra = radius;
			obj.na = name;
			
			obj.of = Serialize.ToByteArray(offsets);
			
			obj.di = Serialize.ToByteArray(dirs);
			
			const inf:Array = [];
			for (var i:int = 0; i < infos.length; ++i) {
				inf.push( infos[i].name );
			}
			obj.inf = Serialize.ToByteArray(inf);
			
			return obj;
		}
		
		public function deserialize(obj:Object):void
		{
			// basic stuff
			id = obj.id;
			name = String(obj.na);
			Scene.INSTANCE.addCrowd(this);
			
			const sobjects:Array = Scene.INSTANCE.sobjects.toArray();
			var i:int;
			
			// nodes
			const serialArrNodes:Array = obj.n;
			for (i = 0; i < serialArrNodes.length; ++i) {
				const nodeObj:Object = serialArrNodes[i];
				const nodeClass:Class = Class(getDefinitionByName(nodeObj.t));
				const node:Node = newNode(null, nodeClass);
				node.deserialize(nodeObj);
				node.sobject = sobjects[nodeObj.s];
			}
			
			// rest-o' crowd stuff (but not least)
			setChars( Serialize.ObjectToArray( Serialize.FromByteArray(obj.inf) ) );
			
			radius = obj.ra;
			_speed = obj.sp;
			
			const drs:Vector.<Boolean> = new Vector.<Boolean>;
			const drsArr:Array = Serialize.ObjectToArray( Serialize.FromByteArray(obj.di) );
			for (i = 0; i < drsArr.length; ++i) {
				drs.push( drsArr[i] );
			}
			setDirs(drs);
			
			const offs:Vector.<Vector3D> = new Vector.<Vector3D>;
			const offArr:Array = Serialize.ObjectToArray( Serialize.FromByteArray(obj.of) );
			for (i = 0; i < offArr.length; ++i) {
				const off:Object = offArr[i];
				offs.push( new Vector3D(off.x, off.y, off.z) );
			}
			setOffsets(offs);
			
			update();
		}
	}
}