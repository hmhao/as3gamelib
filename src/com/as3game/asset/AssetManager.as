package com.as3game.asset
{
	import br.com.stimuli.loading.BulkLoader;
	import flash.events.EventDispatcher;
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
		 * @param	urls
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
		public function getAsset(urls:Array, callback:Function, vars:Object = null):void
		{
			var isLoaded:Boolean = false;
			for each (var req:String in urls)
			{
				isLoaded = m_bulkLoader.hasItem(req);
				if (!isLoaded)
				{
					//
					m_bulkLoader.add(req, vars);
					m_items[req] = new Array();
					m_items[req].push(callback);
					m_bulkLoader.addEventListener(BulkLoader.COMPLETE, onComplete);
					m_bulkLoader.addEventListener(BulkLoader.ERROR, onErrorHandler);
					m_bulkLoader.addEventListener(BulkLoader.PROGRESS, onProgressHandler);
					m_bulkLoader.addEventListener(BulkLoader.SECURITY_ERROR, onSecurityHandler);
					m_bulkLoader.get(req).addEventListener(BulkLoader.COMPLETE, onItemComplete);
					m_bulkLoader.start();
				}
				else
				{
					//已经加载过，从缓存读取
					callback(bulkLoader.getContent(req));
				}
			}
		}
		
		public function getGroupAssets(urls:Array, callback:Function, vars:Object = null):void
		{
			vars = (vars == null) ? vars = {} : vars; //如果vars为空，则赋值{}
			
			for each (var url:String in urls)
			{
				
				//设置将资源加载到哪个域
				if (!vars.hasOwnProperty("context"))
				{
					if (BulkLoader.guessType(url) == BulkLoader.TYPE_SOUND)
					{
						vars.context 
					}
					else
					{
						
					}
					
				}
			}
		}
		
		public function get bulkLoader():BulkLoader
		{
			return m_bulkLoader;
		}
		
		public function getInstance():AssetManager
		{
			if (!m_instance)
			{
				m_instance = new AssetManager(new PrivateClass());
			}
			return m_instance;
		}
		
		public function AssetManager(pvt:PrivateClass)
		{
			if (m_instance)
			{
				throw new Error("AssetManager is a Singleton class. Use getInstance() to retrieve the existing instance.");
			}
			
			m_bulkLoader = new BulkLoader('AssetManager');
			m_items = new Dictionary(true);
		}
		
		private static var m_instance:AssetManager;
		
		private var m_bulkLoader:BulkLoader;
		private var m_items:Dictionary;
	}
}

class PrivateClass
{
	public function PrivateClass()
	{
		trace("包外类，用于实现单例");
	}
}