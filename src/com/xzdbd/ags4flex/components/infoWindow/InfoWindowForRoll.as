package com.xzdbd.ags4flex.components.infoWindow
{ 
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;

	/**************************************************
	 * Grahic的鼠标悬停飞行提示信息窗.
	 * 
	 * @example
     * 下面代码演示如何使用 <code>InfoWindowForRoll</code> 类： 
	 * <listing version="3.0">
	 * //声明并实例化一个鼠标悬浮飞行提示对象
	 * private var infoWindowForRollOver:InfoWindowForRollOver = new InfoWindowForRollOver(map, "目标信息");
	 * 
	 * //添加飞行提示到指定 Graphic 对象，其中 popupUI 为一个实现了 IDataRenderer 接口的 GroupRenderer 对象
	 * infoWindowForRollOver.addInfoWindowForRollOver(graphic, popupUI, graphic.attributes);
	 * </listing>
	 * 
	 * @author 郝超
	 * 创建于 2012-3-27,下午01:52:34.
	 * 
	 **************************************************/ 
	public class InfoWindowForRoll
	{
		//允许弹出飞行提示窗的最大地图显示范围
		private var MAP_MAX_SCALE:Number = 5000000;
		
		//计时器
		private var hideInfoTimer:Timer = new Timer(400, 1);
		//计时常量
		private var hitimer:uint;
		//当前操作的Map对象
		private var map:Map;
		//当前操作的对象（Graphic）
		private var graphic:Graphic;
		//渲染组件对象
		private var renderer:GroupRenderer;
		//显示的数据对象
		private var data:Object;
		
		//标题
		private var labelText:String = "";
		//是否显示标题栏
		private var labelVisible:Boolean;
		//是否显示关闭按钮
		private var closeButtonVisible:Boolean;
		
		//是否使用比例限制
		private var scaleLimit:Boolean;
		//最大、最小显示比例
		private var minScale:Number;
		private var maxScale:Number;
		
		/**
		 * 构造函数。
		 * @param map 当前地图对象的引用。
		 * @param labelText 飞行提示标题栏标题文本。
		 * @param labelVisible 飞行提示标题是否可见。
		 * @param closeButtonVisible 关闭按钮是否显示。
		 */
		public function InfoWindowForRoll(map:Map, labelText:String="", labelVisible:Boolean=true, closeButtonVisible:Boolean=true)
		{
			this.map = map;
			this.labelVisible = labelVisible;
			this.closeButtonVisible = closeButtonVisible;
			this.labelText = labelText;
			hideInfoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hideInfoTimer_timerCompleteHandler, false, 0, true);
		} 
		
		/**
		 * 鼠标悬浮，弹出飞行提示显示信息。
		 * @param target 当前操作的对象（Graphic）。
		 * @param renderer 渲染组件对象。
		 * @param data 显示的数据对象。
		 * @param scaleLimit 是否对飞行提示显示进行范围限制。
		 * @param minScale 飞行提示显示最大限制范围。
		 */
		public function addInfoWindowForRollOver(target:UIComponent, renderer:GroupRenderer, data:Object, scaleLimit:Boolean=false, maxScale:Number=0, minScale:Number=0):void
		{
			this.graphic = target as Graphic;
			this.renderer = renderer;
			this.data = data;
			this.scaleLimit = scaleLimit;
			if(isNaN(maxScale))
				this.maxScale = MAP_MAX_SCALE;
			else
				this.maxScale = maxScale;
			this.minScale = minScale;
			this.graphic.addEventListener(MouseEvent.MOUSE_OVER, showInfoWindowForRollOver);
			this.graphic.addEventListener(MouseEvent.MOUSE_OUT, graphicMouseOutHandler);
		}
		
		/**
		 * 移除Graphic的鼠标悬浮事件监听。
		 * @param target 当前操作的对象（Graphic）。
		 */
		public function removeInfoWindowForRollOver(target:UIComponent):void
		{
			this.graphic = target as Graphic;
			this.graphic.removeEventListener(MouseEvent.MOUSE_OVER, showInfoWindowForRollOver);
			this.graphic.removeEventListener(MouseEvent.MOUSE_OUT, graphicMouseOutHandler);
		}
		
		/**
		 * Graphic的鼠标悬浮事件处理函数，弹出飞行提示信息。
		 */
		private function showInfoWindowForRollOver(event:MouseEvent):void
		{
			if(scaleLimit && (map.scale > maxScale || map.scale < minScale))
			{
				return;
			}
			else if((graphic.symbol is SimpleMarkerSymbol && SimpleMarkerSymbol(graphic.symbol).alpha>0) || 
				     graphic.symbol is PictureMarkerSymbol)
			{
				clearTimeout(hitimer);
				hitimer = setTimeout(showHighLight, 400, graphic, renderer, data);
				hideInfoTimer.reset(); 
			}
		}
		
		/**
		 * Graphic的鼠标移出事件处理函数，停止相关计时器。
		 */
		private function graphicMouseOutHandler(event:MouseEvent):void
		{
			clearTimeout(hitimer);
			hideInfoTimer.reset();
			hideInfoTimer.start();
		}
		
		/**
		 * 高亮显示当前目标飞行提示窗。
		 * @param graphic 当前宿主对象。
		 * @param renderer 弹出窗渲染模板。
		 * @param data 弹出窗数据对象。
		 */ 
		private function showHighLight(graphic:Graphic, renderer:GroupRenderer, data:Object):void
		{
			renderer.data = data;
			map.infoWindow.label = labelText;
			map.infoWindow.labelVisible = labelVisible;
			map.infoWindow.closeButtonVisible = closeButtonVisible;
			map.infoWindow.content = renderer;
			map.infoWindow.contentOwner = graphic;
			map.infoWindow.show(graphic.geometry as MapPoint);
			map.infoWindow.addEventListener(MouseEvent.MOUSE_OVER, keepPopWinShow);
			map.infoWindow.addEventListener(MouseEvent.MOUSE_OUT, graphicMouseOutHandler);
		}
		
		/**
		 * 保持弹出窗在鼠标悬浮状态时的持续显示。
		 */
		private function keepPopWinShow(event:MouseEvent):void
		{
			hideInfoTimer.reset();
		}
		
		/**
		 * 计时器处理函数。
		 */
		private function hideInfoTimer_timerCompleteHandler(event:TimerEvent):void
		{
			map.infoWindow.hide();
			map.infoWindow.removeEventListener(MouseEvent.MOUSE_OVER, keepPopWinShow);
			map.infoWindow.removeEventListener(MouseEvent.MOUSE_OUT, graphicMouseOutHandler);
		}
	} 
} 





