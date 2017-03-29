package scene.action
{
	public class NodeTouchInfo
	{
		/**
		 * Node reference 
		 */
		public var node:Node;
		/**
		 * AbstractNode reference, may be the Node itself or a CtrlNode child 
		 */
		public var abNode:AbstractNode;
		
		public function NodeTouchInfo(node:Node, abNode:AbstractNode)
		{
			this.node = node;
			this.abNode = abNode;
		}
	}
}