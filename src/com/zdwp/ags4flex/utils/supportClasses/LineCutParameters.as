package com.zdwp.ags4flex.utils.supportClasses 
{ 
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;


	/****************************************************
	 * 线段裁剪操作输入参数类.
	 * 
	 * @author 郝超
	 * 创建于 2013-7-20,下午11:46:56.
	 * 
	 *****************************************************/
	public class LineCutParameters 
	{ 
		/**
		 * 构造函数。
		 */
		public function LineCutParameters()
		{
		} 
		
		
		private var _map:Map;
		
		private var _sourceGraphic:Graphic;
		
		private var _startPoint:MapPoint;
		
		private var _breakPoint:MapPoint;
		
		private var _bufferDistance:Number;
		
		
		[Bindable]
		/**
		 * Map对象。
		 */
		public function get map():Map
		{
			return _map;
		}

		/**
		 * @private
		 */
		public function set map(value:Map):void
		{
			_map = value;
		}

		[Bindable]
		/**
		 * 需要被裁剪的线对象要素对应的 Graphic。
		 */
		public function get sourceGraphic():Graphic
		{
			return _sourceGraphic;
		}

		/**
		 * @private
		 */
		public function set sourceGraphic(value:Graphic):void
		{
			_sourceGraphic = value;
		}

		[Bindable]
		/**
		 * 线段裁剪起点。
		 */
		public function get startPoint():MapPoint
		{
			return _startPoint;
		}

		/**
		 * @private
		 */
		public function set startPoint(value:MapPoint):void
		{
			_startPoint = value;
		}

		[Bindable]
		/**
		 * 裁剪线段输入的裁剪点进行缓冲查找周边线要素时的缓冲距离，默认为 50 米。
		 */
		public function get bufferDistance():Number
		{
			return _bufferDistance;
		}

		/**
		 * @private
		 */
		public function set bufferDistance(value:Number):void
		{
			_bufferDistance = value;
		}

		[Bindable]
		/**
		 * 裁剪线段输入的裁剪点。
		 * <br>该点不一定是线上的一个点，但必须是线附近的一个点。
		 */
		public function get breakPoint():MapPoint
		{
			return _breakPoint;
		}

		/**
		 * @private
		 */
		public function set breakPoint(value:MapPoint):void
		{
			_breakPoint = value;
		}


	} 
} 









