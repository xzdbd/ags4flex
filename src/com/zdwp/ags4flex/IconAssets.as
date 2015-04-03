package com.zdwp.ags4flex 
{ 
	
	/*******************************************
	 * 类库中使用的图片文件资源类.
	 * 
	 * @author 郝超
	 * 创建于 2013-7-22,下午1:25:59.
	 * 
	 *******************************************/ 
	public final class IconAssets 
	{ 
		/**
		 * 鼠标绘制时的样式。
		 */
		[Embed(source="assets/images/drawCursor.png")]
		public var cursorForDraw:Class;
		
		/**
		 * 绘制时绘制节点的样式。
		 */
		[Embed(source="assets/images/drawNode.png")]
		public var drawNodeIcon:Class;
		
		/**
		 * 清除绘制按钮的样式。
		 */
		[Embed(source="assets/images/clearDraw.png")]
		public var clearDrawIcon:Class;
		
		/**
		 * 测量时的鼠标样式。
		 */
		[Embed(source="assets/images/measureCursor.png")]
		public var cursorForLengthMeasure:Class;
		
		/**
		 * 绘制入口按钮图片。
		 */
		[Embed(source="assets/images/drawLine.png")]
		public var drawLineIcon:Class;
		
		/**
		 * 测量入口按钮图片。
		 */
		[Embed(source="assets/images/measureIcon.png")]
		public var measureIcon:Class;
		
		/**
		 * 清空地图入口按钮图片。
		 */
		[Embed(source="assets/images/clearMap.png")]
		public var clearMapIcon:Class;
		
		/**
		 * 缩放地图要素功能按钮图片。
		 */
		[Embed(source="assets/images/zoom.png")]
		public var zoomIcon:Class;
		
		/**
		 * 树节点展开图标。
		 */
		[Bindable]
		[Embed(source="assets/images/minus.gif")]
		private var disclosureOpenIconClass:Class;
		
		/**
		 * 树节点收缩图标。
		 */
		[Bindable]
		[Embed(source="assets/images/plus.gif")]
		private var disclosureClosedIconClass:Class; 
		
		
		/**
		 * 根据名称返回该类中的资源对象。
		 * @param resName 资源名称。
		 * @return 资源名称对应的资源类对象。
		 */
		public static function iconClass(resName:String):Class  
		{  
			var iconAssets:IconAssets = new IconAssets();  
			var iconClass:Class = iconAssets[resName] as Class;
			
			return iconClass;
		}  
		
		
		/**
		 * 构造函数。
		 */
		public function IconAssets()
		{
		} 
	} 
} 





