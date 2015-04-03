package com.zdwp.as3core.components.labels 
{ 
	import com.zdwp.as3core.components.SingleLine;
	
	import spark.components.HGroup;
	import spark.components.Label;
	
	
	/*******************************************
	 * 标题组件.
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>LabelTitle</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:as3core="http://www.zdwp.net/2013/flex/as3core"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;as3core:LabelTitle 
	 * 	<b>Properties</b>
	 * 	title="基本信息"
	 * 
	 * 	<b>Styles</b> 
	 * 	titleColor="0x0000FF" 
	 * 	lineVisible="false" 
	 * 	width="100%" /&gt;
	 * </pre>
     * </p>
	 * 
	 * @see com.zdwp.as3core.components.SingleLine
	 * 
	 * @author 郝超
	 * 创建于 2013-5-23,下午2:23:57.
     *  
	 *******************************************/ 
	public class LabelTitle extends HGroup 
	{ 
		/**
		 * 构造函数。
		 */
		public function LabelTitle()
		{
			super();
			
			titleHead = new Label();
			titleHead.text = ">>";
			titleHead.setStyle("fontSize", titleSize);
			titleHead.setStyle("fontWeight", "bold");
			titleHead.setStyle("fontFamily", "宋体");
			titleHead.setStyle("paddingLeft", 2);
			
			titleContent = new Label();
			titleContent.setStyle("color", titleColor);
			titleContent.setStyle("fontSize", titleSize);
			titleContent.setStyle("fontWeight", "bold");
			
			titleLine = new SingleLine();
			titleLine.percentWidth = 100;
			titleLine.weight = 1;
			titleLine.color = _titleColor; //0xCEE7F4;
			titleLine.visible = _lineVisible;
			titleLine.alpha = 0.7;
			
			this.percentWidth = 100;
			this.verticalAlign = "middle";
			this.gap = 4;
			this.addElement(titleHead);
			this.addElement(titleContent);
			this.addElement(titleLine);
		} 
		
		//标题头部
		private var titleHead:Label;
		
		//标题主体内容
		private var titleContent:Label;
		
		//标题后面跟随的占位横线
		private var titleLine:SingleLine;
		
		//标题文本字符串
		private var _title:String;
		
		//标题文本颜色。
		private var _titleColor:uint = 0x3e97af;
		
		//标题文本大小。
		private var _titleSize:Number = 12;
		
		//标题后面横线可见性
		private var _lineVisible:Boolean = true;

		
		[Bindable]
		/**
		 * 标题文本。
		 */
		public function get title():String
		{
			return _title;
		}

		/**
		 * @private
		 */
		public function set title(value:String):void
		{
			_title = value;
			titleContent.text = _title;
		}

		[Bindable]
		/**
		 * 标题颜色。
		 */
		public function get titleColor():uint
		{
			return _titleColor;
		}

		/**
		 * @private
		 */
		public function set titleColor(value:uint):void
		{
			_titleColor = value;
			titleContent.setStyle("color", _titleColor);
		}
		
		[Bindable]
		/**
		 * 标题文本字体大小。
		 */
		public function get titleSize():Number
		{
			return _titleSize;
		}
		
		/**
		 * @private
		 */
		public function set titleSize(value:Number):void
		{
			_titleSize = value;
			titleHead.setStyle("fontSize", titleSize);
			titleContent.setStyle("fontSize", titleSize);
		}

		[Bindable]
		/**
		 * 标题后的横线可见性。
		 */
		public function get lineVisible():Boolean
		{
			return _lineVisible;
		}

		/**
		 * @private
		 */
		public function set lineVisible(value:Boolean):void
		{
			_lineVisible = value;
			titleLine.visible = _lineVisible;
		}


	} 
} 







