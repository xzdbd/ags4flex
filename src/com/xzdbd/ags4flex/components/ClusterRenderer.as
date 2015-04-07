package com.xzdbd.ags4flex.components
{
    import com.esri.ags.Graphic;
    import com.esri.ags.Map;
    import com.esri.ags.events.ExtentEvent;
    import com.esri.ags.geometry.Geometry;
    import com.esri.ags.geometry.MapPoint;
    import com.esri.ags.layers.GraphicsLayer;
    import com.esri.ags.renderers.supportClasses.ClassBreakInfo;
    import com.esri.ags.symbols.CompositeSymbol;
    import com.esri.ags.symbols.SimpleMarkerSymbol;
    import com.esri.ags.symbols.Symbol;
    import com.esri.ags.symbols.TextSymbol;
    
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
    import com.xzdbd.ags4flex.components.supportClasses.Cluster;

    [DefaultProperty("classBreakInfo")]
	
	
	/****************************************************
	 * 地图上点集的聚合Renderer.
	 * 
	 * <p> 
     * 扩展基于flexviewer实现的点聚合效果.
     * <ol> 
     * <li>重构.</li> 
     * <li>增加分级配置功能.</li> 
     * <li>增加默认递增聚合效果.</li> 
     * </ol> 
     * </p> 
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>ClusterRenderer</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:ags="http://www.xzdbd.net/2013/flex/ags"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;ags:ClusterRenderer 
	 * 	<b>Properties</b>
	 * 	map="{map}"
	 * 	renderLayer="{graphicsLayer}" 
	 * 	mapPointGraphicSource="{graphicAC}"
	 * 	clusterLengthVisible="false" 
	 * 
	 * 	<b>Styles</b>
	 * 	radius="10" &gt;
	 * 
	 * 	&lt;esri:ClassBreakInfo maxValue="10" symbol="{symbol_s}" /&gt;
	 * 	&lt;esri:ClassBreakInfo minValue="11" maxValue="30" symbol="{symbol_m}" /&gt;
	 * 	&lt;esri:ClassBreakInfo minValue="31" symbol="{symbol_b}" /&gt;
	 * 
	 * /&gt;
	 * 
	 * 其中，根据包含 Graphic 要素对象数量的多少，对聚合点分成三个级别，分别是 1~10、11~30、31~无穷大.
	 * </pre>
     * </p>
	 * 
	 * @author xzdbd（该类引入自网络）
	 * 创建于 2013-4-16,下午06:00:04.
	 * 
	 *****************************************************/
    public class ClusterRenderer 
	{
        private var _map:Map;
        private var _renderLayer:GraphicsLayer;
		
        [ArrayElementType("com.esri.ags.Graphic")]
        private var _mapPointGraphicSource:ArrayCollection = new ArrayCollection();
        private var _radius:int = 20;

        [ArrayElementType("com.esri.ags.renderers.ClassBreakInfo")]
        private var _classBreakInfo:Array;
		
		[ArrayElementType("com.esri.ags.Graphic")]
		private var _clusterGraphics:ArrayCollection = new ArrayCollection();
		
		private var _clusterLengthVisible:Boolean;

		
		private var diameter:int;
        /**
         * 当没有分级配置信息时, 默认聚合点基数的大小
         */
        private var baseSize:uint = 10;

        /**
         * 当没有分级配置信息时, 聚合点最大限制
         */
        private var maxSize:uint = 150;

        /**
         * 当没有分级配置信息时, 默认聚合点透明度
         */
        private var defaultAlpha:Number = 0.75;
		
        /**
         * 聚合点要素
         */
        [ArrayElementType("clusterers.Cluster")]
        private var clusters/*<int,Cluster>*/:Dictionary;
        
        private var overlapExists:Boolean;
		
		
		/**
		 * 需要聚合的原始Graphic点集合。
		 */
		public function get mapPointGraphicSource():ArrayCollection 
		{
			return this._mapPointGraphicSource;
		}
		public function set mapPointGraphicSource(value:ArrayCollection):void 
		{
			this._mapPointGraphicSource = value;
			
			// 监听数据源是否变化, 需要重新聚合
			this._mapPointGraphicSource.addEventListener(CollectionEvent.COLLECTION_CHANGE, graphicChangeHandler);
			
			clusterMapPoints();
		}
		
		/**
		 * 展现聚合点的GraphicsLayer。
		 * <br><br>想通过GraphicsLayer来获得Map, 但由于Map还未初始化好, 会得到null。
		 */
		public function get renderLayer():GraphicsLayer 
		{
			return this._renderLayer;
		}
		public function set renderLayer(value:GraphicsLayer):void 
		{
			this._renderLayer = value;
		}
		
		/**
		 * 必须获得Map对象调用其转换经纬度的方法(toScreen)
		 */
		public function get map():Map 
		{
			return this._map;
		}
		public function set map(value:Map):void 
		{
			this._map = value;
			
			// 监听Map extent是否改变, 需要重新聚合
			this.map.addEventListener(ExtentEvent.EXTENT_CHANGE, extentChangeHandler);
		}
		
		/**
		 * 聚合后的Graphic点集合。
		 */
		public function get clusterGraphics():ArrayCollection 
		{
			return this._clusterGraphics;
		}
		
		/**
		 * 聚合的范围 in pixels。
		 */
		public function get radius():int 
		{
			return this._radius;
		}
		public function set radius(value:int):void 
		{
			this._radius = value;
		}
		
		/**
		 * 分级配置信息, 设置聚合点数量区间对应的Symbol。
		 */
		public function get classBreakInfo():Array 
		{
			return this._classBreakInfo;
		}
		public function set classBreakInfo(value:Array):void 
		{
			this._classBreakInfo = value;
		}
		
		/**
		 * 聚合点符号是否显示聚合对象个数。
		 */
		[Bindable]
		public function get clusterLengthVisible():Boolean
		{
			return _clusterLengthVisible;
		}
		/**
		 * @private
		 */
		public function set clusterLengthVisible(value:Boolean):void
		{
			_clusterLengthVisible = value;
		}
		
		
		/**
		 * 构造函数。
		 */
		public function ClusterRenderer(_map:Map = null, _renderLayer:GraphicsLayer = null, _mapPointGraphicSource:ArrayCollection = null) 
		{
            if (_map) 
			{
                map = _map;
            }

            if (_renderLayer) 
			{
                renderLayer = _renderLayer;
            }

            if (_mapPointGraphicSource) 
			{
                mapPointGraphicSource = _mapPointGraphicSource;
            }
        }
		
		/**
		 * 聚合点集。
		 */
		public function clusterMapPoints():void 
		{
			diameter = radius * 2;
			
			assignMapPointsToClusters();
			
			// 合并重叠集群，知道没有重叠的。
			do 
			{
				mergeOverlappingClusters();
			} while (overlapExists);
			
			showClusterGraphics();
		}
		
		/**
		 * 给Graphic添加滤镜效果。
		 * @param cluster 聚合对象。
		 */
		protected function getGraphicFilters(cluster:Cluster):Array 
		{
			var dropShadowFilter:DropShadowFilter = new DropShadowFilter(5);
			var glowFilter:GlowFilter = new GlowFilter(0x88AEF7, 1, 12, 12, 1, 2);
			
			return [dropShadowFilter, glowFilter];
		}
		
		/**
		 * 创建聚合对象渲染符号。
		 * @param cluster 聚合对象。
		 */
		protected function createClusterSymobl(cluster:Cluster):Symbol
		{
			var clusterMapPointCount:uint = cluster.getMapPointCount();
			
			// 混合聚合点和文字
			var compositeSymbol:CompositeSymbol = new CompositeSymbol();
			var symbols:ArrayCollection = compositeSymbol.symbols as ArrayCollection;
			
			// 显示聚合点
			var baseSymbol:Symbol;
			if (_classBreakInfo) 
			{
				baseSymbol = getSymoblFromBreak(clusterMapPointCount);
			} 
			else 
			{
				baseSymbol = getDefaultSymobl(clusterMapPointCount);
			}
			
			// 从分级配置信息中获取Symbol, 可能获得null
			if (baseSymbol) 
			{
				symbols.addItem(baseSymbol);
			}
			
			//是够显示聚合点数量
			if(clusterLengthVisible)
			{
				//显示聚合点的数量
				var clusterCountTextSymbol:TextSymbol = new TextSymbol();
				
				//自定义TextSymbol
				clusterCountTextSymbol.color = 0xFFFFFF;
				clusterCountTextSymbol.text = cluster.getMapPointCount().toString();
				symbols.addItem(clusterCountTextSymbol);
			}
			
			return compositeSymbol;
		}
		
		/**
		 * 根据聚合点总数量来递增聚合点大小。
		 * @param clusterMapPointCount 聚合对象中Graphic的数目。
		 */
		protected function getClusterSize(clusterMapPointCount:uint):uint 
		{
			var size:uint = baseSize + clusterMapPointCount;
			
			if (size > maxSize) 
			{
				return maxSize;
			}
			
			return size;
		}
		
		/**
		 * 根据聚合点数量和基色形成一组递增色。
		 * @param clusterMapPointCount 聚合对象中Graphic的数目。
		 */
		protected function getClusterColor(clusterMapPointCount:uint):uint 
		{
			var colorValue:uint = (0xff0000 | (0x00ff00 * (clusterMapPointCount / 20)) | (0x0000ff * (clusterMapPointCount / 20)));
			
			return colorValue;
		}

		/**
		 * 监听Graphic更改。
		 */
        private function graphicChangeHandler(event:CollectionEvent):void 
		{
            clusterMapPoints();
        }

		/**
		 * 监听地图Extent更改。
		 */
        private function extentChangeHandler(event:ExtentEvent):void 
		{
            clusterMapPoints();            
        }

		/**
		 * 将聚合后的要素对象添加到图层。
		 */
        private function showClusterGraphics():void 
		{
            clusterGraphics.removeAll();

            for each (var cluster:Cluster in clusters) 
			{
                //将聚合对象转换成Graphic集合，以便能添加到图层进行显示。
                var mapPoint:MapPoint = map.toMap(new Point(cluster.x, cluster.y))
                cluster.x = mapPoint.x;
                cluster.y = mapPoint.y;

                var graphic:Graphic = new Graphic(cluster, createClusterSymobl(cluster));
                graphic.filters = getGraphicFilters(cluster);
                clusterGraphics.addItem(graphic);
            }

            //会覆盖图层中原有的Graphic
			if(this._renderLayer)
			{
            	this._renderLayer.graphicProvider = clusterGraphics;
			}
        }

        /**
         * 从分级配置信息中获取Symbol, 如果没有匹配上则返回null。
         */
        private function getSymoblFromBreak(clusterMapPointCount:uint):Symbol 
		{
            for each (var info:ClassBreakInfo in _classBreakInfo) 
			{
                if (clusterMapPointCount >= info.minValue && clusterMapPointCount <= info.maxValue) 
				{
                    return info.symbol;
                }
            }

            return null;
        }

		/**
		 * 获取默认渲染符号。
		 * @param clusterMapPointCount 聚合对象中Graphic的数目。
		 */
        private function getDefaultSymobl(clusterMapPointCount:uint):Symbol 
		{
            var sms:SimpleMarkerSymbol = new SimpleMarkerSymbol();
            sms.alpha = defaultAlpha;
            sms.size = getClusterSize(clusterMapPointCount);
            sms.color = getClusterColor(clusterMapPointCount);

            return sms;
        }

		/**
		 * 合并重叠的聚合对象。
		 */
        private function mergeOverlappingClusters():void 
		{
            overlapExists = false;

            // Create a new set to hold non-overlapping clusters.            
            const dest/*<int,Cluster>*/:Dictionary = new Dictionary();
            for each (var cluster:Cluster in clusters) {
                // skip merged cluster
                if(cluster.getMapPointCount() === 0) {
                    continue;
                }

                // Search all immediately adjacent clusters.
                searchAndMerge(cluster,  1,  0);
                searchAndMerge(cluster, -1,  0);
                searchAndMerge(cluster,  0,  1);
                searchAndMerge(cluster,  0, -1);
                searchAndMerge(cluster,  1,  1);
                searchAndMerge(cluster,  1, -1);
                searchAndMerge(cluster, -1,  1);
                searchAndMerge(cluster, -1, -1);

                // Find the new cluster centroid values.
                var cx:int = cluster.x / diameter;
                var cy:int = cluster.y / diameter;
                cluster.cx = cx;
                cluster.cy = cy;

                // Compute new dictionary key.
                var ci:int = (cx << 16) | cy;
                dest[ci] = cluster;
            }
            clusters = dest;
        }

		/**
		 * 寻找附近的cluster并做合成。
		 */
        private function searchAndMerge(cluster:Cluster, ox:int, oy:int):void 
		{
            const cx:int = cluster.cx + ox;
            const cy:int = cluster.cy + oy;
            const ci:int = (cx << 16) | cy;

            const found:Cluster = clusters[ci] as Cluster;
            if(found && found.getMapPointCount()) 
			{
                const dx:Number = found.x - cluster.x;
                const dy:Number = found.y - cluster.y;
                const dd:Number = Math.sqrt(dx * dx + dy * dy);
                // Check if there is a overlap based on distance. 
                if (dd < diameter) 
				{
                    overlapExists = true;
                    cluster.merge(found)
                }
            }
        }

        /**
         * 将地图点集分配到点集合群Cluster中。
         */
        private function assignMapPointsToClusters():void 
		{
            clusters = new Dictionary();

            for each (var graphic:Graphic in this._mapPointGraphicSource) 
			{
                if (graphic.geometry.type == Geometry.MAPPOINT) 
				{
                    var mapPoint:MapPoint = graphic.geometry as MapPoint;

                    // Cluster only map points in the map extent
                    if(map.extent.contains(mapPoint)) 
					{
                        // Convert world map point to screen values.
                        var screenPoint:Point = map.toScreen(mapPoint);
                        var sx:Number = screenPoint.x;
                        var sy:Number = screenPoint.y;
     
                        // Convert to cluster x/y values.
                        var cx:int = sx / diameter;
                        var cy:int = sy / diameter;
    
                        // Convert to cluster dictionary key.
                        var ci:int = (cx << 16) | cy;
                        // Find existing cluster
                        var cluster:Cluster = clusters[ci];
                        if (cluster) 
						{
                            // Average centroid values based on new map point.
                            cluster.x = (cluster.x + sx) / 2.0;
                            cluster.y = (cluster.y + sy) / 2.0;
                        } 
						else
						{
                            // Not found - create a new cluster as that index.
                            clusters[ci] = new Cluster(sx, sy, cx, cy);

                            cluster = clusters[ci];
                        }

                        // add map point graphic to that cluster.
                        // Increment the number map points in that cluster.
                        // include itself
                        cluster.addMapPointGraphic(graphic);
                    }
                }
            }
        }
    }
}













