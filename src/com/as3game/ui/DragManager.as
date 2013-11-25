package com.as3game.ui
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * 拖放管理类，可以对任何可视化对象设置为可拖动。
	 * @author cbm
	 * 
	 */	
	public class DragManager
	{
		/**
		 * 构造函数 
		 * 
		 */		
		public function DragManager()
		{

		}
		
		private static var _target:Sprite
		private static var _rect:Rectangle;
		private static var _draging:Boolean;
		private static var _hitArea:InteractiveObject;
		/**
		 * 是否拖动时 updateAfterEvent
		 */		
		public static var updateAfterEvent:Boolean;
		/**
		 * 多个popUp时是否按点击自动调整到最前面 
		 */		
		public static var autoToFront:Boolean;
		
		private static var _targets:Dictionary = new Dictionary(true);
		/**
		 * 在显示对象添加可以被拖动的功能。 
		 * @param target 已经在显示列表需要添加拖动拖动对象。
		 * @param rect 拖动的限制范围，默认无限制。
		 * @param hitArea 指定特别的hitArea，默认对象本身
		 * 
		 * 
		 */		
		public static function addTarget(target:Sprite,rect:Rectangle = null,hitArea:InteractiveObject = null):void{
			
			_target = target;
			
			_rect = rect;
			
			_hitArea = hitArea || target;
			
			_targets[_hitArea] = {'rect':_rect,'target':_target}
			
			_hitArea.addEventListener(MouseEvent.MOUSE_DOWN,targetMouseDown);
		}
		/**
		 * 移除显示对象拖拽功能
		 * @param target 对象
		 * @param hitArea 热区，如果之前有特别设置的话。
		 * 
		 */		
		public static function removeTarget(target:Sprite,hitArea:InteractiveObject = null):void{
			
			var _hitArea:InteractiveObject = hitArea || target;
			
			if(_targets[_hitArea]){
				
				_hitArea.removeEventListener(MouseEvent.MOUSE_DOWN,targetMouseDown);
				
				delete _targets[_hitArea];
			}
			
		}
		/**
		 * 添加内置事件 
		 * 
		 */		
		private static function addEvent():void{
			
			if(_target.stage){
				
				_target.stage.addEventListener(MouseEvent.MOUSE_MOVE,targetMouseMove);
				_target.stage.addEventListener(MouseEvent.MOUSE_UP,targetMouseUp);
				
			}
		}
		/**
		 * 移除内置事件 
		 * 
		 */		
		private static function removeEvent():void{
			
			if(_target.stage)
			{
				_target.stage.removeEventListener(MouseEvent.MOUSE_UP,targetMouseUp);
				_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE,targetMouseMove);
			}

		}
		private static function targetMouseDown(event:MouseEvent):void{
			
			_target = _targets[event.currentTarget].target;
			_rect = _targets[event.currentTarget].rect;
			
			if(autoToFront)PopUpManager.bringToFront(_target)
			
			addEvent()

		}
		private static function targetMouseMove(event:MouseEvent):void 
		{
			if (!_draging) 
			{
				_draging = true;
				
				_target.startDrag(false,_rect);
				
			}
			
			if(updateAfterEvent){
				
				event.updateAfterEvent();
				
			}else{
				
				_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE,targetMouseMove);
				
			}
		}
		private static function targetMouseUp(event:MouseEvent):void{
			
			removeEvent()

			_target.stopDrag();
			
			if(_draging)_target.dispatchEvent(new Event('LOCATION_CHANGE'))//发送LOCATION_CHANGE事件
			
			_draging = false;
		}

	}
}