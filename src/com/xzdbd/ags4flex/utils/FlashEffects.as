package com.xzdbd.ags4flex.utils
{ 
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import spark.filters.GlowFilter;

	
	/****************************************************
	 * 针对地图要素的闪烁效果实现类.
	 * 
	 * @author xzdbd
	 * 创建于 2012-3-31,下午02:41:52.
	 * 
	 *****************************************************/
	public class FlashEffects 
	{ 
		/**
		 * 单例。
		 */
		private static var _effects:FlashEffects;
		
		/**
		 * 上一次闪烁的时间间隔计时 id。
		 */
		private static var preIntervalId:uint;
		
		/**
		 * 公共渲染图层。
		 */
		private static var graphicsLayer:GraphicsLayer = new GraphicsLayer();
		
		/**
		 * 上一个闪烁的Graphic对象。
		 */
		private static var preFlashGraphic:Graphic;
		
		/**
		 * 单次闪烁计时 id。
		 */
		private static var timeoutId:uint;
		
		/**
		 * 单例模式。
		 * @return 单例对象。
		 */
		public static function getInstance():FlashEffects
		{
			if(_effects == null)
				_effects = new FlashEffects();
			
			return _effects;
		}
		
		
		/**
		 * 通过固定的swf效果高亮闪烁目标点(MapPoint)。
		 * @param graphic 需要渲染的 Graphic 对象。
		 * @param layer 渲染效果的宿主图层 GraphicsLayer。
		 */
		public static function flashMapPoint(mapPoint:MapPoint, layer:GraphicsLayer, swfUrl:String):void
		{
			if(preFlashGraphic)
			{
				layer.remove(preFlashGraphic);
				preFlashGraphic = null;
				clearTimeout(timeoutId);
			}
			
			if(mapPoint == null)
			{
				return;
			}
			
			var flashSymbol:Symbol = new PictureMarkerSymbol(swfUrl, 150, 150);
			
			//构造新的Graphic，和原始Graphic完全重合。
			preFlashGraphic = new Graphic(new MapPoint(mapPoint.x, mapPoint.y), flashSymbol);
			layer.add(preFlashGraphic);
			timeoutId = setTimeout(flashFun, 2300);
			
			function flashFun():void
			{
				layer.remove(preFlashGraphic);
			}
		}
		
		
		/**
		 * 高亮闪烁指定 Geometry 对象。
		 * @param map map 引用。
		 * @param geometry Geometry 对象。
		 * @param flashColor 闪烁的颜色，默认为 0xFF0000。
		 * @param flashWidth 闪烁渲染的宽度，默认为 10。
		 * @param flashCount 闪烁的次数，默认为10。
		 */
		public static function flashGeometry(map:Map, 
											 geometry:Geometry=null, 
											 flashColor:uint=0xFF0000, 
											 flashWidth:Number=10, 
											 flashCount:Number=10):void
		{
			if(map == null || geometry == null)
			{
				return;
			}
			//清除上一次的渲染效果。
			clearInterval(preIntervalId);
			graphicsLayer.clear();
			map.removeLayer(graphicsLayer);
			
			var symbol:Symbol;
			if(geometry.type == Geometry.MAPPOINT)
			{
				symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 10, 0x22A050, 0.7);
			}
			else if(geometry.type == Geometry.POLYLINE)
			{
				symbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0x22A050, 0.7, 4);
			}
			else if(geometry.type == Geometry.POLYGON)
			{
				symbol = new SimpleFillSymbol(SimpleFillSymbol.STYLE_NULL, 0x22A050, 0, 
												new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0x22A050, 0.7, 5));
			}
			
			//构建Geometry对应的Graphic对象，并添加到图层
			var flashGraphic:Graphic = new Graphic(geometry, symbol);
			graphicsLayer.add(flashGraphic);
			map.addLayer(graphicsLayer);
			
			preIntervalId = setInterval(flashFun, 300, flashGraphic);
			var glowFilter:GlowFilter = new GlowFilter(flashColor, 0.6, flashWidth, flashWidth, 6, BitmapFilterQuality.HIGH);
			
			function flashFun(graphic:Graphic):void
			{
				if(flashCount <= 0)
				{
					clearInterval(preIntervalId);
					graphicsLayer.clear();
					map.removeLayer(graphicsLayer);
					return;
				}
				if( flashCount % 2 == 0 )
				{
					if(graphic.geometry.type == Geometry.POLYGON)
					{
						glowFilter.alpha = 0.4;
					}
					else
					{
						glowFilter.alpha = 0.8;
					}
					graphic.filters = [ glowFilter ];
				}
				else
				{
					graphic.filters = [ ];
				}
				
				flashCount --;
			}
		}
		
		/**
		 * 高亮闪烁目标集合。
		 * <br>调用该方法后，可以通过调用该类的静态方法 clearFlash() 方法来取消高亮效果。
		 * @param targets 基于可显示对象DisplayObject的对象（多为 Graphic）集合。
		 * @param flashColor 目标闪烁的颜色，默认为 0xFF0000。
		 * @param flashCount 目标闪烁的次数，默认是闪烁10次，如果设置为 -1，则为持续闪烁。
		 */
		public static function flashTargets(targets:Array=null, flashColor:uint=0xFF0000, flashCount:Number=10):void
		{
			if(!targets && targets.length<=0)
			{
				return;
			}
			
			//取消上一目标高亮效果
			clearInterval(preIntervalId);
			
			var count:Number = flashCount;
			preIntervalId = setInterval(flashFun, 300, targets);
			var glowFilter:GlowFilter = new GlowFilter(flashColor, 0.8, 4, 4, 4, BitmapFilterQuality.HIGH);
			
			function flashFun(array:Array):void
			{
				//在设定闪烁次数的情况下，当闪烁次数完成时，取消闪烁
				if(count == 0)
				{
					clearInterval(preIntervalId);
					return;
				}
				
				//闪烁所有目标
				for each (var target:DisplayObject in targets)
				{
					if( Math.abs(count) % 2 == 0 )
					{
						if(Graphic(target).geometry.type == Geometry.POLYGON)
						{
							glowFilter.alpha = 0.4;
						}
						else
						{
							glowFilter.alpha = 0.8;
						}
						
						//闪烁高亮
						target.filters = [ glowFilter ];
					}
					else
					{
						//暂时取消高亮
						target.filters = [ ];
					}
				}
				
				//设置下一步使用的 count 参数
				if(count < 0)
				{
					count = count == -1 ? -2 : -1;
				}
				else
				{
					count --;
				}
			}
		}
		
		
		/**
		 * 清除当前闪烁目标上的效果。
		 * @param targets 当前正在闪烁的目标集合。
		 */
		public static function clearFlash(targets:Array=null):void
		{
			clearInterval(preIntervalId);
			if(targets)
			{
				for each (var target:DisplayObject in targets)
				{
					if(target)
					{
						target.filters = [ ];
					}
				}
			}
		}
		
		
		/**
		 * 构造函数。
		 */
		public function FlashEffects()
		{
		}
	} 
} 








