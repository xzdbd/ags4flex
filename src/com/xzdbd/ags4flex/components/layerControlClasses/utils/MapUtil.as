package com.xzdbd.ags4flex.components.layerControlClasses.utils
{
	import com.esri.ags.Map;
	import com.esri.ags.layers.Layer;
	
	import mx.utils.StringUtil;

	
	/*********************************************
	 * 地图(Map)工具类.
	 * 
	 * @author 郝超
	 * 创建于 2012-11-27,上午10:19:13.
	 * 
	 *********************************************/
	public final class MapUtil
	{
		
		/**
		 * 重复迭代  map 中的所有 layer，并将每个图层对象传入指定 func 函数。
		 * @param map  map对象。
		 * @param func 指定格式的处理函数，如： <code>func(layer:Layer):void</code>.
		 */
		public static function forEachMapLayer(map:Map, func:Function):void
		{
			if (map)
			{
				for each (var layer:Layer in map.layers)
				{
					func(layer);
				}
			}
		}
		
		
		/**
		 * 根据地图服务Url获取该地图服务(MapServer)的服务名称。
		 * @param url 地图服务的Url。
		 * @return 地图服务名称。
		 */
		public static function getMapServiceName(url:String):String
		{
			if(!url || StringUtil.trim(url) == "")
			{
				return null;
			}
			var lIndex:int = url.indexOf("/services/");
			var rIndex:int = url.lastIndexOf("/MapServer");
			var serviceName:String = url.substring(lIndex+String(/services/).length, rIndex);
			
			return serviceName;
		}

	}

}













