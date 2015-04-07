package com.xzdbd.ags4flex.components.infoWindow
{ 
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.symbols.Symbol;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	
	/**************************************************
	 * Grahic的鼠标点击飞行提示信息窗.
	 * 
	 * @example
     * 下面代码演示如何使用 <code>SingleInfoWindow</code> 类： 
	 * <listing version="3.0">
	 * //通过该方法调用可以为目标对象添加一个飞行提示弹出框，一旦鼠标点击该目标，飞行提示框便会弹出
	 * //该方法最后一个参数即是飞行弹出框模板(GroupRenderer对象)，详见方法说明
	 * SingleInfoWindow.addInfoWindow(map, labelString, graphic, new SluiceInfoTemplate());
	 * 
	 * //如果在为目标添加飞行提示框之后，并不想等到点击再弹出提示框，而是直接弹出来，那么可以作如下调用
	 * //其中，mapPoint 为飞行提示框在地图上弹出来时的点对象
	 * SingleInfoWindow(graphic.attributes.infoWindow).showInfoWindowDirectly(mapPoint);
	 * </listing>
	 * 
	 * @author xzdbd
	 * 创建于 2013-3-27,下午01:52:34.
	 * 
	 **************************************************/ 
	public class SingleInfoWindow
	{
		/**
		 * 为指定 Graphic 对象添加飞行提示窗口对象。
		 * @param map 地图对象。
		 * @param label 飞行提示标题。
		 * @param graphic 飞行提示主体对象。
		 * @param targetItem 飞行提示主体实体。
		 * @param renderer 飞行提示模板。
		 * @return 新创建的SingleInfoWindow引用。
		 */
		public static function addInfoWindow(map:Map, 
											 label:String, 
											 graphic:Graphic, 
											 renderer:GroupRenderer,
											 rollOverSymbol:Symbol=null):SingleInfoWindow
		{
			var infoWindow:SingleInfoWindow = new SingleInfoWindow(map, true, label, true, rollOverSymbol);
			infoWindow.addClickInfoWindow(graphic, renderer);
			graphic.attributes.infoWindow = infoWindow;
			
			return infoWindow;
		}
		
		/**
		 * 构造函数。
		 * @param map 当前地图对象的引用。
		 * @param labelVisible 飞行提示标题是否可见。
		 * @param labelText 飞行提示标题栏标题文本。
		 * @param closeButtonVisible 关闭按钮是否显示。
		 * @param rollOverSymbol 鼠标悬浮时的对象符号。
		 */
		public function SingleInfoWindow(map:Map, 
										 labelVisible:Boolean=true, 
										 labelText:String="", 
										 closeButtonVisible:Boolean=true,
										 rollOverSymbol:Symbol=null)
		{
			this.map = map;
			this.labelVisible = labelVisible;
			this.closeButtonVisible = closeButtonVisible;
			this.labelText = labelText;
			this.rollOverSymbol = rollOverSymbol;
		} 
		
		
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
		
		//点击地图位置点
		private var clickLocation:MapPoint;
		
		//符号
		private var rollOverSymbol:Symbol;
		private var rollOutSymbol:Symbol;
		
		
		/**
		 * 编程直接弹出指定Graphic飞行提示框。
		 * @param location 飞行提示框弹出的锚定位置（点），默认取Graphic对应Geometry的中心点。
		 */
		public function showInfoWindowDirectly(location:MapPoint=null):void
		{
			if(graphic.symbol)
			{
				popupInfoWindow(graphic, renderer, data, location);
			}
		}
		
		/**
		 * Graphic从图层上移除时清空其相关监听。
		 * @param graphic 当前操作的Graphic对象。
		 */
		public function removeGraphicListener(graphic:Graphic):void
		{
			graphic.removeEventListener(MouseEvent.CLICK, graphicClickHandler);
			graphic.removeEventListener(MouseEvent.ROLL_OVER, graphicRollOverHandler);
			graphic.removeEventListener(MouseEvent.ROLL_OUT, graphicRollOutHandler);
		}
		
		/**
		 * 为Graphic添加飞行提示信息窗口对象（点击弹出）。
		 * @param target 当前操作的对象（Graphic）。
		 * @param renderer 渲染组件对象。
		 * @param data 显示的数据对象（默认为空，自动取graphic中的attributes为数据源）。
		 */
		private function addClickInfoWindow(target:UIComponent, renderer:GroupRenderer, data:Object=null):void
		{
			this.graphic = target as Graphic;
			this.renderer = renderer;
			if(data)
				this.data = data;
			else
				this.data = graphic.attributes;
			
			this.graphic.addEventListener(MouseEvent.CLICK, graphicClickHandler);
			this.graphic.addEventListener(MouseEvent.ROLL_OVER, graphicRollOverHandler);
			this.graphic.addEventListener(MouseEvent.ROLL_OUT, graphicRollOutHandler);
			//this.graphic.addEventListener(Event.REMOVED, graphicRemovedHandler);
			graphic.buttonMode = true;
			graphic.useHandCursor = true;
		}
		
		/**
		 * 目标对象的 MouseEvent.Click 事件处理函数，弹出飞行提示信息窗。
		 */
		private function graphicClickHandler(event:MouseEvent):void
		{
			clickLocation = map.toMap(new Point(event.stageX, event.stageY - 40));
			popupInfoWindow(graphic, renderer, this.data);
		}
		
		/**
		 * 目标对象的 MouseEvent.RollOver 事件处理函数。
		 */
		private function graphicRollOverHandler(event:MouseEvent):void
		{
			if(rollOverSymbol != null)
			{
				rollOutSymbol = graphic.symbol;
				graphic.symbol = rollOverSymbol;
			}
		}
		
		/**
		 * 目标对象的 MouseEvent.RollOut 事件处理函数。
		 */
		private function graphicRollOutHandler(event:MouseEvent):void
		{
			if(this.rollOutSymbol != null)
			{
				graphic.symbol = rollOutSymbol;
			}
		}
		
		/**
		 * Graphic从图层上移除处理函数。
		 */
		private function graphicRemovedHandler(event:Event):void
		{
			this.graphic.removeEventListener(GraphicEvent.GRAPHIC_REMOVE, graphicRemovedHandler);
			this.graphic.removeEventListener(MouseEvent.CLICK, graphicClickHandler);
			this.graphic.removeEventListener(MouseEvent.ROLL_OVER, graphicRollOverHandler);
			this.graphic.removeEventListener(MouseEvent.ROLL_OUT, graphicRollOutHandler);
		}
		
		/**
		 * 弹出目标飞行提示信息窗口。
		 * @param graphic 目标Graphic对象。
		 * @param renderer 飞行提示窗口模板。
		 * @param data 飞行提示数据源。
		 * @param location 飞行提示框弹出时锚定的位置点。
		 */
		private function popupInfoWindow(graphic:Graphic, renderer:GroupRenderer, data:Object, location:MapPoint=null):void
		{
			renderer.data = data;
			map.infoWindow.label = labelText;
			map.infoWindow.labelVisible = labelVisible;
			map.infoWindow.closeButtonVisible = closeButtonVisible;
			map.infoWindow.content = renderer;
			map.infoWindow.contentOwner = graphic;
			//锚定点，弹出信息框
			var locationPoint:MapPoint;
			if(graphic.geometry.type == Geometry.MAPPOINT)
				locationPoint = graphic.geometry as MapPoint;
			else
				locationPoint = clickLocation;
			map.infoWindow.show(location ? location : locationPoint);
		}
	} 
} 









