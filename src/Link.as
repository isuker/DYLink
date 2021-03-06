package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import net.Client;
	
	import user.Param;

	public class Link extends EventDispatcher
	{
		private var _client:Client;
		private var _checkOnlineSeed:uint;
		
		private var roomId:String;
		private var getMsgFun:Function;
		private var getGiftFun:Function;
		private var welcomefun:Function;
		
		private var check:CheckAS=CheckAS.instant;
		
		public static const LINK_OK:String="link_Ok";
		
		private var No:int;
		
		public function Link()
		{
			
		}
		//-----------------------------------------------------------------------------------------
		
		public function initService(roomid:int,msgfun:Function=null,giftfun:Function=null,no:int=0):void{
			this.No=no;
			roomId=String(roomid);
//			getMsgFun=msgfun;
//			getGiftFun=giftfun;
			check.addEventListener(CheckAS.CHECK_COMPLETE_EVENT,checkcomplete);
			check.sendChecking(roomId,String(new Date().time));
		}
		
		public function sendMsg(msg:String):void{
			//trace("service linkclass s="+msg);
			this._client.SendChatContent(msg);
		}
		
		public function setTHwelcome(fun:Function):void{
			welcomefun=fun;
		}
		
		public function setGetMsg(fun:Function):void{
			getMsgFun=fun;
		}
		
		public function setGift(fun:Function):void{
			getGiftFun=fun;
		}
		
		//-----------------------------------------------------------------------------------------
		private function dmLinkOk():void{
			this.dispatchEvent(new Event(LINK_OK));
		}
		
		protected function checkcomplete(event:Event):void
		{
			if(check.ISCHECK){
				var obj:Object=new Object();
				obj["Servers"]=check.IPOBJ;
				obj["RoomId"]=roomId;
				Param.init(obj);
				link();
			}
		}
		
		private function link():void{
			this._client = new Client();
			this._client.reserviceMsg=getMsgFun;
			this._client.giftMsg=getGiftFun;
			this._client.dmLinkOk=dmLinkOk;
			this._client.welcomeFun=welcomefun;
			this._client.ConnectServer(Param.ServerIp, Param.ServerPort, this.OnConn);
		}
		
		private function OnConn(param1:Event) : void
		{
			if (this._checkOnlineSeed)
			{
				clearInterval(this._checkOnlineSeed);
			}
			this._checkOnlineSeed = setInterval(this.CheckOnline, 120000);
			
			if(No==0){
				//猫小胖
				this._client.UserLogin(0);
			}else{
				//匿名 监测用
				this._client.UserLogin2();
			}
			return;
		}
		
		private function CheckOnline() : void
		{
			if (!this._client._conn || !this._client._conn.is_connected)
			{
				this.link();
			}
			return;
		}
		
		private static var _instant:Link;
		
		public static function get instant():Link
		{
			if( null == _instant )
			{
				_instant = new Link();
			}
			return _instant;
		}
	}
}