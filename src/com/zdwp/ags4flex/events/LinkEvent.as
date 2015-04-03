package com.zdwp.ags4flex.events
{
	import flash.events.Event;
	
	
	/**********************************************
	 * 组件链接事件类.
	 * 
	 * @author 郝超
	 * 创建于 2012-4-11,上午09:24:20.
	 * 
	 **********************************************/
	public class LinkEvent extends Event
	{
		/**
		 * 构造函数。
		 */
		public function LinkEvent(type:String, data:Object=null, callback:Function=null)
		{
			super(type);
			_data = data;
			_callback = callback;
		}
		
		//--------------------------------------------------------------------------
		//  属性
		//--------------------------------------------------------------------------
		
		private var _data:Object;

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







