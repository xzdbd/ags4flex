package com.xzdbd.as3core.components 
{ 
	import flash.display.CapsStyle;
	
	import mx.graphics.SolidColorStroke;
	
	import spark.components.HGroup;
	import spark.primitives.Line;
	
	/*******************************************
	 * 绘制单条直线段.
	 * 
	 * <p>该组件以 <code>HGroup</code> 作为容器，实现 <code>Line</code> 的绘制.</p>
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>SingleLine</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:as3core="http://www.xzdbd.net/2013/flex/as3core"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;as3core:SingleLine 
	 * 	<b>Properties</b>
	 * 
	 * 	<b>Styles</b>
	 * 	weight="2"
	 * 	color="0x999999"
	 * 	paddingTop="2"
	 * 	width="100%" /&gt;
	 * </pre>
     * </p>
	 * 
	 * @author 郝超
	 * 创建于 2013-4-16,下午06:00:04.
	 * 
	 *******************************************/ 
	public class SingleLine extends HGroup 
	{ 
		/**
		 * 构造函数。
		 */
		public function SingleLine()
		{
			super();
			
			_line = new Line();
			_lineStroke = new SolidColorStroke(color, weight, 1.0, false, "normal", CapsStyle.SQUARE);
			_line.stroke = _lineStroke;
			_line.percentWidth = 100;
			
			this.percentWidth = 100;
			this.horizontalAlign = "center";
			this.addElement(_line);
		} 	
		
		//线对象
		private var _line:Line;
		
		//线条笔触
		private var _lineStroke:SolidColorStroke;
			
		//线条颜色
		private var _color:uint = 0x999999; //0xADD8E1;
		
		//线条粗细
		private var _weight:int = 1;
		
		[Bindable]
		/**
		 * 直线颜色，默认为系统contentBackgroundColor对应主题色。
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * @private
		 */
		public function set color(value:uint):void
		{
			_color = value;
			_lineStroke.color = _color;
		}
		
		[Bindable]
		/**
		 * 直线粗细粒度，默认为1。
		 */
		public function get weight():int
		{
			return _weight;
		}
		
		/**
		 * @private
		 */
		public function set weight(value:int):void
		{
			_weight = value;
			_lineStroke.weight = _weight;
		}
		
	} 
} 








