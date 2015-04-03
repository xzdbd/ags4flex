package com.xzdbd.ags4flex.managers
{
	import com.esri.ags.Map;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.GraphicsLayerEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.Layer;
	
	import mx.collections.ArrayCollection;


	/****************************************************
	 * GraphicsLayer管理类.
	 * 
	 * <p> 
     * 强烈建议：
     * <ol> 
     * <li>通过该类来对系统中的 GraphicsLayer 进行统一管理；</li> 
     * <li>通过该类中的 <code>createGraphicsLayer()</code> 方法统一创建渲染图层 <code>GraphicsLayer</code>。</li> 
     * </ol> 
     * </p> 
	 * 
	 * @author 郝超
	 * 创建于 2013-6-6,上午11:05:41 。
	 * 
	 ****************************************************/
	public class GraphicsLayerManager
	{
		/**
		 * 单例实例。
		 */
		private static var _graphicsLayerManager:GraphicsLayerManager;
		
		/**
		 * 系统中GraphicsLayer的统一存储集。
		 */
		private var _graphicsLayers:ArrayCollection;
		
		
		/**
		 * 获取单例。
		 */
		public static function getInstance():GraphicsLayerManager
		{
			if(_graphicsLayerManager == null)
				_graphicsLayerManager = new GraphicsLayerManager();
			
			return _graphicsLayerManager;
		}
		
		
		/**
		 * 构造函数。
		 */
		public function GraphicsLayerManager()
		{
			_graphicsLayers = new ArrayCollection();
		}
		
		
		/**
		 * 创建 GraphicsLayer，并添加到 map 中。
		 * <p>GraphicsLayer 的创建都应通过该方法创建，从而纳入统一控制管理。</p>
		 * @param name 创建的图层名称。
		 * @param map 图层所属地图 Map 引用。
		 * @param clearable 是否可通过外部工具进行统一清空，默认为 true。
		 * @return 新创建的 GraphicsLayer 实例。
		 */
		public function createGraphicsLayer(name:String, map:Map, clearable:Boolean=true, index:int=-1):GraphicsLayer
		{
			if(! map)
			{
				return null;
			}
			
			//创建 GraphicsLayer
			var graphicsLayer:GraphicsLayer = new GraphicsLayer();
			graphicsLayer.name = name;
			map.addLayer(graphicsLayer, index);
			
			//集中存储
			_graphicsLayers.addItem({layer:graphicsLayer, clearable:clearable});
			
			//监听要素添加到图层的事件
			graphicsLayer.addEventListener(GraphicEvent.GRAPHIC_ADD, layerAddElementHandler);
			
			//监听图层要素清空的事件
			graphicsLayer.addEventListener(GraphicsLayerEvent.GRAPHICS_CLEAR, layerClearHandler);
			
			return graphicsLayer;
			
			function layerAddElementHandler(event:GraphicEvent):void
			{
				var layer:GraphicsLayer = event.target as GraphicsLayer;
				layer.visible = true;
			}
			function layerClearHandler(event:GraphicsLayerEvent):void
			{
				var layer:GraphicsLayer = event.target as GraphicsLayer;
				layer.visible = false;
				map.infoWindow.hide();
			}
		}
		
		
		/**
		 * 获取已通过 createGraphicsLayer 方法创建的所有 GraphicsLayer。
		 * @return 包含所有 GraphicsLayer 的集合。
		 */
		public function getAllGraphicsLayer():ArrayCollection
		{
			return _graphicsLayers;
		}
		
		
		/**
		 * 根据图层名称获取已创建的 GraphicsLayer。
		 * @param layerName 图层名称。
		 * @return 对应的GraphicsLayer引用。
		 */
		public function getGraphicsLayer(layerName:String):GraphicsLayer
		{
			for each(var layerObj:Object in _graphicsLayers)
			{
				if(layerObj.layer.name == layerName)
				{
					return layerObj.layer as GraphicsLayer;
				}
			}
			
			return null;
		}
		
		
		
		/**
		 * 根据图层名称获取已创建的 GraphicsLayer 的 id。
		 * @param layerName 图层名称。
		 * @param map 地图 Map 的引用。
		 * @return 对应的 GraphicsLayer 的 id。
		 */
		public function getGraphicsLayerId(layerName:String, map:Map):String
		{
			for each(var layer:Layer in map.layers)
			{
				if(layer is GraphicsLayer && layer.name == layerName)
				{
					return layer.id;
				}
			}
			
			return null;
		}
		
		
		/**
		 * 切换不同模块（分组）之间的GraphicsLayer显示隐藏。
		 * @param group 分组名称。 
		 */
		public function switchGraphicsLayersVisible(group:String):void
		{
			var layer:GraphicsLayer;
			var groups:Array;
			for each(var layerObj:Object in _graphicsLayers)
			{
				layer = layerObj.layer as GraphicsLayer;
				groups = layerObj.groups as Array;
				if(groups.indexOf(group) != -1)
				{
					//layer.clear();
					layer.visible = true;
				}
				else
				{
					//layer.clear();
					layer.visible = false;
				}
			}
		}
		
		
	}
}







