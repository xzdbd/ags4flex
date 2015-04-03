package com.zdwp.ags4flex.managers
{ 
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.tasks.IdentifyTask;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.IdentifyParameters;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.AsyncResponder;
	import mx.utils.ObjectUtil;


	/***********************************************************************************
	 * 空间分析查询管理类（包括 QueryTask 和 IdentifyTask）。
	 * 
	 * @example
     * 下面代码演示如何使用 <code>QueryManager</code> 类： 
	 * <p>
	 * 1、使用 QueryManager 类进行 Query 查询：
	 * </p>
	 * <listing version="3.0">
	 * //设置 Query 查询参数（详见函数说明）
	 * QueryManager.getInstance().setQueryParams(map, dikeLayer, "1=1", null, []);
	 * 
	 * //执行查询操作
	 * QueryManager.getInstance().executeQuery(onResult, 0nFault);
	 * 
	 * function onResult(featureSet:FeatureSet, featureLayer:FeatureLayer):void
	 * {
	 * 	//查询成功返回执行过程
	 * }
	 * function 0nFault(faultInfo:String, featureLayer:FeatureLayer):void
	 * {
	 * 	//查询失败执行过程
	 * }
	 * </listing>
	 * 
	 * <p>
	 * 2、使用 QueryManager 类进行 Identify 查询：
	 * </p>
	 * <listing version="3.0">
	 * //设置 Identify 查询参数（详见函数说明）
	 * QueryManager.getInstance().setIdentifyQuery(map, curQueryLayer.url, centerPoint, 6, layerIds);
	 * 
	 * //执行查询操作
	 * QueryManager.getInstance().executeQuery(onResult, onFault);
	 * 
	 * function onResult(identifyResults:Array, geom:Geometry):void
	 * {
	 * 	//查询成功返回执行过程
	 * }
	 * function onFault(event:FaultEvent):void
	 * {
	 * 	//查询失败执行过程
	 * }
	 * </listing>
	 * 
	 * @author 郝超
	 * 创建于 2012-9-26,上午10:31:27 。
	 * 
	 ***********************************************************************************/
	public class QueryManager 
	{
		//======================= 空间查询类别 ==============================
		/**
		 * 根据关键字进行 Query 查询。（空间查询类别）
		 */
		public static const TEXT_QUERY:String = "textQuery";
		
		/**
		 * 根据 Geometry 进行 Query 查询。（空间查询类别）
		 */
		public static const GEOMETRY_QUERY:String = "geometryQuery";
		
		/**
		 * Identify 查询。（空间查询类别）
		 */
		public static const IDENTIFY_QUERY:String = "identifyQuery"; 
		
		
		//======================= Query查询类型 ==============================
		/**
		 * 查询要素集。（Query查询类型）
		 */
		public static const QUERY_FEATURE:String = "queryFeature";
		
		/**
		 * 查询要素数量。（Query查询类型）
		 */
		public static const QUERY_COUNT:String = "queryCount";
		
		/**
		 * 查询要素 ObjectId 集。（Query查询类型）
		 */
		public static const QUERY_IDS:String = "queryIds";
		
		
		/**
		 * 单例。
		 */
		private static var queryManager:QueryManager;
		
		
		/**
		 * 获取单例。
		 * @param QueryManager 类单例对象。
		 */
		public static function getInstance():QueryManager
		{
			if(queryManager == null)
				queryManager = new QueryManager();
			
			return queryManager;
		}
		
		
		//引用的map对象
		private var map:Map;
		//空间查询类型
		private var queryType:String;
		//查询结果是否返回Geometry信息
		private var returnGeometry:Boolean;
		
		//==================== Query =======================
		//QueryTask
		private var queryTask:QueryTask;
		//Query
		private var query:Query;
		//待查询子图层
		private var queryLayer:FeatureLayer;
		//Text关键字查询条件
		private var condition:String;
		//查询对应的Geometry
		private var geometry:Geometry;
		//查询指定的objectid
		private var objectIds:Array;
		//查询结果输出字段
		private var outFields:Array;
		//查询结果排序字段
		private var orderByFields:Array;
		
		//==================== Identify =======================
		//待查询地图Rest服务Url
		private var serviceUrl:String;
		//点查询指定的目标子图层Id数组
		private var identifyLayerIds:Array;
		//点查询缓冲容差
		private var tolerance:Number;
		
		
		/**
		 * 构造函数。
		 */
		public function QueryManager()
		{
			queryType = "";
		}
		
		
		/**
		 * Query 查询参数设置。
		 * @param map 地图对象。
		 * @param layer 查询的目标子图层（FeatureLayer）。
		 * @param queryCondition Query对应的查询条件，若为Geometry查询则该参数应该为一个Geometry对象，若为Text关键字查询，该参数应该为一个where条件。
		 * @param objectIds 查询限定的要素ObjectId集合。
		 * @param outFields 查询结果输出的字段数组。
		 * @param orderByFields 查询结果的排序字段数组。
		 * @param returnGeometry 查询结果是否返回Geometry信息，默认为true。
		 */
		public function setQueryParams(map:Map, 
									   layer:FeatureLayer,
									   queryCondition:Object,
									   objectIds:Array=null,
									   outFields:Array=null,
									   orderByFields:Array=null,
									   returnGeometry:Boolean=true):void
		{
			//重置参数
			resetParams();
			
			this.queryType = queryCondition is Geometry ? GEOMETRY_QUERY : TEXT_QUERY;
			this.map = map;
			this.queryLayer = layer;
			this.condition = queryCondition is String ? queryCondition.toString() : "";
			this.geometry = queryCondition is Geometry ? queryCondition as Geometry : null;
			this.objectIds = objectIds;
			this.returnGeometry = returnGeometry;
			this.outFields = outFields;
			this.orderByFields = orderByFields;
		}
		
		
		/**
		 * Identify 查询参数设置。
		 * @param map 地图对象。
		 * @param serviceUrl 点查询地图Rest服务地址。
		 * @param geom 点查询对应点Geometry对象。
		 * @param tolerance 点查询缓冲容差。
		 * @param layerIds 点查询子图层id数组，默认为全部子图层。
		 * @param returnGeometry 查询结果是否返回Geometry信息，默认为true。
		 */
		public function setIdentifyQuery(map:Map, 
										 serviceUrl:String,
										 geom:Geometry,
										 tolerance:Number,
										 layerIds:Array=null,
										 returnGeometry:Boolean=true):void
		{
			this.queryType = IDENTIFY_QUERY;
			this.map = map;
			this.serviceUrl = serviceUrl;
			this.geometry = geom;
			this.tolerance = tolerance;
			if(layerIds)
			{
				this.identifyLayerIds = layerIds;
			}
			this.returnGeometry = returnGeometry;
		}
		
		
		/**
		 * 根据当前查询参数设置，执行相应 Query 查询。
		 * @param Complete 查询成功回调的函数。
		 * @param Fault 查询失败回调的函数。
		 * @param type 查询过程类型，QUERY_FEATURE：基础要素查询；QUERY_COUNT：查询要素总数；QUERY_IDS：查询要素ObjectId集合。
		 */
		public function executeQuery(Complete:Function, Fault:Function = null, type:String=QUERY_FEATURE):void
		{
			//监听图层成功加载
			if (queryLayer && !queryLayer.loaded)
			{
				queryLayer.addEventListener(LayerEvent.LOAD, queryLayer_loadHandler);
				function queryLayer_loadHandler(event:LayerEvent):void
				{
					executeQuery(Complete, Fault, type);
				}
				return;
			}
			
			//执行查询
			switch(this.queryType)
			{
				case TEXT_QUERY:
				case GEOMETRY_QUERY:
					if(type == QUERY_FEATURE)
					{
						//要素查询
						executeQueryTask(queryLayer, Complete, Fault);
					}
					else
					{
						//附加信息查询
						executeAdditionalQuery(queryLayer, type, Complete, Fault);
					}
					break;
				case IDENTIFY_QUERY:
					//Identify查询
					executeIdentifyQuery(Complete, Fault);
					break;
			}
		}
		
		
		/**
		 * 根据关键字Text或Geometry查询图层相应要素数量或ObjectId集合。
		 * @param queryLayer 查询的要素图层。
		 * @param type 查询过程类型。
		 * @param Complete 查询成功回调的函数(参数为查询的结果集和待查询图层的引用)。
		 * @param Fault 查询失败回调的函数，默认为 null。
		 */
		private function executeAdditionalQuery(queryLayer:FeatureLayer, type:String, Complete:Function, Fault:Function = null):void
		{
			CursorManager.setBusyCursor();
			
			//Query
			query = query ? query : new Query();
			query.returnGeometry = false;
			
			//设置查询条件
			if(this.queryType == TEXT_QUERY)
			{
				query.where = condition;
			}
			else if(this.queryType == GEOMETRY_QUERY)
			{
				query.geometry = geometry;
			}
			
			//根据查询的不同类型分别执行相应操作
			if(type == QUERY_COUNT)
			{
				queryLayer.queryCount(query, new AsyncResponder(onResultCount, onFault, queryLayer));
			}
			else if(type == QUERY_IDS)
			{
				queryLayer.queryIds(query, new AsyncResponder(onResultIds, onFault, queryLayer));
			}
			
			//查新要素数量成功回调函数
			function onResultCount(featureCount:Number, queryLayer:FeatureLayer = null):void
			{
				Complete(featureCount, queryLayer);
				CursorManager.removeBusyCursor();
			}
			
			//查新要素ObjectId集成功回调函数
			function onResultIds(featureIds:Array, queryLayer:FeatureLayer = null):void
			{
				Complete(featureIds, queryLayer);
				CursorManager.removeBusyCursor();
			}
			
			//查询失败
			function onFault(info:Object, queryLayer:FeatureLayer = null):void
			{
				if(Fault != null)
				{
					Fault(info, queryLayer);
				}
				if(queryLayer && queryLayer.layerDetails)
				{
					Alert.show("图层[" + queryLayer.layerDetails.name + "]查询不成功！\n 可能原因："+info.faultDetail, "操作提示...");
				}
				CursorManager.removeBusyCursor();
			}
		}
		
		
		/**
		 * 根据关键字Text或Geometry执行空间要素集查询。
		 * @param queryLayer 查询的要素图层。
		 * @param Complete 查询成功回调的函数(参数为查询的结果集和待查询图层的引用)。
		 * @param Fault 查询失败回调的函数，默认为 null。
		 */
		private function executeQueryTask(queryLayer:FeatureLayer, Complete:Function, Fault:Function = null):void
		{
			CursorManager.setBusyCursor();
			
			//QueryTask
			queryTask = queryTask ? queryTask : new QueryTask();
			queryTask.url = queryLayer.url;
			
			//Query
			query = query ? query : new Query();
			query.outSpatialReference = map.spatialReference;
			query.returnGeometry = returnGeometry;
			
			//params
			query.outFields = (outFields && outFields.length > 0) ? outFields : null;
			query.orderByFields = (orderByFields && orderByFields.length > 0) ? orderByFields : null;
			
			//根据不同的Query查询类型，执行不同的过程
			if(this.queryType == TEXT_QUERY)
			{
				query.where = condition;
				query.geometry = null;
				if(this.objectIds && this.objectIds.length > 0)
				{
					query.where = "";
					query.objectIds = this.objectIds;
				}
			}
			else if(this.queryType == GEOMETRY_QUERY)
			{
				query.spatialRelationship = Query.SPATIAL_REL_INTERSECTS;
				query.geometry = geometry;
				query.where = "";
			}
			
			//执行查询
			queryTask.execute(query, new AsyncResponder(onResult, onFault, queryLayer));
			
			function onResult(featureSet:FeatureSet, queryLayer:FeatureLayer = null):void
			{
				//查询结果预处理
				graphicsPretreatment(featureSet);
				//回调
				Complete(featureSet, queryLayer);
				CursorManager.removeBusyCursor();
			}
			
			function onFault(info:Object, queryLayer:FeatureLayer = null):void
			{
				if(Fault != null)
				{
					Fault(info, queryLayer);
				}
				if(queryLayer && queryLayer.layerDetails)
				{
					Alert.show("图层[" + queryLayer.layerDetails.name + "]查询不成功！\n 可能原因："+info.faultDetail, "操作提示...");
				}
				CursorManager.removeBusyCursor();
			}
		}
		
		
		/**
		 * 点查询（Identify）。
		 * @param Complete 查询成功回调函数。
		 * @param Fault 查询失败回调函数，默认为 null。
		 */
		private function executeIdentifyQuery(Complete:Function, Fault:Function = null):void
		{
			//查询参数设置
			var identifyParam:IdentifyParameters = new IdentifyParameters();
			identifyParam.returnGeometry = returnGeometry;
			identifyParam.tolerance = tolerance;
			identifyParam.geometry = geometry;
			identifyParam.height = map.height;
			identifyParam.width = map.width;
			identifyParam.mapExtent = map.extent;
			identifyParam.layerOption = IdentifyParameters.LAYER_OPTION_ALL;
			identifyParam.layerIds = identifyLayerIds;
			identifyParam.spatialReference = map.spatialReference;
			
			//执行Identify
			var identifyTask:IdentifyTask = new IdentifyTask(serviceUrl);
			identifyTask.execute(identifyParam, new AsyncResponder(onResult, onFault, geometry));
			CursorManager.removeAllCursors();
			CursorManager.setBusyCursor();
			
			function onResult(identifyResults:Array, geometry:Geometry = null):void
			{
				try
				{
					//回调
					Complete(identifyResults, geometry);
				}
				catch (error:Error)
				{
					//Alert.show("点击查询不成功！");
				} 
				CursorManager.removeBusyCursor();
			}
			
			function onFault(info:Object, geometry:Geometry = null):void
			{
				if(Fault != null)
				{
					Fault(info);
				}
				Alert.show("图层[" + serviceUrl + "]查询不成功！\n 可能原因：" + info.faultDetail, "操作提示...");
				CursorManager.removeBusyCursor();
			}
		}
		
		
		/**
		 * 批量的Graphic数据属性字段集预处理，对每个Graphic对象中attributes属性中的字段名进行逐一处理。
		 * <br>主要是针对在mxd文档中因对多个图层进行了Join操作而导致相应属性字段名被添加了类似于"SDE.SDE.堤防"的前缀。
		 * <br>处理之后，会将该类型的属性名称全部截取成最后一部分，即 "OBJECTID"。
		 * @param featureSet 待处理要素集合。
		 */
		private function graphicsPretreatment(featureSet:FeatureSet):void
		{
			var count:int = featureSet.features.length;
			for(var i:int=0; i<count; i++)
			{
				//transferJoinedTableFields
				var graphic:Graphic = featureSet.features[i] as Graphic;
				var attributes:Object = graphic.attributes;
				var objInfo:Object = ObjectUtil.getClassInfo(attributes); 
				var fieldName:Array = objInfo["properties"] as Array; 
				var newAttributes:Object = new Object();
				for each(var qname:QName in fieldName)
				{
					var nodeArr:Array = qname.localName.split(".");
					var value:Object = attributes[qname.localName]; 
					if(nodeArr.length > 1)
					{
						newAttributes[nodeArr[nodeArr.length-1]] = value;
					}
					else
					{
						newAttributes[qname.localName] = value;
					}
					
				} 
				
				//更新Graphic的属性数据
				graphic.attributes = newAttributes;
			}
		}
		
		
		/**
		 * 重置查询参数。
		 */
		private function resetParams():void
		{
			this.queryLayer = null;
			this.serviceUrl = "";
			this.queryType = "";
			this.condition = "";
			this.geometry = null;
			this.objectIds = null;
			this.returnGeometry = true;
			this.outFields = null;
			this.orderByFields = null;
		}
		
	} 
} 








