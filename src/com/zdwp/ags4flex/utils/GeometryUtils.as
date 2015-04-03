package com.zdwp.ags4flex.utils
{ 
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	
	import flash.geom.Point;


	/****************************************************
	 * Geometry相关工具类.
	 * 
	 * @author 郝超
	 * 创建于 2013-6-6,上午11:05:41.
	 * 
	 *****************************************************/
	public class GeometryUtils 
	{ 
		
		/**
		 * 获取 Geometry 中心点。
		 * @param geometry 指定的 Geometry 对象。
		 * @return Geometry 的中心点。
		 */
		public static function getGeomCenter(geometry:Geometry):MapPoint
		{
			var point:MapPoint;
			if (geometry)
			{
				switch (geometry.type)
				{
					case Geometry.MAPPOINT:
					{
						point = geometry as MapPoint;
						break;
					}
					case Geometry.POLYLINE:
					{
						const pl:Polyline = geometry as Polyline;
						var pathIndex:int;
						var midPath:Array = [];
						var pathCount:Number = pl.paths.length;
						if(pathCount%2 != 0)
						{
							pathIndex = int(pathCount / 2);
							midPath = pl.paths[pathIndex];
							if(midPath.length <= 2)
							{
								point = new MapPoint();
								point.x = (midPath[0].x + midPath[midPath.length-1].x) / 2;
								point.y = (midPath[0].y + midPath[midPath.length-1].y) / 2;
							}
							else
							{
								point = midPath[int(midPath.length / 2)];
							}
						}
						else
						{
							pathIndex = int(pathCount / 2);
							point = pl.getPoint(pathIndex, 0);
						}	
						break;
					}
					case Geometry.EXTENT:
					{
						const ext:Extent = geometry as Extent;
						point = ext.center;
						break;
					}
					case Geometry.POLYGON:
					{
						const poly:Polygon = geometry as Polygon;
						point = poly.extent.center;
						if(!poly.contains(point))
						{
							var pg:Polygon = new Polygon();
							pg.addRing(poly.rings[0]);
							point = pg.extent.center;
						}
						break;
					}
				}
			}
			
			return point;
		}
		
		
		/**
		 * 通过 MapPoint 构造一个矩形区域，并以一定的屏幕像素范围转化成地图上得 Extent。
		 * @param map 地图 Map 对象。
		 * @param centerPoint 构造中心点。
		 * @param tolerance 构造偏移量。
		 * @return 新生成的Extent对象。
		 */
		public static function createExtentAroundMapPoint(map:Map, centerPoint:MapPoint, tolerance:Number):Extent
		{
			//转换成屏幕坐标
			var screenPoint:Point = map.toScreen(centerPoint as MapPoint);
			
			//根据屏幕坐标生成矩形区域控制点（左上和右下）
			var upperLeftScreenPoint:Point = new Point(screenPoint.x - tolerance, screenPoint.y - tolerance);
			var lowerRightScreenPoint:Point = new Point(screenPoint.x + tolerance, screenPoint.y + tolerance);
			
			//转换到地图坐标
			var upperLeftMapPoint:MapPoint = map.toMap(upperLeftScreenPoint);
			var lowerRightMapPoint:MapPoint = map.toMap(lowerRightScreenPoint);
			
			//构造Extent
			var newExtent:Extent = new Extent(upperLeftMapPoint.x, upperLeftMapPoint.y, lowerRightMapPoint.x, lowerRightMapPoint.y, map.spatialReference);
			
			return newExtent;
		}
		
		
		/**
		 * 构造函数。
		 */
		public function GeometryUtils()
		{
		} 
	} 
} 











