package com.xzdbd.ags4flex.components.mapTools.supportClasses 
{ 
	import com.esri.ags.Map;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import com.xzdbd.ags4flex.skins.SingleButtonSkin;
	
	/**
	 * 定义工具按钮单击事件。
	 */
	[Event(name="toolClick", type="flash.events.MouseEvent")]
	
	
	/*******************************************
	 * 地图工具项按钮类.
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>MapToolButton</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:ags="http://www.xzdbd.net/2013/flex/ags"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;as3core:MapToolButton 
	 * 	<b>Properties</b>
	 * 	map={map}
	 * 	iconUrl="assets/images/myToolIcon.png"
	 * 	toolTip="图层开关"
	 * 
	 * 	<b>Events</b>
	 * 	toolClick="layerCtrlButton_clickHandler(event)" /&gt;
	 * 
	 * 	其中，<code>layerCtrlButton_clickHandler(event)</code> 为工具按钮的默认点击处理函数，该方法继承自父类，因此引用该类不用再自己添加 MouseEvent.CLICK 事件.
	 * </pre>
     * </p>
	 * 
	 * @author 郝超
	 * 创建于 2013-7-19,下午2:23:28.
	 * 
	 *******************************************/ 
	public class MapToolButton extends NavSingleButton 
	{ 
		/**
		 * 工具按钮单击事件。
		 */
		private const TOOL_CLICK:String = "toolClick";
		
		/**
		 * 构造函数。
		 * <br>创建一个地图导航工具项。
		 */
		public function MapToolButton()
		{
			super();
			
			this.setStyle("skinClass", com.xzdbd.ags4flex.skins.SingleButtonSkin);
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.addEventListener(MouseEvent.CLICK, toolMouseClickHandler);
		} 
		
		private var _map:Map;
		
		[Bindable]
		/**
		 * 地图 Map 对象的引用。
		 */
		public function get map():Map
		{
			return _map;
		}
		/**
		 * @private
		 */
		public function set map(value:Map):void
		{
			_map = value;
		}
		
		/**
		 * 组件创建完毕之后调用该方法。
		 */
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		/**
		 * 接收鼠标单击事件时调用该方法。
		 * <br>该方法会派发一个叫 TOOL_CLICK 的内部事件。
		 */
		protected function toolMouseClickHandler(event:MouseEvent):void
		{
			dispatchEvent(new MouseEvent(TOOL_CLICK, true)); // bubbles
		}

	} 
} 








