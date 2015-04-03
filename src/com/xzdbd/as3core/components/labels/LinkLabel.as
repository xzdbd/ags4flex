package com.xzdbd.as3core.components.labels 
{ 
	import flash.events.MouseEvent;
	
	import spark.components.Label;
	
	
	/*******************************************
	 * 可链接样式文本组件.
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>LinkLabel</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:as3core="http://www.xzdbd.net/2013/flex/as3core"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;as3core:LinkLabel 
	 * 	<b>Properties</b>
	 * 	text="更多信息..." 
	 * 
	 * 	<b>Styles</b>
	 * 	rollOverColor="0x0000FF" 
	 * 	rollOutColor="0x000000" 
	 * 	underline="false" 
	 * 	useFontWeight="true" /&gt;
	 * </pre>
     * </p>
	 * 
	 * @author 郝超
	 * 创建于 2013-7-12,上午10:24:47.
	 * 
	 *******************************************/ 
	public class LinkLabel extends Label 
	{ 
		public function LinkLabel()
		{
			super();
			
			this.buttonMode = true;
			this.setStyle("textDecoration", "none");
			this.addEventListener(MouseEvent.ROLL_OVER, labelMouseRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, labelMouseRollOutHandler);
		} 
		
		private var _rollOverColor:uint  = 0x1000000;
		private var _rollOutColor:uint;
		private var _underline:Boolean = false;
		private var _useFontWeight:Boolean = true;

		/**
		 * 鼠标悬浮时文本显示的颜色值，默认为 0x1000000。
		 */
		public function get rollOverColor():uint
		{
			return _rollOverColor;
		}

		/**
		 * @private
		 */
		public function set rollOverColor(value:uint):void
		{
			_rollOverColor = value;
		}

		/**
		 * 鼠标移出时文本显示的颜色值。
		 */
		public function get rollOutColor():uint
		{
			return _rollOutColor;
		}

		/**
		 * @private
		 */
		public function set rollOutColor(value:uint):void
		{
			_rollOutColor = value;
		}

		/**
		 * 鼠标悬浮时是否显示文本下划线，默认为 false。
		 */
		public function get underline():Boolean
		{
			return _underline;
		}

		/**
		 * @private
		 */
		public function set underline(value:Boolean):void
		{
			_underline = value;
		}

		/**
		 * 鼠标悬浮和移出时是否改变文本字体粗细，默认为 true。
		 */
		public function get useFontWeight():Boolean
		{
			return _useFontWeight;
		}

		/**
		 * @private
		 */
		public function set useFontWeight(value:Boolean):void
		{
			_useFontWeight = value;
		}

		
		/**
		 * MouseEvent.ROLL_OVER 事件的默认处理函数。
		 */
		protected function labelMouseRollOverHandler(event:MouseEvent):void
		{
			if(rollOverColor <= 0xFFFFFF)
			{
				rollOutColor = this.getStyle("color");
				event.target.setStyle("color", rollOverColor);
			}
			if(useFontWeight)
				event.target.setStyle("fontWeight", "bold");
			if(underline)
				event.target.setStyle("textDecoration", "underline");
		}
		
		/**
		 * MouseEvent.ROLL_OUT 事件的默认处理函数。
		 */
		protected function labelMouseRollOutHandler(event:MouseEvent):void
		{
			if(rollOverColor <= 0xFFFFFF)
			{
				event.target.setStyle("color", rollOutColor);
			}
			if(useFontWeight)
				event.target.setStyle("fontWeight", "normal");
			if(underline)
				event.target.setStyle("textDecoration", "none");
		}
	} 
} 




