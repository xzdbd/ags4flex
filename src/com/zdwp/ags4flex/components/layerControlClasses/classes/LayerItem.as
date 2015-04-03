package com.zdwp.ags4flex.components.layerControlClasses.classes
{ 
	import com.esri.ags.layers.Layer;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	
	/**************************************************
	 * 图层信息实体类.
	 * 
	 * @author 郝超
	 * 创建于 2012-4-11,上午09:24:20.
	 * 
	 **************************************************/
	[Bindable]
	public class LayerItem extends EventDispatcher
	{ 
		/**
		 * 构造函数。
		 */
		public function LayerItem()
		{
			children = new ArrayCollection();
			checkedChildren = 0;
		} 
		
		//图层id
		private var _layerId:Number;
		//地图服务url（针对顶级节点）
		private var _layerUrl:String;
		//节点名称
		private var _label:String;
		//选中状态字段
		private var _state:int = 0;
		//是否为叶子节点
		private var _isLeafNode:Boolean;
		//父级节点项
		private var _parent:LayerItem;
		//孩子节点集
		private var _children:ArrayCollection;
		//当前节点被选中节点数
		private var _checkedChildren:Number;
		//节点图标资源路径
		private var _iconPath:String;
		//地图服务图层
		private var _mapLayer:Layer;
		
		/**
		 * 图层id。
		 */
		public function get layerId():Number
		{
			return _layerId;
		}
		/**
		 * @private
		 */
		public function set layerId(value:Number):void
		{
			_layerId = value;
		}

		/**
		 * 地图服务url（针对顶级节点）。
		 */		
		public function get layerUrl():String
		{
			return _layerUrl;
		}
		/**
		 * @private
		 */
		public function set layerUrl(value:String):void
		{
			_layerUrl = value;
		}

		/**
		 * 图层节点名称。
		 */
		public function get label():String
		{
			return _label;
		}
		/**
		 * @private
		 */
		public function set label(value:String):void
		{
			_label = value;
		}

		/**
		 * 选中状态字段。
		 */
		public function get state():int
		{
			return _state;
		}
		/**
		 * @private
		 */
		public function set state(value:int):void
		{
			_state = value;
		}

		/**
		 * 指定是否为叶子节点。
		 */
		public function get isLeafNode():Boolean
		{
			return _isLeafNode;
		}
		/**
		 * @private
		 */
		public function set isLeafNode(value:Boolean):void
		{
			_isLeafNode = value;
		}

		/**
		 * 当前节点对应父节点对象。
		 */
		public function get parent():LayerItem
		{
			return _parent;
		}
		/**
		 * @private
		 */
		public function set parent(value:LayerItem):void
		{
			_parent = value;
		}

		/**
		 * 当前节点对应孩子节点集合。
		 */
		public function get children():ArrayCollection
		{
			return _children;
		}
		/**
		 * @private
		 */
		public function set children(value:ArrayCollection):void
		{
			_children = value;
		}

		/**
		 * 当前节点的孩子节点中被选中的节点数目。
		 */
		public function get checkedChildren():Number
		{
			return _checkedChildren;
		}
		/**
		 * @private
		 */
		public function set checkedChildren(value:Number):void
		{
			_checkedChildren = value;
		}

		/**
		 * 节点图标资源路径。
		 */
		public function get iconPath():String
		{
			return _iconPath;
		}
		/**
		 * @private
		 */
		public function set iconPath(value:String):void
		{
			_iconPath = value;
		}

		/**
		 * 地图服务图层对象。
		 */
		public function get mapLayer():Layer
		{
			return _mapLayer;
		}
		/**
		 * @private
		 */
		public function set mapLayer(value:Layer):void
		{
			_mapLayer = value;
		}
		
	} 
} 









