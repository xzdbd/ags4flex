package com.zdwp.as3core.components.labels 
{ 
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.HGroup;
	import spark.components.Label;
	
	import flashx.textLayout.formats.LineBreak;
	
	/**
	 * 当用户单击文本内容链接时分派。
	 */
	[Event(name="linkClick", type="flash.events.Event")]
	
	
	/**************************************************
	 * 用于显示键值对的属性和相应值的 Label 组件.
	 * 
	 * @mxml
	 * <p> 
     * 下面代码演示如何使用 <code>InfoText</code> 类： 
	 * <p>首先，引用命名空间  <b><code>xmlns:as3core="http://www.zdwp.net/2013/flex/as3core"</code></b>，调用如下：</p>
	 * <pre>
	 * &lt;as3core:InfoText 
	 * 	<b>Properties</b>
	 * 	title="堤防名称" 
	 * 	content="上徐堤" 
	 * 	contentLinkable="false" 
	 * 
	 * 	<b>Styles</b>
	 * 	titleColor="0x52abc3" 
	 * 	contentColor="0x666666" 
	 * 	contentBold="false" 
	 * 
	 * 	<b>Events</b>
	 * 	linkClick="No default" /&gt;
	 * </pre>
     * </p>
	 * 
	 * @author 郝超
	 * 创建于 2013-5-22,下午11:16:44.
	 * 
	 **************************************************/ 
	public class InfoText extends HGroup 
	{ 
		//信息文本标题标签
		private var titleLbl:Label;
		
		/**
		 * 信息文本内容标签。
		 * @see com.zdwp.as3core.components.labelComp.LinkLabel。
		 */
		private var contentLbl:LinkLabel;
		
		/**
		 * 构造函数。
		 */
		public function InfoText()
		{
			super();
			
			this.titleLbl = new Label();
			this.titleLbl.setStyle("fontWeight", "bold");
			this.titleLbl.setStyle("color", _titleColor);
			
			this.contentLbl = new LinkLabel();
			this.contentLbl.percentWidth = 100;
			this.contentLbl.maxDisplayedLines = 50;
			this.contentLbl.setStyle("lineBreak", LineBreak.TO_FIT);
			this.contentLbl.setStyle("color", _contentColor);
			this.contentLbl.setStyle("fontWeight", _contentBold ? "bold" : "normal");
			this.contentLbl.mouseEnabled = _contentLinkable;
			this.contentLbl.underline = _contentLinkable;
			
			//添加内容标签的单击事件监听
			this.contentLbl.addEventListener(MouseEvent.CLICK, contentLbl_clickHandler);
			
			this.gap = 0;
			this.addElement(titleLbl);
			this.addElement(contentLbl);
		} 
		
		
		private var _title:String;
		
		[Bindable]
		/**
		 * 属性标题文本。
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
			this.titleLbl.text = _title + "：";
		}
		
		private var _content:String;
		
		[Bindable]
		/**
		 * 属性值文本。
		 */
		public function get content():String
		{
			return _content;
		}
		
		/**
		 * @private
		 */
		public function set content(value:String):void
		{
			_content = value;
			this.contentLbl.text = _content;
		}
		
		private var _titleColor:uint = 0x52abc3;
		
		[Bindable]
		/**
		 * 标题文本颜色，默认为 0x52abc3。
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
			this.titleLbl.setStyle("color", _titleColor);
		}
		
		private var _contentColor:uint = 0x666666;
		
		[Bindable]
		/**
		 * 属性值文本颜色，默认为 0x666666。
		 */
		public function get contentColor():uint
		{
			return _contentColor;
		}
		
		/**
		 * @private
		 */
		public function set contentColor(value:uint):void
		{
			_contentColor = value;
			this.contentLbl.setStyle("color", _contentColor);
		}
		
		private var _contentBold:Boolean = false;
		
		[Bindable]
		/**
		 * 属性值文本是否加粗，默认不加粗。
		 */
		public function get contentBold():Boolean
		{
			return _contentBold;
		}
		
		/**
		 * @private
		 */
		public function set contentBold(value:Boolean):void
		{
			_contentBold = value;
			this.contentLbl.setStyle("fontWeight", _contentBold ? "bold" : "normal");
		}
		
		private var _contentLinkable:Boolean = false;
		
		[Bindable]
		/**
		 * 属性值文本是否为可链接文本，默认为非链接文本。
		 */
		public function get contentLinkable():Boolean
		{
			return _contentLinkable;
		}
		
		/**
		 * @private
		 */
		public function set contentLinkable(value:Boolean):void
		{
			_contentLinkable = value;
			this.contentLbl.mouseEnabled = _contentLinkable;
			this.contentLbl.underline = _contentLinkable;
		}
		
		//文本内容链接单击
		private function contentLbl_clickHandler(event:MouseEvent):void
		{
			if(contentLinkable)
			{
				dispatchEvent(new Event("linkClick", true)); // bubbles
			}
		}
	} 
} 











