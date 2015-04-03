package com.xzdbd.ags4flex.components.layerControlClasses.utils
{ 
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.Layer;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.xzdbd.ags4flex.components.layerControlClasses.classes.LayerItem;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	
	/**************************************************************************************************************************
	 * 地图图层信息管理类。主要负责根据配置文件的配置，从Map对象中读取出Map中相应地图服务中的图层信息，并组织成树形数据集.
	 * 
	 * @author 郝超
	 * 创建于 2012-11-27,上午10:19:13.
	 * 
	 **************************************************************************************************************************/
	public class MapLayerInfoManager 
	{
		//排除的地图服务子图层
		private static var m_excludeSubLayers:ArrayCollection;
		
		
		/**
		 * 根据Map对象，从中读取并组织该对象中的所有地图图层信息
		 * @param map 当前地图对象
		 * @param excludeMapLayers 排除的地图服务图层
		 * @param excludeSubLayers 排除的地图服务子图层
		 * @return 组织后的所有地图图层信息集合
		 */
		/*public static function getMapLayersInfo(map:Map,
												excludeMapLayers:ArrayCollection, 
												excludeSubLayers:ArrayCollection):ArrayCollection
		{
			m_excludeMapLayers = excludeMapLayers;
			m_excludeSubLayers = excludeSubLayers;
			
			var layersInfoAC:ArrayCollection = new ArrayCollection();
			MapUtil.forEachMapLayer(map, function(layer:Layer):void
			{
				if(layer is ArcGISDynamicMapServiceLayer)
				{
					var layerItem:LayerItem = getLayerInfo(layer);
					if(layerItem)
						layersInfoAC.addItem(layerItem);
				}
			});
			
			return layersInfoAC;
		}*/
		
		
		/**
		 * 读取Map中的Layer对象，组织该图层中的图层信息。
		 * @param mapLayer 当前地图服务图层对象。
		 * @param allExcludeSubLayers 该Layer中的排除子图层。
		 * @return 组织后的地图图层信息对象。
		 */
		public static function getLayerInfo(mapLayer:Layer, allExcludeSubLayers:ArrayCollection):LayerItem
		{
			//过滤子图层
			m_excludeSubLayers = allExcludeSubLayers;
			
			//当前控制的动态图层
			var curDynLayer:ArcGISDynamicMapServiceLayer = mapLayer as ArcGISDynamicMapServiceLayer;
			if(! curDynLayer)
				return null;
			
			//监听图层更新完成，移除鼠标忙碌状态。
			//此处包含两种情况，一种是人机交互直接对checkbox进行操作，另外一种是通过代码直接对该图层进行更新操作。
			//这两种情况都会诱发图层更新事件。
			//curDynLayer.addEventListener(LayerEvent.UPDATE_END, removeBusyCursor, false, 0, true);
			//排除在外的子图层
			var excludeSubLayers:ArrayCollection = getExcludeSubLayersByService(m_excludeSubLayers, curDynLayer.id);
			
			//地图服务顶级节点
			var layerItem:LayerItem = new LayerItem();
			layerItem.layerId = -1;
			layerItem.layerUrl = curDynLayer.url;
			layerItem.label = curDynLayer.id ? curDynLayer.id : MapUtil.getMapServiceName(curDynLayer.url);
			layerItem.isLeafNode = false;
			layerItem.parent = null;
			layerItem.mapLayer = curDynLayer;
			
			//在递归过程中剔除非叶子图层节点 id
			removeVisibleLayerId(layerItem.layerId, curDynLayer);
			
			//遍历子级节点
			var layerInfos:Array = curDynLayer.layerInfos; 
			if(layerInfos)
			{
				var subLayerAC:ArrayCollection = new ArrayCollection();
				for(var j:int=0; j<layerInfos.length; j++)
				{
					var layerInfo:LayerInfo = layerInfos[j] as LayerInfo;
					
					//过滤图层
					if(excludeSubLayers.getItemIndex(layerInfo.name) >= 0)
					{
						continue;
					}
					
					//子图层节点
					var subLayerItem:LayerItem = new LayerItem();
					if(layerInfo.parentLayerId == -1)
					{
						subLayerItem.layerId = layerInfo.layerId;
						subLayerItem.label = layerInfo.name;
						subLayerItem.parent = layerItem;
						subLayerItem.mapLayer = curDynLayer;
						//子级节点的孩子节点集（递归遍历）
						if(layerInfo.subLayerIds && layerInfo.subLayerIds.length>0)
						{
							var childAC:ArrayCollection = new ArrayCollection();
							getSubLayerInfos(layerInfo, childAC, subLayerItem, curDynLayer, excludeSubLayers);
							subLayerItem.children = childAC;
							//设置复选框状态字段
							setLayerItemCheckedState(subLayerItem, curDynLayer);
							//非叶子节点
							subLayerItem.isLeafNode = false;
							//在递归过程中剔除非叶子图层节点 id
							removeVisibleLayerId(subLayerItem.layerId, curDynLayer);
						}
						else
						{
							//无任何孩子节点
							subLayerItem.children = null;
							if(curDynLayer.visible)
							{
								subLayerItem.state = layerInfo.defaultVisibility ? 1 : 0;
							}
							else
							{
								subLayerItem.state = 0;
							}
							
							//叶子节点
							subLayerItem.isLeafNode = true;
						}
						
						//如果当前节点项为全选中或半选中状态，则给当前节点项父项的选中孩子节点数加 1
						if(subLayerItem.state == 1 || subLayerItem.state == 2)
						{
							subLayerItem.parent.checkedChildren ++;
						}
						subLayerAC.addItem(subLayerItem);
					}
				}
				layerItem.children = subLayerAC;
				
				//设置顶级节点项复选框状态字段
				setLayerItemCheckedState(layerItem, curDynLayer);
				
				//遍历完成，返回
				return layerItem;
			}
			
			return null;
		}
		
		
		/**
		 * 递归遍历layerInfos。
		 * @param layerInfo 当前遍历的节点 LayerInfo。
		 * @param childAC 遍历结果存放的集合对象。
		 * @param parent 当前节点的父级节点项。
		 * @param mapLayer 当前子图层的顶级地图服务图层。
		 * @param excludeSubLayers 排除在外的子图层集合。
		 */
		private static function getSubLayerInfos(layerInfo:LayerInfo,
										  		 childAC:ArrayCollection,
										  		 parent:LayerItem,
										  		 mapLayer:ArcGISDynamicMapServiceLayer,
										  		 excludeSubLayers:ArrayCollection):void
		{
			for(var i:int=0; i<layerInfo.subLayerIds.length; i++)
			{
				var subLayerInfo:LayerInfo;
				var infoId:Number = Number(layerInfo.subLayerIds[i]);
				
				//循环匹配当前节点指定子图层对应的LayerInfo
				var layerInfos:Array = mapLayer.layerInfos;
				for(var j:int=0; j<layerInfos.length; j++)
				{
					if(infoId == LayerInfo(layerInfos[j]).layerId)
					{
						subLayerInfo = layerInfos[j];
						break;
					}
				}
				
				//过滤图层
				if(excludeSubLayers.getItemIndex(subLayerInfo.name) >= 0)
				{
					continue;
				}
				
				//子图层项
				var layerItem:LayerItem = new LayerItem();
				layerItem.layerId = subLayerInfo.layerId;
				layerItem.label = subLayerInfo.name;
				layerItem.parent = parent;
				layerItem.mapLayer = mapLayer;
				
				//递归遍历子图层项对应的孩子节点集
				if(subLayerInfo.subLayerIds && subLayerInfo.subLayerIds.length>0)
				{
					var children:ArrayCollection = new ArrayCollection();
					getSubLayerInfos(subLayerInfo, children, layerItem, mapLayer, excludeSubLayers);
					layerItem.children = children;
					
					//设置复选框状态字段
					setLayerItemCheckedState(layerItem, mapLayer);
					
					//非叶子节点
					layerItem.isLeafNode = false;
					
					//在递归过程中剔除非叶子图层节点 id
					removeVisibleLayerId(layerItem.layerId, mapLayer);
				}
				else
				{
					layerItem.children = null;
					if(mapLayer.visible)
					{
						layerItem.state = subLayerInfo.defaultVisibility ? 1 : 0;
					}
					else
					{
						layerItem.state = 0;
					}
					
					//叶子节点
					layerItem.isLeafNode = true;
				}
				
				//设置父级节点选中孩子节点数
				if(layerItem.state==1 || layerItem.state==2)
				{
					layerItem.parent.checkedChildren ++;
				}
				childAC.addItem(layerItem);
			}
		}
		
		/**
		 * 根据地图服务名称获取该服务中排除在外子图层集合。
		 * @param excludeSubLayers 全部的排除子图层集合。
		 * @param mapLayerName 当前地图服务名称。
		 * @return 当前服务中的待排除子图层集。
		 */
		private static function getExcludeSubLayersByService(excludeSubLayers:ArrayCollection, mapLayerName:String):ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection();
			if (excludeSubLayers)
			{
				for (var i:Number = 0; i < excludeSubLayers.length; i++)
				{
					if(excludeSubLayers[i].mapLayerName == mapLayerName)
					{
						result.addItem(excludeSubLayers[i].subLayerName);
					}
				}
			}
			
			return result;
		} 
		
		/**
		 * 设置指定节点复选框状态字段。
		 * @param layerItem 设置状态字段的节点项。
		 * @param mapLayer 顶级地图服务图层。
		 */
		private static function setLayerItemCheckedState(layerItem:LayerItem, mapLayer:ArcGISDynamicMapServiceLayer):void
		{
			if(mapLayer.visible)
			{
				if(layerItem.checkedChildren >= layerItem.children.length)
				{
					layerItem.state = 1;
				}
				else if(layerItem.checkedChildren < layerItem.children.length)
				{
					layerItem.state = layerItem.checkedChildren==0 ? 0 : 2;
				}
			}
			else
			{
				layerItem.state = 0;
			}
		}
		
		/**
		 * 从图层可见id集合中删除指定图层对应 id。
		 * @param id 待删除的指定图层 id。
		 * @param mapLayer 地图动态服务图层。
		 */
		private static function removeVisibleLayerId(id:Number, mapLayer:ArcGISDynamicMapServiceLayer):void
		{
			var visibleLayerIds:IList = mapLayer.visibleLayers;
			if(visibleLayerIds)
			{
				var idIndex:int = visibleLayerIds.getItemIndex(id);
				if(idIndex != -1)
				{
					visibleLayerIds.removeItemAt(idIndex);
				}
			}
		}
		
		
		/**
		 * 构造函数。
		 */
		public function MapLayerInfoManager()
		{
		} 
		
	} 
} 





