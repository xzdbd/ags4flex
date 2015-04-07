package com.xzdbd.ags4flex.components.layerControlClasses.checkTree.controls
{
	import flash.events.Event;

	import mx.controls.CheckBox;

	
	/**************************************************
	 * 支持三态选择的复选框.
	 * 
	 * @author xzdbd
	 * 创建于 2012-4-10,下午01:25:22.
	 * 
	 **************************************************/
	public class TriStateCheckBox extends CheckBox
	{
		/**
		 * 构造函数。
		 */
		public function TriStateCheckBox()
		{
			setStyle("icon", TriStateCheckBoxIcon);
			setStyle("indeterminate", _indeterminate);
			//setStyle("layoutDirection", "ltr"); // fix check mark's direction 
		}

		//--------------------------------------------------------------------------
		//  Property:  indeterminate
		//--------------------------------------------------------------------------
		private var _indeterminate:Boolean=false;

		[Bindable("indeterminateChanged")]
		
		/**
		 * 指定该复选框是否为 indeterminate 状态。
		 * 
		 */
		public function get indeterminate():Boolean
		{
			return _indeterminate;
		}

		/**
		 * @private
		 */
		public function set indeterminate(value:Boolean):void
		{
			if (value != _indeterminate)
			{
				_indeterminate=value;
				setStyle("indeterminate", _indeterminate);

				dispatchEvent(new Event("indeterminateChanged"));
			}
		}
	}
}





