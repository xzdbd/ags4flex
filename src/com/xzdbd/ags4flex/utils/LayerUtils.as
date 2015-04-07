package com.xzdbd.ags4flex.utils
{ 
	import com.esri.ags.Map;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.Layer;
	import com.xzdbd.ags4flex.utils.supportClasses.MapServiceType;
	
	import mx.collections.IList;
	import mx.managers.CursorManager;
	

	/****************************************************
	 * 图层及图层服务处理通用工具类.
	 * 
	 * @author xzdbd
	 * 创建于 2013-6-6,上午11:00:42.
	 * 
	 *****************************************************/
	public class LayerUtils 
	{ 
		
		/**
		 * 单独打开或关闭某一地图服务的一个或多个指定子图层（不含联动控制）。
		 * @param serviceName 地图服务名称（仅仅指动态服务）。
		 * @param layerIds 需要打开或者关闭的子图层 id 集合。
		 * @param visible 针对子图层的操作类型，true 为打开，false 为关闭。
		 */
		public static function specialLayerVisibleSwitch(map:Map, serviceName:String, layerIds:Array, visible:Boolean):void
		{
			var dynLayer:ArcGISDynamicMapServiceLayer = LayerUtils.getDynamicLayer(map, serviceName);
			
			//监听图层更新完成，移除鼠标忙碌状态
			dynLayer.addEventListener(LayerEvent.UPDATE_END, removeBusyCursor, false, 0, true);
			
			var visibleLayers:IList = dynLayer.visibleLayers;
			var isChanged:Boolean = false;
			for(var i:int=0; i<layerIds.length; i++)
			{
				var index:int = visibleLayers.getItemIndex(Number(layerIds[i]));
				if(visible && index == -1)
				{
					visibleLayers.addItem(Number(layerIds[i]));
					isChanged = true;
				}
				else if(!visible && index != -1)
				{
					visibleLayers.removeItemAt(index);
					isChanged = true;
				}
			}
			
			if(isChanged)
			{
				//存在图层可见性状态发生更改，则设置忙碌鼠标样式
				CursorManager.setBusyCursor(); 
			}
			if(visible)
			{
				//使对应地图服务为可见
				LayerUtils.getDynamicLayer(map, serviceName).visible = true;
			}
			
			//向外发布图层显示变化事件（此处临时注释）
			//AppEvent.dispatch(AppEvent.LAYER_VISIBLE_CHANGED, {serverName:serviceName, layerIds:layerIds, visible:visible});
			
			function removeBusyCursor():void
			{
				dynLayer.removeEventListener(LayerEvent.UPDATE_END, removeBusyCursor, false);
				CursorManager.removeBusyCursor();
			}
		}
		
		
		/**
		 * 设置图层顺序，使指定名称的图层切换到 map 最顶层。
		 * @param layerName 图层名称。
		 * @param map Map引用。
		 * @return 被操作的图层对象。
		 */
		public static function setLayerToTop(layerName:String, map:Map):Layer
		{
			var layer:Layer;
			for each(layer in map.layers)
			{
				if(layer.name == layerName)
				{
					map.reorderLayer(layer.id, map.layerIds.length-1);
					return layer;
				}
			}
			
			return layer;
		}
		
		
		/**
		 * 获取指定服务名的服务对象引用（仅仅针对已添加到地图上的动态地图服务）。
		 * @param map 地图 Map 引用。
		 * @param serviceName 地图服务发布名称，或者地图服务配置名称。
		 * @return 对应的动态图层对象，若未找到则返回 null。
		 */
		public static function getDynamicLayer(map:Map, serviceName:String):ArcGISDynamicMapServiceLayer
		{
			if(!map)
			{
				return null;
			}
			
			for each(var layer:Layer in map.layers)
			{
				if(layer is ArcGISDynamicMapServiceLayer)
				{
					var dynLayer:ArcGISDynamicMapServiceLayer = layer as ArcGISDynamicMapServiceLayer;
					if(dynLayer)
					{
						var serverName:String = LayerUtils.getMapServiceNameByUrl(dynLayer.url, MapServiceType.MAP_SERVER);
						if(serverName == serviceName || dynLayer.id == serviceName)
						{
							return dynLayer;
						}
					}
				}
			}
			
			return null;
		}
		
		
		/**
		 * 根据地图服务名称和服务类型，获取地图服务完整的服务Url。
		 * @param serviceName 服务名称。
		 * @param serviceType 服务类型。
		 * @param host 主机（服务器）名称。
		 * @return 地图服务Url。
		 */
		public static function getServiceUrl(host:String, serviceName:String, serviceType:String=null):String
		{
			serviceType = serviceType ? serviceType : MapServiceType.MAP_SERVER;
			var url:String = "http://" + host + "/ArcGIS/rest/services/" + serviceName + "/" + serviceType + "/";
			
			return url;
		}
		
		
		/**
		 * 通过子服务图层（FeatureLayer）获取地图服务地址。
		 * @param subLayer FeatureLayer服务图层。
		 * @return 对应服务地址。
		 */
		public static function getServerUrlBySubLayer(subLayer:FeatureLayer):String
		{
			var serviceUrl:String = subLayer.url.substring(0, subLayer.url.lastIndexOf("/"));
			
			return serviceUrl;
		}
		
		
		/**
		 * 根据地图服务Url，截取服务名称。
		 * @param url 地图服务完整url。
		 * @param serviceType 地图服务类型，默认为 MapServiceType.MAP_SERVER。
		 * @return 服务名称。
		 */
		public static function getMapServiceNameByUrl(url:String, serviceType:String=null):String
		{
			serviceType = serviceType ? serviceType : MapServiceType.MAP_SERVER;
			var startIndex:int = url.indexOf("/services/") + 10;
			var endIndex:int = url.lastIndexOf("/" + serviceType);
			var serviceName:String = url.substring(startIndex, endIndex);
			
			return serviceName;
		}
		
		
		/**
		 * 根据地图服务Url获取子图层id（要求url是包含子图层id的）。
		 * @param url 对应子图层的地图服务 Url。
		 * @param serviceType 服务类型，默认为 MapServiceType.MAP_SERVER。
		 * @return 子图层 id。
		 */
		public static function getSubLayerIdByUrl(url:String, serviceType:String=null):Number
		{
			serviceType = serviceType ? serviceType : MapServiceType.MAP_SERVER;
			var startIndex:int = url.lastIndexOf("/" + serviceType) + serviceType.length + 2;
			var layerId:Number = Number(url.substring(startIndex, url.length));
			
			return layerId;
		}
		
		
		/**
		 * 获取由配置表中的配置创建的要素图层。
		 * @param serverName 地图服务名称。
		 * @param layerId 图层 id。
		 * @param host 主机名。
		 * @return FeatureLayer对象。
		 */
		public static function getFeatureLayer(serverName:String, layerId:Number, host:String):FeatureLayer
		{
			var layerUrl:String = getServiceUrl(host, serverName, MapServiceType.MAP_SERVER) + layerId;
			var featureLayer:FeatureLayer = new FeatureLayer(layerUrl);
			
			return featureLayer;
		}
		
		
		/**
		 * 获取配置表中编辑图层
		 * @param serverName 地图服务名称。
		 * @param layerId 图层 id。
		 * @param host 主机名。
		 * @return FeatureLayer对象
		 */
		public static function getEditLayer(serverName:String, layerId:Number, host:String):FeatureLayer
		{
			var layerUrl:String = getServiceUrl(host, serverName, MapServiceType.FEATURE_SERVER) + layerId;
			var featureLayer:FeatureLayer = new FeatureLayer(layerUrl);
			
			return featureLayer;
		}
		
		/**
		 * 获取一个切片图层
		 * @param serverName 地图服务名称。
		 * @param host 主机名。
		 * @return ArcGISTiledMapServiceLayer对象
		 */
		public static function getTiledLayer(serverName:String, host:String):ArcGISTiledMapServiceLayer
		{
			var layerUrl:String = getServiceUrl(host, serverName, MapServiceType.MAP_SERVER);
			var arcGISTiledMapServiceLayer:ArcGISTiledMapServiceLayer = new ArcGISTiledMapServiceLayer(layerUrl);
			
			return arcGISTiledMapServiceLayer;
		}
		
		//===================================================================
		
		/**
		 * 构造函数。
		 */
		public function LayerUtils()
		{
		} 
		
		
	} 
} 









