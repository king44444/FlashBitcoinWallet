 package
{
	
	import com.adobe.crypto.SHA256;
	import com.adobe.fileformats.vcard.Address;
	import com.adobe.serialization.json.JSONEncoder;
	import com.bit101.components.Label;
	import com.bit101.components.TextArea;
	import com.greensock.TweenLite;
	import com.king.encoder.Base58Encoder;
	
	import controller.AddressCon;
	import controller.BitCoinUtil;
	import controller.DatabaseController;
	import controller.ViewController;
	
	import flame.crypto.ECCParameters;
	import flame.crypto.ECDSA;
	import flame.crypto.ICryptoTransform;
	import flame.crypto.RIPEMD160;
	import flame.crypto.RandomNumberGenerator;
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.DNSResolverEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.ServerSocket;
	import flash.net.SharedObject;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.dns.AAAARecord;
	import flash.net.dns.ARecord;
	import flash.net.dns.DNSResolver;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import model.BlockVO;
	import model.IPPort;
	import model.Work;
	import model.txVO;
	
	[SWF(width="500", height="400", backgroundColor="#dddddd", frameRate=60)]
	public class ardbit extends Sprite
	{
		public var statusLbl:Label = new Label(this as DisplayObjectContainer, 15,0, "Loading, please wait...");
		public var logTxt:TextArea = new TextArea(this as DisplayObjectContainer, 15, 325);
		
		public var socketDic:Dictionary = new Dictionary(true);
		
		private var user:String = "mking44444@hotmail.com_3";// "bitcoinrpc";//"mking44444@hotmail.com_2";
		private var password:String = "123456";// "HNyD3jtPiDVmXem8HMviviuWf8g64nhXBfBzerwic5Eg";// "123456";
		private var host:String = "pit.deepbit.net";// "10.10.10.184";// "pit.deepbit.net";
		private var port:int = 8332;
		//private var peerIp:String = "0.0.0.0";
		private var myIp:String = "67.182.218.41";
		//private var socket:Socket;
		private var listenSocket:ServerSocket = new ServerSocket();
		//private var clientSocket:Socket;
		public var clientSockets:Vector.<Socket> = new Vector.<Socket>();
		//private var partPayload:ByteArray;
		////////////
		private var useTestNet:Boolean = true;
		public var util:BitCoinUtil;// = new BitCoinUtil(useTestNet);
		///////////
		private var response:String;
		private var peerIPS:Vector.<String> = new Vector.<String>();
		private var expectedNumberOfBlocks:uint = 0;
		private var viewcon:ViewController;// = new ViewController();
		
		private var maxConnections:uint = 1;
		
		///for dev stuff
		private var currentgetblk:uint = 0;
		private var currentgettx:uint = 0;
		
		
		//end dev stuff
		
		/*
		private var pips:Array = ["65.23.129.159","66.205.209.74","194.249.0.45","202.37.70.206","108.63.244.34","74.84.132.97","208.37.186.102","76.115.65.165"
			
	*/
		public function ardbit()
		{
			log("loading keys", "please wait");
			logTxt.width = 470;
			logTxt.height = 70;
			TweenLite.delayedCall(0.2, init);
			 
		}
		public function log(... arguments):void
		{
			trace(arguments.join(" "));
			if(logTxt.text.length > 500)
			{
				logTxt.text = "";
			}
			
			logTxt.text += arguments.join(" ") + "\n";
			//trace(logTxt.textField.scrollV, logTxt.textField.scrollH, logTxt);
			
			//logTxt.draw();
		}	
		private function init():void
		{
			
			loadSettings();
			//mistest();
			//testkey();
			//return;
			//testBlock();
			//testFilterLoad();
			//return;
			
			findIPAddress();
			//listenForPeer();
			connectToPeer();	
		}
		private function loadSettings():void
		{
			var lo:SharedObject = SharedObject.getLocal("bitcoinAS3");
			if(lo.data.useTestNet != null)
			{
				//useTestNet = lo.data.useTestNet;
				maxConnections = lo.data.maxConnections;
				  
			}
			util = new BitCoinUtil(useTestNet);
			util.log = this.log;
			util.init();
			
			viewcon = new ViewController();
			util.log = this.log;
			
			addChild(viewcon);
			viewcon.init(this);
		}
	
		private function sendMsg(ba:ByteArray, socket:Socket):void
		{
			
			
			if(socket == null || socket.connected == false)
			{
				//need to remove it from the array
				return;
			}
			socket.writeBytes(ba);
			socket.flush();
			
		}
		
		private function listenForPeer():void
		{
			var url:String = "92.243.23.21";//+":"+port;
			
			
			if( listenSocket.bound ) 
			{
				listenSocket.close();
				listenSocket = new ServerSocket();
			}
			
			listenSocket.bind(18333, myIp);// "127.0.0.1");// "10.10.10.184");// "192.168.1.108" );
			listenSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onListenConnect );
			listenSocket.listen();
			log( "Bound to: " + listenSocket.localAddress + ":" + listenSocket.localPort );
			myIp = listenSocket.localAddress;
			
			
			
		}
		
		private function onListenConnect( event:ServerSocketConnectEvent ):void
		{
			var clientSocket:Socket = event.socket;
			clientSocket.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData, false, 0, true );
			log( "Connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort );
			clientSockets.push(clientSocket);
			
			//peerIp = clientSocket.remoteAddress;
		}
		
		private function onClientSocketData( event:ProgressEvent ):void
		{
			
			log("onClientSocketData");
			var socket:Socket = event.target as Socket;
			if(socketDic[socket] == null)
			{
				socketDic[socket] = new ByteArray();
			}
			var buffer:ByteArray = socketDic[socket];
			buffer.position = buffer.length;
			if(buffer.length != 0)
			{
				//trace("some form last message");
			}
			socket.readBytes( buffer, buffer.length, socket.bytesAvailable );
			//log( "Received: " + buffer.length, "bytes. Bytes Pending", socket.bytesPending );
			//buffer.position = 0;
			gotMessage(buffer, socket);
			//sendtest(buffer);
			
		}
		private function gotMessage(ba:ByteArray, socket:Socket):void
		{
			if(ba.length < 24)
			{
				log("part Message 1, there should be some left over");
				ba.position = ba.length;
				socketDic[socket] = ByteArrayUtil.copy(ba);
				return;
			}
			ba.position = 0;
			
			var i:int = 0;
			var magic:uint = ba.readUnsignedInt();
			if(magic != BitCoinUtil.USEMAGIC)// 0xf9beb4d9)
			{
				log("NOT MAGIC");
				
				return;
			}
			log("Magic","0x"+magic.toString(16));
			var command:String =  ba.readUTFBytes(12);
			var payloadLength:uint = util.rotateBytes(ba.readUnsignedInt());
			var checkSum:uint = ba.readUnsignedInt();
			log("<-- command", command);
			log("<-- payloadLength", payloadLength);
			log("<-- checkSum", checkSum.toString(16));
			
			var secondMsg2:ByteArray;
			
			
			if(ba.length - 24 < payloadLength)
			{
				log("part Message, there should be some left over");
				socketDic[socket] = ByteArrayUtil.copy(ba);
				return;
			}
			
			var payload:ByteArray = new ByteArray();
			if(payloadLength != 0)
			{
				payload.writeBytes(ba, ba.position , payloadLength);
			}
			var fullbitmsg:ByteArray = new ByteArray();
			fullbitmsg.writeBytes(ba, 0, ba.position + payloadLength);
			//trace("ba:", ByteArrayUtil.toHexString(ba));
			//trace("payload:", ByteArrayUtil.toHexString(payload));
			
				//if(ba.length -24 == payloadLength)log("exact Message Length");
			if(ba.length - 24 > payloadLength)
			{
				log("<-- Larger", ba.position, "Bytes over", ba.length-24-payloadLength);
				ba.position = 24+payloadLength;
			 	secondMsg2 = new ByteArray();
				secondMsg2.writeBytes(ba,24+payloadLength);
				secondMsg2.position = 0;
			//	trace("ba:", ByteArrayUtil.toHexString(ba));
			//	trace("secondMsg2:", ByteArrayUtil.toHexString(secondMsg2));
			//	trace("payload:", ByteArrayUtil.toHexString(payload));
				
			}
			

			
			
			//log("Size of payload", payload.length);
			
			//socketDic[socket] = secondMsg2;
				
			SHA256.hashBytes(payload);
			var payHash:String = SHA256.hashBytes(SHA256.digest);
			//trace("payload hash:", payHash);
			payload.position = 0;
			
			var checkSumString:String = checkSum.toString(16);
			while(checkSumString.length < 8)
			{
				checkSumString = "0" + checkSumString;
			}
			
			log("<-- payload hash match:", payHash.substr(0,8), checkSumString );
			if( payHash.substr(0,8) != checkSumString)
			{
				trace("playload did not match hash");
				//socketDic[socket] = null;
				return;
			}
			if(command == "version")
			{
				util.gotVersion(payload);
				//sendVersion(socket);
				sendVerack(socket);
				
				//sendLoadFilter(socket);
				
			}else if(command == "verack")
			{
				log("<-- got verack");
				if(util.isThin)
				{
					sendLoadFilter(socket);
					//sendMemPool(socket);
				}
				//sendGetBlocks(socket);
				sendGetBlock(socket);
				//TweenLite.delayedCall(6,sendGetAddr);
			}else if(command == "getaddr")
			{
				
				//sendAddr();
				//sendGetBlock();
				sendGetAddr(socket);
				//TweenLite.delayedCall(6,sendGetAddr);
				
			}else if(command == "addr")
			{
				log("<-- Got addr");
				util.gotAddr(payload);
				//sendGetBlocks();
				//sendGetBlocks();
				
			}else if(command == "getblocks")
			{
				log("<-- Got getblocks");
				util.gotGetBlocks(payload);
			}else if(command == "inv")
			{
				log("<-- Got inv");
				util.gotInv(payload);
				
				sendGetData(socket);
			}else if(command == "block")
			{
				log("<-- Got block");
				var block:BlockVO = util.gotBlock(payload, false);
				//good util.saveBastardBlock(block);
				//dev
				util.saveBastardBlockWithRealName(block);
				//end dev
				util.sortBlocks();
				
				expectedNumberOfBlocks++;
				if(expectedNumberOfBlocks >= 495)
				{
					//good sendGetBlocks(socket);
					expectedNumberOfBlocks = 0;
				}
				
			}else if(command == "merkleblock")
			{
				log("<-- Got merkleblock");
				
				var idnum:String = currentgetblk.toString();
				while(idnum.length < 3)
				{
					idnum = "0" + idnum;
				}
				var folder:File = File.desktopDirectory.resolvePath("unit");
				if(!folder.exists)
				{
					folder.createDirectory();
					
				}
				var bfile:File = folder.resolvePath("ubk"+idnum+".bk");
				if(bfile.exists)
				{
					bfile.deleteFile();
				}
				var fs:FileStream = new FileStream();
				fs.open(bfile, FileMode.WRITE);
				//this was a bad idea fs.writeBytes(block.hash);
				fs.writeBytes(fullbitmsg);
				fs.close();
				trace("Done writing merkle.blk", bfile.nativePath);
				payload.position = 0;
				//util.gotMerkleblock(payload);
				++currentgetblk;
				
			}else if(command == "tx")
			{
				
				
				var tidnum:String = currentgettx.toString();
				while(tidnum.length < 3)
				{
					tidnum = "0" + tidnum;
				}
				var tfolder:File = File.desktopDirectory.resolvePath("unit");
				if(!tfolder.exists)
				{
					tfolder.createDirectory();
					
				}
				var tfile:File = tfolder.resolvePath("utx"+tidnum+".tx");
				if(tfile.exists)
				{
					tfile.deleteFile();
				}
				var tfs:FileStream = new FileStream();
				tfs.open(tfile, FileMode.WRITE);
				//this was a bad idea fs.writeBytes(block.hash);
				tfs.writeBytes(fullbitmsg);
				tfs.close();
				
				payload.position = 0;
				currentgettx++;
				
				//var txVo:txVO = util.getTxn(payload, true);
				
			}else
			{
				log("Unknown command:", command);
				
			}
			
			
			if(secondMsg2 != null)
			{
				//TweenLite.delayedCall(3,gotMessage, [secondMsg2]);
				gotMessage(secondMsg2, socket);
			}else
			{
				socketDic[socket] = null;
			}
			
			
		}
	
		private function sendAddr(socket:Socket):void
		{
			log("--> sendAddr");
			var ba:ByteArray = util.getAddr();
			sendMsg(ba, socket);
			
		}
		
		private function sendGetBlocks(socket:Socket):void
		{
			return
			log("--> sendGetBlocks");
			
			var ba:ByteArray = util.getGetBlocks();
			sendMsg(ba, socket);
			
		}
		private function sendGetData(socket:Socket):void
		{
			log("--> send GetData");
			
			var ba:ByteArray = util.getGetData();
			sendMsg(ba, socket);
		}
		private function sendGetBlock(socket:Socket):void
		{
			//this is for dev only
				trace("SEND GET BLOCK");
			//block Number:216458
			//00000000000003f8e1323d49977d4053a64735ff15ce0778203479ca0c4ad848
			//this is the tansaction http://blockexplorer.com/t/61XEbzxmQS
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("0000000000000240382b43305de1cc8108e94d75497cbd6d956a1715fc0958f3"));
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("00000000000003f8e1323d49977d4053a64735ff15ce0778203479ca0c4ad848"));
			var getBlocksid:Array = new Array();
			getBlocksid.push("00000000f026562d33d7d7ed3d40f72779a8dd9d830068132cb43c1b8099cdaf");
			getBlocksid.push("00000000630a148a2a94ba24ecf97f679cde8cbf18572b3359b8cd7e30a89554");
			getBlocksid.push("00000000e83da801cdf5f293a4d001ce74efd0696d5b86af8a07261940cd5b9f");
			getBlocksid.push("000000000003cd887bc770ce2f87cc2bab3c5daf9b79c9d955061eaa5fce4668");
			getBlocksid.push("000000003b496eb3da6f458926c24596876103082336e3941d8059778fbe0832");
			getBlocksid.push("00000000577c81e48925beb0585d3cc1af81342e837e722e4c8c979ee8562980");
			getBlocksid.push("00000000bf81ae49affed75b933edd77bb9770c12ccb14ad1722d8e39b2efb66");
			getBlocksid.push("0000000050f97fa7b700149487e013c4f1246a73c6a7f2790522e5d0b8315ebc");
			getBlocksid.push("0000000019ecc77735798d6852edc64c9bb069ea5104cc03f78959bc224df830");
			getBlocksid.push("00000000aac0ba2bc9750d811fad47e3a76d9ed93b6bf6c5892d9725def68bf6");
			getBlocksid.push("000000005901ce91ffab3281dac520d9926e82d0c0bc0cc71aaf2f29aecc1a09");
			getBlocksid.push("0000000042863b995d41e5325535a5993b133363d7307cdb0d9f0892cfecc0a4");
			getBlocksid.push("00000000f3e8e8f714277c8d7254b7ee5b8a8cfd8fa38abfb0181a2b45b6104f");
			getBlocksid.push("00000000b15b18a23614231071a58509afb63f52995bc74c2695f0cf5b4b903b");
			getBlocksid.push("00000000bad9a197f0b4d65f7de91629e8b5776f32256b8ba8a6f51f8b52b8ce");
			getBlocksid.push("0000000041ce564d1502b65fbb2aa8829fbc73d8d6d865f74a32a0cfe699b4bb");
			
			if(currentgetblk == getBlocksid.length)
			{
				trace("DONE GETTING BLOCKS");
				return;
			}
			
			var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString(getBlocksid[currentgetblk]));
				//http://blockexplorer.com/testnet/block/00000000aac0ba2bc9750d811fad47e3a76d9ed93b6bf6c5892d9725def68bf6 last one - do next
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("00000000aac0ba2bc9750d811fad47e3a76d9ed93b6bf6c5892d9725def68bf6"));
			
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("00000000f0816fe38cd51c7f9a5602b60233ac311fd8351b8353f35981133501"));
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("000000008d9dc510f23c2657fc4f67bea30078cc05a90eb89e84cc475c080805"));
			
			//var hashAry:ByteArray = ByteArrayUtil.fromHexString("4A20590FA8CB3842AB637FF967E8DB33D3B4E3E1C44090E9E81AB64F00000000");
			
			var ba:ByteArray = util.getGetDataForBlock(hashAry, true);
			
			//let try a transaction: this wont work, bitcoin does not save trans in memory
			//out of bitcoin: 842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f
			//var hashAry:ByteArray =util.getByteAryFromHashString("842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f");
			//var ba:ByteArray = util.getGetDataForTrans(hashAry);
			
			sendMsg(ba, socket);
			
			
			
			TweenLite.delayedCall(9, this.sendGetBlock, [socket]);
			
		}
		
		private function sendGetAddr(socket:Socket):void
		{
			log("--> send Get Addr");
			var ba:ByteArray = util.getGetAddr();
			socket.writeBytes(ba);
			socket.flush();
		}
		private function sendVerack(socket:Socket):void
		{
			log("--> send Verack");
			var ba:ByteArray = util.getVerack();
			socket.writeBytes(ba);
			socket.flush();
		}
		private function sendVersion(socket:Socket):void
		{
			if(socket.connected == false)return;
			
			log("--> send Version");
			var ba:ByteArray = util.getVersion(socket.remoteAddress, socket.localAddress);
			ba.position = 0;
			sendMsg(ba, socket);
			
		}
		private function sendMemPool(socket:Socket):void
		{
			
			log("--> send sendmempool");
			var ba:ByteArray = util.getMemPool();
			ba.position = 0;
			sendMsg(ba, socket);
			
		}
		private function sendLoadFilter(socket:Socket):void
		{
			log("--> send FilterLoad");
			var ba:ByteArray = util.getFilterLoad();
			ba.position = 0;
			sendMsg(ba, socket);
			
		}
		private function getPeeList():void
		{
			var domainsAry:Array = ["seed.bitcoin.sipa.be", "dnsseed.bluematt.me", "dnsseed.bitcoin.dashjr.org", "bitseed.xf2.org"];
			var url:String = domainsAry[0];//+":"+port;
			var dns:DNSResolver = new DNSResolver();
			dns.addEventListener(DNSResolverEvent.LOOKUP, lookupComplete);
			dns.lookup(url, ARecord);
			
		}
		private function lookupComplete(event:DNSResolverEvent):void
		{
			log( "Query string: " + event.host );
			log( "Record type: " +  flash.utils.getQualifiedClassName( event.resourceRecords[0] ) + 
				", count: " + event.resourceRecords.length );
			
			for each( var record:ARecord in event.resourceRecords )
			{
				peerIPS.push(record.address);
				if( record is ARecord ) log( record.address );
				if( record is AAAARecord ) log( record.name + " : " + record.address );
				
			}   
			connectToPeer();
		}
		
		private function connectToPeer():void
		{
			for(var i:int = clientSockets.length-1;i>-1;--i)
			{
				var sock:Socket = clientSockets[i];
				if(sock == null || sock.connected == false)
				{
					clientSockets.splice(i, 1);
				}
			}
			
			if(clientSockets.length < viewcon.connectionsSlider.value)
			{
				statusLbl.text = "looking for peers.";
			 	//var peerIp:String = "192.168.1.116";// "195.191.55.115";// peerIPS[currentPeer];//"46.40.126.186";// "69.120.72.236";//
				//var peerPort:uint;
				var ipp:IPPort = util.getPeerAddress();
				
				connecToPeerIP(ipp.ip, ipp.port);
				
			}
			
			
			
			TweenLite.delayedCall(35, connectToPeer);
			
		}
		private function connecToPeerIP(ip:String,port:uint ):void
		{
			
			var socket:Socket = new Socket();
			configureListeners(socket);
			log("trying to connect to:",ip, port);
			socket.connect(ip, port);
		}
		private function irc():void
		{
			log("IRC");
			var url:String = "92.243.23.21";//+":"+port;
			var socket:Socket = new Socket();
			configureListeners(socket);
			socket.connect(url, 6667);
			
		}
		/*
		private function peerConnectd():void
		{
			log("Peer Connected");
			response = "";
			var ba:ByteArray = util.getVersion(peerIp, myIp);
			log("sending version");
			ba.position = 0;
			sendMsg(ba);
		}
		*/
		
		private function writeZero(ba:ByteArray, count:int):void
		{
			for(var i:int = 0;i<count;++i)
			{
				ba.writeByte(0x0);
			}
		}
		private function ircConnected():void
		{
			
			
			
		}
		/*	
		private function login ():void
		{
			response = "";
			var url:String = host;//+":"+port;
			socket = new Socket();
			configureListeners();
			socket.connect(host, port);
		}
		*/
		
		////////socket
		private function configureListeners(socket:Socket):void 
		{
			clientSockets.push(socket);
			socket.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
			socket.addEventListener(Event.CONNECT, connectHandler, false, 0, true);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData, false, 0, true);
		}
				
		private function closeHandler(event:Event):void {
			log("closeHandler: " + event);
		}
		
		private function connectHandler(event:Event):void {
			log("connectHandler: " + event);
			var socket:Socket = event.target as Socket;
			//sendVersion(socket);
			TweenLite.delayedCall(1.5, sendVersion, [socket]);
			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			log("ioErrorHandler: " + event);
			//this.connectToPeer();
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			log("securityErrorHandler: " + event);
		}
		
		
		private function findIPAddress():void
		{
		
			var networkInfo:NetworkInfo = NetworkInfo.networkInfo;
			var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces();
			var interfaceObj:NetworkInterface;
			var address:InterfaceAddress;
			
			//Get available interfaces
			for (var i:int = 0; i < interfaces.length; i++)
			{
				interfaceObj = interfaces[i];
				
				for (var j:int = 0; j < interfaceObj.addresses.length; j++)
				{
					address = interfaceObj.addresses[j];
					if(address.address != "::1")
					{
						myIp = address.address;
					}
					log(address.address, address.broadcast);
				}
			}
		}
		
		private function testBlock():void
		{
			
			var hash:ByteArray = ByteArrayUtil.fromHexString("000000003c8bd9e74ccb2f323f81d1daf8515f974bfbcc1264b01ca7faaf189b");
			trace("Block hash for looking online:", String(ByteArrayUtil.toHexString(util.reverseByteAry(hash))).toLowerCase());
			
			//var rawtrans:ByteArray = ByteArrayUtil.fromHexString("0100000002414d0c6c284620f07eacb24c088c7d01d49fc819df2c8ced8b6a75a8c6b5f19e010000006b4830450220783deda1951b6a756fb7070cdb732d6ca17f92d63d373b8a22d4c8ed58a98621022100bf5c7ade42aed27178edf0b52dd35da4239b68ffcbb989c7893a42f02a949c460121036b5e8ce801f3e05330a47a414ced776ac12c7961d0cde903b4b63b9023fe9659ffffffff7623fc358c0a8f84c65eb3e7033b85c56d731a2aa5f6a055843850305a5f895e010000006a4730440220557414f06ded5a5bec5390ac7461fd82abcd8a820a9c79b05810fc86a2d4cfe702204a78ae0a7dc728c4114ba02fc5dafdd8f6e6191c3873b29c95a9fba31a3bb6700121037f632935681993ba0b6d2238e24e11832dc222a78f9498e4504758437a8f3accffffffff024e42b206000000001976a91405f49d365829fb0592a1b48536b4cb2d64491bf088ace4f71300000000001976a91406fa34a895b4aa489b8eba5cfc3cdf67245e302488ac00000000");
			var rawtrans:ByteArray = ByteArrayUtil.fromHexString("0100000001C6330C22FA18A18B51E5A0401F58C0ACEF45DCE1E95DBB169ED63B6528B5600B000000008B483045022049C62C641FF6A702BCEC06AC4638CD144C572E3F69098C89E7691F6874A08C900221009B6444703891814E15CA67EFC3BD7097718E399CAEA10995853DDF959E13519E0141040BA72B3ABF429E70AB7E96521CEA6D385E8BBD4C981445343A0C47913DDBB14F0511F83D59A8440F36FAEF66504CBD7A11B89BC625FCC2449049BCABA682BC64FFFFFFFF0100C2EB0B000000001976A914097072524438D003D23A2F23EDB65AAE1BB3E46988AC00000000");
			
			var tx:txVO = util.getTxn(rawtrans, true);
			var transIsForUs:Boolean =util.transIsForUs(tx);
			log("trans hash us:", transIsForUs);
			//83371 or 83372
			var block:BlockVO = util.getBlockByNumber(400);
			if(block == null)
			{
				log("didn't have block");
				return;
				
			}
			
			log("Block", block.blockNum);
			var coinbaseOut:BigInteger = new BigInteger(util.reverseByteAry( block.txns[0]._out[0].value), true);
			log("Value:", coinbaseOut.toString(), "16:", coinbaseOut.toString(16));
			var fees:BigInteger = util.transCon.getFeesInBlock(block);
			log("fees in block:", fees.toString());
			util.scanBlockForUS(block);
				
			log("end");
		}
		private function testkey():void
		{
			//For wallet inport
			//var big:BigInteger = BigInteger.parse("FB1173660F504233B2FAD0A68BC64F5D46876CB0");
			
			var addressCon:AddressCon = this.util.addressCon;
			var unaddress:ByteArray = addressCon.getUnAddress("mpfjBs5vJrwM8pKdKWjZcUE6KnVYKhVh8u");
			trace(ByteArrayUtil.toHexString(unaddress));
			var backToRiped:ByteArray = Base58Encoder.decode("cMvCJtUqv4aVmFC6Mu8omo8vfC6wqvW6GPoaoiENF1pF4L3xbeCu");
			trace(ByteArrayUtil.toHexString(backToRiped));
			
			//324c8aa9f236f500a66d4cdc7348aefe1a1bb4372f90b4a389b34d5acb0102d7
			//A9F4FC05AF4C709FF514BADADCEEC1ED2F182D9212FDD52308248599E46F18474B8A693D85CED89A4B145F36D13CA15DCB0B9399C42E1F
			//919D2832E06C7F7C5F0B5D1A8FAA07B1BAA6CA9F
			var pbKey:BigInteger = BigInteger.parse("A9F4FC05AF4C709FF514BADADCEEC1ED2F182D9212FDD52308248599E46F18474B8A693D85CED89A4B145F36D13CA15DCB0B9399C42E1F");//EF0A074DA39A51F50A24D45945C19BA3152E60D8857B4731BC892FF976FBFBC3E3012256A626");
			trace(addressCon.getFullBitAddress(pbKey, true));
			/*
			key import format
			* uncompressed: 0x80 + [32-byte secret] + [4 bytes of Hash() of
				previous 33 bytes], base58 encoded
			*/
			var testnet:Boolean = true;
			var privKey:String = "533db631ba0c9c32cf4aca70860c59754686574ad291f126162db77cf2228503"
			var enkey:String = testnet? "EF":"80"
			var ba:ByteArray =  ByteArrayUtil.fromHexString(enkey+privKey);
			var hash1:String = SHA256.hashBytes(ba);
			trace(hash1);
			var hash2:String = SHA256.hashBytes(SHA256.digest);
			trace(hash2);
			var checksum:String = hash2.substr(0,8);
			
			var finalAddress:String = Base58Encoder.encode( ByteArrayUtil.fromHexString(enkey+privKey+checksum));
			trace("wallet inport key format:");
			trace("Client:importprivkey", finalAddress, "\"I made this\" true");
			
		}
		private function mistest():void
		{
			var ba:ByteArray =  ByteArrayUtil.fromHexString("0100000001C6330C22FA18A18B51E5A0401F58C0ACEF45DCE1E95DBB169ED63B6528B5600B000000001976A91448F83FEC4A492FE5E17E6974F38A4E6E6889E9E888ACFFFFFFFF0100743BA40B0000001976A9146461EF4D3FC6D450B2305D037997C7A1C0788F9E88AC0000000001000000");
			var hash1:String = SHA256.hashBytes(ba);
			trace(hash1);
			var hash2:String = SHA256.hashBytes(SHA256.digest);
			trace(hash2);
			
		}
		private function testFilterLoad():void
		{
			var ba:ByteArray = util.getFilterLoad();
			
		}
	
		
	}
}