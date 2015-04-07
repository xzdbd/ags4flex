package com.xzdbd.ags4flex.components.mapTools.supportClasses
{
	import spark.components.Button;

	
	/**
	 * 地图工具栏工具按钮基类.
	 * 
	 * @author xzdbd
	 * 创建于 2013-5-22,下午3:18:08.
	 * 
	 */
	public class NavSingleButton extends Button
	{
		/**
		 * 构造函数。
		 */
		public function NavSingleButton()
		{
			this.buttonMode = true;
		}
		
		//工具按钮图片资源 Url
		private var _iconUrl:Object;

		[Bindable]
		/**
		 * 工具按钮图片资源对象，若未设置则使用默认图片。
		 * <br>图片大小最大长宽均为 20 px。
		 */
		public function get iconUrl():Object
		{
			return _iconUrl;
		}
		/**
		 * @private
		 */
		public function set iconUrl(value:Object):void
		{
			_iconUrl = value;
		}

	}
}









