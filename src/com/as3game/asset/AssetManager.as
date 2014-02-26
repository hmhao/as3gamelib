package com.as3game.asset
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.BinaryItem;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import com.as3game.event.GameEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;
	
	/**
	 * 资源管理类AssetManager（基于BulkLoader库）
	 * 负责加载和承载资源的全局单例，对于需要加载的资源，首先判断是否已经加载，没有加载才需要add，否则从缓存中读取
	 * @author Tylerzhu
	 */
	public class AssetManager extends EventDispatcher
	{
		/**
		 * 加载url指定资源
		 * @param	url
		 * @param	callback
		 * @param	vars - 加载资源参数选项{
		 * 		id: 资源标识key,
		 * 		context: LoaderContext or SoundLoaderContex，可以指定将资源加载到哪个域中
		 * 		preventCache: 是否缓存,
		 * 		priority: 可以通过priority属性调整加载对象的加载顺序，priority值越大，优先权越高，越早加载
		 * 		maxTries: maxTries属性用于设定加载失败时的重试次数
		 * 		headers: An array of RequestHeader objects to be used when constructing the URL. If the url parameter is passed as a string, BulkLoader will use these request headers to construct the url.
		 * 		pausedAtStart: 加载动画的时候可以用pausedAtStart属性暂停播放动画
		 * 		weight:文件大小 }
		 */
		public function getAsset(url:String, callback:Function, vars:Object = null):void
		{
			trace(url)
			var isLoaded:Boolean = bulkLoader.hasItem(url);
			if (!isLoaded)
			{
				if (!bulkLoader.get(url))
				{
					//如果vars为空，则赋值{}
					vars = (vars == null) ? vars = {} : vars;
					//设置将资源加载到哪个域
					if (!vars.hasOwnProperty("context"))
					{
						if (BulkLoader.guessType(url) == BulkLoader.TYPE_SOUND)
						{
							vars.context = new SoundLoaderContext();
						}
						else
						{
							//设置默认将资源加载到当前域，方便后面使用
							vars.context = new LoaderContext(false, ApplicationDomain.currentDomain, null);
							
						}
					}
					//callback需要使用一个数组来存储
					//因为可能一个资源没有加载完成的情况下，另一处同时请求这个资源，前面的回调会被覆盖而失效
					m_items[url] = m_items[url] || {};
					m_items[url].callback = m_items[url].callback || [];
					m_items[url].callback.push(callback);
					bulkLoader.add(url, vars);
					bulkLoader.get(url).addEventListener(BulkLoader.COMPLETE, onItemComplete);
					
					bulkLoader.addEventListener(BulkLoader.COMPLETE, onAllComplete);
					bulkLoader.addEventListener(BulkLoader.ERROR, onErrorHandler);
					bulkLoader.addEventListener(BulkLoader.PROGRESS, onProgressHandler);
					bulkLoader.addEventListener(BulkLoader.SECURITY_ERROR, onSecurityHandler);
					bulkLoader.start();
				}
				else 
				{
					m_items[url].push(callback);
				}
			}
			else
			{
				//已经加载过，从缓存读取
				if (callback.length > 1)
				{
					//一次加载一组资源
					callback(m_items[url].group, m_items[url].groupCallback, url);
				}
				else
				{
					callback(bulkLoader.getContent(url));
				}
			}
		}
		
		public function getGroupAssets(groupName:String, urls:Array, callback:Function, vars:Object = null):void
		{
			if (m_groupsDic[groupName] != null)
			{
				return;
				throw new Error(groupName + " is already exist");
			}
			m_groupsDic[groupName] = { "urls": urls.slice(), "callback": callback };
			for each (var url:String in urls)
			{
				if (!bulkLoader.hasItem(url))
				{
					//
					m_items[url] = m_items[url] || {};
					m_items[url].group = groupName;
					m_items[url].groupCallback = callback;
					getAsset(url, onGroupItemComplete, vars);
				}
				else
				{
					if (bulkLoader.get(url).status == LoadingItem.STATUS_FINISHED)
					{
						var groupUrls:Array = m_groupsDic[groupName].urls;
						var idx:int = groupUrls.indexOf(url);
						if (idx != -1)
						{
							groupUrls.splice(idx, 1);
						}
						
						if (groupUrls.length == 0)
						{ //资源加载完成
							delete m_groupsDic[groupName];
							callback();
							return;
						}
					}
					else
					{
						m_items[url].group = groupName;
						m_items[url].groupCallback = callback;
						m_items[url].callback.push(onGroupItemComplete);
					}
				}
			}
		}
		
		public function getContent(key:String, clearMemory:Boolean = false):*
		{
			var loader:BulkLoader = BulkLoader.whichLoaderHasItem(key)
			return loader.getContent(key, clearMemory);
		}
		
		public function getClassByName(clsName:String, domain:ApplicationDomain = null):Class
		{
			var cls:Class = null;
			var appDomain:ApplicationDomain = (domain != null) ? domain : ApplicationDomain.currentDomain;
			if (appDomain.hasDefinition(clsName))
			{
				cls = appDomain.getDefinition(clsName) as Class;
			}
			return cls ? cls : null;
		}
		
		public function getMovieClipByName(clsName:String):MovieClip
		{
			var cls:Class = getClassByName(clsName);
			if (cls != null)
			{
				return new cls();
			}
			return null;
		}
		
		/**
		 * Register a new file extension to be loaded as a given type. This is used both in the guessing of types from the url and affects how loading is done for each type.
		 *   If you are adding an extension to be of a type you are creating, you must pass the <code>withClass</code> parameter, which should be a class that extends LoadingItem.
		 *   @param  extension   The file extension to be used (can include the dot or not)
		 *   @param  atType      Which type this extension will be associated with.
		 *   @param  withClass   For new types (not new extensions) wich class that extends LoadingItem should be used to mange this item.
		 *   @see #TYPE_IMAGE
		 *   @see #TYPE_VIDEO
		 *   @see #TYPE_SOUND
		 *   @see #TYPE_TEXT
		 *   @see #TYPE_XML
		 *   @see #TYPE_MOVIECLIP
		 *   @see #LoadingItem
		 *
		 *   @return A <code>Boolean</code> indicating if the new extension was registered.
		 */
		public function registerNewType(extension:String, atType:String, withClass:Class = null):Boolean
		{
			return BulkLoader.registerNewType(extension, atType, withClass);
		}
		
		public function get bulkLoader():BulkLoader
		{
			return m_bulkLoader;
		}
		
		public static function getInstance():AssetManager
		{
			if (!m_instance)
			{
				m_instance = new AssetManager(new PrivateClass());
			}
			return m_instance;
		}
		
		private function onItemComplete(e:Event):void
		{
			var request:URLRequest = e.currentTarget.url;
			var itemObj:Object = m_items[request.url];
			delete m_items[request.url];
			for each (var callback:Function in itemObj.callback)
			{
				if (callback.length > 1)
				{
					//一次加载一组资源
					//callback(itemObj.group, itemObj.groupCallback, request.url);
					for (var groupName:String in m_groupsDic) 
					{
						for each(var item:String in m_groupsDic[groupName].urls) 
						{
							if (item == request.url) 
							{
								callback(groupName, m_groupsDic[groupName].callback, request.url);
							}
						}
					}
				}
				else
				{
					callback(bulkLoader.getContent(request.url));
				}
			}
			
			bulkLoader.get(request.url).removeEventListener(BulkLoader.COMPLETE, onItemComplete);
			
			dispatchEvent(new GameEvent(Event.COMPLETE, {"target": e.target}));
		}
		
		private function onGroupItemComplete(groupName:String, groupCallback:Function, url:String):void
		{
			var groupUrls:Array = m_groupsDic[groupName].urls;
			if (groupUrls != null)
			{
				var idx:int = groupUrls.indexOf(url);
				if (idx != -1)
				{
					groupUrls.splice(idx, 1);
				}
				
				if (groupUrls.length == 0)
				{ //资源加载完成
					delete m_groupsDic[groupName];
					groupCallback();
				}
			}
			else 
			{
				trace("group: ", groupName, "找不到")
			}
		}
		
		private function onAllComplete(e:Event):void
		{
			trace("所有资源已经加载完成, bulkloader处于空闲状态")
		}
		
		private function onSecurityHandler(e:Event):void
		{
		
		}
		
		private function onProgressHandler(e:Event):void
		{
			//trace("加载资源")
		}
		
		private function onErrorHandler(e:Event):void
		{
			//失败的时候，删除错误的请求，否则m_items会越来越大，而且保存了回调函数的引用，相当于内存泄漏
			var failItems:Array = bulkLoader.getFailedItems();
			for each (var item:Object in failItems)
			{
				delete m_items[item.url.url];
			}
			
			//删除失败的请求，否则bulkloader的状态一致处于非空闲状态，即还有资源要加载
			bulkLoader.removeFailedItems();
		}
		
		public function AssetManager(pvt:PrivateClass)
		{
			if (m_instance)
			{
				throw new Error("AssetManager is a Singleton class. Use getInstance() to retrieve the existing instance.");
			}
			
			//m_bulkLoader = new BulkLoader('utils');
			m_bulkLoader = BulkLoader.getLoader("utils");
			if (m_bulkLoader == null)
			{
				m_bulkLoader = new BulkLoader('utils');
			}
			m_items = new Dictionary(true);
			m_groupsDic = new Dictionary(true);
		}
		
		public static const TYPE_ZIP:String = "zip"; //文件类型
		public static const CLASS_BINARY:Class = BinaryItem; //二进制格式解析类
		
		private static var m_instance:AssetManager;
		private var m_bulkLoader:BulkLoader;
		private var m_items:Dictionary;
		private var m_groupsDic:Dictionary;
	}
}

class PrivateClass
{
	public function PrivateClass()
	{
		//trace("包外类，用于实现单例");
	}
}