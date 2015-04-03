package com.zdwp.ags4flex.components.layerControlClasses.checkTree.controls
{
	import mx.skins.halo.CheckBoxIcon;

	/******************************************************
	 * 三态复选框选择状态（中间状态）填充.
	 * 
	 * @author 郝超
	 * 创建于 2012-4-10,下午01:30:22.
	 * 
	 ******************************************************/
	public class TriStateCheckBoxIcon extends CheckBoxIcon
	{
		/**
		 * 重写父类 updateDisplayList 方法。
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);

			var indet:Boolean = getStyle("indeterminate");

			if (indet)
			{
				var cornerRadius:Number = 1;

				//var boxFillColors:Array = [ 0xAAAACC, 0x666666 ];
				var boxFillColors:Array=[0x000000, 0x666666];
				var boxFillAlphas:Array=[0.7, 0.7];
				
				drawRoundRect(3, 3, w - 6, h - 6, cornerRadius, boxFillColors, boxFillAlphas, verticalGradientMatrix(1, 1, w - 2, h - 2));
			}
		}
	}
}






