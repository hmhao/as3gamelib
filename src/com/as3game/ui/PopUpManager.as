package com.as3game.ui
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 弹窗管理类
	 * @author tyler
	 */
	public class PopUpManager extends EventDispatcher
	{
		private static var _popUpLayer:DisplayObjectContainer;
		private static var _stage:DisplayObjectContainer;
		private static var _dict:Dictionary = new Dictionary(true);
		private static var _items:Array = [];
		
		/**
		 *  stageWidth，非 NO_SCALE 时需要使用
		 */
		public static var stageWidth:int = 0;
		/**
		 *  stageHeight，非 NO_SCALE 时需要使用
		 */
		public static var stageHeight:int = 0;
		/**
		 * 使用自动居中时可选偏移量。
		 */
		public static var offset:Point = new Point(0, 0);
		
		/**
		 * 返回存在的PopUp实例。
		 * @return PopUp实例
		 */
		public static function get items():Array
		{
			
			return _items;
		}
		
		public function PopUpManager()
		{
			super();
			
			if (_popUpLayer != null)
			{
				throw new Error("实例化单例类出错 - " + getQualifiedClassName(this));
			}
		
		}
		
		/**
		 * 初始化
		 * @param stage 舞台。
		 * @param popUpLayer 弹出层放置的容器
		 *
		 */
		public static function init(popUpLayer:DisplayObjectContainer, stage:DisplayObjectContainer):void
		{
			if (popUpLayer == null)
			{
				throw new Error('检查到 popUpLayer 为空');
			}
			_stage = stage;
			setPopUpLayer(popUpLayer);
		}
		
		/**
		 * 获得弹出层实例
		 */
		public static function getPopUpLayer():DisplayObjectContainer
		{
			return _popUpLayer;
		}
		
		private static function setPopUpLayer(target:DisplayObjectContainer):void
		{
			
			if (_popUpLayer == null)
			{
				_popUpLayer = target;
				_popUpLayer.mouseEnabled = false;
				_stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			}
		
		}
		
		/**
		 * 添加一个 popUp 实例
		 * @param popUp 指定实例
		 * @param modal 是否有阻挡层
		 * @param moveToCenter 移动到居中位置
		 * @param parent 在那个父级上创建PopUp
		 * @return popUp 实例
		 */
		public static function addPopUp(popUp:DisplayObject, modal:Boolean = false, moveToCenter:Boolean = true, parent:DisplayObjectContainer = null):DisplayObject
		{
			if (_stage == null)
			{
				throw new Error('检查到 stage 为空，请预先使用 PopUpManager.init() 进行初始化。');
			}
			
			if (parent == null)
				parent = getPopUpLayer();
			
			var point:Point = new Point();
			if (moveToCenter)
			{
				point = centerPopUp(popUp);
			}
			else
			{
				point = new Point(popUp.x, popUp.y);
			}
			
			if (modal)
			{
				var modalLayer:Sprite = new Sprite();
				var w:int = stageWidth ? stageWidth : _stage.stage.stageWidth;
				var h:int = stageHeight ? stageHeight : _stage.stage.stageHeight;
				draw(modalLayer, 0x000000, .3, new Rectangle(0, 0, w, h), true);
				parent.addChild(modalLayer);
				_stage['root'].tabChildren = false;
			}
			
			_stage.stage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUp);
			popUp.addEventListener(Event.CLOSE, _CLOSE);
			_dict[popUp] = {'popUp': popUp, 'modal': modalLayer};
			_items.push(popUp);
			
			popUp.filters = [new DropShadowFilter(5, 45, 0, .6, 5, 5)];
			parent.addChild(popUp);
			
			//popUp.x = point.x;
			//popUp.y = point.y;
			
			//popUp.scaleX = 0.5;
			//popUp.scaleY = 0.5;
			popUp.x = (_stage.stage.stageWidth - popUp.width) / 2;
			popUp.y = (_stage.stage.stageHeight - popUp.height) / 2;
			
			//TweenMax.to(popUp, .3, {x: point.x, y: point.y, scaleX: 1, scaleY: 1, ease: Back.easeOut, onComplete: function():void
			//{
			//
			//}});
			
			if (popUp is Sprite && popUp.hasOwnProperty('headArea'))
			{
				var titleWindow:Sprite = popUp as Sprite;
				DragManager.addTarget(titleWindow, null, titleWindow['headArea'])
			}
			
			return popUp;
		}
		
		public static function draw(target:DisplayObject, color:uint = 0, alpha:Number = 1, rect:Rectangle = null, fill:Boolean = false, clear:Boolean = true):void
		{
			
			if (target.hasOwnProperty('graphics'))
			{
				var g:Graphics = target['graphics'];
				if (clear)
					g.clear();
				if (fill)
					g.beginFill(color, alpha);
				else
					g.lineStyle(1, color, alpha);
				if (rect)
					g.drawRect(rect.x, rect.y, rect.width, rect.height);
				else
					g.drawRect(0, 0, target.width, target.height)
				g.endFill();
			}
		}
		
		/**
		 * 将移动到 popUp 居中位置
		 * @param popUp 实例
		 *
		 */
		public static function centerPopUp(popUp:DisplayObject):Point
		{
			
			var scaleX:Number = getPopUpLayer().scaleX;
			var scaleY:Number = getPopUpLayer().scaleY;
			var w:int = stageWidth ? stageWidth : _stage.stage.stageWidth;
			var h:int = stageHeight ? stageHeight : _stage.stage.stageHeight;
			var x:int = middle(w, popUp.width * scaleX) + offset.x;
			var y:int = middle(h, popUp.height * scaleY) + offset.y;
			x = x / scaleX;
			y = y / scaleY;
			if (y < 0)
			{
				y = 0;
			}
			
			popUp.x = x;
			popUp.y = y;
			
			return new Point(x, y);
		}
		
		public static function middle(maxValue:Number, value:Number):Number
		{
			var v:Number = 0;
			v = maxValue / 2 - value / 2;
			return v;
		}
		
		/**
		 * 将指定popUp带到最前面。
		 * @param popUp
		 *
		 */
		public static function bringToFront(popUp:DisplayObjectContainer):void
		{
			if (getPopUpLayer().numChildren)
			{
				getPopUpLayer().setChildIndex(popUp, getPopUpLayer().numChildren - 1);
			}
		}
		
		/**
		 * 按指定 Class 创建 popUp
		 * @param className Class 的名称
		 * @param modal 是否有阻挡层
		 * @param moveToCenter 移动到居中位置
		 * @param parent 在那个父级上创建PopUp
		 * @return popUp 实例
		 *
		 */
		public static function createPopUp(className:Class, modal:Boolean = false, moveToCenter:Boolean = true, parent:DisplayObjectContainer = null):DisplayObject
		{
			if (parent)
				_stage = parent;
			var popUp:DisplayObjectContainer = new className();
			addPopUp(popUp, modal, moveToCenter, parent);
			return popUp;
		}
		
		/**
		 * 移除所有的 popUp 实例。
		 * @return
		 *
		 */
		public static function removeAllPopUp():void
		{
			var len:int = _items.length;
			for (var i:int = len - 1; i > -1; i--)
			{
				removePopUp(_items[i] as DisplayObject);
			}
		}
		
		/**
		 * center all popUp when resize
		 * @param	e
		 */
		protected static function onResize(e:Event):void
		{
			var len:int = _items.length;
			for (var i:int = len - 1; i > -1; i--)
			{
				centerPopUp(_items[i] as DisplayObject);
			}
		}
		
		/**
		 * 移除 popUp 对象
		 * @param popUp 实例
		 *
		 */
		public static function removePopUp(popUp:DisplayObject):DisplayObject
		{
			if (popUp is Sprite && popUp.hasOwnProperty('headArea'))
			{
				var titleWindow:Sprite = popUp as Sprite;
				DragManager.removeTarget(titleWindow, titleWindow['headArea'])
			}
			
			if (popUp && popUp.parent)
			{
				if (_dict[popUp])
				{
					if (_dict[popUp].modal && popUp.parent)
						popUp.parent.removeChild(_dict[popUp].modal);
					var index:int = _items.indexOf(popUp);
					if (index > -1)
					{
						_items.splice(index, 1);
					}
					
					delete _dict[popUp];
				}
				
				/**
				 * 检查PopUp存在modal的情况，如果没有，恢复 tabChildren为true。
				 */
				
				var hasMedal:Boolean = false;
				for each (var item:Object in _dict)
				{
					if (item.modal)
					{
						hasMedal = true;
						break;
					}
				}
				
				if (hasMedal == false)
				{
					_stage['root'].tabChildren = true;
				}
				
				if (popUp)
				{
					popUp.parent.removeChild(popUp);
						//TweenLite.to(popUp, .2, {x: (_stage.stage.stageWidth - popUp.width * 0.5) / 2, y: (_stage.stage.stageHeight - popUp.height * 0.5) / 2, scaleX: 0.5, scaleY: 0.5, ease: Back.easeIn, onComplete: function():void
						//{
						//if (popUp.parent)
						//{
						//popUp.scaleX = 1;
						//popUp.scaleY = 1;
						//popUp.parent.removeChild(popUp);
						//}
						//}})
				}
				
			}
			
			return popUp;
		}
		
		/**
		 * 如果popUp对象发起了CLOSE事件，将其自动移除。
		 * @param event
		 *
		 */
		private static function _CLOSE(event:Event):void
		{
			
			var popUp:DisplayObjectContainer = event.currentTarget as DisplayObjectContainer;
			
			if (popUp)
			{
				
				popUp.removeEventListener(Event.CLOSE, _CLOSE);
				
				removePopUp(popUp);
				
				if (ApplicationDomain.currentDomain.hasDefinition('tft.qui.managers::ToolTipManager'))
				{
					
					var ToolTipManagerClass:* = ApplicationDomain.currentDomain.getDefinition('tft.qui.managers::ToolTipManager');
					
					ToolTipManagerClass.hide();
					
				}
				
			}
		
		}
		
		private static function stageKeyUp(e:KeyboardEvent):void
		{
			if (getPopUpLayer().numChildren && e.keyCode == 13)
			{
				var popUp:DisplayObject = getPopUpLayer().getChildAt(getPopUpLayer().numChildren - 1) as DisplayObject;
				
				if (popUp && popUp.hasOwnProperty('keyEnter'))
				{
					popUp['keyEnter'](e);
					
				}
				
			}
		}
	
	}

}