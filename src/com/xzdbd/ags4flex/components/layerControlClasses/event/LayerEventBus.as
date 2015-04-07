///////////////////////////////////////////////////////////////////////////
// 图层控制内部全局事件总线。
///////////////////////////////////////////////////////////////////////////
package com.xzdbd.ags4flex.components.layerControlClasses.event
{
	import flash.events.EventDispatcher;

	/*************************************************************************************
	 * 图层控制内部全局事件总线类。内部事件的监听和派发都是由该类的单例统一进行.
	 * 
	 * @author xzdbd
	 * 创建于 2012-4-11,上午09:24:20.
	 * 
	 *************************************************************************************/
	public class LayerEventBus extends EventDispatcher
	{
		/**
		 * 图层控制内部全局事件单例。
		 */
		public static const instance:LayerEventBus = new LayerEventBus();

		/**
		 * 构造函数。
		 */
		public function LayerEventBus()
		{
		}
	}
}






