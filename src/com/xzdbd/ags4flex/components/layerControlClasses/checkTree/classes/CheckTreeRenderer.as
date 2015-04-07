package com.xzdbd.ags4flex.components.layerControlClasses.checkTree.classes
{
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.xzdbd.ags4flex.components.layerControlClasses.checkTree.CheckTree;
	import com.xzdbd.ags4flex.components.layerControlClasses.checkTree.controls.TriStateCheckBox;
	import com.xzdbd.ags4flex.components.layerControlClasses.checkTree.controls.TriStateCheckBoxIcon;
	import com.xzdbd.ags4flex.components.layerControlClasses.classes.LayerItem;
	import com.xzdbd.ags4flex.events.LayerSwitchEvent;
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.controls.CheckBox;
	import mx.controls.Image;
	import mx.controls.Tree;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	import mx.events.ListEvent;
	import mx.utils.StringUtil;
	
	
    /**************************************************
     * 三状态复选框树的自定义的项呈示器.
	 * 
     * @author xzdbd
	 * 创建于 2012-4-10,下午08:23:42.
	 * 
     **************************************************/
    public class CheckTreeRenderer extends TreeItemRenderer   
    { 
		/**  
		 * STATE_SCHRODINGER	: 部分子项选中。
		 * <br>STATE_CHECKED	: 全部子项选中。
		 * <br>STATE_UNCHECKED	: 全部子项未选中。
		 */  
		static private var STATE_SCHRODINGER:int=2;   
		static private var STATE_CHECKED:int=1;   
		static private var STATE_UNCHECKED:int=0;   
		
		//复选框对象
        protected var myCheckBox:TriStateCheckBox; 
		
		//自定义图标
        protected var myImage:Image;
		private var dufaultIconUrl:String = "";
        
		//宿主树对象引用
        private var myTree:CheckTree;
		
		//当前操作状态改变的选项列表
        private var selectChangeList:ArrayCollection = new ArrayCollection();
		
		/**
		 * 构造函数。
		 */
        public function CheckTreeRenderer()   
        {   
            super();
            mouseEnabled = true;   
            myImage = new Image();
			
			//添加外部图层开关事件监听
			LayerSwitchEvent.addListener(LayerSwitchEvent.LAYER_VISIBLE_CHANGED, layerVisibleChangedHandler);
        }  
		
		/**
		 * 重写父类commitProperties方法。
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (data is LayerItem)
			{
				var item:LayerItem = LayerItem(data);
				
				//if(myCheckBox.selected != (item.state==1))
					//myCheckBox.dispatchEvent(new MouseEvent(MouseEvent.CLICK));   
				//invalidateProperties();
			}
		}
		
        /**  
         * 重写父类createChildren方法。
		 * <br>初始化完成时处理复选框和图片对象。
         */  
        override protected function createChildren():void  
        {   
            myCheckBox = new TriStateCheckBox(); 
			myCheckBox.setStyle("icon", TriStateCheckBoxIcon);
            addChild(myCheckBox);   
            myCheckBox.addEventListener(MouseEvent.CLICK, checkBoxToggleHandler);   
               
            myTree = this.owner as CheckTree;   
            
            super.createChildren();   
            myTree.addEventListener(ListEvent.CHANGE,onPropertyChange);
            
           	myImage.source = dufaultIconUrl;
            addChild(myImage);
        }  
		/**
		 * 属性更改时调用该方法。
		 */
		protected function onPropertyChange(e:ListEvent=null):void  
		{   
			this.updateDisplayList(unscaledWidth,unscaledHeight);   
		}   
		
		/**
		 * 重写父类方法。
		 */
		override public function set data(value:Object):void  
		{   
			if (value != null)   
			{   
				super.data = value;   
				if (data.iconPath && StringUtil.trim(data.iconPath) != "")
				{
					myImage.source = data.iconPath;
				}
				else if(dufaultIconUrl != "")
				{
					myImage.source = dufaultIconUrl;
				}
				else
				{
					myImage.source = null;
				}
				setCheckState(myCheckBox, value, value[myTree.checkBoxStateField]);   
			}
		}   
		
		/**
		 * 重写父类updateDisplayList方法。
		 * 
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  
		{   
			super.updateDisplayList(unscaledWidth, unscaledHeight);  
			if (super.data)   
			{
				if(super.icon != null)
				{
					if(myTree.itemIconVisible)
					{
						if(myImage.source)
						{
							myCheckBox.x = super.icon.x + myTree.checkBoxLeftGap;   
							myCheckBox.y = (height - myCheckBox.height) / 2;   
							super.icon.x = myCheckBox.x + myCheckBox.minWidth + myTree.checkBoxRightGap;
							myImage.x = super.icon.x;
							myImage.y = super.icon.y;
							myImage.width = 15;	//super.icon.width;
							myImage.height = 15;	//super.icon.height;
							super.icon.visible = false;
							super.label.x = super.icon.x + super.icon.width + 3; 
						}
						else
						{
							myCheckBox.x = super.icon.x + myTree.checkBoxLeftGap;   
							myCheckBox.y = (height - myCheckBox.height) / 2;   
							super.icon.x = myCheckBox.x + myCheckBox.minWidth + myTree.checkBoxRightGap;
							super.icon.visible = true;
							super.label.x = super.icon.x + super.icon.width + 3; 
						}
					}
					else
					{
						myCheckBox.x = super.icon.x + myTree.checkBoxLeftGap; 
						myCheckBox.y = (height - myCheckBox.height) / 2; 
						super.icon.visible = false;
						super.label.x = super.icon.x + super.icon.width + myTree.checkBoxRightGap;
					}
				}
				else
				{
					myCheckBox.x = super.label.x + myTree.checkBoxLeftGap;   
					myCheckBox.y = (height - myCheckBox.height) / 2;   
					super.label.x = myCheckBox.x + myCheckBox.minWidth + myTree.checkBoxRightGap; 
				}
				
				//设置复选框选中状态
				setCheckState(myCheckBox, data, data[myTree.checkBoxStateField]);   
				if (myTree.checkBoxEnableState && data[myTree.checkBoxStateField] == STATE_SCHRODINGER)   
				{   
					//fillCheckBox(true);   
					myCheckBox.indeterminate = true;
					//trace(myTree.checkBoxEnableState);   
					//trace(data[myTree.checkBoxStateField]);   
				}   
				else  
				{
					//fillCheckBox(false);  
					myCheckBox.indeterminate = false;
				}
				
				super.label.setActualSize(unscaledWidth - super.label.x, measuredHeight);
				
				//绘制树节点之间的线条
				if(myTree.useTreeStyle)
				{
					drawItemLines(unscaledWidth, unscaledHeight);
				}
			}   
		}   
		
		/**
		 * 外部编程对图层控制事件的默认处理函数。
		 */
		private function layerVisibleChangedHandler(event:LayerSwitchEvent):void
		{
			if(data == null)
				return;
			var curLayerItem:LayerItem = data as LayerItem;
			if(curLayerItem.mapLayer is ArcGISDynamicMapServiceLayer)
			{
				var layerUrl:String = event.data.url;
				var layerId:Number = Number(event.data.id);
				var visible:Boolean = Boolean(event.data.visible);
				var serverUrl:String = ArcGISDynamicMapServiceLayer(curLayerItem.mapLayer).url;
				if(serverUrl.indexOf(layerUrl) != -1 && curLayerItem.layerId == layerId)
				{
					if(myCheckBox.selected != visible)
					{
						myTree.useBusyCursor = event.useBusyCursor;
						//派发模拟鼠标单击事件
						myCheckBox.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
					}
				}
			}
		}
		
        /**  
         * 递归设置父项目的状态。
         * @param item 当前节点项。  
         * @param tree 树对象引用。  
         * @param state 目标状态。
         * 
         */  
        private function toggleParents(item:Object, tree:Tree, state:int):void  
        {   
            if (item == null)   
                return ;   
            else  
            {   
                var stateField:String = myTree.checkBoxStateField;   
                var tmpTree:IList = myTree.dataProvider as IList;   
                var oldValue:Number = item[stateField] as Number;   
                var newValue:Number = state as Number;   
                   
                item[myTree.checkBoxStateField] = state;   
                tmpTree.itemUpdated(item,stateField,oldValue,newValue);   
                   
                //item[myTree.checkBoxStateField]=state;   
                var parentItem:Object = tree.getParentItem(item);   
                if(null != parentItem)   
                    toggleParents(parentItem, tree, getState(tree, parentItem));   
            }   
        }   
		
        /**  
         * 设置当前项目的状态和其对应子项的状态。
         * @param item 当前节点项。  
         * @param tree 树对象引用。  
         * @param state 目标状态。
         *  
         */  
        private function toggleChildren(item:Object, tree:Tree, state:int):void  
        {   
            if (item == null) 
			{
                return ; 
			}
            else  
            {   
                var stateField:String = myTree.checkBoxStateField;   
                var tmpTree:IList = myTree.dataProvider as IList;   
                var oldValue:Number = Number(item[stateField].toString());   
                var newValue:Number = state as Number;   
                   
                item[myTree.checkBoxStateField] = state;   
                tmpTree.itemUpdated(item,stateField,oldValue,newValue);   
                var treeData:ITreeDataDescriptor = tree.dataDescriptor;   
                if(!treeData.hasChildren(item))
                {
                	if(oldValue != newValue)
					{
                		selectChangeList.addItem(item);
					}
            	}
                if (myTree.checkBoxCascadeOnCheck && treeData.hasChildren(item))   
                {   
                    var children:ICollectionView = treeData.getChildren(item);   
                    var cursor:IViewCursor = children.createCursor();   
                    while(!cursor.afterLast)   
                    {   
                        toggleChildren(cursor.current, tree, state);   
                        cursor.moveNext();   
                    }   
                }   
            }   
        }   
		
        /**  
         * 获取Tree中指定节点项目的状态。
         * @param tree 树对象引用。
         * @param parent 目标项。
         * @return 目标项目选中状态值。  
         *  
         */  
		private function getState(tree:Tree, parent:Object):int  
		{   
			var noChecks:int = 0;   
			var noCats:int = 0;   
			var noUnChecks:int = 0;   
			if (parent != null)   
			{   
				var treeData:ITreeDataDescriptor = tree.dataDescriptor;   
				var cursor:IViewCursor = treeData.getChildren(parent).createCursor();   
				while(!cursor.afterLast)   
				{   
					if (cursor.current[myTree.checkBoxStateField] == STATE_CHECKED)   
					{
						noChecks ++;   
					}
					else if (cursor.current[myTree.checkBoxStateField] == STATE_UNCHECKED)   
					{
						noUnChecks ++;   
					}
					else
					{
						noCats ++;   
					}
					cursor.moveNext();   
				}   
			}   
			if ((noChecks > 0 && noUnChecks > 0) || noCats > 0)   
			{
				return STATE_SCHRODINGER;   
			}
			else if (noChecks > 0)  
			{
				return STATE_CHECKED;  
			}
			else 
			{
				return STATE_UNCHECKED;   
			}
		}   

		/**
		 * 当前项目节点对应CheckBox单击选择操作事件处理函数。
		 * <br>设置当前项目的父项状态和子项状态。
         *  
         */  
        private function checkBoxToggleHandler(event:MouseEvent):void  
        {   
            if (data)   
            {
            	var toggle:Boolean = myCheckBox.selected;
                var myListData:TreeListData = TreeListData(this.listData);   
                var selectedNode:Object = myListData.item;   
                myTree = myListData.owner as CheckTree;
                if (toggle)
                {
                	selectChangeList.removeAll();
                    toggleChildren(data, myTree, STATE_CHECKED); 
                    myTree.SelectChangeData(toggle, selectChangeList);
                    if (myTree.checkBoxOpenItemsOnCheck) 
					{
                        myTree.expandChildrenOf(data, true);   
					}
                }
                else  
                {
                	selectChangeList.removeAll();
                    toggleChildren(data, myTree, STATE_UNCHECKED);  
                    myTree.SelectChangeData(toggle,selectChangeList);
                    if (myTree.checkBoxCloseItemsOnUnCheck)
					{
                        myTree.expandChildrenOf(data, false);
					}
                }
				
                //如果所有子项选中时需要选中父项则执行以下代码   
                if (myTree.checkBoxCascadeOnCheck)   
                {   
                    var parent:Object = myTree.getParentItem(data);   
                    if(null != parent)   
					{
                        toggleParents(parent, myTree, getState(myTree, parent));   
					}
                }
				//设置忙碌鼠标样式
				//cursorManager.setBusyCursor();
            }   
            //myTree.PropertyChange();   
            //dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));   
        }   
		
        /**  
         * 设置当前项对应的复选框状态。
         * @param checkBox 当前项对应复选框。  
         * @param value 当前项数据对象。
         * @param state 要设置的状态。  
         *  
         */  
        private function setCheckState(checkBox:CheckBox, value:Object, state:int):void  
        {   
            if (state == STATE_CHECKED) 
			{
                checkBox.selected=true;   
			}
            else if (state == STATE_UNCHECKED)
			{
                checkBox.selected=false;
			}
            else if (state == STATE_SCHRODINGER)
			{
                checkBox.selected=false;
			}
        }   
		
		/**
		 * 填充项目对应CheckBox。
		 * @param isFill 是否对复选框进行填充。
		 */
        private function fillCheckBox(isFill:Boolean):void  
        {   
            myCheckBox.graphics.clear();   
            if (isFill)   
            {   
                var myRect:Rectangle = getCheckTreeBgRect(myTree.checkBoxBgPadding);   
                myCheckBox.graphics.beginFill(myTree.checkBoxBgColor, myTree.checkBoxBgAlpha)   
                myCheckBox.graphics.drawRoundRect(myRect.x, myRect.y, myRect.width, myRect.height, myTree.checkBoxBgElips, myTree.checkBoxBgElips);   
                myCheckBox.graphics.endFill();   
            }   
        }   
		
		/**
		 * 根据设置参数，获取CheckBox内部填充矩形区域对象。
		 * @param checkTreeBgPadding 填充矩形外边距。
		 * @return 复选框内部填充矩形对象。
		 */
		private function getCheckTreeBgRect(checkTreeBgPadding:Number):Rectangle   
        {   
           /* var myRect:Rectangle=myCheckBox.getBounds(myCheckBox);   
            var mmRect:Rectangle=myCheckBox.getRect(myCheckBox);
            myRect.top+=checkTreeBgPadding;   
            myRect.left+=checkTreeBgPadding;   
            myRect.bottom-=checkTreeBgPadding;   
            myRect.right-=checkTreeBgPadding;   
			*/
            var myRect:Rectangle = new Rectangle();
            myRect.top = -4;
            myRect.left = 3;
            myRect.right = 11;
            myRect.bottom = 4;
			
            return myRect;   
        }   
		
		/**
		 * 绘制项目节点间关联虚线。
		 */
		private function drawItemLines(w:Number, h:Number):void
		{
			if ((w > 0) && (h > 0)) 
			{
				var treeLineStyle:TreeLineStyle = new TreeLineStyle(disclosureIcon, icon, label);
				
				// go up the hierarchy, drawing the vertical dotted lines for each node 
				var tree:Tree = (owner as Tree);
				var desc:ITreeDataDescriptor = tree.dataDescriptor;
				var currentNode:Object = data;
				var parentNode:Object = tree.getParentItem(currentNode);
				// the level is zero at this node, then increases as we go up the tree
				var levelsUp:int = 0;
				
				var lineStyle:String = getStyle("lineStyle");
				var lineColor:uint = getColorStyle("lineColor", 0x333333); //0x808080
				var lineAlpha:Number = getNumberStyle("lineAlpha", 1);
				var lineThickness:Number = getNumberStyle("lineThickness", 1);
				var indentation:Number = tree.getStyle("indentation");
				
				// move the icon and label over to make room for the lines (less for root nodes)
				var shift:int = (parentNode == null ? 2 : 6) + lineThickness;
				if (icon) 
				{
					icon.move(icon.x + shift, icon.y);
				}
				if (label) 
				{
					label.move(label.x + shift, label.y);
				}
				
				var g:Graphics = graphics;
				g.clear();
				
				if ((lineStyle != TreeLineStyle.NONE) && (lineAlpha > 0) && (lineThickness > 0)) 
				{
					while (parentNode != null) 
					{
						var children:ICollectionView = desc.getChildren(parentNode);
						if (children is IList) 
						{
							var itemIndex:int = (children as IList).getItemIndex(currentNode);
							
							// if this node is the last child of the parent
							var isLast:Boolean = (itemIndex == (children.length - 1));
							treeLineStyle.drawLines(g, w, h, lineStyle, lineColor, lineAlpha, lineThickness, isLast, levelsUp, indentation);
							
							// go up to the parent, increasing the level
							levelsUp ++;
							currentNode = parentNode;
							parentNode = tree.getParentItem(parentNode);
						} 
						else 
						{
							break;
						}
					}
				}
			}
			
			//获取颜色属性值。
			function getColorStyle(propName:String, defaultValue:uint):uint 
			{
				var color:uint = defaultValue;
				if (propName != null) 
				{
					var n:Number = getStyle(propName);
					if (!isNaN(n)) 
					{
						color = uint(n);
					}
				}
				
				return color;
			}
			
			//获取数值属性值。
			function getNumberStyle(propName:String, defaultValue:Number):Number 
			{
				var number:Number = defaultValue;
				if (propName != null) 
				{
					var n:Number = getStyle(propName);
					if (!isNaN(n))
					{
						number = n;
					}
				}
				
				return number;
			}
		} 
		
    } //end class   
}





