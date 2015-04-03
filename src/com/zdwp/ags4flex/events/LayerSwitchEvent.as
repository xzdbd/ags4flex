package com.zdwp.ags4flex.events
{
	import flash.events.Event;
	import com.zdwp.ags4flex.components.layerControlClasses.event.LayerEventBus;
	
	
	/*****************************************************************************************************************
	 * 图层控制组件内部事件类.
	 * 
	 * <p>该类不仅包含内部事件常量的定义，还通过内部事件总线 LayerEventBus 的单例实现了事件的监听和派发.</p>
	 * 
	 * @author 郝超
	 * 创建于 2012-4-11,上午09:24:20.
	 * 
	 ******************************************************************************************************************/
	public class LayerSwitchEvent extends Event
	{
		/**
		 * 组件外部驱动的图层可见性更改事件，用来通知组件，以使得实际图层打开情况与组件内部图层树统一。
		 */
		public static const LAYER_VISIBLE_CHANGED:String = "layerVisibleChanged";
		
		/**
		 * 组件内部事件，该事件在图层树列表中的项目选择被更改时派发，从而打开或者关闭相应地图图层。
		 */
		public static const SELECT_ITEMS_CHANGED:String = "selectItemsChanged";
		
		
		/**
		 * 派发一个特定类型的 LayerSwitchEvent 事件（包括数据对象）。
		 */
		public static function dispatch(type:String, data:Object = null, useBusyCursor:Boolean=true, callback:Function = null):Boolean
		{
			return LayerEventBus.instance.dispatchEvent(new LayerSwitchEvent(type, data, useBusyCursor, callback));
		}
		
		/**
		 * 监听一个特定类型的 LayerSwitchEvent 事件。
		 */
		public static function addListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			LayerEventBus.instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * 移除对特定类型的 LayerSwitchEvent 事件的监听。
		 */
		public static function removeListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			LayerEventBus.instance.removeEventListener(type, listener, useCapture);
		}
		
		
		/**
		 * 构造函数。
		 */
		public function LayerSwitchEvent(type:String, data:Object=null, useBusyCursor:Boolean=true, callback:Function=null)
		{
			super(type);
			_data = data;
			_useBusyCursor = useBusyCursor;
			_callback = callback;
		}
		
		//--------------------------------------------------------------------------
		//  属性
		//--------------------------------------------------------------------------
		
		private var _data:Object;
		//默认为true
		private var _useBusyCursor:Boolean = true;

		private var _callback:Function;
		
		/**
		 * 随事件一起被派发的数据对象。
		 */
		[Bindable]
		public function get data():Object
		{
			return _data;
		}
		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			_data=value;
		}
		
		/**
		 * 状态变化过程中，是否使用鼠标忙碌状态进行过渡，默认为true。
		 */
		[Bindable]
		public function get useBusyCursor():Boolean
		{
			return _useBusyCursor;
		}
		/**
		 * @private
		 */
		public function set useBusyCursor(value:Boolean):void
		{
			_useBusyCursor = value;
		}
		
		/**
		 * 和该类事件关联的回调函数。
		 */
		public function get callback():Function
		{
			return _callback;
		}
		/**
		 * @private
		 */
		public function set callback(value:Function):void
		{
			_callback=value;
		}
		
	}
}







