package com.xzdbd.ags4flex.components.layerControlClasses.classes
{ 
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.Layer;
	import com.xzdbd.ags4flex.components.layerControlClasses.checkTree.CheckTree;
	import com.xzdbd.ags4flex.events.LayerSwitchEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	
	/**************************************************
	 * 图层列表树组件实现类.
	 * 
	 * @author 郝超
	 * 创建于 2012-11-27,上午09:53:28.
	 * 
	 **************************************************/
	public class LayerList extends CheckTree
	{
		/**
		 * 构造函数。
		 */
		public function LayerList()
		{
			super();
			addEventListener(LayerSwitchEvent.SELECT_ITEMS_CHANGED, OnSelectChangeHandler);
		} 
		
		/**
		 * 打开指定子图层（集）。
		 * @param mapLayer 所属地图服务图层。
		 * @param layers 需要显示的子图层对象集合。
		 */
		public function showLayer(mapLayer:Layer, layers:Array):void
		{
			var visibleLayers:IList;
			if(mapLayer is ArcGISDynamicMapServiceLayer)
			{
				visibleLayers = ArcGISDynamicMapServiceLayer(mapLayer).visibleLayers;
				for each(var layerItem:LayerItem in layers)
				{
					var idIndex:int = visibleLayers.getItemIndex(layerItem.layerId);
					if (idIndex == -1)
					{
						if(layerItem.isLeafNode)
						{
							visibleLayers.addItem(layerItem.layerId); 
							if(! ArcGISDynamicMapServiceLayer(mapLayer).visible)
							{
								ArcGISDynamicMapServiceLayer(mapLayer).visible = true;
							}
						}
					}
				}
			}
		}
		
		/**
		 * 关闭指定子图层（集）。
		 * @param mapLayer 所属地图服务图层。
		 * @param layerIds 需要隐藏的子图层id的集合。
		 */
		public function hideLayer(mapLayer:Layer, layers:Array):void
		{
			var visibleLayers:IList;
			if(mapLayer is ArcGISDynamicMapServiceLayer)
			{
				visibleLayers = ArcGISDynamicMapServiceLayer(mapLayer).visibleLayers;
			}
			else
			{
				return;
			}
			
			for each(var layerItem:LayerItem in layers)
			{
				var idIndex:int = visibleLayers.getItemIndex(layerItem.layerId);
				if(idIndex != -1)
				{
					if(layerItem.isLeafNode)
					{
						visibleLayers.removeItemAt(idIndex);
					}
					var parentIds:Array = [];
					getParentIds(layerItem, parentIds);
					for each(var item:Object in parentIds)
					{
						var layerId:Number = Number(item);
						if(visibleLayers.getItemIndex(layerId) != -1)
						{
							visibleLayers.removeItemAt(visibleLayers.getItemIndex(layerId));
						}
					}
				}
			}
		}
		
		/**
		 * 向上递归查找指定节点的所有父节点。
		 * @param layerItem 当前节点对象。
		 * @param parentIds 存放父节点的集合。
		 */
		public function getParentIds(layerItem:LayerItem, parentIds:Array):void
		{
			if(layerItem.parent && layerItem.parent.parent)
			{
				parentIds.push(layerItem.parent.layerId);
				getParentIds(layerItem.parent, parentIds);
			}
			else
			{
				return;
			}
		}
		
		/**
		 * 树节点选择值变化时的处理函数。
		 */
		private function OnSelectChangeHandler(event:LayerSwitchEvent):void
		{
			if(event.data)
			{
				//从事件中获取出当前更改选中状态的“根节点”项目
				var changedItemsArr:ArrayCollection = event.data.data as ArrayCollection;
				if(changedItemsArr && changedItemsArr.length>0)
				{
					//设置忙碌鼠标样式
					if(this.useBusyCursor)
					{
						cursorManager.setBusyCursor();
					}
					
					var mapLayer:Layer = LayerItem(changedItemsArr.getItemAt(0)).mapLayer;
					var changedLayers:Array = [];
					for each(var item:LayerItem in changedItemsArr)
					{
						changedLayers.push(item);
					}
					if(event.data.state == true)
					{
						showLayer(mapLayer, changedLayers);
					}
					else
					{
						hideLayer(mapLayer, changedLayers);
					}
				}
			}
		}
		
	} 
} 





