 package
{
	
	import com.adobe.crypto.SHA256;
	import com.adobe.fileformats.vcard.Address;
	import com.adobe.serialization.json.JSONEncoder;
	import com.greensock.TweenLite;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.util.Hex;
	import com.king.encoder.Base58Encoder;
	
	import controller.BitCoinUtil;
	import controller.DatabaseController;
	
	import flame.crypto.ECCParameters;
	import flame.crypto.ECDSA;
	import flame.crypto.ICryptoTransform;
	import flame.crypto.RIPEMD160;
	import flame.crypto.RandomNumberGenerator;
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
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
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.dns.AAAARecord;
	import flash.net.dns.ARecord;
	import flash.net.dns.DNSResolver;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import model.BlockVO;
	import model.Work;
	import model.txVO;
	
	public class ardbit extends Sprite
	{
		private var user:String = "mking44444@hotmail.com_3";// "bitcoinrpc";//"mking44444@hotmail.com_2";
		private var password:String = "123456";// "HNyD3jtPiDVmXem8HMviviuWf8g64nhXBfBzerwic5Eg";// "123456";
		private var host:String = "pit.deepbit.net";// "10.10.10.184";// "pit.deepbit.net";
		private var port:int = 8332;
		private var peerIp:String = "0.0.0.0";
		private var myIp:String = "67.182.218.41";
		private var socket:Socket;
		private var listenSocket:ServerSocket = new ServerSocket();
		private var clientSocket:Socket;
		private var partPayload:ByteArray;
		////////////
		private var util:BitCoinUtil = new BitCoinUtil(false);
		///////////
		private var response:String;
		private var peerIPS:Vector.<String> = new Vector.<String>();
		private var currentPeer:int = 0;
		
		/*
		private var pips:Array = ["65.23.129.159","66.205.209.74","194.249.0.45","202.37.70.206","108.63.244.34","74.84.132.97","208.37.186.102","76.115.65.165"
			
	*/
		public function ardbit()
		{
			
			//encodedTest();
			//return;
			//test4();
			//return;
			//test3();
			//return;
			//test2()
			//return;
			//test();
			//return;
			findIPAddress();
			//dowork(null);
			//login();
			//getWork();
			//irc();
			//getPeeList();
			//connectToPeer();
			//peerConnectd();
			listenForPeer();
			
			//testBlock();
			//sendGetGetData();
			//util.getBlockHashFromBlock(util.getGenisisBlock());
			
			//genBitAddress();
			//databaseTest();
		}
		private function test2():void
		{
			//http://bitcoin-kamikaze.com/?userID=110484&secretKey=CkuKhtfTN7jACMDl
			var datastr:String = "(2,3,1,4,1,3,4,4)CBojbCZjCadS9uEaUBSN5l4rNd5SNJAfaP"
				               //  "(1,1,1,5,2,1,1,2)BF7JCBuoKIay3OAfKpmKPY6308Uoa1HCuE"
								//  (4,5,4,4,4,4,2,2)KZdb2Hmo2njtKLFJfzrO8LAPGbAlOYzoLD
			// should be = 4078c2fb0a259d01d3c7b74fc76f723f733aa4ed5bf36072689aa6d3c01e57e6
			
			var startBA:ByteArray = util.getByteAryFromHashString(datastr);
			var byteHash:String = SHA256.hashBytes(startBA);
			byteHash = SHA256.hash(datastr);
			trace(byteHash);
			
		}
		private function test3():void
		{
			var version:uint = util.rotateBytes(1);
			var hash:String = "00000000000000001e8d6829a8a21adc5d38d0a473b144b6765798e61f98bd1d";
			var prev_block:String = "00000000000008a3a41b85b8b29ad444def299fee21793cd8b9e567eab02cd81";
			var murkleRoot:String = "2b12fcf1b09288fcaff797d71e950e71ae42b91e8bdb2304758dfcffc2b620e3";
			var time:uint = util.rotateBytes(1305998791);
			var bits:uint = util.rotateBytes(440711666);
			var nonce:uint = util.rotateBytes(2504433986);
			
			//reverse the block and murle root
			//prev_block = prev_block.split("").reverse().join("");
			//murkleRoot = murkleRoot.split("").reverse().join("");
			
			
			var prev_blockAry:ByteArray = util.getByteAryFromHashString(prev_block);
			var murkleRootAry:ByteArray = util.getByteAryFromHashString(murkleRoot);
			
			prev_blockAry = util.reverseByteAry(prev_blockAry);
			murkleRootAry = util.reverseByteAry(murkleRootAry);
			//trace(prev_block);
			//util.printAry(prev_blockAry);
			
			var hashAry:ByteArray = new ByteArray();
			hashAry.writeUnsignedInt(version);
			hashAry.writeBytes(prev_blockAry);
			hashAry.writeBytes(murkleRootAry);
			hashAry.writeUnsignedInt(time);
			hashAry.writeUnsignedInt(bits);
			hashAry.writeUnsignedInt(nonce);
			//var padAry:ByteArray = util.reverseByteAry2(util.getByteAryFromHashString("000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000"))
			//util.printAry(padAry);
			//hashAry.writeBytes(padAry);
			
			util.printAry(hashAry);
			
			var byteHash1:String = SHA256.hashBytes(hashAry);
			//trace("byte hash 1", byteHash);
			var byteAry2:ByteArray = util.getByteAryFromHashString(byteHash1);
			var byteHash2:String = SHA256.hashBytes(byteAry2);
			trace("byte hash 2", byteHash2);
			
			trace("done");
			
			
			hashAry = new ByteArray();
			hashAry.writeUnsignedInt(version);
			hashAry.writeBytes(prev_blockAry);
			hashAry.writeBytes(murkleRootAry);
			hashAry.writeUnsignedInt(time);
			hashAry.writeUnsignedInt(bits);
			hashAry.writeUnsignedInt(0);
			hashAry.writeBytes(util.getByteAryFromHashString("000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000"));
			util.printAry(hashAry);
			
			var data:Object = {data:"0100000081CD02AB7E569E8BCD9317E2FE99F2DE44D49AB2B8851BA4A308000000000000E320B6C2FFFC8D750423DB8B1EB942AE710E951ED797F7AFFC8892B0F1FC122BC7F5D74DF2B9441A00000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000"};
			//wont work, rotated the bytes dowork(data);
			
			
		}
		private function test4():void
		{
			var data:Object = {data:"00000002b44cf06e708712d2d1033935b201c974b3d2b6be7df008b1000002d800000000a878f1ffb96971c431749902e81b44682479661e50fd4c53817625d892b686eb514cc0d01a0375fa0c25500a000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000"};
			dowork(data);
			
			
		}
		private function test():void
		{
			var magix:uint = 0x11223344;
			var fisrt:uint = magix >> 24 & 0xFF;
			var second:uint = magix >> 16 & 0xFF;
			var third:uint = magix >> 8 & 0xFF;
			var fourth:uint = magix & 0xFF;
			trace(magix.toString(16), fisrt.toString(16), second.toString(16), third.toString(16), fourth.toString(16));
			
			var str:String = "9f09e3d7438deadaf7f8e3ccdc711a10e71e3628cec7943f0000024c00000000";
			trace(str.split("").reverse().join(""));
		}
		private function testBlock():void
		{
			
			var genBlock:BlockVO = util.getGenisisBlock();
			
			var genBlockBytes:ByteArray = util.blockToByteArry(genBlock);
			var bin:ByteArray = new ByteArray();
			bin.writeUnsignedInt( util.rotateBytes( 0xD9B4BEF9 ) );//magic
			bin.writeUnsignedInt( util.rotateBytes( 0x11D ) );//size
			//bin.writeUnsignedInt( util.rotateBytes( 0x1 ) );//verison
			bin.writeBytes(genBlockBytes);
			var file:File = File.desktopDirectory.resolvePath("genBlock.dat");
			
			if(file.exists == false)
			{
				
			}
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(bin);
			fileStream.close();
			
		}
		private function getWork():void
		{
			
			
		}
		private function sendMsg(ba:ByteArray):void
		{
			if(clientSocket == null || clientSocket.connected == false)return;
			
			clientSocket.writeBytes(ba);
			clientSocket.flush();
			
		}
		private function listenForPeer():void
		{
			var url:String = "92.243.23.21";//+":"+port;
			
			
			if( listenSocket.bound ) 
			{
				listenSocket.close();
				listenSocket = new ServerSocket();
			}
			
			listenSocket.bind(8333, myIp);// "127.0.0.1");// "10.10.10.184");// "192.168.1.108" );
			listenSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onListenConnect );
			listenSocket.listen();
			trace( "Bound to: " + listenSocket.localAddress + ":" + listenSocket.localPort );
			myIp = listenSocket.localAddress;
			
			
			
		}
		private function onListenConnect( event:ServerSocketConnectEvent ):void
		{
			clientSocket = event.socket;
			clientSocket.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData );
			trace( "Connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort );
			peerIp = clientSocket.remoteAddress;
		}
		
		private function onClientSocketData( event:ProgressEvent ):void
		{
			var buffer:ByteArray = new ByteArray();
			clientSocket.readBytes( buffer, 0, clientSocket.bytesAvailable );
			trace( "Received: " + buffer.length, "bytes. Bytes Pending", clientSocket.bytesPending );
			/*
			while(buffer.bytesAvailable)
			{
				trace(buffer.position, buffer.readUnsignedByte().toString(16));
			}
			trace("End buffer");
			*/
			if(clientSocket.bytesPending != 0)
			{
				trace("half");
			}
			buffer.position = 0;
			gotMessage(buffer);
			//sendtest(buffer);
			
		}
		private function gotMessage(ba:ByteArray):void
		{
			if(ba.length < 24)
			{
				//trace("part Message");
				ba.position = 0;
				partPayload = ba;
				return;
			}
			
			var i:int = 0;
			//var m1:String = ba.readUnsignedByte().toString(16);
			//var m2:String = ba.readUnsignedByte().toString(16);
			//var m3:String = ba.readUnsignedByte().toString(16);
			//var m4:String = ba.readUnsignedByte().toString(16);
			var magic:uint = ba.readUnsignedInt();
			if(magic != 0xf9beb4d9)
			{
				trace("NOT MAGIC");
				ba.position = 0;
			
				if(partPayload != null)
				{
					trace("Start", partPayload.length, ba.length, partPayload.length + ba.length);
					partPayload.position = partPayload.length;
					partPayload.writeBytes(ba);
					trace("End", partPayload.length);
					
					ba = partPayload;
					partPayload = null;
					ba.position = 0;
					magic = ba.readUnsignedInt();
					
				}else
				{
					
					while(ba.bytesAvailable)
					{
						
						//trace(ba.position, ba.readUnsignedByte().toString(16));
					}
					trace(ba.readUTFBytes(ba.bytesAvailable));
					ba.position = 0;
					//trace(ba.toString());
					
					return;
				}
			}
			trace("Magic","0x"+magic.toString(16));
			var command:String =  ba.readUTFBytes(12);
			var payloadLength:uint = util.rotateBytes(ba.readUnsignedInt());
			/*
			var c1:String = ba.readUnsignedByte().toString(16);
			var c2:String = ba.readUnsignedByte().toString(16);
			var c3:String = ba.readUnsignedByte().toString(16);
			var c4:String = ba.readUnsignedByte().toString(16);
			ba.position = ba.position-4;
			*/
			var checkSum:uint = ba.readUnsignedInt();
			trace("<-- command", command);
			trace("<-- payloadLength", payloadLength);
			trace("<-- checkSum", checkSum.toString(16));
			
			var payload:ByteArray = new ByteArray();
			var secondMsg2:ByteArray;
			
			//if(payloadLength != 0)
			//{
				if(ba.length - 24 < payloadLength)
				{
					//trace("part Message");
					ba.position = 0;
					partPayload = ba;
					return;
				}else
				{
					//if(ba.length -24 == payloadLength)trace("exact Message Length");
					
					payload.writeBytes(ba,ba.position, payloadLength);
					
					if(ba.length - 24 > payloadLength)
					{
						//trace("<-- Larger", ba.position, "Bytes over", ba.length-24-payloadLength);
						
					 	secondMsg2 = new ByteArray();
						secondMsg2.writeBytes(ba,24+payloadLength);
						secondMsg2.position = 0;
						
					}
					
				}
				
		//	}
			//trace("Size of payload", payload.length);
			
			var payHash:String = SHA256.hashBytes(util.getByteAryFromHashString( SHA256.hashBytes(payload)));
			payload.position = 0;
			trace("<-- payload hash match:", payHash.substr(0,8),checkSum.toString(16) );
			if(command == "version")
			{
				util.gotVersion(payload);
				sendVersion();
				sendVerack();
				
			}else if(command == "verack")
			{
				trace("<-- got verack");
				sendGetBlocks();
				//sendGetBlock();
				//TweenLite.delayedCall(6,sendGetAddr);
			}else if(command == "getaddr")
			{
				
				//sendAddr();
				//sendGetBlock();
				//sendGetAddr();
				//TweenLite.delayedCall(6,sendGetAddr);
				
			}else if(command == "addr")
			{
				trace("<-- Got addr");
				util.gotAddr(payload);
				//sendGetBlocks();
				//sendGetBlocks();
				
			}else if(command == "getblocks")
			{
				trace("<-- Got getblocks");
				util.gotGetBlocks(payload);
				
				
				
			}else if(command == "inv")
			{
				trace("<-- Got inv");
				util.gotInv(payload);
				
				sendGetData();
			}else if(command == "block")
			{
				trace("<-- Got block");
				util.gotBlock(payload, true, 0, true);
				util.sortBlocks();
			}else
			{
				trace("Unknown command:", command);
			}
			
			if(secondMsg2 != null)
			{
				//TweenLite.delayedCall(3,gotMessage, [secondMsg2]);
				gotMessage(secondMsg2);
			}
			
		}
	
		private function sendAddr():void
		{
			trace("--> sendAddr");
			var ba:ByteArray = util.getAddr();
			
			sendMsg(ba);
			
		}
		
		private function sendGetBlocks():void
		{
			trace("--> sendGetBlocks");
			
			var ba:ByteArray = util.getGetBlocks();
			sendMsg(ba);
			
		}
		private function sendGetData():void
		{
			trace("--> send GetData");
			
			var ba:ByteArray = util.getGetData();
			sendMsg(ba);
		}
		private function sendGetBlock():void
		{
				
			//block Number:216458
			//00000000000003f8e1323d49977d4053a64735ff15ce0778203479ca0c4ad848
			//this is the tansaction http://blockexplorer.com/t/61XEbzxmQS
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("0000000000000240382b43305de1cc8108e94d75497cbd6d956a1715fc0958f3"));
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("00000000000003f8e1323d49977d4053a64735ff15ce0778203479ca0c4ad848"));
			
			var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("0000000000000240382b43305de1cc8108e94d75497cbd6d956a1715fc0958f3"));
			//var hashAry:ByteArray = util.reverseByteAry(util.getByteAryFromHashString("000000008d9dc510f23c2657fc4f67bea30078cc05a90eb89e84cc475c080805"));
			
			//var hashAry:ByteArray = ByteArrayUtil.fromHexString("4A20590FA8CB3842AB637FF967E8DB33D3B4E3E1C44090E9E81AB64F00000000");
			
			var ba:ByteArray = util.getGetDataForBlock(hashAry);
			
			//let try a transaction: this wont work, bitcoin does not save trans in memory
			//out of bitcoin: 842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f
			//var hashAry:ByteArray =util.getByteAryFromHashString("842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f");
			//var ba:ByteArray = util.getGetDataForTrans(hashAry);
			
			sendMsg(ba);
		}
		
		private function sendGetAddr():void
		{
			trace("--> send Get Addr");
			var ba:ByteArray = util.getGetAddr();
			clientSocket.writeBytes(ba);
			clientSocket.flush();
		}
		private function sendVerack():void
		{
			trace("--> send Verack");
			var ba:ByteArray = util.getVerack();
			clientSocket.writeBytes(ba);
			clientSocket.flush();
		}
		private function sendVersion():void
		{
			trace("--> send Version");
			var ba:ByteArray = util.getVersion(peerIp, myIp);
			ba.position = 0;
			sendMsg(ba);
			
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
			trace( "Query string: " + event.host );
			trace( "Record type: " +  flash.utils.getQualifiedClassName( event.resourceRecords[0] ) + 
				", count: " + event.resourceRecords.length );
			
			for each( var record:ARecord in event.resourceRecords )
			{
				peerIPS.push(record.address);
				if( record is ARecord ) trace( record.address );
				if( record is AAAARecord ) trace( record.name + " : " + record.address );
				
			}   
			connectToPeer();
		}
		
		private function connectToPeer():void
		{
			
		 	peerIp = "192.168.1.116";// "195.191.55.115";// peerIPS[currentPeer];//"46.40.126.186";// "69.120.72.236";//
			connecToPeerIP(peerIp);
			currentPeer++;
		}
		private function connecToPeerIP(ip:String):void
		{
			socket = new Socket();
			configureListeners();
			trace("trying ",ip, currentPeer);
			socket.connect(ip, 8332);
		}
		private function irc():void
		{
			trace("IRC");
			var url:String = "92.243.23.21";//+":"+port;
			socket = new Socket();
			configureListeners();
			socket.connect(url, 6667);
			
		}
		private function peerConnectd():void
		{
			trace("Peer Connected");
			response = "";
			var ba:ByteArray = util.getVersion(peerIp, myIp);
			trace("sending version");
			ba.position = 0;
			sendMsg(ba);
		}
		
		
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
			
		private function login ():void
		{
			response = "";
			var url:String = host;//+":"+port;
			socket = new Socket();
			configureListeners();
			socket.connect(host, port);
			
			
		}
	
		////////socket
		private function configureListeners():void 
		{
			socket.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
			socket.addEventListener(Event.CONNECT, connectHandler, false, 0, true);
			socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
		}
		
		private function writeln(str:String):void 
		{
			trace("Sending:", str);
			//str += "\n";
			try {
				socket.writeUTFBytes(str);
			}
			catch(e:IOError) {
				trace(e);
			}
		}
		
		private function sendRequest():void 
		{
			trace("sendRequest");
			response = "";
			var obj:Object = new Object();
			//obj.jsonrpc = "1.0";
			obj.id = "getinfo";
			obj.method = "getinfo";
			obj.params = new Array();
			
			//jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] 
			var en:JSONEncoder = new JSONEncoder(obj);
			var str:String = en.getString();
			trace(str);
			writeln(str+"\r\n\r\n");
			//socket.flush();
		}
		private function authenticate():void 
		{
			//weknowdvd.com/ldsbc/buslib.zip
				
				
			var obj:Object = new Object();
			//obj.jsonrpc = "1.0";
			obj.id = "getwork";
			obj.method = "getwork";
			obj.params = new Array();
			var en:JSONEncoder = new JSONEncoder(obj);
			var bitStr:String = en.getString();
			//h += "\r\n\r\n";
			
			trace("authenticate");
			var path:String = "/";
			
			var userpass:String = Base64.encode(user+":"+password);
		
			var lines:Array= ['POST / HTTP/1.1','Host:'+host,'Authorization: Basic ' +userpass,"Content-Type: application/json; charset=utf-8","Content-Length: "+bitStr.length,'Connection: closed'];
			//jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] 
			//var en:JSONEncoder = new JSONEncoder(obj);
			//var str:String = en.getString();
			var h:String =  lines.join("\r\n");
			h += "\r\n\r\n";
			//h += "\r\n";
			
			h += bitStr;
			
			//jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] 
			//var en:JSONEncoder = new JSONEncoder(obj);
			//h += en.getString();
			//h += "\r\n\r\n";
			
			trace(h);
			
			writeln(h);
			socket.flush();
			
		}
		
		private function dowork(data:Object):void
		{
			var startBA:ByteArray = util.reverseByteAry2(util.getByteAryFromHashString(data.data));
			var nuonce:uint =0;
			var byteAry:ByteArray = new ByteArray()
			byteAry.writeBytes(startBA, 0, 80);
			var byteHash:String;
			var byteAry2:ByteArray;
			var byteHash2:String;
			var lastNum:uint = 0;
			util.printAry(byteAry);
			var lastTime:uint = flash.utils.getTimer();
			var TotalHashes:uint = 0;
			
			while( nuonce < 0x3FFFF)
			{
				
				byteAry.position = 76;
				byteAry.writeUnsignedInt(util.rotateBytes(nuonce));
				byteAry.position = 0;
				//util.printAry(byteAry);
				
				byteHash = SHA256.hashBytes(byteAry);
				//trace("byte hash 1", byteHash);
			 	byteAry2 = util.getByteAryFromHashString(byteHash);
				byteHash2 = SHA256.hashBytes(byteAry2);
				//trace("byte hash 2", byteHash2);
				byteAry2 = util.getByteAryFromHashString(byteHash2);
				byteAry2.position = 32-4;
				lastNum = byteAry2.readUnsignedInt();
				if(TotalHashes == 50000)
				{
					trace(nuonce.toString(16), "Last Number", lastNum.toString(16));
					var totalmilt:uint = flash.utils.getTimer() - lastTime;
					trace("Time laspe:", totalmilt / 1000);
					
					// uint32_t totalmilt = TotalHashes * 1000;
					trace("Hashes:", TotalHashes);
					
					var hashes:Number = (TotalHashes  / (totalmilt / 1000));
					trace("Hashes per second:", hashes);
					lastTime =flash.utils.getTimer()
					TotalHashes = 0;
					//delay(1);
					
				}
				if(lastNum <= 0x0)
				{
					trace("WINNER ", nuonce);
					sendWork(nuonce, data.data);
					return;
				}
				nuonce++;
				TotalHashes++;
			}
			trace("Tried them all");
			/*might work?
			var hash1:String = SHA256.hash(hashStart);
			var hash2:String =  SHA256.hash(hash1);
			trace(hash1);
			trace(hash2);
			*/
			socket.close();
			
			TweenLite.delayedCall(4, login);
			
			return;
			var hex:String ="2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824";// "00000000000004ec998fb6a053ddf7ba992846ec1a01b46499cd78fc26c7329c";//"hello"
			var byteAry:ByteArray = new ByteArray();
			
			for (var i:uint=0;i<hex.length;i+=2) {
				trace(parseInt(hex.substr(i,2),16));
				byteAry[i/2] = parseInt(hex.substr(i,2),16);
			}
			
			//byteAry.writeByte(0xff);
			//byteAry.writeByte(0xff);
			var byteHash:String = SHA256.hashBytes(byteAry);
			trace("byte hash 1", byteHash);
			
			return;
			
			var test:int = 8;
			var want:uint = 0x80000000;
			var start:int = 7 * 4;
			trace( want, want == uint.MAX_VALUE, uint.MAX_VALUE);
			for( i = 0;i<8;++i)
			{
			
				trace("shift",(start+i), test << (start+i), test << (start+i) == want, want);
			}
			
			return;
			//eightReverse("12345678");
			//return;
			
			var work:Work = new Work();
			work.midstate = "866c737b096759d96e5d563415a3f77fc3121ded44ede5912c64f1d747db3508";
			work.hash1 = "00000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000010000";
			work.data = "000000019768d7b054e34d896500476993d2f41f82f1fc408ada66ed000000bc0000000028cfcb08116a0fe5179ef85213d5f204484da083bbde9e77d867e72a5553d8e15057f8231a063a3800000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000080020000";
			work.target = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000";
			//00 00 00 19 76 8d 7b 05 4e 34 d896500476993d2f41f82f1
			
			var total:ByteArray = util.getByteAryFromHashString(work.data);
			trace(total.length);
			total.position= 4;
			total.writeInt(0);
			total.position = 0;
			
			return;
			//work.data = work.data.split("").reverse().join("");
			
			trace(work.data.length, work.midstate.length);
			var firstHalf:ByteArray;// = Hex.getByteAryFromHashString( work.data.substring(0,127));
			util.printAry(firstHalf);
			firstHalf
			util.printAry(firstHalf);
				
			var secondHalf:ByteArray;// = Hex.getByteAryFromHashString( work.data.substring(128));
			secondHalf.endian = Endian.LITTLE_ENDIAN;
			var hashedFirst:String =  SHA256.hashBytes(firstHalf);
			var hashedSecond:String =  SHA256.hashBytes(secondHalf);
			trace(hashedFirst);
			trace(hashedSecond);
			return;
			//midstate
			//data
			//hash1
			//target
			var hashStart:String ="00000000000004ec998fb6a053ddf7ba992846ec1a01b46499cd78fc26c7329c";// "00000000000004ec998fb6a053ddf7ba992846ec1a01b46499cd78fc26c7329c";//"hello"
			var byteAry:ByteArray = util.getByteAryFromHashString(hashStart);// new ByteArray();
			//byteAry.writeUTFBytes(hashStart);
			var byteHash:String = SHA256.hashBytes(byteAry);
			trace("byte hash 1", byteHash);
			
		
			var byteAry2:ByteArray = util.getByteAryFromHashString(byteHash);//new ByteArray();
			//byteAry2.writeInt(byteHashInt);
			var byteHash2:String = SHA256.hashBytes(byteAry2);
			trace("byte hash 2", byteHash2);
			
			
			var hash1:String = SHA256.hash(hashStart);
			var hash2:String =  SHA256.hash(hash1);
			trace(hash1);
			trace(hash2);
			
		}
		private function eightReverse(str:String):ByteArray
		{
			var count:int = str.length / 8;
			var thirtyTwoBitNumbers:Vector.<int> = new Vector.<int>();
			for(var i:int = 0;i<count;++i)
			{
				var hexStr:String = str.substr(i*8, 8);
				var threeTwoTotal:int = 0;
				for(var j:int = 0;j<hexStr.length;++j)
				{
					var char:String = hexStr.charAt(j);
					var threeTwo:int = HexUtil.decode(char);
					var shifted:int = threeTwo << (8*8);// (8-j);
					trace(char, threeTwo, shifted)
					threeTwoTotal += shifted;
				}
				
				trace(hexStr, threeTwoTotal);
				
			}
			var ba2:ByteArray = new ByteArray();
			return ba2;
		}
		
		
		private function readResponse():void 
		{
			var str:String = socket.readUTFBytes(socket.bytesAvailable);
			trace(str);
			response += str;
			if(str.indexOf("Found your") != -1)
			{
				this.writeln("NICK bobs\n");
				socket.flush();
				this.writeln("USER bobs ok ok :bobs\n");
				socket.flush();

				
			}
			
			if(str.indexOf("MODE bobs") != -1)
			{
				
				
				this.writeln("USERHOST bobs\n");
				socket.flush();
			}
			
			if(str.indexOf("bobs=+bobs@") != -1)
			{
				var ip:String = str.split("@")[1];
				trace("My IP is", ip);
				
				
			}	
			if(str.indexOf("midstate") != -1)
			{
				var ary:Array = str.split("\r\n\r\n");
				
				var jsonStr:String =ary.pop();// str.substring(str.indexOf("{"));
				
				var resultObj:Object = JSON.parse(jsonStr);
				if(resultObj.id == "getwork")
				{
					dowork(resultObj.result);
				}
			}
		
		}
		
		private function closeHandler(event:Event):void {
			trace("closeHandler: " + event);
			trace(response.toString());
			this.connectToPeer();
		}
		
		private function connectHandler(event:Event):void {
			trace("connectHandler: " + event);
			//sendRequest();
			authenticate();
			//ircConnected();
			//peerConnectd();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: " + event);
			this.connectToPeer();
			
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		
		private function socketDataHandler(event:ProgressEvent):void {
			trace("socketDataHandler: " + event);
			readResponse();
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
					trace(address.address, address.broadcast);
				}
			}
		}
		private function genBitAddress():void
		{
			/*
			var keyxml:XML = <ECDSAKeyValue xmlns="http://www.w3.org/2001/04/xmldsig-more#">
			  <DomainParameters>
			    <NamedCurve URN="urn:oid:1.2.840.10045.3.1.7"/>
			  </DomainParameters>
			  <PublicKey>
			    <X Value="36422191471907241029883925342251831624200921388586025344128047678873736520530" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
			    <Y Value="20277110887056303803699431755396003735040374760118964734768299847012543114150" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
			  </PublicKey>
			  <PrivateKey>
			    <D Value="11253563012059685825953619222107823549092147699031672238385790369351542642469" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
			  </PrivateKey>
			</ECDSAKeyValue>;
			*/
			var keyxml:XML = <ECDSAKeyValue xmlns="http://www.w3.org/2001/04/xmldsig-more#">
						  <DomainParameters>
							<NamedCurve URN="urn:oid:1.2.840.10045.3.1.7"/>
						  </DomainParameters>
						  <PublicKey>
							<X Value="34961353899697724931866372407785763709715866987652770046466152079004726527846" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
							<Y Value="19107882550152301489713263901790769872403228098053367101432450838161863292624" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
						  </PublicKey>
						  <PrivateKey>
							<D Value="908173248920127022929968509872062022378588115024631874819275168689514742274" xsi:Type="PrimeFieldElemType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
						  </PrivateKey>
						</ECDSAKeyValue>;
			/*
			0202020202020202020202020202020202020202020202020202020202020202 - private key
			908173248920127022929968509872062022378588115024631874819275168689514742274
			
			x? = 4d4b6cd1361032ca9bd2aeb9d900aa4d45d9ead80ac9423374c451a7254d0766
			34961353899697724931866372407785763709715866987652770046466152079004726527846
			
			y? = 2a3eada2d0fe208b6d257ceb0f064284662e857f57b66b54c198bd310ded36d0
			19107882550152301489713263901790769872403228098053367101432450838161863292624
			
			*/
			
			
			//var privateKeyString:String = "50863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B2352";
			//var privateKeyString:String = "2CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6"
			var privateKeyString:String = "2a3eada2d0fe208b6d257ceb0f064284662e857f57b66b54c198bd310ded36d0";
			//var privateKeyString:String = "5JxQGNNCjZviq8KBmTGuemFndhqeXBXY1xJ2LcU4fLwWSEPkds6";
			//var privateKey:ByteArray = Base58Encoder.decode(privateKeyString);
			//var privateKeyString:String = "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725";
			//this used to work var privateKey:ByteArray = Hex.toArray(privateKeyString);
			var privateKey:ByteArray = util.getByteAryFromHashString(privateKeyString);
			
			
		
			trace("private key length", privateKey.length);
			var buff:ByteArray = new ByteArray();
			
			
			buff.writeByte(0);
			buff.writeBytes(privateKey);
			var key:String = new BigInteger(buff).toString();
			trace("private key", key);
			
			var eccParms:ECCParameters = new ECCParameters();
			
			var ecdsa:ECDSA = new ECDSA();
			var eccParms2:ECCParameters = ecdsa.exportParameters(true);
			var testing:Boolean = false;
			
			while(testing)
			{
				ecdsa = new ECDSA();
				eccParms2 =  ecdsa.exportParameters(true);
				var hexStr:String = Hex.fromArray(eccParms2.d);
				trace(hexStr);
				if(hexStr.indexOf('44') == 0)
				{
					testing = false;
					trace("Found it");
				}
			}
			
			
			trace(Hex.fromArray(eccParms2.d), ecdsa.toXMLString(true));
			trace(Hex.fromArray(eccParms2.d));
			trace(Hex.fromArray(eccParms2.x));
			trace(Hex.fromArray(eccParms2.y));
			
			ecdsa.fromXMLString(keyxml);
			eccParms2 = ecdsa.exportParameters(true);
			
			trace(Hex.fromArray(eccParms2.d));
			trace(Hex.fromArray(eccParms2.x));
			trace(Hex.fromArray(eccParms2.y));
			
			var publicKey:ByteArray = new ByteArray();
			publicKey.writeByte(0x04);
			publicKey.writeBytes(eccParms2.x);
			publicKey.writeBytes(eccParms2.y);
			
			var hash1:String = SHA256.hashBytes(publicKey);
			trace(hash1);
			var ripe:RIPEMD160 = new RIPEMD160();
			var riped:ByteArray = ripe.computeHash(Hex.toArray(hash1));
			trace(Hex.fromArray(riped));
			var versionRiped:ByteArray = new ByteArray();
			versionRiped.writeByte(0x00);
			versionRiped.writeBytes(riped);
			
			var hash2:String = SHA256.hashBytes(versionRiped);
			trace(hash2);
			var hash3:String = SHA256.hashBytes(Hex.toArray(hash2));
			trace(hash3);
			
			
			var checksum:String = hash3.substr(0,8);
			trace(checksum);
			trace(versionRiped.position);
			versionRiped.writeBytes(Hex.toArray(checksum));
			
			trace("Riped:", Hex.fromArray(versionRiped), "bytes:", versionRiped.length);
			//trace(ByteArrayUtil.toHexString(cipher), "1ADF171F7316370DE4FDB0422B665895255FA79B4ED71D12FF2D581EF3A10454A34A2D7D113807B702183B72BFA680CE426CBBD9FE54B6FCCAB4FE7A8FCE8089C0E1545AB66CE721BC4DEDBD6830413FD6DDE830AAD73C46717C6F873F4EF43115469DB05F22A1E05CEEA82B6BE0C9C183C01D43B046E611162847D85223C7BDF521D7D39D5ADC30A7B17800F8499D89BD4F5C8E074299FA587AE61CA2374F592A8D4A93141754B32B6CCF40DF399A32AD4068C5842858C925D50D0BD0E864D0B03EEBF5018999F5F219713CE758B3B5CBC34122B93BF2FD77DD7890E5ABC6E736590657AC2D37DA8B84C4AD761A57E5F1E43F582279564436303BE6F6AFF4C6857A1C4EDC6E520DFE7BFB97CE7BC76D3F7C7997870926B8281BE43A0A05297E1504B7209D3DE397F5AA035C93B896A7DA869C785EEEF540B7731D044C816F9D2DA590D2C155A14C746CABFC30FB037BD31E87634AC9A61F2A26B2FA6208CA87425DD86502D1158BF6B00AF9450C46BCECCE9F3801AB9E1544C8440C8F73C73BC8CA2FE1F9DAE69F04EAAB77C12675396D5CA5ED3C3C2CEE6311B441F954DF0C02C18C7B83D19BA2AEEA757221BA90AB055525AE4B16DD69454B2045973A5FBAA91A1E1205E42B2225AD57A90944FBEAE1FD6B9D15993118DB22DEC4D8B265D904FF88C6B9F1910327C4DC11DAC96E7B9F0D8BDA635D9D1515693D71D037326D44CD5726EB33D1DF82A488F22A9CD6021CF3F703F2D269835987D6161BAA4F33C0EBB85DF0BECE89C074AFB6E3B6CDB2C19F0DA4E075FF18F12BEB62D837F804F6C5AA306CF3C6358ADEA047190070D2F09EEB283D9643132D1E9C349AE7C9034F7F02A5574D07230FDCA805C6BD45C9D8B675FB5A3D8F94DDDCEA506684DFC21DC10AA3872E08CD58351B16A71D91450E4A3E8442AED5FCB8C3DEC3939A4A0E73C621393C9CA5F36F0D7B4DEB16D332D905E7D66E16727989B51DCAAED3D53FCBAB70C1BF318E2D9880443721B3ABA77E307F9C659B47FFC02421171254868FFD9F75F2675C9387749E128F528E6A805834F317765E47E647947D99ADBC17CFBA7D6AC414B4E5BC92CC7E854F5AE7CAA1FF7330CB6A1581632AB5A06C4FDBAD9B237766C6D90B95F9B51316CFAE1C6F2AC7108BC05DD82716274E2113ECDACD8348E1E21B59A78890DC4EB9BE20A8F13B221E35C56D6EF4CF789597DC3CD6992C03685E64EB1B436F2F949C5BE46A6F9C012AE7E0E1BE26947C9A8DA948669C3B57B2515FE008AE9CDA2916716EA6201A6D37998A71098A381E81D1617EDE57E73FCC4CF4CAF5CCF37FF8E8767745C4A26AAB66A2EFC37283562C4D6784D5968DF3CDA67D7E69A3146021C1806DC3EB5891E5892B44B58763961C2F905EE33212D1DDD11C7990640F9DDCD9B0B736E226A92E60CEA46E5268B4D8F05402DA2B46DD747E0674D9B131D52EC2F67FB917DA3851AAAFC116673A2271122822D4AB8CD43D0D7333D0D089A7D4B591682C8E880B2DF04B7693BB0604761AA956120435FD1927424CF4371E30099D7A4889A49CAD59D0D29113803D040C4F3983A6BC3D8FDE2F4BA28B27D8D91869061F8306D4C2713A1CE1283AB6AAEC6DECC956105D2F6FEE1615B4D14782B5FE2AF8B7EA404988F1EB3318A7193B1C2C4E4859D5806D430B526931B4494EF547F513BBFB077F8483069F3BB8E2589AAAD945F79513A9920C3E7F1CFF3194A18755D692E605526F4058B26966AFAF3243D4EF0DABDB7B3852B1DA32AB143044245E97BF74962124C80898F2E566441F5CEB6F5724E6181B801623AFB69161407C6D98C6618A398A97FD7BBA22E3DAB38AA9374A295085177009CEB07413AB8B5889E72A6234AC989863E29D7760FBEA708A5C8E22E8C22FA421D8E5172D55D62AFFEC46108090577477ABDADF462661E51EA634740E16F0F62D591ADBAC688101245E23F0782F6613DC26EC668D26E7B1699DE856160BDF8EABE092A1123D749902F70DAA8EA17769BB3BFAE77C1F3254ED940F7C2ED24E7367AA405F2444D3D56ECC18E197556F00070F72837C687514CA6940A256514B854B09F29ABC50C76C82FEDD62FB8F6C73943ED75505625E3CA8A995945B6AFB5ADAE6CA9D425F35A3A037F99DDBE2EA59372257FAD190FC8D5AADCCE230D51E6F6E4991B3E93ACCDF14630743762DC9BF93253FE1FA62F7AF98CD3738727DDD05E452207F6C96C922B7FD1FEA39F6747934250BBDD23D8B82E722D825778418805BAC5C59303ACE7996C9B7C767F9A34A3D36CB6CE81E2A150DABC3684EC262D89DF30505502E87D118EA431A7DA998E1B26EFFCFC36BA6FC129868E9A4335E6D6A88249213C13464FFE2B3ACBD478D2D09E31EAA4D126B0DA2BFC84BCFF75F4BCF862877BAFBECEE61DFD1DBEE09250B45B9B1A4C63A87ABBB3E20A3579A72535B298285DFAF7D6C9BC322A5C264860F3F283B8D1F490F24A443D02B23280D03D790F4E6C750757D67D4FA204323311E3874674EDD5A65AA958A93E5B9C5C73E63FB15835E7C7D19F9CE2A58769C4081DDAC6CFD9EC8234622A8870F2E7087BE1585F9D64A0173843F2AF876A5F37309FEBBDB6EBAA67D051B4D090DE63BFDDAC6245122228CA473F7BACBE0BBCB5EC45112D0692D3C9C74EA9A11B21CD7224E4C6A2223FEA1E7184A0BD0D16CE4CEC0B744D3F2523D61B4517B2E8A9447FC2B08AA6AD924DB2404A27D34FEE1AC564C83659211159DE4BE1914D845D5C796A812052244337BC705795A54A60DDE5980B7933951E06FCEEE0A3D06BAADBA086B248A5FAE876BE1869A33EDA9854AFA7EF06F5AA775929A37287B3549");
			versionRiped.position = 0;
			var finalAddress:String = Base58Encoder.encode(versionRiped);
			trace("final", finalAddress);
			
			
			var backToRiped:ByteArray = Base58Encoder.decode(finalAddress);
			trace("Back to Riped:", Hex.fromArray(backToRiped));
			
		}
		private function databaseTest():void
		{
			var dc:DatabaseController = new DatabaseController();
			
		}
		private function sendtest(ba:ByteArray):void
		{
			trace("send test");
			trace(ba.readUTFBytes(ba.bytesAvailable));
			trace("Sending replay", "");
			trace("__________________");
			var msg:ByteArray = new ByteArray();
			msg.writeUTFBytes("test");
			sendMsg(msg);
			
		}
		private function sendWork(nounce:uint, data:String):void
		{
			//{"method":"getwork","params":["0000000141a0e898cf6554fd344a37b2917a6c7a6561c20733b09c8000009eef00000000d559e21 882efc6f76bbfad4cd13639f4067cd904fe4ecc3351dc9cc5358f1cd54db84e7a1b00b5acba97b6 0400000080000000000000000000000000000000000000000000000000000000000000000000000 0000000000080020000"],"id":1}
			
			var dataAry:ByteArray = Hex.toArray(data);
			util.printAry(dataAry);
			dataAry.position = 76;
			dataAry.writeUnsignedInt(nounce);
			util.printAry(dataAry);
			
			var obj:Object = new Object();
			//obj.jsonrpc = "1.0";
			obj.id = 1;
			obj.method = "getwork";
			obj.params = [Hex.fromArray(dataAry)];
			var en:JSONEncoder = new JSONEncoder(obj);
			var bitStr:String = en.getString();
			//h += "\r\n\r\n";
			
			trace("authenticate");
			var path:String = "/";
			
			var userpass:String = Base64.encode(user+":"+password);
			
			var lines:Array= ['POST / HTTP/1.1','Host:'+host,'Authorization: Basic ' +userpass,"Content-Type: application/json; charset=utf-8","Content-Length: "+bitStr.length,'Connection: keep-alive'];
			//jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] 
			//var en:JSONEncoder = new JSONEncoder(obj);
			//var str:String = en.getString();
			var h:String =  lines.join("\r\n");
			h += "\r\n\r\n";
			//h += "\r\n";
			
			h += bitStr;
			
			//jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] 
			//var en:JSONEncoder = new JSONEncoder(obj);
			//h += en.getString();
			//h += "\r\n\r\n";
			
			trace(h);
			
			writeln(h);
			socket.flush();
			trace("done");
			
		}
		private function encodedTest():void
		{
			var genBlock:BlockVO = util.getGenisisBlock();
			var firstTrans:txVO = genBlock.txns[0];
			var genBlockByte:ByteArray = util.txToByteArry(firstTrans);
			trace("Gen Block trans:", ByteArrayUtil.toHexString(genBlockByte));
			var transhash:String = SHA256.hashBytes(util.getByteAryFromHashString( SHA256.hashBytes(genBlockByte)));
			trace("Gen block trans hash:", transhash);
			genBlockByte.position = 0;
			var bitutlHash:String = util.getTransactionHash(genBlockByte, true);
			trace("Util hash:", bitutlHash);
			var trans:ByteArray = ByteArrayUtil.fromHexString("01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000");
			var payHash:String = SHA256.hashBytes(util.getByteAryFromHashString( SHA256.hashBytes(trans)));
			trace("hash of the trans:", payHash);
			var reversed:ByteArray = util.reverseByteAry(ByteArrayUtil.fromHexString(payHash));
			trace("hash reversed for looking up online only:", ByteArrayUtil.toHexString(reversed));
			
			trace("--> encodngTest");
			trace("842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f", "842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f".length);
			//base 64 encoding test:
			var encoded:String = Base64.encodeByteArray(ByteArrayUtil.fromHexString("842dcbfdf7fc279c671efbc281fe66af8066b4a43597dffb0ad982042a552e6f"));
			trace(encoded, encoded.length);
			
		}
	}
}