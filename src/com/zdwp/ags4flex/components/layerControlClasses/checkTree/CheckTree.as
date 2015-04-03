package com.zdwp.ags4flex.components.layerControlClasses.checkTree
{
	import com.zdwp.ags4flex.components.layerControlClasses.checkTree.classes.CheckTreeRenderer;
	import com.zdwp.ags4flex.events.LayerSwitchEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Tree;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;

	
	/**************************************************
	 * 支持三状态复选框的树控件.
	 * 
	 * @author 郝超
	 * 创建于 2012-4-10,下午01:25:22.
	 * 
	 **************************************************/
    public class CheckTree extends Tree   
    {
		/**
		 * 构造函数。
		 */
		public function CheckTree()   
		{   
			super();
			doubleClickEnabled=true;  
		}
		
        //数据源中状态字段
        private var _checkBoxStateField:String = "@state";   
        //部分选中的填充色   
        private var _checkBoxBgColor:uint = 0x009900;   
        //填充色的透明度   
        private var _checkBoxBgAlpha:Number = 1;   
        //填充色的边距   
        private var _checkBoxBgPadding:Number = 3;   
        //填充色的四角弧度   
        private var _checkBoxBgElips:Number = 2;   
        //取消选择是否收回子项   
        private var _checkBoxCloseItemsOnUnCheck:Boolean = false;   
        //选择项时是否展开子项   
        private var _checkBoxOpenItemsOnCheck:Boolean = false;   
        //选择框左边距的偏移量   
        private var _checkBoxLeftGap:int = 3; //4
        //选择框右边距的偏移量   
        private var _checkBoxRightGap:int = 5; //20
        //是否显示三状态   
        private var _checkBoxEnableState:Boolean = true;   
        //与父项子项关联   
        private var _checkBoxCascadeOnCheck:Boolean = true; 
		//是否在节点头部显示图标
		private var _itemIconVisible:Boolean = false;   
		//是否使用树样式
		private var _useTreeStyle:Boolean = false;   
		//更改状态过程中，是否使用鼠标忙碌状态过渡
		private var _useBusyCursor:Boolean = true;   
        //是否接收双击展开项目节点动作   
        private var _itemDClickSelect:Boolean = false; 
		
        /**  
         * 数据源中状态字段。
         */        
        [Bindable]   
        public function get checkBoxStateField():String   
        {   
            return _checkBoxStateField;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxStateField(v:String):void  
        {   
            _checkBoxStateField=v;   
            PropertyChange();   
        }   
           
        /**  
         * 部分选中的填充色。
         */        
        [Bindable]   
        public function get checkBoxBgColor():uint   
        {   
            return _checkBoxBgColor;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxBgColor(v:uint):void  
        {   
            _checkBoxBgColor=v;   
            PropertyChange();   
        }   
           
        /**  
         * 填充色的透明度。
         */        
        [Bindable]   
        public function get checkBoxBgAlpha():Number   
        {   
            return _checkBoxBgAlpha;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxBgAlpha(v:Number):void  
        {   
            _checkBoxBgAlpha=v;   
            PropertyChange();   
        }   
           
           
        /**  
         * 填充色的边距。
         */        
        [Bindable]   
        public function get checkBoxBgPadding():Number   
        {   
            return _checkBoxBgPadding;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxBgPadding(v:Number):void  
        {   
            _checkBoxBgPadding=v;   
            PropertyChange();   
        }   
           
        /**  
         * 填充色的四角弧度。 
         */        
        [Bindable]   
        public function get checkBoxBgElips():Number   
        {   
            return _checkBoxBgElips;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxBgElips(v:Number):void  
        {   
            _checkBoxBgElips=v;   
            PropertyChange();   
        }   
           
        /**  
         * 取消选择是否收回子项。
         */        
        [Bindable]   
        public function get checkBoxCloseItemsOnUnCheck():Boolean   
        {   
            return _checkBoxCloseItemsOnUnCheck;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxCloseItemsOnUnCheck(v:Boolean):void  
        {   
            _checkBoxCloseItemsOnUnCheck=v;   
            PropertyChange();   
        }   
		
        /**  
         * 选择项时是否展开子项。  
         */        
        [Bindable]   
        public function get checkBoxOpenItemsOnCheck():Boolean   
        {   
            return _checkBoxOpenItemsOnCheck;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxOpenItemsOnCheck(v:Boolean):void  
        {   
            _checkBoxOpenItemsOnCheck=v;   
            PropertyChange();   
        }   
           
        /**  
         * 选择框左边距的偏移量。  
         */        
        [Bindable]   
        public function get checkBoxLeftGap():int  
        {   
            return _checkBoxLeftGap;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxLeftGap(v:int):void  
        {   
            _checkBoxLeftGap=v;   
            PropertyChange();   
        }   
           
        /**  
         * 选择框右边距的偏移量。  
         */        
        [Bindable]   
        public function get checkBoxRightGap():int  
        {   
            return _checkBoxRightGap;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxRightGap(v:int):void  
        {   
            _checkBoxRightGap=v;   
            PropertyChange();   
        }   
           
        /**  
         * 是否显示三状态。
         */        
        [Bindable]   
        public function get checkBoxEnableState():Boolean   
        {   
            return _checkBoxEnableState;   
        }  
		/**
		 * @private
		 */
        public function set checkBoxEnableState(v:Boolean):void  
        {   
            _checkBoxEnableState=v;   
            PropertyChange();   
        }   
           
        /**  
         * 与父项子项关联。  
         */  
        [Bindable]   
        public function get checkBoxCascadeOnCheck():Boolean   
        {   
            return _checkBoxCascadeOnCheck;   
        }   
		/**
		 * @private
		 */
        public function set checkBoxCascadeOnCheck(v:Boolean):void
        {   
            _checkBoxCascadeOnCheck=v;   
            PropertyChange();   
        }
		
		/**  
		 * 是否显示节点图标。
		 */  
		[Bindable]   
		public function get itemIconVisible():Boolean   
		{   
			return _itemIconVisible;   
		}   
		/**
		 * @private
		 */
		public function set itemIconVisible(v:Boolean):void
		{   
			_itemIconVisible=v;   
			PropertyChange();   
		}
		
		/**  
		 * 是否使用指定Tree样式。
		 */  
		[Bindable]   
		public function get useTreeStyle():Boolean   
		{   
			return _useTreeStyle;   
		}
		/**
		 * @private
		 */
		public function set useTreeStyle(v:Boolean):void
		{   
			_useTreeStyle=v;   
			PropertyChange();   
		}
		
		/**
		 * 状态变化，是否使用鼠标忙碌样式过渡。
		 */
		[Bindable]
		public function get useBusyCursor():Boolean
		{
			return _useBusyCursor;
		}
		/**
		 * @private
		 */
		public function set useBusyCursor(value:Boolean):void
		{
			_useBusyCursor = value;
		}
		
		/**
		 * 是否接收双击展开项目节点动作。
		 */
		[Bindable]
		public function get itemDClickSelect():Boolean
		{
			return _itemDClickSelect;
		}
		/**
		 * @private
		 */
		public function set itemDClickSelect(value:Boolean):void
		{
			_itemDClickSelect = value;
		}
		
		//====================================================================================
		
		/**
		 * 重写父类 labelFunction 函数。
		 */
		override public function set labelFunction(value:Function):void
		{
			invalidateProperties();
		}
		
		/**
		 * 重写父类 createChildren 函数。
		 */
		override protected function createChildren():void  
		{   
			var myFactory:ClassFactory=new ClassFactory(CheckTreeRenderer);   
			this.itemRenderer=myFactory;   
			super.createChildren();   
			addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onItemDClick);   
		}   
		
		/**
		 * 当属性更改时调用，派发列表属性更改事件。
		 */
		public function PropertyChange():void  
		{   
			dispatchEvent(new ListEvent(mx.events.ListEvent.CHANGE));   
		}   
		
		/**
		 * 当Tree项目节点上CheckBox选择更改时，调用该函数。
		 * <br>该函数将当前最新的选择数据项打包通过事件的方式向外派发。
		 * @param state 当前的选择状态。
		 * @param data 当前项目选择的数据集。
		 */
        public function SelectChangeData(state:Boolean, data:ArrayCollection):void
        {
        	var sendObject:Object = new Object();
        	sendObject.state = state;
        	sendObject.data = data;
			
			//构建并派发事件
			var event:LayerSwitchEvent = new LayerSwitchEvent(LayerSwitchEvent.SELECT_ITEMS_CHANGED, sendObject, useBusyCursor);
			this.dispatchEvent(event);
			
			//恢复默认值
			useBusyCursor = true;
        }
		
		/**  
		 * 打开Tree中选中节点项，被有打开节点功能的函数调用。
		 */  
		public function OpenItems():void  
		{   
			if (this.selectedIndex >= 0 && this.dataDescriptor.isBranch(this.selectedItem))  
			{
				this.expandItem(this.selectedItem, !this.isItemOpen(this.selectedItem), true);  
			}
		}
		
		/**  
		 * 树中项目双击时的处理函数。
		 */  
		private function onItemDClick(event:ListEvent):void  
		{   
			if(itemDClickSelect)   
			{
				OpenItems();   
			}
		}   

    }   
}





