package com.xzdbd.ags4flex.services
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/***********************************************************************************
	 * SOE扩展服务调用类。
	 * 
	 * @example
	 * 下面代码演示如何调用SOE扩展服务： 
	 * <p>
	 * 
	 * </p>
	 * <listing version="3.0">
	 * //设置soe扩展服务参数
	 * var soeParam:Object=
					{
						firstfield: "waterlevel", 
						secondfield: "fTopEle", 
						thirdfield: "Classify", 
						f: "json"
					};
	 * 
	 * //定义一个SOE服务
	 * var fieldCalculateSoe:SOEService = new SOEService(fieldCalculateServiceUrl, soeParam);
	 * 
	 * //调用SOE服务
	 * fieldCalculateSoe.sendSOEService(onResult, onFault);
	 * 
	 * function onResult(event:ResultEvent):void
	 * {
	 * 		//调用成功后执行
	 * }
	 * 
	 * function onFault(event:FaultEvent):void
	 * {
	 * 		//调用失败后执行
	 * }
	 * </listing>
	 * 
	 * @author 庄锡伟
	 * 创建于 2013-9-17.
	 * 
	 ***********************************************************************************/
	public class SOEService
	{
		//用作 URL 参数的名称/值对的对象
		private var _request:Object;
		
		//服务地址
		private var _url:String;
		
		//发送请求的HTTP方法
		private var _method:String;
		
		//HTTP 调用返回的结果类型
		private var _resultFormat:String;
		
		//是否使用 Flex 代理服务
		private var _useProxy:Boolean;
		
		/**
		 * 用作 URL 参数的名称/值对的对象
		 */
		public function get request():Object
		{
			return _request;
		}

		public function set request(value:Object):void
		{
			_request = value;
		}

		/**
		 * 服务地址
		 */
		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

		/**
		 * 发送请求的HTTP方法
		 */
		public function get method():String
		{
			return _method;
		}

		public function set method(value:String):void
		{
			_method = value != null ? value : "POST";
		}

		/**
		 * HTTP 调用返回的结果类型
		 */
		public function get resultFormat():String
		{
			return _resultFormat;
		}

		public function set resultFormat(value:String):void
		{
			_resultFormat = value != null ? value : "object";
		}

		/**
		 * 是否使用 Flex 代理服务
		 */
		public function get useProxy():Boolean
		{
			return _useProxy;
		}

		public function set useProxy(value:Boolean):void
		{
			_useProxy = value;
		}

		//定义HTTP服务
		private var httpService:HTTPService;
		
		/**
		 * 执行SOE扩展服务请求。
		 * @param Complete 执行完成回调函数。
		 * @param Fault 执行不成功时的回调函数。
		 */
		public function sendSOEService(Complete:Function, Fault:Function):void
		{
			//设置http服务参数
			httpService = new HTTPService();
			httpService.url = _url;
			httpService.request = _request;
			httpService.method = _method;
			httpService.resultFormat = _resultFormat;
			httpService.useProxy = _useProxy;
			
			//监听http服务回调
			httpService.addEventListener(ResultEvent.RESULT, Complete);
			httpService.addEventListener(FaultEvent.FAULT, Fault);
			
			//发送http请求
			httpService.send();
		}
		
		/**
		 * 构造函数。
		 */
		public function SOEService(url:String, 
								   request:Object, 
								   method:String="POST", 
								   resultFormat:String="object", 
								   useProxy:Boolean=false)
		{
			_url = url;
			_request = request;
			_method = method;
			_resultFormat = resultFormat;
			_useProxy = useProxy;
		}

	}
}

