package com.xzdbd.ags4flex.utils
{ 
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.GeometryServiceSingleton;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	import com.esri.ags.tasks.supportClasses.OffsetParameters;
	import com.xzdbd.ags4flex.utils.supportClasses.LineCutParameters;
	
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncResponder;
	import mx.rpc.events.FaultEvent;

	
	/****************************************************
	 * 地图空间分析通用工具类.
	 * 
	 * @author 郝超
	 * 创建于 2013-5-27,上午8:38:28.
	 * 
	 *****************************************************/
	public class SpaceAnalysisUtils 
	{ 
		/**
		 * 操作结果成功返回。
		 */
		public static const RESULT_SUCCESS:String = "resultSuccess";
		/**
		 * 操作无结果返回，操作失败。
		 */
		public static const RESULT_FAULT:String = "resultFault";
		
		
		/**
		 * 对空间要素集进行缓冲分析(Buffer)。
		 * @param map 地图 Map 引用。
		 * @param geometrys 需要进行缓冲的 Geometry 对象集合。
		 * @param distance 缓冲的半径距离。
		 * @param Complete 缓冲完成时的回调函数。
		 */
		public static function bufferGeometry(map:Map, geometrys:Array, distance:Number, Complete:Function, Fault:Function=null):void
		{
			var bufferParameters:BufferParameters = new BufferParameters();
			bufferParameters.distances = [distance];
			bufferParameters.geometries = geometrys;
			bufferParameters.unit = GeometryService.UNIT_METER;
			bufferParameters.bufferSpatialReference = map.spatialReference;
			GeometryServiceSingleton.instance.buffer(bufferParameters, 
													 new AsyncResponder(bufferCompleteHandler, bufferFaultHandler, geometrys));
			
			function bufferCompleteHandler(bufferLastResult:Array, geometrys:Array = null):void
			{
				Complete(bufferLastResult, geometrys);
			}
			function bufferFaultHandler(event:FaultEvent, geometry:Geometry = null):void
			{
				if(Fault != null)
				{
					Fault("buffer 分析不成功，请重试！ \n 可能原因：" + event.fault.faultDetail);
				}
			}
		}
		
		
		/**
		 * 对线要素集进行偏移操作(OffSet)，为每一个线要素产生一条与之平行的线条。
		 * @param polylines 需要进行操作的线要素集合。
		 * @param distance 偏移的位移量，如果为正值将在原始线要素右侧构造新的曲线，为负值则在左侧构造偏移曲线。
		 * @param Complete 偏移操作完成时的回调函数。
		 */
		public static function offsetPolylines(polylines:Array, distance:Number, Complete:Function):void
		{
			var offsetParams:OffsetParameters = new OffsetParameters();
			offsetParams.geometries = polylines;
			offsetParams.offsetDistance = distance;
			offsetParams.offsetUnit = GeometryService.UNIT_METER;
			offsetParams.offsetHow = OffsetParameters.OFFSET_ROUNDED;
			GeometryServiceSingleton.instance.offset(offsetParams, new AsyncResponder(onOffsetResult, onOffsetFault));
			function onOffsetResult(offsetLastResult:Array, token:Object = null):void
			{
				Complete(offsetLastResult, polylines);
			}
			function onOffsetFault(info:Object, token:Object = null):void
			{
				Alert.show("偏移操作不成功！", "操作提示...");
			}
		}
		
		
		/**
		 * 对线要素进行双向偏移，利用偏移后的两条线构建一个面要素。
		 * @param map 地图 Map 引用。
		 * @param polyline 需要进行操作的线要素。
		 * @param distance 偏移的位移量。
		 * @param Complete 偏移操作完成时的回调函数。
		 */
		public static function offsetLineToPolygon(map:Map, polyline:Polyline, distance:Number, Complete:Function):void
		{
			//对 Polyline 进行 simplify 处理。
			GeometryServiceSingleton.instance.simplify([polyline], new AsyncResponder(simplifyComplete, simplifyFault));
			function simplifyComplete(simplifyLastResult:Array, token:Object = null):void
			{
				//对 Polyline 进行正偏移操作。
				offsetPolylines([ simplifyLastResult[0] ], distance, offsetComplete_right);
				function offsetComplete_right(offsetLastResult:Array, token:Object = null):void
				{
					var polyline_right:Polyline = offsetLastResult[0] as Polyline;
					
					//对 Polyline 进行正偏移操作。
					offsetPolylines([ polyline ], -distance, offsetComplete_left);
					function offsetComplete_left(offsetLastResult:Array, token:Object = null):void
					{
						var polyline_left:Polyline = offsetLastResult[0] as Polyline;
						
						//将两次偏移的线对应的 path 构造成一个 ring 环，进一步构造 Polygon。
						var ring:Array = (polyline_left.paths[0] as Array).concat((polyline_right.paths[0] as Array).reverse());
						var newPolygon:Polygon = new Polygon([ring], map.spatialReference);
						
						//回调
						//Complete(newPolygon, token[0]);
						
						//对构造的面进行 convexHull（凸包）处理，生成一个完整范围的 Polygon。
						GeometryServiceSingleton.instance.convexHull([newPolygon], map.spatialReference, new AsyncResponder(convexHullComplete, convexHullFault));
						function convexHullComplete(convexHullLastResult:Geometry, token:Object = null):void
						{
							//回调
							Complete(convexHullLastResult);
						}
						function convexHullFault(info:Object, token:Object = null):void
						{
							Alert.show("凸包操作不成功！", "操作提示...");
						}
						
					}
				}
			}
			function simplifyFault(info:Object, token:Object = null):void
			{
				Alert.show("simplify 操作不成功！", "操作提示...");
			}
		}
		
		
		
		//======================================= 线段裁剪分析（开始） =============================================
		
		/**
		 * 执行线段裁剪。
		 * <br>根据参数提供的线要素对象、起点和终点断点等，裁剪出起点和断点之间的线段。
		 * @param lineCutParams 线段裁剪参数对象，包含Map对象、线要素对象、起点和终点断点等。
		 * @param Complete 调用成功完成时的回调函数，该函数形式为：
		 * （resultLine为裁剪的线段对象，endPoint为裁剪结果的真实终点，info则包含一些操作信息）
		 * <listing version="3.0">function Complete(resultLine:Polyline, endPoint:MapPoint, info:String);</listing>
		 * 
		 * @param Fault 调用失败时的回调函数。
		 * 
		 * @see com.xzdbd.ags4flex.utils.mapUtils.supportClasses.LineCutParameters.
		 */
		public static function executeLineCut(lineCutParams:LineCutParameters, Complete:Function, Fault:Function=null):void
		{
			CursorManager.setBusyCursor();
			
			var sourceGraphic:Graphic = lineCutParams.sourceGraphic;
			var breakPoint:MapPoint = lineCutParams.breakPoint;
			
			if(sourceGraphic && sourceGraphic.geometry is Polyline)
			{
				//构造面，偏移为上下左右各0.1个地图单位（米）。
				//主要目的是为了产生一个面来和线图层求相交，从而求得需要打断的线要素对象。
				//因为偏移的距离特别小，所以该面可以近似等价于断点本身。
				var extent:Extent = new Extent(breakPoint.x-0.1, breakPoint.y-0.1, breakPoint.x+0.1, breakPoint.y+0.1);
				
				//第一次执行 intersect 操作，求面和线的交集，即线对象
				GeometryServiceSingleton.instance.intersect([sourceGraphic.geometry], 
															extent, 
															new AsyncResponder(onResult, onFault, lineCutParams));
				
				//执行intersect操作成功完成
				function onResult(intersectLastResult:Array, params:LineCutParameters = null):void
				{
					//成功求得相交线对象
					//因为本次求交的原始面要素半径非常小，几乎等价于断点本身，因此可以直接将该断点作为目标线上的点处理
					//而本次相交操作的结果因为原始面半径很小，截取的线段也可以视为一个点，就是断点
					if(intersectLastResult.length > 0 && intersectLastResult[0].paths.length > 0)
					{
						//var resultLine:Polyline = intersectLastResult[0] as Polyline;
						
						//如果“点”在线上，则直接以该点为终点构造最终的打断线对象
						//构建打断后新的Polyline对象
						var resultPolyline:Polyline = createBreakPolyline(breakPoint, params);
						
						//回调
						Complete(resultPolyline, breakPoint);
						CursorManager.removeBusyCursor();
					}
					else
					{
						//如果本次求交不成功，即点不在线上，就进一步执行缓冲操作，生成一个面，再做进一步相交分析
						bufferAndIntersect(params, Complete, Fault);
					}
				}
				
				function onFault(info:Object, token:Object = null):void
				{
					CursorManager.removeBusyCursor();
					Fault("intersect 分析不成功，请重试！ \n 可能原因：" + info.faultDetail);
				}
			}
			
		}
		
		/**
		 * 利用缓冲产生的面与原始线进行 intersect 分析操作。
		 * @param lineCutParams 线段裁剪参数对象，包含Map对象、线要素对象、起点和终点断点等。
		 * @param Complete 调用成功完成时的回调函数。
		 * @param Fault 调用失败时的回调函数。
		 */
		private static function bufferAndIntersect(lineCutParams:LineCutParameters, Complete:Function, Fault:Function=null):void
		{
			var map:Map = lineCutParams.map;
			var sourceGraphic:Graphic = lineCutParams.sourceGraphic;
			var startPoint:MapPoint = lineCutParams.startPoint;
			var breakPoint:MapPoint = lineCutParams.breakPoint;
			var bufferDistance:Number = lineCutParams.bufferDistance;
			
			//缓冲分析
			SpaceAnalysisUtils.bufferGeometry(map, [ breakPoint ], bufferDistance, bufferCompleteHandler, bufferFaultHandler);
			function bufferCompleteHandler(polygons:Array, geometrys:Array = null):void
			{
				var bufferPolygon:Polygon = polygons[0] as Polygon;
				if(bufferPolygon != null)
				{
					//利用缓冲产生的面，进一步做 intersect 分析
					GeometryServiceSingleton.instance.intersect([sourceGraphic.geometry], 
																bufferPolygon, 
																new AsyncResponder(onResult, onFault, lineCutParams));
				}
				else
				{
					CursorManager.removeBusyCursor();
					Fault("缓冲分析不成功！");
				}
			}
			function bufferFaultHandler(faultInfo:String):void
			{
				CursorManager.removeBusyCursor();
				Fault(faultInfo);
			}
			
			//执行intersect分析完成
			function onResult(intersectLastResult:Array, params:LineCutParameters = null):void
			{
				CursorManager.removeBusyCursor();
				var geom:Geometry = intersectLastResult[0] as Geometry;
				if(geom == null || geom.type != Geometry.POLYLINE || !Polyline(geom).getPoint(0, 0))
				{
					//回调
					Complete(null, null, "当前点没有命中任何目标，请重试！");
					return;
				}
				
				//从缓冲区域中的打断线上获取线上真实断点
				var breakPointOnLine:MapPoint = getBreakPointInBuffer(geom as Polyline);
				
				//构建裁剪产生的新的Polyline对象
				var resultPolyline:Polyline = createBreakPolyline(breakPointOnLine, params);
				
				//回调
				Complete(resultPolyline, breakPointOnLine);
			}
			
			function onFault(info:Object, token:Object = null):void
			{
				CursorManager.removeBusyCursor();
				Fault("intersect 分析不成功，请重试！ \n 可能原因：" + info.faultDetail);
			}
		}
		
		/**
		 * 在缓冲区域中的打断线段中,确定其中点，作为线上断点。
		 * @param resultLine 缓冲区域中的打断线段。
		 * @return 线上断点.
		 */
		private static function getBreakPointInBuffer(resultLine:Polyline):MapPoint
		{
			var pathCount:Number = resultLine.paths.length;
			//存储Polyline中的所有的点
			var pointArr:Array = [];
			for(var i:int=0; i<resultLine.paths.length; i++)
			{
				var path:Array = resultLine.paths[i] as Array;
				for(var j:int=0; j<path.length; j++)
				{
					pointArr.push(path[j]);
				}
			}
			
			//查找缓冲区中打断线的中点，即Polyline中的线上断点
			//如果打断线中的节点数为奇数，则取中间点
			//如果打断线中的节点数为偶数，则取中间两个点的中点
			var sPoint:MapPoint;
			var ePoint:MapPoint;
			var mPoint:MapPoint;
			//求中间节点
			var halfIndex:int = pointArr.length / 2;
			if(pointArr.length % 2 == 0)
			{
				sPoint = pointArr[halfIndex - 1];
				ePoint = pointArr[halfIndex];
				mPoint = new MapPoint((sPoint.x + ePoint.x) / 2, (sPoint.y + ePoint.y) / 2);
			}
			else
			{
				mPoint = pointArr[halfIndex];
			}
			
			return mPoint;
		}
		
		/**
		 * 通过Polyline上的任意点打断该Polyline，并构建新的Polyline对象。
		 * @param breakPoint 断点。
		 * @param params 线段裁剪参数对象。
		 * @return 构建的新的Polyline。
		 */
		private static function createBreakPolyline(breakPointOnLine:MapPoint, params:LineCutParameters):Polyline
		{
			var sourceLine:Polyline = params.sourceGraphic.geometry as Polyline;
			
			//存储起点到断点之间的打断后Polyline的节点
			var newPaths:Array = [];
			
			//判断线型的真实起点（河流上游等。。。）
			var paths:Array = sourceLine.paths;
			var defaultStartPoint:MapPoint = paths[0][0] as MapPoint;
			var defaultEndPoint:MapPoint = paths[paths.length-1][paths[paths.length-1].length-1] as MapPoint;
			
			//一些局部临时变量
			var i:int, j:int; //循环计数
			var path:Array; //当前操作的path
			var newPath:Array; //当前新建的path
			var firstPoint:MapPoint; //循环遍历的当前点
			var secondPoint:MapPoint; //循环遍历的下一个点
			var flag:Boolean; //指示当前循环是否遍历到终点（断点所在）
			
			//以10m的误差进行判别，如果规定的起点不是线型默认终点，那么就以默认起点作为计算起点
			if(Math.abs(defaultEndPoint.x - params.startPoint.x) < 10 && 
				Math.abs(defaultEndPoint.y - params.startPoint.y) < 10)
			{
				//startPoint = defaultEndPoint;
				//从默认终点开始遍历原始Polyline的节点
				for(i=sourceLine.paths.length-1; i>=0; i--)
				{
					path = sourceLine.paths[i] as Array;
					newPath = [];
					flag = false;
					for(j=path.length-1; j>=1; j--)
					{
						//构建新的path
						newPath.push(path[j]);
						//当前点和下一点逐一处理
						firstPoint = path[j] as MapPoint;
						secondPoint = path[j-1] as MapPoint;
						//检测已取得的断点是否在当前点和下一节点之间，如果是，则当前点为倒数第二个点，已取得的断点为终点
						if(checkBreakPoint(breakPointOnLine, firstPoint, secondPoint))
						{
							flag = true;
							//加入终点
							newPath.push(breakPointOnLine);
							//添加path到paths
							newPaths.push(newPath);
							break;
						}
					}
					//如果当前循环未找到终点，则添加当前path到paths
					if(!flag)
						newPaths.push(path);
					else
						break;
				}
			}
			else
			{
				//startPoint = defaultStartPoint;
				//从默认起点开始遍历原始Polyline的节点
				for(i=0; i<sourceLine.paths.length; i++)
				{
					path = sourceLine.paths[i] as Array;
					newPath = [];
					flag = false;
					for(j=0; j<path.length-1; j++)
					{
						//构建新的path
						newPath.push(path[j]);
						//当前点和下一点逐一处理
						firstPoint = path[j] as MapPoint;
						secondPoint = path[j+1] as MapPoint;
						//检测已取得的断点是否在当前点和下一节点之间，如果是，则当前点为倒数第二个点，已取得的断点为终点
						if(checkBreakPoint(breakPointOnLine, firstPoint, secondPoint))
						{
							flag = true;
							//加入终点
							newPath.push(breakPointOnLine);
							//添加path到paths
							newPaths.push(newPath);
							break;
						}
					}
					//如果当前循环未找到终点，则添加当前path到paths
					if(!flag)
						newPaths.push(path);
					else
						break;
				}
			}
			
			//构建打断后新的Polyline对象
			var newLine:Polyline = new Polyline(newPaths);
			newLine.spatialReference = params.map.spatialReference;
			
			return newLine;
		}
		
		/**
		 * 检测当前点是否在起点和终点之间。<br>
		 * 采用的方法是：先计算两个端点与目标点之间X方向的差值和Y方向的差值，再作进一步对比。
		 */
		private static function checkBreakPoint(sourcePoint:MapPoint, firstPoint:MapPoint, secondPoint:MapPoint):Boolean
		{
			//目标点与两端坐标差值
			var deltaX1:Number = Math.abs(sourcePoint.x - firstPoint.x);
			var deltaY1:Number = Math.abs(sourcePoint.y - firstPoint.y);
			var deltaX2:Number = Math.abs(sourcePoint.x - secondPoint.x);
			var deltaY2:Number = Math.abs(sourcePoint.y - secondPoint.y);
			//两端坐标差值
			var deltaX0:Number = Math.abs(secondPoint.x - firstPoint.x);
			var deltaY0:Number = Math.abs(secondPoint.y - firstPoint.y);
			
			//设置容差为1，判断目标点是否与起点坐标重合
			if(deltaX1 < 1 && deltaY1 < 1) 
				return true;
			else if(deltaX1 <= deltaX0 && deltaX2 <= deltaX0 && deltaY1 <= deltaY0 && deltaY2 <= deltaY0 )
				return true;
			
			return false;
		}
		
		
		//======================================= 线段裁剪分析（结束） =============================================
		
		
		
		/**
		 * 构造函数。
		 */
		public function SpaceAnalysisUtils()
		{
		} 
		
	} 
} 






	
	
	
	

	

