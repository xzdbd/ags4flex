package com.xzdbd.ags4flex.components.supportClasses
{
    import com.esri.ags.Graphic;
    import com.esri.ags.geometry.MapPoint;

    /****************************************************
     * 在地图上实现点集的聚合.
	 * 
	 * <p> 
     * 扩展基于flexviewer实现的点聚合效果.
     * <ol> 
     * <li>重构.</li> 
     * <li>增加分级配置功能.</li> 
     * <li>增加默认递增聚合效果.</li> 
     * </ol> 
     * </p> 
	 * 
	 * @author 郝超
	 * 创建于 2013-5-9,下午6:35:42.
	 * 
     *****************************************************/
    public class Cluster extends MapPoint 
	{
		/**
		 * 构造函数。
		 */
		public function Cluster(x:Number, y:Number, cx:int, cy:int) 
		{
			super(x, y);
			this.cx = cx;
			this.cy = cy;
			
			_mapPointGraphics = new Array();
		}
		
        //聚合点质心X坐标
        private var _cx:int;
        //聚合点质心Y坐标
        private var _cy:int;

        //聚合的MapPoint对应的Graphic集合
        [ArrayElementType("com.esri.ags.Graphic")]
        private var _mapPointGraphics:Array;
		
		/**
		 * 聚合点质心X坐标。
		 */
		public function get cx():int 
		{
			return this._cx;
		}
		
		/**
		 * @private
		 */
		public function set cx(value:int):void {
			this._cx = value;
		}
		
		/**
		 * 聚合点质心Y坐标。
		 */
		public function get cy():int {
			return this._cy;
		}
		
		/**
		 * @private
		 */
		public function set cy(value:int):void {
			this._cy = value;
		}
		
		/**
		 * 聚合的MapPoint对应的Graphic集合。
		 */
		public function get mapPointGraphics():Array 
		{
			return this._mapPointGraphics;
		}

		/**
		 * 向聚合对象集合中添加Graphic。
		 * @param mapPointGraphic 对应MapPoint的Graphic对象。
		 */
        public function addMapPointGraphic(mapPointGraphic:Graphic):void 
		{
            mapPointGraphics.push(mapPointGraphic);
        }

		/**
		 * 获取聚合对象集合中对象总数。
		 * @return 聚合对象总数(uint)。
		 */
        public function getMapPointCount():uint 
		{
            return mapPointGraphics.length;
        }

        /**
		 * 合并点对象集合，并根据聚合点数量调整质心权重。
         */
        public function merge(rhs:Cluster):void
		{
            // 左边
            var lhsMapPointCount:uint = this.getMapPointCount();
            // 右边
            var rhsMapPointCount:uint = rhs.getMapPointCount();

            const nume:Number = lhsMapPointCount + rhsMapPointCount;
            this.x = (lhsMapPointCount * this.x + rhsMapPointCount * rhs.x) / nume;
            this.y = (lhsMapPointCount * this.y + rhsMapPointCount * rhs.y) / nume;

            // 合并点对象集合。
            // 将graphic转移到聚合点上, rhs将不再包含任何点(已被合并为)。
            for (var i:int=rhs.mapPointGraphics.length-1; i>=0; i--) 
			{
                this.addMapPointGraphic(rhs.mapPointGraphics.pop());
            }
        }

    }
}




