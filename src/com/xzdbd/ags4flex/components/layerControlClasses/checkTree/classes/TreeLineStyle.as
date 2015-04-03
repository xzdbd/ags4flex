package com.xzdbd.ags4flex.components.layerControlClasses.checkTree.classes
{ 
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUITextField;
	
	
	/**
	 * 线条透明度。
	 * @default 1。
	 */
	[Style(name="lineAlpha", type="Number", format="Length", inherit="no")]
	
	/**
	 * 线条颜色。
	 * @default 0x808080。
	 */
	[Style(name="lineColor", type="uint", format="Color", inherit="no")]
	
	/**
	 * 线条粗细。
	 * @default 1。
	 */
	[Style(name="lineThickness", type="Number", format="Length", inherit="no")]
	
	/**
	 * 线条样式 - 无样式(none)、虚线(dotted (default))、实线(solid)。
	 * @default "dotted"。
	 */
	[Style(name="lineStyle", type="String", enumeration="dotted,solid,none", inherit="no")]
	
	
	/************************************************************
	 * 该类实现树组件(Tree)各节点之间的关联线段绘制.
	 * 
	 * @author 郝超
	 * 创建于 2012-11-26,下午04:23:42.
	 * 
	 ************************************************************/    
	public class TreeLineStyle 
	{
		/**
		 * 虚线（线型样式类别）（默认值）。
		 */
		public static const DOTTED:String = "dotted";
		/**
		 * 实线（线型样式类别）。
		 */
		public static const SOLID:String = "solid";
		/**
		 * 无样式（线型样式类别）。
		 */
		public static const NONE:String = "none";
		
		//Tree默认呈示器
		private var _itemRenderer:TreeItemRenderer;
		
		private var _disclosureIcon:IFlexDisplayObject;
		private var _icon:IFlexDisplayObject;
		private var _label:IUITextField;
		
		/**
		 * 构造函数。
		 * @param disclosureIcon 显示泄露图标的内部 IFlexDisplayObject。
		 * @param icon 显示图标的内部 IFlexDisplayObject。
		 * @param label 显示文本的内部 UITextField。
		 */
		public function TreeLineStyle(disclosureIcon:IFlexDisplayObject,
									  icon:IFlexDisplayObject,
									  label:IUITextField)
		{
			_disclosureIcon = disclosureIcon;
			_icon = icon;
			_label = label;
		} 
		
		/**
		 * 绘制线条。
		 * @param g 指定属于此 sprite 的 Graphics 对象。
		 * @param w 节点项宽度。
		 * @param h 节点项高度。
		 * @param lineStyle 线条样式。
		 * @param lineColor 线条颜色。
		 * @param lineAlpha 线条透明度。
		 * @param lineThickness 线条粗细。
		 * @param isLastItem 是否为最末节点项。
		 * @param levelsUp 节点级别编号。
		 * @param indentation 缩进。
		 * 
		 */
		public function drawLines(g:Graphics, w:Number, h:Number, lineStyle:String, lineColor:uint,
								  lineAlpha:Number, lineThickness:Number, isLastItem:Boolean, levelsUp:int, indentation:Number):void 
		{
			var midY:Number = Math.round(h / 2);
			var lineX:Number = 0;
			if (_disclosureIcon) 
			{
				lineX = _disclosureIcon.x + (_disclosureIcon.width / 2);
			} 
			else if (_icon) 
			{
				lineX = _icon.x - 8;
			}
			else if (_label) 
			{
				lineX = _label.x - 8;
			}
			lineX = Math.floor(lineX) - int(lineThickness / 2);
			
			// adjust the x position based on the indentation
			if (levelsUp > 0) 
			{
				if (!isNaN(indentation) && (indentation > 0)) 
				{
					lineX = lineX - (levelsUp * indentation);
				} 
				else 
				{
					// Invalid indentation style value
					return;
				}
			}
			var lineY:Number = h;
			
			// stop the dotted line halfway on the last item
			if (isLastItem) 
			{
				lineY = midY;
				
				// no lines need to be drawn for parents of the last item
				if (levelsUp > 0) 
				{
					return;
				}
			}
			
			g.lineStyle(0, 0, 0);
			if (lineStyle == SOLID) {
				g.beginFill(lineColor, lineAlpha);
			} else {
				var verticalDottedLine:BitmapData = createDottedLine(lineColor, lineAlpha, lineThickness, true);
				g.beginBitmapFill(verticalDottedLine);
			}
			
			// draw the vertical line
			g.drawRect(lineX, 0, lineThickness, lineY);
			// end the fill and start it again otherwise the lines overlap and it create white squares
			g.endFill();
			
			// draw the horizontal line - only needed on this node (not on any parents)
			if (levelsUp == 0) 
			{
				var startX:int = lineX + 1 + int(lineThickness / 2);
				var endX:int = startX + 11;	// 5 dots
				if (isLastItem) 
				{
					startX = lineX;
				}
				var startY:Number = midY - int(lineThickness / 2);
				if (lineStyle == SOLID) 
				{
					g.beginFill(lineColor, lineAlpha);
				} 
				else 
				{
					var horizontalDottedLine:BitmapData = createDottedLine(lineColor, lineAlpha, lineThickness, false);
					g.beginBitmapFill(horizontalDottedLine);
				}
				g.drawRect(startX, startY, endX - startX, lineThickness);	
				g.endFill();
			}
		}
		
		/**
		 * 创建一个BitmapData是用来渲染一条虚线。
		 * <br>如果参数 "vertical" 为 true，则创建一个长度（高度）是宽度（即线型粗细linethickness）两倍的矩形位图。
		 * <br>否则就创建一个宽度是长度（高度）两倍的矩形位图。
		 * <br>矩形位图的上一半以线条颜色和透明度的值来进行填充，而下一半则为透明度。
		 * <br><br>(EN)
		 * <br>Creates a BitmapData that is used to renderer a dotted line.
		 * <br>If the vertical parameter is true, then it creates a rectangle bitmap that is 
		 * twice as long as it is wide (lineThickness).  Otherwise it creates a rectangle
		 * that is twice as wide as it is long.
		 * <br>The first half of the rectangle is filled with the line color (and alpha value),
		 * then second half is transparent.
		 */
		private function createDottedLine(lineColor:uint, lineAlpha:Number, lineThickness:Number, 
										  vertical:Boolean = true):BitmapData 
		{
			var w:Number = (vertical ? lineThickness : 2 * lineThickness);
			var h:Number = (vertical ? 2 * lineThickness : lineThickness);
			var color32:uint = combineColorAndAlpha(lineColor, lineAlpha);
			var dottedLine:BitmapData = new BitmapData(w, h, true, 0x00ffffff);
			
			// 创建一个点型位图
			for (var i:int = 0; i < lineThickness; i++) 
			{
				for (var j:int = 0; j < lineThickness; j++) 
				{
					dottedLine.setPixel32(i, j, color32);
				}
			}
			
			return dottedLine;
		}
		
		/**
		 * 结合线条颜色值和透明度值，得到一个32位的整型数值，如 #AARRGGBB。
		 * @param color 线条颜色值。
		 * @param alpha 线条透明度值。
		 * @return 一个综合整形数值。
		 */
		private function combineColorAndAlpha(color:uint, alpha:Number):uint 
		{
			// make sure the alpha is a valid number [0-1]
			if (isNaN(alpha)) 
			{
				alpha = 1;
			} 
			else 
			{
				alpha = Math.max(0, Math.min(1, alpha));
			}
			
			// convert the [0-1] alpha value into [0-255]
			var alphaColor:Number = alpha * 255;
			
			// bitshift it to come before the color
			alphaColor = alphaColor << 24;
			
			// combine the two values: #AARRGGBB
			var combined:uint = alphaColor | color;
			
			return combined;  
		}
	} 
} 










