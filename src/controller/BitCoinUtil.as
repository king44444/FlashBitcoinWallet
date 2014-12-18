package controller
{
	import com.adobe.crypto.SHA256;
	import com.adobe.fileformats.vcard.Address;
	import com.adobe.serialization.json.JSONEncoder;
	import com.hurlant.util.der.DER;
	import com.hurlant.util.der.IAsn1Type;
	import com.hurlant.util.der.Integer;
	import com.king.encoder.Base58Encoder;
	
	import flame.crypto.ECCParameters;
	import flame.crypto.ECDSA;
	import flame.crypto.ECDSASignatureDeformatter;
	import flame.crypto.ECDomainParameters;
	import flame.crypto.ECFieldElement;
	import flame.crypto.ECPoint;
	import flame.crypto.ICryptoTransform;
	import flame.crypto.PrimeEllipticCurve;
	import flame.crypto.RIPEMD160;
	import flame.crypto.RandomNumberGenerator;
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import model.BlockVO;
	import model.IPPort;
	import model.InVO;
	import model.OutPointVO;
	import model.OutRecord;
	import model.OutVO;
	import model.txVO;
	
	import org.osmf.utils.Version;

	public class BitCoinUtil
	{
		public var transCon:TransActionController = new TransActionController();
		
		private var seedIPs:Array = ["5.9.24.81", "85.17.239.32", "94.142.155.5", "46.4.121.98", "87.106.84.25", "69.64.34.118", "66.221.254.76", "199.192.76.206"];
		//private var testseedIPs:Array = ["5.9.24.81", "85.17.239.32", "94.142.155.5", "46.4.121.98", "87.106.84.25", "69.64.34.118", "66.221.254.76", "199.192.76.206"];
		
		public static var testnet:Boolean;
		public static const INVFILENAME:String = "inv.dat";
		public static const BLOCKSFILENAME:String = "blocks.dat";
		public static const MAINDIRECTORYNAME:String = "ASBitcoin";
		public static const TESTMAINDIRECTORYNAME:String = "ASTESTBitcoin";
		
		public static const MAGIC:uint = 0xF9BEB4D9;
		public static const TESTMAGIC:uint = 0x0B110907;
		
		public static var USEMAGIC:uint;
		public static var TRANSLOG:File;
		public static var TRANSFOLDER:File;
		public static var UNBLOCKFOLDER:File;
		public static var BLOCKFOLDER:File;
		public static var adderFile:File;
		public static var mainDirectory:File;
		public static var blockFile:File;
		public static var invFile:File;
		public var keyRecordSize:uint;
		
		public var keys:Vector.<BigInteger> = new Vector.<BigInteger>();
		public var publicKeys:Vector.<ByteArray> = new Vector.<ByteArray>();
		public var fullAddress:Vector.<String> = new Vector.<String>();
		
		public static var point:ECPoint;
		public static var _curve:PrimeEllipticCurve;
		public static var params:ECDomainParameters;
		
		public var addressCon:AddressCon = new AddressCon();
		
		public var log:Function;
		public var status:Function;
		
		public var highestBlock:uint;
		
		public var isThin:Boolean = true;
		
		
		public function BitCoinUtil(useTestNet:Boolean)
		{
			transCon.btil = this;
			testnet = useTestNet;
			
		}
		
		public function init():void
		{
			var stra:String = "0000000000000000000000000000000000000000000000000000000000000000";
			var strb:String = "0000000000000000000000000000000000000000000000000000000000000007";
			var strn:String = "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141";
			var strq:String = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F";
			var strx:String = "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798";
			var stry:String = "483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8";
			//(keySize:int, a:String, b:String, n:String, q:String, x:String, y:String
			params = new ECDomainParameters();
			params.a = BigInteger.parse(stra, 16);
			params.b = BigInteger.parse(strb, 16);
			params.n = BigInteger.parse(strn, 16);
			
			params.q = BigInteger.parse(strq, 16);
			params.x = BigInteger.parse(strx, 16);
			params.y = BigInteger.parse(stry, 16);
			
			_curve = new PrimeEllipticCurve(params.q, params.a, params.b);
			
			USEMAGIC = testnet? TESTMAGIC:MAGIC;
			mainDirectory = testnet? File.desktopDirectory.resolvePath(TESTMAINDIRECTORYNAME):File.desktopDirectory.resolvePath(MAINDIRECTORYNAME);
			if(mainDirectory.exists == false)
			{
				mainDirectory.createDirectory();
			}
			///adders
			adderFile = mainDirectory.resolvePath(testnet? "testadder.dat":"adder.dat");
			
			
			///////////////
			blockFile = mainDirectory.resolvePath(BitCoinUtil.BLOCKSFILENAME);
			if(!blockFile.exists)
			{
				//create the first one
				//4860EB18BF1B1620E37E9490FC8A427514416FD75159AB86688E9A8300000000
				if(testnet)
				{
					//000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943
					addHashToBlockDB(reverseByteAry(getByteAryFromHashString("000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943")));
				}else
				{
					addHashToBlockDB(getByteAryFromHashString("6FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000"));
				}
				//addHashToBlockDB(reverseByteAry2( getByteAryFromHashString("6FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000")));
			}
			TRANSLOG = mainDirectory.resolvePath("translog.dat");
			invFile = mainDirectory.resolvePath(BitCoinUtil.INVFILENAME);
			UNBLOCKFOLDER = mainDirectory.resolvePath("unblocks");
			if(!UNBLOCKFOLDER.exists)UNBLOCKFOLDER.createDirectory();
			BLOCKFOLDER = mainDirectory.resolvePath("blocks");
			if(!BLOCKFOLDER.exists)BLOCKFOLDER.createDirectory();
			
			TRANSFOLDER = mainDirectory.resolvePath("trans");
			if(!TRANSFOLDER.exists)
			{
				TRANSFOLDER.createDirectory();
				makeTransFiles("", 0);
			}
			
			var fileStream:FileStream = new FileStream();
			var keysFileName:String = testnet? "testnetkeys.dat":"keys.dat";
			//var keysFile:File = mainDirectory.resolvePath(keysFileName);
			var keysFile:File = File.desktopDirectory.resolvePath(keysFileName);
			var bigStart:BigInteger = addressCon.getRandomPrivateKey();
			var publicKey:ByteArray = addressCon.getPublicKey(bigStart);
			var fulladdress:String = addressCon.getFullBitAddress(bigStart, testnet);
			
			keyRecordSize = 32 + publicKey.length + fulladdress.length;
			
			var publicKeySize:uint = publicKey.length;
			var addressSize:uint = fulladdress.length;
			log("Key record size", keyRecordSize, "address size:", addressSize);
			
			var i:int;
			if(!keysFile.exists)
			{
				fileStream.open(keysFile, FileMode.APPEND);
				//need to generate some keys;
				for(i = 0;i<10;++i)
				{
					//var bitAddress:String = getBitAddress(bigStart);
					fileStream.writeBytes(bigStart.toByteArray());
					fileStream.writeBytes(publicKey);
					fileStream.writeUTFBytes(fulladdress);
					
					keys.push(bigStart);
					publicKeys.push(publicKey);
					fullAddress.push(fulladdress);
					
					bigStart = bigStart.add(BigInteger.ONE);
					publicKey = addressCon.getPublicKey(bigStart);
					fulladdress = addressCon.getFullBitAddress(bigStart, testnet);
					log("Key created:", fulladdress, "private Key:", bigStart.toString(16),"public:",  ByteArrayUtil.toHexString(publicKey));
				}
				fileStream.close();
				
			}else
			{
				var numberOfKeys:uint = keysFile.size / keyRecordSize;
				fileStream.open(keysFile, FileMode.READ);
				for( i = 0;i<numberOfKeys;++i)
				{
					var readBytes:ByteArray = new ByteArray();
					fileStream.readBytes(readBytes,0, 32 );
					bigStart = new BigInteger(readBytes);
					keys.push(bigStart);
					
					publicKey = new ByteArray();
					fileStream.readBytes(publicKey, 0, publicKeySize);
					publicKeys.push(publicKey);
					fulladdress = fileStream.readUTFBytes(addressSize);//addressCon.getFullBitAddress(bigStart, testnet) // fileStream.readUTFBytes(addressSize);
					fullAddress.push(fulladdress);
					var backToRiped:ByteArray = Base58Encoder.decode(fulladdress);
					log("Key added:", fulladdress, "un58ed:",ByteArrayUtil.toHexString(backToRiped) ,  "private Key:", bigStart.toString(16),"public:",  ByteArrayUtil.toHexString(publicKey));
				}
				fileStream.close();
			}
		}
		public function makeTransFiles(currentPrefex:String, currentDepth:uint):void
		{
			if(currentDepth == 2)
			{
				var transFile:File = TRANSFOLDER.resolvePath(currentPrefex + ".dat");
				if(transFile.exists == false)
				{
					var fs:FileStream = new FileStream();
					fs.open(transFile, FileMode.APPEND);
					fs.close();
					return;
				}
			}
			var i:uint = 0;
			for(i = 0;i<16;++i)
			{
				var letterPrefex:String = i.toString(16);
				makeTransFiles(currentPrefex + letterPrefex,currentDepth+1);
			}
			
		}
		public function addHashToBlockDB(hash:ByteArray):void
		{
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.APPEND);
			fileStream.writeBytes(hash);
			fileStream.close();
		}
		public function getLastBlock():ByteArray
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.READ);
			fileStream.position = blockFile.size - 32;
			var hash:ByteArray = new ByteArray();
			fileStream.readBytes(hash, 0, 32);
			fileStream.close();
			//var reversed:ByteArray = this.reverseByteAry2(hash);
			//log("Last block hash in DB:", ByteArrayUtil.toHexString(hash));
			
			return hash;
		}
		public function dbHasBlock(hash:ByteArray):Boolean
		{
			
			var blockCount:uint = blockFile.size / 32;
			var i:uint;
			var j:uint;
			var testbyte:uint;
			var testHash:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.READ);
			//log("Blocks in DB:", blockCount);
			for(i = 0;i<blockCount;++i)
			{
				
				//log(i, fileStream.position, fileStream.bytesAvailable);
				fileStream.position = i*32;
				testHash.position = 0;
				fileStream.readBytes(testHash, 0, 32);
				
				//do an inital check first?
				for(j = 0;j<32;++j)
				{
					testbyte = testHash.readUnsignedByte();
					if(testbyte == hash[j])
					{
						if(j == 31)
						{
							fileStream.close();
							return true;
						}
					}
					else
					{
						break;
					}
				}
			}
			fileStream.close();
			return false;
		}
		public function getGenisisBlock():BlockVO
		{
			if(testnet)
			{
				return realGenisisBlcock();
				
			}else
			{
				return realGenisisBlcock();
			}
		}

		private function realGenisisBlcock():BlockVO
		{
			/*
			04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
			*/
			
			var block:BlockVO = new BlockVO();
			block.hash = getByteAryFromHashString("000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");
			block.prev_block = getByteAryFromHashString("0000000000000000000000000000000000000000000000000000000000000000");
			block.ver = 1;
			block.time = 1231006505;//29AB5F49 0x495FAB29
			block.bits = 486604799;
			block.nonce = 2083236893;
			block.n_tx = 1;
			block.size = 285;
			for(var j:int = 0;j<1;++j)
			{
			var tx:txVO = new txVO();
			tx.hash = getByteAryFromHashString("4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b");
			tx.ver = 1;
			tx.vin_sz = 1;
			tx.vout_sz = 1;
			tx.lock_time = 0;
			tx.size = 204;
			block.txns.push(tx);
			for(var i:int = 0;i<1;++i)
			{
			var inTx:InVO = new InVO();
			inTx.prev_out.hash = getByteAryFromHashString("0000000000000000000000000000000000000000000000000000000000000000");
			inTx.prev_out.n = 4294967295;
			//inTx.coinbase = "04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73";//"The Times 03/Jan/2009 Chancellor on brink of second bailout for banks";
			inTx.sequence = 0xFFFFFFFF;
			inTx.script_length = 0x4D;//77 lenth in bytes
			////04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F7
			inTx.signature_script = getByteAryFromHashString("04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73");
			tx._in.push(inTx);
			}
			
			for( i = 0;i<1;++i)
			{
			var outTx:OutVO = new OutVO();
			outTx.value = getByteAryFromHashString("00f2052a01000000");
			outTx.lengthPubKey = 0x43;
			//
			//outTx.scriptPubKey = "04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f OP_CHECKSIG";
			//outTx.scriptPubKey = "5F1DF16B2B704C8A578D0BBAF74D385CDE12C11EE50455F3C438EF4C3FBCF649B6DE611FEAE06279A60939E028A8D65C10B73071A6F16719274855FEB0FD8A6704 OP_CHECKSIG";//to address
			outTx.scriptPubKey = getByteAryFromHashString("4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac");
			tx._out.push(outTx);
			}
			}
			block.mrkl_root = getByteAryFromHashString("4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b");
			//block.mrkl_root = getByteAryFromHashString("3BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A");
			
			
			return block;
		}
		//the pay needs to be just the block and nothing elese
		public function gotBlock(pay:ByteArray, traceit:Boolean):BlockVO
		{
			
			//log("sb2:", ByteArrayUtil.toHexString(pay));
			var block:BlockVO = new BlockVO();
			
			/*
			var fileStream:FileStream = new FileStream();
			var tfile:File = mainDirectory.resolvePath("tempblcok.dat");
			fileStream.open(tfile, FileMode.WRITE);
			fileStream.writeBytes(pay);
			fileStream.close();
			*/
			
			var blockHash:ByteArray = new ByteArray();
			blockHash.writeBytes(pay, 0, 80);
			//log("First 80 bytes:", ByteArrayUtil.toHexString(pay));
			//printAry(ba);
			SHA256.hashBytes(blockHash);
			SHA256.hashBytes(SHA256.digest);
			block.hash = ByteArrayUtil.copy( SHA256.digest);
			//hasHArray = reverseByteAry2(hasHArray);
			//hasHArray.position = 32;
			//traceit = true;
			if(traceit)log("Block hash:", ByteArrayUtil.toHexString(block.hash));
			if(traceit)log("Block hash for looking online:", ByteArrayUtil.toHexString(reverseByteAry(block.hash)));
			//traceit = false;
			//hasHArray.writeBytes(pay);
			
			var blockVersion:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("Block version", blockVersion);
			block.ver = blockVersion;
			
			var prevBlock:ByteArray = reverseByteAry( getNextbytes(pay, 32));
			//prevBlock = reverseByteAry2(prevBlock);
			if(traceit)log("prevBlock:",ByteArrayUtil.toHexString(prevBlock))
			block.prev_block = prevBlock;
			
			//printAry(prevBlock);
			var merckleRoot:ByteArray = reverseByteAry( getNextbytes(pay, 32));
			//log("merckleRoot")
			//printAry(merckleRoot);
			block.mrkl_root = merckleRoot;
			
			var timestamp:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("time stamp", timestamp);
			block.time = timestamp;
			var bits:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("bits", bits);
			block.bits = bits;
			var nounce:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("nounce", nounce);
			block.nonce = nounce;
			
			var numberOfTxn:uint = getIntLength(pay);
			if(traceit)log("Number of Txn", numberOfTxn);
			block.n_tx= numberOfTxn;
			
			for(var i:int = 0;i<numberOfTxn;++i)
			{
				if(traceit)log("trans:", i);
				
				var txvo:txVO = getTxn(pay, traceit);
				txvo.indexInBlock = i;
				block.txns.push(txvo);
			}
			return block;
		}
		public function processTransactions(block:BlockVO, blockNum:uint, traceit:Boolean = false):void
		{
			var i:uint;
			if(blockNum == 105)
			{
				//log("Stop");
				//traceit = true;
			}
			for(i = 0;i<block.n_tx;++i)
			{
				if(traceit)log("trans:", i);
				var txvo:txVO = block.txns[i];
				if(traceit)log("saving txhash:", ByteArrayUtil.toHexString(txvo.hash));
				if(ByteArrayUtil.isEqual(txvo.hash, ByteArrayUtil.fromHexString("6749762AE220C10705556799DCEC9BB6A54A7B881EB4B961323A3363B00DB518")))
				{
				//log("stop");
					
				}
				for(var j:int = 0;j<txvo._out.length;++j)
				{
					this.saveOut(blockNum,txvo.indexInBlock, txvo.hash, j, txvo._out[j])
					
					
				}
			}
			/*
			for(i = 0;i<block.n_tx;++i)
			{
				var isvalid:Boolean = validateTrans(txvo);
				if(traceit)log("txn is valid:", isvalid);
			}
			*/
		}
		
		public function saveBastardBlockWithRealName(block:BlockVO):Boolean
		{
			//got a new block, but it hasn't be confirmed
			var blockBytes:ByteArray = this.blockToByteArry(block);
			//log("sb2:", ByteArrayUtil.toHexString(blockBytes));
			var prevBlock:ByteArray = block.hash;// block.prev_block;
			prevBlock.position = 0;
			var prevBlockInt:uint = prevBlock.readUnsignedInt();// reverseByteAry( prevBlock ).readUnsignedInt();
			var bname:String = getBlockName(prevBlockInt, true);
			log("got block hash:", ByteArrayUtil.toHexString(reverseByteAry(block.hash)));
			log("saving block to:", bname);
			var blockNum:uint = 0;
			var scanning:Boolean = true;
			while(scanning)
			{
				var bfile:File = mainDirectory.resolvePath(bname + "." + blockNum.toString());
				if(bfile.exists)
				{
					blockNum++;
				}else
				{
					scanning = false;
				}
			}
			
			
			var fs:FileStream = new FileStream();
			fs.open(bfile, FileMode.WRITE);
			//this was a bad idea fs.writeBytes(block.hash);
			fs.writeBytes(blockBytes);
			fs.close();
			return true;
		}
		public function saveBastardBlock(block:BlockVO):Boolean
		{
			//got a new block, but it hasn't be confirmed
			var blockBytes:ByteArray = this.blockToByteArry(block);
			//log("sb2:", ByteArrayUtil.toHexString(blockBytes));
			var prevBlock:ByteArray = block.prev_block;
			prevBlock.position = 0;
			var prevBlockInt:uint = reverseByteAry( prevBlock ).readUnsignedInt();
			var bname:String = getBlockName(prevBlockInt, true);
			//log("saving block to:", bname);
			var blockNum:uint = 0;
			var scanning:Boolean = true;
			while(scanning)
			{
				var bfile:File = mainDirectory.resolvePath(bname + "." + blockNum.toString());
				if(bfile.exists)
				{
					blockNum++;
				}else
				{
					scanning = false;
				}
			}
			
			
			var fs:FileStream = new FileStream();
			fs.open(bfile, FileMode.WRITE);
			//this was a bad idea fs.writeBytes(block.hash);
			fs.writeBytes(blockBytes);
			fs.close();
			return true;
		}
		public function getTxn(pay:ByteArray, traceit:Boolean):txVO		
		{
			var startLocation:uint = pay.position;
			var hashStr:String = this.getTransactionHash(pay, traceit);
			pay.position = startLocation;
			if(traceit)log("Trans Hash", hashStr);
			var tx_hash:ByteArray = ByteArrayUtil.fromHexString(hashStr);
			
			var raw_tx_reversed:ByteArray = reverseByteAry(tx_hash);
			if(traceit)log("trans hash for looking up online:", ByteArrayUtil.toHexString(raw_tx_reversed));
			//for dev looking for a trans
			if( ByteArrayUtil.toHexString(raw_tx_reversed).toUpperCase() == "5043A53C2B2D3C2D8CB7E7E23C26909C942134F9B47261B0F034C4DCDBB7F704".toUpperCase())
			{
				log("found my trans");
					
			}
				
			var tx:txVO = new txVO();
			//tx.hash = tx_hash;
			tx.hash = raw_tx_reversed;
			if(traceit)log("--Tranaction--");
			var varsion:uint = rotateBytes(pay.readUnsignedInt());
			tx.ver = varsion;
			if(traceit)log("varsion:", varsion);
			var inputN:uint = getIntLength(pay);
			if(traceit)log("In count:", inputN);
			tx.vin_sz = inputN;
			
			for(var i:int = 0;i<inputN;++i)
			{
				var invo:InVO = getInput(pay, traceit);
				tx._in.push(invo);
			}
			
			
			var outputN:uint = getIntLength(pay);
			if(traceit)log("Out count:", outputN);
			tx.vout_sz = outputN;
			for( i = 0;i<outputN;++i)
			{
				var byteStart:uint = pay.position;
				var outvo:OutVO = getOutput(pay, traceit);
				var outLength:uint = (pay.position) - byteStart;
				outvo.byteLength = outLength;
				outvo.byteStart = byteStart;
				tx._out.push(outvo);
				
			}
			
			var lockTime:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("lockTime:", lockTime);
			tx.lock_time = lockTime;
			
			return tx;
		}
		
		public function getOutput(pay:ByteArray, traceit:Boolean = false):OutVO	
		{
			var out:OutVO = new OutVO();
			var valuebytes:ByteArray = this.getNextbytes(pay, 8);
			//value
			out.value = this.reverseByteAry(valuebytes);
			if(traceit)
			{
				var deletemeint:BigInteger = new BigInteger(out.value, true);
				log("value:",deletemeint.toString(10));
			}
			
			
			var pk_scriptLength:uint = getIntLength(pay);
			if(traceit)log("pk_script Length:", pk_scriptLength);
			var pk_script:ByteArray = new ByteArray();
			out.lengthPubKey = pk_scriptLength;
			if(out.lengthPubKey != 0)
			{
				pk_script = getNextbytes(pay, pk_scriptLength);
			}
			if(traceit)log("signature script")
			if(traceit)printAry(pk_script);
			out.scriptPubKey = pk_script;
			
			return out;
		}
		public function getInput(pay:ByteArray, traceit:Boolean = false):InVO		
		{
			var invo:InVO = new InVO();
			if(traceit)log("input:");
			//previous input hash
			var prevtrans:ByteArray = reverseByteAry(getNextbytes(pay, 32));
			if(traceit)log("prevtrans Hash:")
			if(traceit)printAry(prevtrans);
			
			//previous input index;
			//var txindex:int = rotateBytes(pay.readInt());
			var txindex:uint = rotateBytes(pay.readUnsignedInt());
			if(txindex != 0 && txindex != 1 && txindex != 0xffffffff)
			{
			//log("txindex", txindex);
			}
			if(traceit)log("txn Index:", txindex);
			var prevout:OutPointVO = new OutPointVO();
			prevout.hash = prevtrans;
			prevout.n = txindex;
			invo.prev_out = prevout;
			
			var lengthOfSigScript:uint = getIntLength(pay);
			if(traceit)log("The length of the signature script:", lengthOfSigScript);
			invo.script_length = lengthOfSigScript;
			//signature script
			var signaturescript:ByteArray = getNextbytes(pay, lengthOfSigScript);
			invo.signature_script = signaturescript;
			if(traceit)log("signature script")
			if(traceit)printAry(signaturescript);
			
			//sequence
			var sequence:uint = rotateBytes(pay.readUnsignedInt());
			if(traceit)log("sequence:", sequence);
			invo.sequence = sequence;
			return invo;
			
		}
		
		public function getNextbytes(pay:ByteArray, amount:uint):ByteArray
		{
			var hash:ByteArray = new ByteArray();
			
			hash.writeBytes(pay, pay.position, amount);
			pay.position += amount;
			
			
			return hash;
		}
		public function gotInv(pay:ByteArray):void
		{
			
			if(invFile.exists)
			{
				invFile.deleteFile();
			}
			var fileStream:FileStream = new FileStream();
			fileStream.open(invFile, FileMode.WRITE);
			//
			//
			
			
			var lengthAdr:uint = getIntLength(pay);
			
			var byte:uint;
			
			for(var i:int = 0;i<lengthAdr;++i)
			{
				var invType:uint = pay.readUnsignedInt();
				var hash:ByteArray = this.getNextbytes(pay, 32);
				if(dbHasBlock(hash) == false)
				{
					fileStream.writeUnsignedInt(invType);
					fileStream.writeBytes(hash);
					log("inv", i,"type", rotateBytes(invType).toString(16), "hash", ByteArrayUtil.toHexString(hash));
					
				}
				
			}
			fileStream.close();
		}
		public function gotAddr(pay:ByteArray):void
		{
			var lengthAdr:uint = getIntLength(pay);
			for(var i:int = 0;i<lengthAdr;++i)
			{
				getAddress(pay, true);	
			}
			//log(pay.position, pay.length);
		}
		
		public function getAddress(ba:ByteArray, timeStamp:Boolean, traceit:Boolean = false):void
		{
			if(traceit)log("Network Address");
			
			if(timeStamp)
			{
				var timeStamp1:uint = rotateBytes(ba.readUnsignedInt());
				var dateNew:Date = new Date();
				dateNew.setTime(timeStamp1*1000);
				if(traceit)log("IP timeStamp:", dateNew, timeStamp1.toString(16));
			}
			
			var services1:uint = rotateBytes(ba.readUnsignedInt());
			var services2:uint = rotateBytes(ba.readUnsignedInt());
			if(traceit)log("Network Services:", services1.toString(16), services2.toString(16));
			var net1:uint = ba.readUnsignedInt();
			var net2:uint = ba.readUnsignedInt();
			var net3:uint = ba.readUnsignedInt();
			var ip1:uint = ba.readUnsignedByte();
			var ip2:uint = ba.readUnsignedByte();
			var ip3:uint = ba.readUnsignedByte();
			var ip4:uint = ba.readUnsignedByte();
			var p1:uint = ba.readUnsignedByte();
			var p2:uint = ba.readUnsignedByte();
			
			var port:uint = (p1 << 8) + p2;
			if(traceit)log("IP", net1.toString(16), net2.toString(16), net3.toString(16), ip1+"."+ip2+"."+ip3+"."+ip4, "Port", port);
			
			
		}
	
		public function gotGetBlocks(pay:ByteArray):void
		{
			//this is broke
			return
			var version:uint = rotateBytes(pay.readUnsignedInt());
			log("Getblocks version", version.toString(16), version);
			var hashCount:uint = getIntLength(pay);
			log("GetBlocks hashes", hashCount);
			log("GetBlocks pay size", pay.length -pay.position,( pay.length-pay.position)/hashCount,"should have:", hashCount * 32);
			var pos:uint = pay.position;
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.WRITE);
			fileStream.writeBytes(pay,pos);
			fileStream.close();
			pay.position = pos;
			var byte:uint;
			
			for(var i:int = 0;i<=hashCount;++i)
			{
				var byteAry:ByteArray =  new ByteArray();
				
				for(var k:int = 0;k<8;++k)
				{
					byte = pay.readUnsignedInt();
					//fileStream.writeUnsignedInt(byte);
					byteAry.writeUnsignedInt( rotateBytes( byte ) );
				}
				byteAry.position = 0;
				var h1:uint = 0;
				var str:String = "";
				for(var j:int = 0;j<32;++j)
				{
					h1 =  byteAry.readUnsignedByte();// rotateBytes( pay.readUnsignedInt());
					if(h1 < 16)
					{
						str += "0"+ h1.toString(16);	
					}else
					{
						str += h1.toString(16);
					}
					//log(i,j,  pay.readUnsignedByte());
				}
				var inputArr:Array=str.split("");
				inputArr.reverse();
				var reverseStr:String=inputArr.join("");
				log(i, str, "revered", reverseStr);
			}
			log("left?", pay.position, pay.bytesAvailable);
			//fileStream.close();
			
		}
		
		public function gotVersion(ba:ByteArray):void
		{
			ba.position = 0;
			var version:uint = rotateBytes(ba.readUnsignedInt());
			//log("version:", version.toString());
			var services1:uint = rotateBytes(ba.readUnsignedInt());
			var services2:uint = rotateBytes(ba.readUnsignedInt());
			//log("Services:", services1.toString(16), services2.toString(16));
			var timeStamp1:uint = rotateBytes(ba.readUnsignedInt());
			var timeStamp2:uint = rotateBytes(ba.readUnsignedInt());
			var dateNew:Date = new Date();
			dateNew.setTime(timeStamp1*1000);
			
			//log("timeStamp:", dateNew, timeStamp1.toString(16), timeStamp2.toString(16));
			
			getAddress(ba, false);
			
			if(version >= 106)
			{
				getAddress(ba, false);
				
				var ran1:uint = rotateBytes(ba.readUnsignedInt());
				var ran2:uint = rotateBytes(ba.readUnsignedInt());
				//log("Random Number" , ran1, ran2);
				var versionStringLength:uint = ba.readUnsignedByte();
				if(versionStringLength > 0)
				{
					var versionStr:String = ba.readUTFBytes(versionStringLength);
					//log("Version String:", versionStr);
				}
				var lastBlock:uint = rotateBytes(ba.readUnsignedInt());
				//log("last Block", lastBlock);
				highestBlock = Math.max(highestBlock, lastBlock);
				
			}
			var i:int = 0;
			for(i=0;i<26;++i)
			{
				
			}
			return;
			
			while(ba.bytesAvailable)
			{
				log(ba.position, ba.readUnsignedByte().toString(16));
			}
		}
		//////////////
		//
		//get
		//////////////
		public function getBlockLocator(spot:uint):ByteArray
		{
			var pay:ByteArray = new ByteArray();
			var all:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.READ);
			fileStream.readBytes(all);//,spot*32,32);
			fileStream.close();
			pay.writeBytes(all, spot*32, 32);
			printAry(pay);
			return pay;
		}
		public function getGetDataForTrans(transHash:ByteArray):ByteArray
		{
			var pay:ByteArray = new ByteArray();
			//count
			pay.writeBytes(getVeribleIntBytes(1));
			//object type 0 = error, 1 = tx, 2 = block
			pay.writeUnsignedInt(rotateBytes(1));
			//block hash now
			pay.writeBytes(transHash);
			
			var ba:ByteArray = getGenMessage("getdata", pay);
			return ba;
			
		}
		public function getGetDataForBlock(blockHash:ByteArray, merkle:Boolean = false):ByteArray
		{
			var pay:ByteArray = new ByteArray();
			//count
			pay.writeBytes(getVeribleIntBytes(1));
			//object type 0 = error, 1 = tx, 2 = block, 3 = merkle
			pay.writeUnsignedInt(rotateBytes(merkle? 3:2));
			//block hash now
			pay.writeBytes(blockHash);
			
			var ba:ByteArray = getGenMessage("getdata", pay);
			return ba;
			
		}
		public function getGetData():ByteArray
		{
			var pay:ByteArray = new ByteArray();
			var numberOfinvs:ByteArray = getVeribleIntBytes(invFile.size/36);
			//log("Get data number of INVS:", ByteArrayUtil.toHexString(numberOfinvs));
			pay.writeBytes(numberOfinvs);
			var fileStream:FileStream = new FileStream();
			fileStream.open(invFile, FileMode.READ);
			fileStream.readBytes(pay, numberOfinvs.length);//,spot*32,32);
			fileStream.close();
			var ba:ByteArray = getGenMessage("getdata", pay);
			return ba;
			/*
			
			var pay:ByteArray = new ByteArray();
			var count:uint = 3;
			pay.writeUnsignedInt(rotateBytes(count));
			
			for(var i:int = 0;i<count;++i)
			{
				pay.writeUnsignedInt( rotateBytes (2) );
				pay.writeBytes( getBlockLocator( i ) );
			}
			printAry(pay);
			var ba:ByteArray = getGenMessage("getdata", pay);
			return ba;
			*/
		}
		public function getVerack():ByteArray
		{
			//log("sending verack");
			var pay:ByteArray = new ByteArray();
			var ba:ByteArray = getGenMessage("verack", pay);
			return ba;
			
		}
		public function getVersion(peerIp:String, myIp:String):ByteArray
		{
			/*
			f9 be b4 d9 
			76 65 72 73  69 6f 6e 00 00 00 00 00 ....vers ion.....
			64 00 00 00  payload
			
			64 1f 96 10  checksum
			62 ea 00 00  version 60002
			01 00 00 00 00 00 00 00 services 1 (NODE_NETWORK services)
			24 32 93 50  00 00 00 00 timeStamp in seconds 1351823908
			from network ip
			01 00 00 00 00 00 00 00 services again
			00 00 00 00  00 00 00 00 00 00 ff ff 47 a4 c6 27 their ip address
			20 8d their port
			my ip
			01 00  00 00 00 00 00 00 services again
			00 00 00 00 00 00 00 00 00 00  ff ff 43 b6 da 29 my ip
			20 8d my port
			
			14 00 2c 74 8f 3c e1 85 random number/uid
			0f 
			2f 53 61 74 6f 73 68 /Satosh
			69 3a 30 2e 37 2e 31 2f  i:0.7.1/
			91 22 03 00 The last block received by the emitting node 205457
			*/
			//main	 0xD9B4BEF9	 F9 BE B4 D9
			//testnet	 0xDAB5BFFA	 FA BF B5 DA
			var i:int;
			
			
			var pay:ByteArray = new ByteArray();
			
			//62 ea 00 00  version 60002
			
			/*
			pay.writeByte(0x62);
			pay.writeByte(0xea);
			pay.writeByte(0x0);
			pay.writeByte(0x0);
			*/
			//pay.writeUnsignedInt(rotateBytes(60002));
			//71110100 = 00011171 = 70001
			pay.writeUnsignedInt(rotateBytes(70001));
			
			
			//01 00 00 00 00 00 00 00 services 1 (NODE_NETWORK services)
			if(!isThin)
			{
				pay.writeUnsignedInt(rotateBytes(1));
			}else
			{
				pay.writeUnsignedInt(0);
			}
			pay.writeUnsignedInt(0);
			
			//24 32 93 50  00 00 00 00 timeStamp in seconds 1351823908
			var myDate:Date = new Date();
			var unixTime:uint = Math.round(myDate.getTime()/1000);
			unixTime = rotateBytes(unixTime);
			//writeZero(ba)
			pay.writeUnsignedInt(unixTime);
			pay.writeUnsignedInt(0);
			
			//Ip now
			pay.writeUnsignedInt(rotateBytes(1));//services agains
			pay.writeUnsignedInt(0);
			pay.writeUnsignedInt(0);// 00 00 00 00 
			pay.writeUnsignedInt(0);//00 00 00 00 
			pay.writeByte(0);//00   
			pay.writeByte(0);//00 
			pay.writeByte(0xFF);//FF 
			pay.writeByte(0xFF);//FF 
			var ipary:Array = peerIp.split(".");
			for( i = 0;i<4;++i)
			{
				pay.writeByte(int(ipary[i]));
			}
			//port
			pay.writeByte(0x20);
			pay.writeByte(0x8d);
			
			//my ip now
			pay.writeUnsignedInt(rotateBytes(1));//services agains
			pay.writeUnsignedInt(0);
			pay.writeUnsignedInt(0);// 00 00 00 00 
			pay.writeUnsignedInt(0);//00 00 00 00 
			pay.writeByte(0);//00   
			pay.writeByte(0);//00 
			pay.writeByte(0xFF);//FF 
			pay.writeByte(0xFF);//FF 
			ipary = myIp.split(".");
			for( i = 0;i<4;++i)
			{
				pay.writeByte(int(ipary[i]));
			}
			//port
			pay.writeByte(0x20);
			pay.writeByte(0x8d);
			
			//14 00 2c 74 8f 3c e1 85 random number/uid
			pay.writeUnsignedInt(int.MAX_VALUE * Math.random());
			pay.writeUnsignedInt(int.MAX_VALUE * Math.random());
			//version stirng
			pay.writeByte(0x0);
			
			//last block
			pay.writeUnsignedInt(rotateBytes(blockFile.size/32));
			//pay.writeUnsignedInt(rotateBytes(234549));
			
			//update the payload size
			
			//new relay!
			if(isThin)
			{
				pay.writeByte(0);
			}
			var ba:ByteArray = getGenMessage("version", pay);
			
			return ba;
			
			
		}
	
		public function getAddr():ByteArray
		{
			var pay:ByteArray = new ByteArray();
			pay.writeByte(0);
			var ba:ByteArray = getGenMessage("addr", pay);
			
			return  ba;
			
		}
		
		public function getGetBlocks():ByteArray
		{
			var sendBlocks:uint = Math.min(200, (blockFile.size/32));
			var pay:ByteArray = new ByteArray();
			//version 
			pay.writeUnsignedInt(rotateBytes(60002));
			//hash count
			pay.writeBytes(getVeribleIntBytes(sendBlocks));
			//pay.writeUnsignedInt(rotateBytes(sendBlocks));
			//block locator hashes
			var fileStream:FileStream = new FileStream();
			fileStream.open(BitCoinUtil.blockFile, FileMode.READ);
			fileStream.position = blockFile.size - (sendBlocks * 32);
			var lastBlock:ByteArray = new ByteArray();
			fileStream.readBytes(lastBlock, 0, (sendBlocks * 32));
			fileStream.close();
			
			//"000000009AA29EC3F8C110D34BE2090471D6BF3F9159B3C0DECFB798DE0B79BF"
			//"DE0B79BFDECFB7989159B3C071D6BF3F4BE20904F8C110D39AA29EC300000000"
			//"00000000C39EA29AD310C1F80409E24B3FBFD671C0B3599198B7CFDEBF790BDE"
			//lastBlock = reverseByteAry2(ByteArrayUtil.fromHexString("bf790bde98b7cfdec0b359913fbfd6710409e24bd310c1f8c39ea29a00000000"));
			//lastBlock = reverseByteAry(ByteArrayUtil.fromHexString("DE0B79BFDECFB7989159B3C071D6BF3F4BE20904F8C110D39AA29EC300000000"));
			//lastBlock = ByteArrayUtil.fromHexString("00000000c39ea29ad310c1f80409e24b3fbfd671c0b3599198b7cfdebf790bde");
			
			//pay.writeBytes( getBlockHashFromBlock( getGenisisBlock( ) ) );
			//var lastBlock:ByteArray = this.getLastBlock();
			//log("last block hash:", ByteArrayUtil.toHexString(this.reverseByteAry( lastBlock )));
			pay.writeBytes(lastBlock);
			pay.writeBytes( getByteAryFromHashString( "0000000000000000000000000000000000000000000000000000000000000000" ) );
			var ba:ByteArray = getGenMessage("getblocks", pay);
			return ba;
			
		}
		public function getGetAddr():ByteArray
		{
			
			
			var pay:ByteArray = new ByteArray();
			var payHash:String = SHA256.hashBytes(getByteAryFromHashString( SHA256.hashBytes(pay)));
			var hasHArray:ByteArray = getByteAryFromHashString(payHash);
			
			var ba:ByteArray =getGenMessage("getaddr", pay);
			//magic numbers
			return ba;
			
		}
		/////////////
		//
		//
		////////////////////////////////////////////////////////////////////////////////////////
		public function blockToByteArry(block:BlockVO):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt( rotateBytes( block.ver ) );
			ba.writeBytes(reverseByteAry(block.prev_block));
			
			//printAry(block.mrkl_root);
			//printAry(reverseByteAry(block.mrkl_root));
			
			ba.writeBytes(reverseByteAry(block.mrkl_root));
			ba.writeUnsignedInt(rotateBytes(block.time));
			ba.writeUnsignedInt(rotateBytes(block.bits));
			ba.writeUnsignedInt(rotateBytes(block.nonce));
			ba.writeBytes(getVeribleIntBytes(block.n_tx));
			
			for(var i:int = 0;i<block.txns.length;++i)
			{
				ba.writeBytes(txToByteArry(block.txns[i]));
			}
			return ba;
		}
		public function txToByteArry(tx:txVO, stripForSigning:Boolean = false):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt( rotateBytes( tx.ver ) );
			//in
			ba.writeBytes( getVeribleIntBytes( tx.vin_sz ) );
			
			for(var i:int = 0;i<tx._in.length;++i)
			{
				ba.writeBytes(txInputToArray(tx._in[i], stripForSigning));
			}
			
			//out now
			ba.writeBytes( getVeribleIntBytes( tx.vout_sz ) );
			
			for(i = 0;i<tx._out.length;++i)
			{
				ba.writeBytes(txOutputToArray(tx._out[i]));
			}
			ba.writeUnsignedInt(rotateBytes(tx.lock_time));
			return ba;
		}
		public function txInputToArray(invo:InVO, stripforsigning:Boolean = false):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			//invo.prev_out.hash.position = 0;
			ba.writeBytes( reverseByteAry( invo.prev_out.hash ) );
			ba.writeUnsignedInt(rotateBytes(invo.prev_out.n));
			if(stripforsigning)
			{
				ba.writeByte(0x00);
			}else
			{
				ba.writeBytes( getVeribleIntBytes( invo.script_length ) );
				if(invo.script_length != 0)
				{
					ba.writeBytes(invo.signature_script);
				}
			}
			ba.writeUnsignedInt(rotateBytes(invo.sequence));
			return ba;
		}
		
		public function txOutputToArray(outvo:OutVO):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			//ba.writeBytes( reverseByteAry( numberToInt64Bytes( outvo.value ) ) );
			ba.writeBytes( reverseByteAry( outvo.value ));// numberToInt64Bytes( outvo.value ) );
			ba.writeBytes( getVeribleIntBytes( outvo.lengthPubKey ) );
			
			ba.writeBytes( outvo.scriptPubKey );
			return ba;
		}
		
		public function rotateBytes( value:uint ):uint
		{
			return ((value & 0xFF) << 24) | (((value >> 8) & 0xFF) << 16) | (((value >> 16) & 0xFF) << 8) | (value >>> 24);
		}
		public function getVeribleIntBytes(value:uint):ByteArray
		{
			var ba:ByteArray = new ByteArray();
			var i:uint;
			if(value < 0xfd)
			{
				ba.writeByte(value);
				
			}else if (value <= 0xffff)
			{
				ba.writeByte(0xfd);
				var val:uint = 0;
				for(i = 0;i<2;++i)
				{
					var num:uint = value;
					num = num >> (i*8);
					ba.writeByte(num);
				}
				
				
			}else if (value <= 0xffffffff)
			{
				ba.writeByte(0xfe);
				ba.writeUnsignedInt(value);
				
			}else
			{
				//fix, not rights
				ba.writeByte(0xff);
				ba.writeUnsignedInt(value);
				ba.writeUnsignedInt(value);
				
			}
			return ba;
		}
		public function getIntLength(pay:ByteArray):uint
		{
			//pay.position = 0;
			var firstByte:uint = pay.readUnsignedByte();
			var i:uint;
			var val:uint;
			var num:uint;
			if(firstByte < 0xfd)
			{
				return firstByte
			}else if (firstByte == 0xfd )
			{
				 val = 0;
				for(i = 0;i<2;++i)
				{
					num = pay.readUnsignedByte();
					num = num << (i*8);
					val += num;
				}
				
				return val;
			}else if (firstByte == 0xfe )
			{
				 val = 0;
				for(i = 0;i<4;++i)
				{
					 num = pay.readUnsignedByte();
					num = num << (i*8);
					val += num;
				}
				
				return val;
				
			}else if (firstByte == 0xff )
			{
				
				 val = 0;
				for(i = 0;i<8;++i)
				{
					num = pay.readUnsignedByte();
					num = num << (i*8);
					val += num;
				}
				return val;
			}
			log("crap 2");
			return 1;
		}
		public  function getByteAryFromHashString(hex:String):ByteArray {
			hex = hex.replace(/\s|:/gm,'');
			var a:ByteArray = new ByteArray;
			//good if (hex.length&1==1) hex="0"+hex;
			for (var i:uint=0;i<hex.length;i+=2) 
			{
				//a[i/2] = parseint(hex.substr(i,2),16);
				//log(parseInt(hex.substr(i,2),16).toString(16))
				a.writeByte( parseInt(hex.substr(i,2),16) );
			}
			return a;
		}
		public function reverseByteAry(byteAry:ByteArray):ByteArray
		{
			
			var dup:ByteArray = new ByteArray();
			byteAry.position = 0;
			var chuncks:uint = byteAry.length / 4;
			for(var i:uint = 0;i < chuncks;++i)
			{
				var num:uint = byteAry.readUnsignedInt();
				dup.position = ((chuncks-1) - i) * 4;
				//log(i, "num", num.toString(16), "position", dup.position, "rotated", rotateBytes(num).toString(16));
				
				dup.writeUnsignedInt( rotateBytes(num) );
				//dup.position -= 4;
				//log("read:", dup.readUnsignedInt().toString(16).toUpperCase());
					
			} 
			dup.position = 0;
			byteAry.position = 0;
			return dup;
		}
		public function reverseByteAry2(byteAry:ByteArray):ByteArray
		{
			
			var dup:ByteArray = new ByteArray();
			byteAry.position = 0;
			var chuncks:uint = byteAry.length / 4;
			for(var i:uint = 0;i < chuncks;++i)
			{
				var num:uint = byteAry.readUnsignedInt();
				dup.writeUnsignedInt( rotateBytes(num) );
				
			} 
			dup.position = 0;
			byteAry.position = 0;
			return dup;
		}
		private function numberToInt64Bytes(n:Number):ByteArray
		{
			log(n);
			var uint1:uint = n >> 32 & 0xFFFFFFFF;
			log(uint1.toString(16));
			var uint2:uint = n & 0xFFFFFFFF;
			log(uint2.toString(16));
			
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt(rotateBytes(uint1));
			ba.writeUnsignedInt(rotateBytes(uint2));
			ba.position = 0;
			return ba;
		}
		private function numberToInt64BytesWorked(n:Number):ByteArray
		{
			// Write your IEEE 754 64-bit double-precision number to a byte array.
			var b:ByteArray = new ByteArray();
			b.writeDouble(n);
			
			// Get the exponent.
			var e:int = ((b[0] & 0x7F) << 4) | (b[1] >> 4);
			
			// Significant bits.
			var s:int = e - 1023;
			
			// Number of bits to shift towards the right.
			var x:int = (52 - s) % 8;
			
			// Read and write positions in the byte array.
			var r:int = 8 - int((52 - s) / 8);
			var w:int = 8;
			
			// Clear the first two bytes of the sign bit and the exponent.
			b[0] &= 0x80;
			b[1] &= 0xF;
			
			// Add the "hidden" fraction bit.
			b[1] |= 0x10;
			
			// Shift everything.
			while (w > 1) {
				if (--r > 0) {
					if (w < 8)
						b[w] |= b[r] << (8 - x);
					
					b[--w] = b[r] >> x;
					
				} else {
					b[--w] = 0;
				}
			}
			
			// Now you've got your 64-bit signed two's complement integer.
			return b;
		}
		public function getGenMessage(command:String, pay:ByteArray):ByteArray
		{
			
			var payHash:String = SHA256.hashBytes(getByteAryFromHashString( SHA256.hashBytes(pay)));
			var hasHArray:ByteArray = getByteAryFromHashString(payHash);
			
			var ba:ByteArray = new ByteArray();
			//magic numbers
			ba.writeUnsignedInt(USEMAGIC);//rotateBytes(0xD9B4BEF9));
			

			ba.writeUTFBytes(command);
			for(var i:int = command.length;i<12;++i)
			{
				ba.writeByte(0);
			}
			//payload size
			ba.writeUnsignedInt(rotateBytes(pay.length));
			//64 1f 96 10  checksum
			ba.writeBytes(hasHArray,0, 4);
			ba.writeBytes(pay);
			ba.position = 0;
			return ba;
			
		}
		
		public function getBlockHashFromBlock(block:BlockVO):ByteArray
		{
			
			var blockBytes:ByteArray = blockToByteArry(block);
			
			var ba:ByteArray = new ByteArray();
			//ba.writeUnsignedInt( block.ver);
			//ba.writeUnsignedInt(rotateBytes(block.ver));
			//ba.writeBytes(block.prev_block);
			//ba.writeBytes(block.mrkl_root);
			//ba.writeUnsignedInt(rotateBytes(block.time));
			//ba.writeUnsignedInt(rotateBytes(block.bits));
			//ba.writeUnsignedInt(rotateBytes(block.nonce));
			
			//ba.writeUnsignedInt(block.time);
			//ba.writeUnsignedInt(block.bits);
			//ba.writeUnsignedInt(block.nonce);
			ba.writeBytes(blockBytes, 0, 80)
			
			SHA256.hashBytes(ba)
			var payHash:String = SHA256.hashBytes(SHA256.digest);
			log("Block hash:", payHash);
			var hasHArray:ByteArray = getByteAryFromHashString(payHash);
			//var reversed:ByteArray = this.reverseByteAry2(hasHArray);
			return SHA256.digest;
		}
		
		public function getTransactionHash(pay:ByteArray, traceit:Boolean = false):String
		{
			//traceit = false;
			var ba:ByteArray = new ByteArray();
			//log("get Trans Hash start:", pay.position);
			if(traceit)log("--Tranaction--");
			var version:uint = pay.readUnsignedInt();
			ba.writeUnsignedInt(version);
			if(traceit)log("varsion:", this.rotateBytes( version));
			var inputN:uint = getIntLength(pay);
			ba.writeBytes(this.getVeribleIntBytes(inputN));
			if(traceit)log("In count:", inputN);
			
			for(var i:int = 0;i<inputN;++i)
			{
				
				if(traceit)log("input:");
				//previous input hash
				var prevTrans:ByteArray = getNextbytes(pay, 32);
				ba.writeBytes(prevTrans);
				if(traceit)log("prevTrans")
				if(traceit)printAry(prevTrans);
				
				//previous input index;
				var txindex:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(txindex);
				if(traceit)log("txn Index:", txindex.toString(16));
				
				var lengthOfSigScript:uint = getIntLength(pay);
				ba.writeBytes(this.getVeribleIntBytes(lengthOfSigScript));
				if(traceit)log("The length of the signature script:", lengthOfSigScript);
				//signature script
				var signaturescript:ByteArray = getNextbytes(pay, lengthOfSigScript);
				ba.writeBytes(signaturescript);
				if(traceit)log("signature script")
				if(traceit)printAry(signaturescript);
				
				//sequence
				var sequence:uint = rotateBytes(pay.readUnsignedInt());
				ba.writeUnsignedInt(sequence);
				if(traceit)log("sequence:", sequence.toString(16));
				
			}
			
			var outputN:uint = getIntLength(pay);
			ba.writeBytes(this.getVeribleIntBytes(outputN));
			if(traceit)log("Out count:", outputN);
			
			for( i = 0;i<outputN;++i)
			{
				var value1:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(value1);
				var value2:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(value2);
				if(traceit)log("value:", rotateBytes( value1), rotateBytes(value2));
				
				var pk_scriptLength:uint = getIntLength(pay);
				ba.writeBytes(this.getVeribleIntBytes(pk_scriptLength));
				if(traceit)log("pk_script Length:", pk_scriptLength);
				
				var pk_script:ByteArray = getNextbytes(pay, pk_scriptLength);
				ba.writeBytes(pk_script);
				if(traceit)log("signature script")
				if(traceit)printAry(pk_script);
			}
			
			var lockTime:uint = rotateBytes(pay.readUnsignedInt());
			ba.writeUnsignedInt(lockTime);
			if(traceit)log("Block before hash:", ByteArrayUtil.toHexString(ba));
			if(traceit)log("lockTime:", lockTime);
			SHA256.hashBytes(ba);
			var hashStr:String = SHA256.hashBytes(SHA256.digest)
			if(traceit)log("trans hash:", hashStr);
			var raw_tx_reversed:ByteArray = reverseByteAry(SHA256.digest);
			if(traceit)log("trans hash for looking up online:", ByteArrayUtil.toHexString(raw_tx_reversed));
			
			return hashStr;
		}
		/*
		public function getTransactionHashOLD(pay:ByteArray, traceit:Boolean = false):String
		{
			var ba:ByteArray = new ByteArray();
			traceit = true;
			if(traceit)log("--Tranaction--");
			var version:uint = pay.readUnsignedInt();
			ba.writeUnsignedInt(version);
			if(traceit)log("varsion:", version);
			var inputN:uint = getIntLength(pay);
			ba.writeBytes(this.getVeribleIntBytes(inputN));
			if(traceit)log("In count:", inputN);
			
			for(var i:int = 0;i<inputN;++i)
			{
				if(traceit)log("input:");
				//previous input hash
				var prevBlock:ByteArray = getNextbytes(pay, 32);
				ba.writeBytes(prevBlock);
				if(traceit)log("prevBlock")
				if(traceit)printAry(prevBlock);
				
				//previous input index;
				var txindex:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(txindex);
				if(traceit)log("txn Index:", txindex);
				
				var lengthOfSigScript:uint = getIntLength(pay);
				ba.writeBytes(this.getVeribleIntBytes(lengthOfSigScript));
				if(traceit)log("The length of the signature script:", lengthOfSigScript);
				//signature script
				var signaturescript:ByteArray = getNextbytes(pay, lengthOfSigScript);
				ba.writeBytes(signaturescript);
				if(traceit)log("signature script")
				if(traceit)printAry(signaturescript);
				
				//sequence
				var sequence:uint = rotateBytes(pay.readUnsignedInt());
				ba.writeUnsignedInt(sequence);
				if(traceit)log("sequence:", sequence);
				
			}
			
			var outputN:uint = getIntLength(pay);
			ba.writeBytes(this.getVeribleIntBytes(outputN));
			if(traceit)log("Out count:", outputN);
			
			for( i = 0;i<outputN;++i)
			{
				var value1:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(value1);
				var value2:uint = pay.readUnsignedInt();
				ba.writeUnsignedInt(value2);
				if(traceit)log("value:", value1, value2);
				//0x34602F4 little ?
				//0xf4024603
				if(value1 == rotateBytes(40) || value2 == rotateBytes(40))
				{
					log("My trans");
				}
				var pk_scriptLength:uint = getIntLength(pay);
				ba.writeBytes(this.getVeribleIntBytes(pk_scriptLength));
				if(traceit)log("pk_script Length:", pk_scriptLength);
				
				var pk_script:ByteArray = getNextbytes(pay, pk_scriptLength);
				ba.writeBytes(pk_script);
				if(traceit)log("signature script")
				if(traceit)printAry(pk_script);
			}
			
			var lockTime:uint = rotateBytes(pay.readUnsignedInt());
			ba.writeUnsignedInt(lockTime);
			if(traceit)log("lockTime:", lockTime);
			
			if(traceit)log("trans before hash:", ByteArrayUtil.toHexString(ba));
			SHA256.hashBytes(ba);
			return SHA256.hashBytes(SHA256.digest);
		}
		*/
		public function sortBlocks():Boolean
		{
			var scanning:Boolean = true;
			var prevNameChar:String;
			
			while(scanning)
			{
				var lastBlockHash:ByteArray = getLastBlock();
				//get the file name for the next block
				var i:uint = lastBlockHash.readUnsignedInt();//rotateBytes(lastBlockHash.readUnsignedInt());
				//first one should be: 6FE28C0A
			
				scanning = lookForBlock(i);
			}
			return true;
		}
		private function lookForBlock(blockid:uint):Boolean
		{
			var blockName:String = getBlockName(blockid, true);
			for (var j:uint = 0;j<10;++j)
			{
				var testblk:File =  mainDirectory.resolvePath(blockName + "." + j.toString());
				if(testblk.exists)
				{
					if(countChain(blockid, j, 0))
					{
						trace("cain log=ng enought for:", blockid.toString(16));
						blockIsConfirmed(blockid, j);	
						return true;
					}
				}else
				{
					return false
				}
			}
			return false
		}
		public function countChain(blockid:uint, blocknum:uint, count:uint):Boolean
		{
			//trace("Chain count:", count, blockid, blocknum);
			
			if(count == 10)
			{
				trace("Chain is long enough");
				return true;
			}
			
			var blockName:String = getBlockName(blockid, true);
			var fromFile:File = mainDirectory.resolvePath(blockName + "." + blocknum.toString());
			if(fromFile.exists)
			{
				var buf:ByteArray = new ByteArray();
				var fs:FileStream = new FileStream();
				fs.open(fromFile, FileMode.READ);
				fs.readBytes(buf);
				fs.close();
				buf.position = 0;
				var block:BlockVO = this.gotBlock(buf, false);
				block.hash.position = 0;
				var nextBlockid:uint = block.hash.readUnsignedInt();
				
				
				for (var j:uint = 0;j<10;++j)
				{
					var nblockName:String = getBlockName(nextBlockid, true);
					//trace("blockName:", blockName, "exits, now looking for:", nblockName, "count:", count);
					var nfromFile:File = mainDirectory.resolvePath(nblockName + "." + j.toString());
					if(nfromFile.exists)
					{
						var chanLongEnough:Boolean = countChain(nextBlockid, j, count + 1);
						if(chanLongEnough)
						{
							return true;
						}
						
					}else
					{
						return false;
					}
					
				}
				
				return false;
			}else
			{
				return false;
			}
			
		}
		public function blockIsConfirmed(addBlock:uint, blockNum:uint):void
		{
			var blockName:String = getBlockName(addBlock, true);
			var fromFile:File = mainDirectory.resolvePath(blockName + "." + blockNum.toString());
			
			
			var buf:ByteArray = new ByteArray();
			var fs:FileStream = new FileStream();
			fs.open(fromFile, FileMode.READ);
			fs.readBytes(buf);//, 0, 32);
			fs.close();
			//add it to the DB
			var block2:BlockVO = gotBlock(buf, false);
			addHashToBlockDB(block2.hash);
			var blockCount:uint = blockFile.size / 32;
			log("Confirmed block:",  blockCount, "hash",  ByteArrayUtil.toHexString(reverseByteAry(block2.hash)));
			log("___________________________________");
			
			var newNameChar:String = getBlockName(rotateBytes(blockCount), false);
			fromFile.moveTo(mainDirectory.resolvePath(newNameChar), true);
			
			// good processTransactions(block2, blockCount,false);
		}
		public function getBlockName(blockNum:uint, useUnFolder:Boolean):String
		{
			var name:String = blockNum.toString(16);
			while(name.length < 8)
			{
				name = "0" + name;
			}
			
			// /unblocks/4F29F31E.blk
			if(useUnFolder)
			{
				return UNBLOCKFOLDER.name + "/" + name;
			}else
			{
				return BLOCKFOLDER.name + "/" + name + ".blk";
			}
		}
		
		public function unpack(s:String):ECPoint
		{
			var firstByte:uint = parseInt(s.substr(0, 2), 16);
			var bytes:ByteArray = ByteArrayUtil.fromHexString(s.substring(2));
			var xnum:BigInteger = BigInteger.parse(s.substring(2), 16);// new BigInteger(bytes);
			//log("x:", xnum.toString(16));
			var yHex:String;
			var xHex:String;
			
			switch (firstByte) { // first byte
				case 0:
					return _curve.pointAtInfinity;
				case 2:
				case 3:
					var yTilde:uint = firstByte & 1;
					xHex = s.substr(2, s.length - 2);
					var X1:BigInteger = BigInteger.parse(xHex, 16);
					return this.decompressPoint(yTilde, X1);
				case 4:
				case 6:
				case 7:
					var len:uint = (s.length - 2) / 2;
					xHex = s.substr(2, len);
					yHex = s.substr(len + 2, len);
					return _curve.createPoint(BigInteger.parse(xHex, 16), BigInteger.parse(yHex, 16));
				default: // unsupported
					return null;
			}
			
		}
		private function decompressPoint(yTilde:uint, X1:BigInteger):ECPoint
		{
			var stra:String = "0000000000000000000000000000000000000000000000000000000000000000";
			var strb:String = "0000000000000000000000000000000000000000000000000000000000000007";
			var strn:String = "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141";
			var strq:String = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F";
			var a:BigInteger = BigInteger.parse(stra, 16);
			var b:BigInteger = BigInteger.parse(strb, 16);
			var n:BigInteger = BigInteger.parse(strn, 16);
			var q:BigInteger = BigInteger.parse(strq, 16);
			
			var big3:BigInteger = new BigInteger(3);
			var big4:BigInteger = new BigInteger(4);
			var ca:ECFieldElement = _curve.bigIntegerToFieldElement(a);
			var cb:ECFieldElement = _curve.bigIntegerToFieldElement(b);
			var x:ECFieldElement = _curve.bigIntegerToFieldElement(X1);//return new ec.FieldElementFp(this.q, x);
			var alpha:ECFieldElement = x.multiply(x.square().add(ca)).add(cb);
			var beta:ECFieldElement = alpha.sqrt(_curve);
			if (beta == null) throw new Error("Invalid point compression");
			var betaValue:BigInteger = beta.toBigInteger();
			
			var bit0:uint = !betaValue._bits[0] ? 1 : 0;
			if (betaValue.isEven)// bit0 != yTilde) 
			{
				// Use the other root
				beta = _curve.bigIntegerToFieldElement(q.subtract(betaValue));
			}
			log("x:", x.toBigInteger().toString(16),"y:", beta.toBigInteger().toString(16));
			return _curve.createPoint(x.toBigInteger(), beta.toBigInteger());
		}
		
		//dev tools
		public function printAry(ba:ByteArray):void
		{
			var str:String = "";
			ba.position = 0;
			var block:int = 0;
			while(ba.bytesAvailable)
			{
				var ubyte:uint =ba.readUnsignedByte();
				
				if(ubyte < 16)
				{
					str += "0"+ ubyte.toString(16);// +":";	
				}else
				{
					str += ubyte.toString(16);// +":";
				}
				
			}
			log(str.toUpperCase());
			ba.position = 0;
		}
		
		
		/*
		public function getOutTransOld(transHash:ByteArray, spot:uint):OutVO
		{
			//var hashStr:String = ByteArrayUtil.toHexString(transHash);
			//log("looking for trans :", hashStr, "spot:", spot);
			var raw_tx_reversed:ByteArray = reverseByteAry(transHash);
			//log("out hash for looking up online:", ByteArrayUtil.toHexString(raw_tx_reversed));
			var hashStr:String = ByteArrayUtil.toHexString(raw_tx_reversed);
			
			var transRecord:File = TRANSFOLDER.resolvePath(hashStr.substr(0,2) + ".dat");
			if(transRecord.exists == false)
			{
				log("oops, trans problem");
				return null;
			}
			var recordSize:uint = (1 + 32 + 4 + 4 + 4 + 4);//used, hash, blockNum,  trans start, total outs, total outs uesed
			var storedTrans:uint = transRecord.size / recordSize;
			var i:uint;
			var j:uint;
			var fs:FileStream = new FileStream();
			fs.open(transRecord, FileMode.READ);
			for(i = 0;i<storedTrans;++i)
			{
				fs.position = i * recordSize;
				var used:uint = fs.readByte();
				if(used == 0)
				{
					for(j = 0;j<32;++j)
					{
						var testbyte:uint = fs.readUnsignedByte();
						var hashbyte:uint = raw_tx_reversed[j];
						if(testbyte != hashbyte)
						{
							break;
						}else if(j == 31)
						{
							var blockNum:uint = fs.readUnsignedInt();
							log("Found it. Trans is in block:", blockNum, "rotated:", this.rotateBytes(blockNum) );
							//start
							var startPos:uint = fs.readUnsignedInt();
							//total Outs
							var totalOuts:uint = fs.readUnsignedInt();
							//total Outs used
							var usedOuts:uint = fs.readUnsignedInt();
							fs.close();
							
							var bname:String = getBlockName(rotateBytes(blockNum), false);
							var bfile:File = mainDirectory.resolvePath(bname);
							if(!bfile.exists)
							{
								log("Crap, should have block");
							}
							var theWhileBlock:ByteArray = new ByteArray();
							var fs2:FileStream = new FileStream();
							fs2.open(bfile, FileMode.READ);
							fs2.readBytes(theWhileBlock);
							fs2.close();
							
							var transBytes:ByteArray = new ByteArray();
							transBytes.writeBytes(theWhileBlock, startPos);
							transBytes.position = 0;

							var trans:txVO = this.getTxn(transBytes, false,0,0,false);
							return trans._out[spot];
							
							
						}
					}					
				}
			}
			return null;
		}
		*/
		
		/*
		public function saveTrans(hashStr:String, blockNum:uint, start:uint, outs:uint):void
		{
			
			//get the right file
			var transRecord:File = TRANSFOLDER.resolvePath(hashStr.substr(0,2) + ".dat");
			if(transRecord.exists == false)
			{
				log("oops, trans problem");
				return;
			}
			var fs:FileStream = new FileStream();
			fs.open(transRecord, FileMode.APPEND);
			//transaction has not be used
			fs.writeByte(0);
			//hash of transaction
			fs.writeBytes(ByteArrayUtil.fromHexString(hashStr));
			//block number
			fs.writeUnsignedInt(blockNum);
			//start
			fs.writeUnsignedInt(start);
			//total Outs
			fs.writeUnsignedInt(outs);
			//total Outs used
			fs.writeUnsignedInt(0);
			
			fs.close();
		}
		*/
		public function saveOut(blockNum:uint, txNum:uint, txHash:ByteArray, outIndex:uint, outvo:OutVO):void
		{
			var outrec:OutRecord = new OutRecord();
			var recordHash:ByteArray = OutRecord.recordIDHash(txHash, outIndex);
			var recoredStr:String = ByteArrayUtil.toHexString(recordHash);
			log("saveOut", ByteArrayUtil.toHexString(txHash),"index:", outIndex, "recordid",recoredStr );
			
			outrec.used = false;
			outrec.recordIDhash = recordHash;
			outrec.blockNum = blockNum;
			outrec.txNum = txNum;
			outrec.outNum = outIndex;
			outrec.outStart = outvo.byteStart;
			
			outrec.valueBytes =  outvo.value;
			
			//var raw_tx_reversed:ByteArray = reverseByteAry(txHash);
			//to see if a input is good, all we get is the hash of the trans, and the output spot. so we
			//combine transHash and output get a hash used for lookup purposes. 
			//log("SaveOut trans:", ByteArrayUtil.toHexString(raw_tx_reversed));
			var transRecord:File = TRANSFOLDER.resolvePath(recoredStr.substr(0,2) + ".dat");
			if(transRecord.exists == false)
			{
				log("oops, trans problem");
				return;
			}
			var fs:FileStream = new FileStream();
			fs.open(transRecord, FileMode.APPEND);
			fs.writeBytes(outrec.getBytes());
			fs.close();
			
		}
		public function getBlockByNumber(blockNum:uint):BlockVO
		{
			var blockCount:uint = blockFile.size / 32;
			if(blockNum > blockCount)
			{
				return null;
				
			}
			var bname:String = getBlockName(rotateBytes(blockNum), false);
			var bfile:File = BitCoinUtil.mainDirectory.resolvePath(bname);
			if(!bfile.exists)
			{
				log("Crap, should have block");
			}
			var thewholeBlock:ByteArray = new ByteArray();
			var fs2:FileStream = new FileStream();
			fs2.open(bfile, FileMode.READ);
			fs2.readBytes(thewholeBlock);
			fs2.close();
			var block:BlockVO = gotBlock(thewholeBlock,false);
			block.blockNum = blockNum;
			
			return block;
		}
		public function validateTrans(tx:txVO):Boolean
		{
			var valid:Boolean = true;
			//need to finish
			var i:uint = 0;
			//we don't validate on coinbase in
			if(tx.indexInBlock != 0)
			{
				for(i = i;i<tx.vin_sz;++i)
				{
					//all first trans in a block have no input
					valid = transCon.evalInput(tx, i);
					if(valid == false)
					{
						return valid;
					}
				}
			}
			return valid;
		}
		public function scanBlockForUS(block:BlockVO):void
		{
			var i:uint;
			for(i = 0;i<block.txns.length;++i)
			{
				var HasAnOutForUs:Boolean = transIsForUs(block.txns[i]);
				var HasAnInForUs:Boolean = transIsFromUs(block.txns[i]);
			}
		}
		
		
		public function transIsForUs(txs:txVO):Boolean
		{
			var i:uint;
			var j:uint;
			
			var outvo:OutVO;
			var invo:InVO;
			var outScript:ByteArray;
			var publicKey:ByteArray;
			var hasAnOutForUs:Boolean = false;
			
			for(i=0;i<keys.length;++i)
			{
				//publicKey = publicKeys[i];
				publicKey = addressCon.getUnAddress(fullAddress[i]);
				
				for(j=0;j<txs._out.length;++j)
				{
					outvo = txs._out[j];
					outScript = outvo.scriptPubKey;
					//log("out script", ByteArrayUtil.toHexString(outScript));
					if(seeIfByteArrayContainsOtherArray(outScript, publicKey))
					{
							hasAnOutForUs = true;
							saveOutForUs(txs, j);	
					}
				}
			}
			
			
			
			
			return hasAnOutForUs;
		}
		
		public function seeIfByteArrayContainsOtherArray(ba1:ByteArray, ba2:ByteArray):Boolean
		{
			if(ba2.length > ba1.length)return false;
			
			var matchCount:uint = 0;
			var testi:uint = 0;
			for(var i:uint=0;i<ba1.length;++i)
			{
				testi = i;
				for(var j:uint=0;j<ba2.length;++j)
				{
					
					if(ba1[testi] == ba2[j])
					{
						matchCount++;
						++testi;
						if(matchCount == ba2.length)
						{
							return true;
						}
					}else
					{
						break;
						matchCount = 0;
					}
				}
			}
			return false;	
		}
		public function saveOutForUs(tx:txVO, outSpot:uint):void
		{
			//check to see if it's already recorded
			var spot:int = hasRecord(tx.hash, outSpot);
			if(spot != -1)
			{
				log("already has record");
				return;
			}	
			
			var outrec:OutRecord = new OutRecord();
			var recordHash:ByteArray = OutRecord.recordIDHash(tx.hash, outSpot);
			var recoredStr:String = ByteArrayUtil.toHexString(recordHash);
			log("Saving for us", ByteArrayUtil.toHexString(tx.hash),"index:", outSpot, "recordid",recoredStr );
			var outvo:OutVO = tx._out[outSpot];
			outrec.used = false;
			outrec.recordIDhash = recordHash;
			outrec.blockNum = tx.includedInBlock;
			outrec.txNum = tx.indexInBlock;
			outrec.outNum = outSpot;
			outrec.outStart = outvo.byteStart;
			
			outrec.valueBytes =  outvo.value;
			
			var fs:FileStream = new FileStream();
			fs.open(TRANSLOG, FileMode.APPEND);
			
			fs.writeBytes(outrec.getBytes());
			fs.close();
		}
		public function transIsFromUs(tx:txVO):Boolean
		{
			
			var i:uint;
			var j:uint;
			
			var outrec:OutRecord = new OutRecord();
			var recordHash:ByteArray;
			var invo:InVO;
			var fs:FileStream = new FileStream();
			var translog:ByteArray = new ByteArray();
			
			if(TRANSLOG == null || TRANSLOG.exists == false)return false;
			
			fs.open(TRANSLOG, FileMode.READ);
			fs.readBytes(translog);
			fs.close();
			var totalRecords:uint = translog.length / OutRecord.defaultRecordSize;
			var usedByte:uint;
			
			
			for(i = 0;i<tx._in.length;++i)
			{
				invo = tx._in[i];
				
				var spot:int = hasRecord(tx.hash, i);
				if(spot != -1)
				{
					log("hash record");
					
				}	
			}
			log("no match");
			
			//first we need to find the out put
			return false;
		}
		//if not found retorn -1 other wise return the spot
		public function hasRecord(hash:ByteArray, spot:uint):int
		{
			var i:uint;
			var j:uint;
			if(TRANSLOG.exists == false)return -1;
			
			
			var outrec:OutRecord = new OutRecord();
			var recordHash:ByteArray;
			var invo:InVO;
			var fs:FileStream = new FileStream();
			var translog:ByteArray = new ByteArray();
			fs.open(TRANSLOG, FileMode.READ);
			fs.readBytes(translog);
			fs.close();
			var totalRecords:uint = translog.length / OutRecord.defaultRecordSize;
			var usedByte:uint;
			
			recordHash = OutRecord.recordIDHash(hash, i);
			for(j = 0;j<totalRecords;++j)
			{
				translog.position = j * OutRecord.defaultRecordSize;
				usedByte = translog.readUnsignedByte();
				if(usedByte == 0)
				{
					var startSpot:uint = translog.position;
					var recordIdHash:ByteArray = this.getNextbytes(translog, 32);
					log("stored:", ByteArrayUtil.toHexString(recordIdHash), "used in tx:",  ByteArrayUtil.toHexString(recordHash));
					if(ByteArrayUtil.isEqual(recordIdHash, recordHash))
					{
						log("we found a match");
						return startSpot;
					}
				}
				
			}
			return -1;	
			
		}
		public function getOutToSpend(tx:txVO,outsUsed:Vector.<OutVO>, amount:BigInteger, markAsSpent:Boolean):BigInteger
		{
			var i:uint;
			var j:uint;
			if(TRANSLOG.exists == false)return BigInteger.ZERO;
			
			var outrecord:OutRecord;
			
			var fs:FileStream = new FileStream();
			var translog:ByteArray = new ByteArray();
			fs.open(TRANSLOG, FileMode.READ);
			fs.readBytes(translog);
			fs.close();
			var totalRecords:uint = translog.length / OutRecord.defaultRecordSize;
			var usedByte:uint;
			
			
			var totalGathered:BigInteger = new BigInteger(0, true);
			var recordCount:uint = 0;
			
			
			while(totalGathered < amount && recordCount < totalRecords)
			{
				translog.position = recordCount * OutRecord.defaultRecordSize;
				var rec:ByteArray = this.getNextbytes(translog, OutRecord.defaultRecordSize);
				outrecord = new OutRecord();
				outrecord.fromBytes(rec);
				
				if(outrecord.used == false)
				{
					//we can use it
					
					var block:BlockVO = this.getBlockByNumber(outrecord.blockNum);
					var txvo:txVO = block.txns[outrecord.txNum];
					var outvo:OutVO = txvo._out[outrecord.outNum];
					outsUsed.push(outvo);
					
					var invo:InVO = new InVO();
					invo.prev_out.hash = ByteArrayUtil.copy(txvo.hash);
					invo.prev_out.n = outrecord.outNum;
					tx._in.push(invo);
					totalGathered.add(outrecord.value);
					//seems like there should be more
					
					
				}
				
			}
			return totalGathered;
			
		}
		public function getBlockHeight():uint
		{
			
			return blockFile.size/32;
			
		}
		public function getPeerAddress():IPPort
		{
			var ip:IPPort = new IPPort();
			if(adderFile.exists == false)
			{
				if(testnet)
				{
					//this is a testnet faucet
					//ip.ip = "54.243.211.176";
					//ip.ip = "127.0.0.1";
					//ip.ip = "192.168.1.126";
					//ip.ip = "192.168.1.103";
					//ip.ip = Math.random() > 0.5?   "192.168.1.103":"192.168.1.126";
					//ip.ip = "54.243.211.176";
					ip.ip = "192.168.1.100";
					
					ip.port = 18333;
					
				}else
				{
					var ran:uint = Math.floor( seedIPs.length * Math.random());
					ip.ip = seedIPs[ran];
					ip.port = 8333;
					
					//ip.ip = "192.168.1.127";
					ip.ip = "64.53.128.12";
					//ip.port = 8333;
					
				}
				
			}
			return ip;
		}
		public function getFilterLoad():ByteArray
		{
			const LN2SQUARED:Number = 0.4804530139182014246671025263266649717305529515945455;
			const LN2:Number = 0.6931471805599453094172321214581765680755001343602552;
			
			var MAX_HASH_FUNCS:uint = 50;
			var MAX_FILTER_SIZE:uint = 36000;
			
			//for test 3, 0.01, 0,
			
			var elements:int = 3;// 100;
			var falsePositiveRate:Number = 0.01;// 0.2;
			var randomNonce:uint = 0;// 0xFFFFFFFF * Math.random();
			var updateFlag:uint = 2;// 0x02;
			
			var size:int = Math.min((-1  / (Math.pow(Math.log(2), 2)) * elements * Math.log(falsePositiveRate)),MAX_FILTER_SIZE * 8) / 8;// = 41
			trace("Filter size:",size);
			var data:ByteArray = new ByteArray();
			data.length = (size <= 0 ? 1 : size);
			// Optimal number of hash functions for a given filter size and element count.
			var nHashFuncs:uint = Math.min(size * 8 / elements * LN2);
			var hashFuncs:uint = Math.min((data.length * 8 / elements * Math.log(2)), MAX_HASH_FUNCS); // = 2.27
			var nTweak:uint = randomNonce;
			trace("hashFuncs:", hashFuncs, "nTweak:", nTweak);
			var pay:ByteArray = ByteArrayUtil.fromHexString("99108ad8ed9bb6274d3980bab5a85c048f0950c8");//6461EF4D3FC6D450B2305D037997C7A1C0788F9E");
			//var pay:ByteArray = new ByteArray();// 
			//pay.writeUTFBytes("I will not buy this record, it is scratched.");
			
		 	//var bit_mask:Array = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80];
			var bit_mask:ByteArray =ByteArrayUtil.fromHexString("0102040810204080");
			
			var merhash:MurHash = new MurHash();
			
			/*
			
			public var publicKeys:Vector.<ByteArray> = new Vector.<ByteArray>();
			public var fullAddress:Vector.<String> = new Vector.<String>();
			*/
			
			var testAry:Vector.<ByteArray> = new Vector.<ByteArray>();
			pay = ByteArrayUtil.fromHexString("99108ad8ed9bb6274d3980bab5a85c048f0950c8");
			testAry.push(pay);
			pay = ByteArrayUtil.fromHexString("b5a2c786d9ef4658287ced5914b37a1b4aa32eee");
			testAry.push(pay);
			pay = ByteArrayUtil.fromHexString("b9300670b4c5366e95b2699e8b18bc75e5f729c5");
			testAry.push(pay);
			//should eqal 03614e9b050000000000000001
			//03
			//614e9b <- filter
			//05000000
			//00000000
			//01
			//var key1:ByteArray =ByteArrayUtil.tByteArrayFromAry([0xed, 0x53, 0xc4, 0xa5,0x3b, 0x1b, 0xbd, 0xc2,0x52, 0x7d, 0xc3, 0xef,0x53, 0x5f, 0xae, 0x3b]);
			//var testkey:ByteArray = ByteArrayUtil.fromHexString("99108ad8ed9bb6274d3980bab5a85c048f0950c8");
			
			//var str:String = merhash.murmur3("99108ad8ed9bb6274d3980bab5a85c048f0950c8",0);
			
			//trace("Winner?:", str,merhash.hash32(testAry[0],0).toString(16), ",",  merhash.hash(testAry[0], 0).toString(16), " = 28BBD0A8 JS = ");
			//return new ByteArray();
			
			var nIndex:uint;
			
			for (var i:uint = 0; i < testAry.length; i++)
			{
				pay = testAry[i];
				for (var j:uint = 0; j < hashFuncs; j++)
				{
					var seed:uint = (j * 0xFBA4C795 + nTweak) & 0xFFFFFFFF;
					// nIndex =  merhash.hash( pay, seed);//  % (size * 8);
					//nIndex = merhash.hash32(pay,seed);
					nIndex = merhash.MurmurHash3(ByteArrayUtil.toVector( pay),seed);
					
					nIndex = nIndex & 0xFFFFFFFF;
					nIndex = nIndex % (size * 8);
					
					
					// Sets bit nIndex of vData
					
					data[nIndex >> 3] |= bit_mask[7 & nIndex];
					//trace(byteArrayToBinaryString(data));
					
				}
			}
			trace(byteArrayToBinaryString(data));
			
			trace(byteArrayToBinaryString(ByteArrayUtil.fromHexString("614e9b")), "<- should be");
			/*
			for (var i:uint = 0; i < publicKeys.length; i++)
			{
				pay = publicKeys[i];
				for (var j:uint = 0; j < hashFuncs; j++)
				{
					var nIndex:uint = merhash.hash(j, pay, nTweak, data.length) % (size * 8);
					//var nIndex2:uint = merhash.hash32(pay,j * 0xFBA4C795 + nTweak) % (size * 8);
					// Sets bit nIndex of vData
					data[nIndex >> 3] |= bit_mask[7 & nIndex];
				}
			}
			*/
			/*
			for (var j:uint = 0; j < hashFuncs; j++)
			{
				var nIndex:uint = merhash.hash(j, pay, nTweak, data.length) % (size * 8);
				//var nIndex2:uint = merhash.hash32(pay,j * 0xFBA4C795 + nTweak) % (size * 8);
				// Sets bit nIndex of vData
				data[nIndex >> 3] |= bit_mask[7 & nIndex];
			}
			*/
			trace("filter:", ByteArrayUtil.toHexString(data), " should be 614e9b");
			
			
			pay = new ByteArray();
			var sizeOfFilter:ByteArray = getVeribleIntBytes(data.length);
			//log("Get data number of INVS:", ByteArrayUtil.toHexString(numberOfinvs));
			pay.writeBytes(sizeOfFilter);
			pay.writeBytes(data);
			pay.writeUnsignedInt(rotateBytes(hashFuncs));
			pay.writeUnsignedInt(rotateBytes(nTweak));
			pay.writeByte(updateFlag);
			
			
			//for dev
			pay = ByteArrayUtil.fromHexString("81E07F0C213161460800A48000A7FACA041A3E4B140000002222222202");
			
			var ba:ByteArray = getGenMessage("filterload", pay);
			trace("full filter msg:", ByteArrayUtil.toHexString(ba));
			
			return ba;
			
			
			
		}
		public function getMemPool():ByteArray
		{
			var pay:ByteArray = new ByteArray();
			var ba:ByteArray = getGenMessage("mempool", pay);
			return ba;
		}
		// String Padding function
		private	function padString(str:String, len:int, char:String, padLeft:Boolean = true):String{
				// get no of padding characters needed
				var padLength:int = len - str.length;
				
				// padding string
				var str_padding:String = "";
				
				// loop from 0 to no of padding characters needed
				// Note: this loop will not run if padLength is less than 1 
				// as i < padLength will be false from begining
				for(var i:int = 0; i < padLength; i++)
					str_padding += char;
				
				// return string with padding attached either to left or right depending on the padLeft Boolean
				return (padLeft ? str_padding : "") + str + (!padLeft ? str_padding: "");
			}
		
		// Return a Binary String Representation of a byte Array
		private function byteArrayToBinaryString(bArray:ByteArray):String{
			// binary string to return
			var str:String = "";
			
			// store length so that it is not recomputed on every loop
			var aLen:uint = bArray.length;
			
			// loop over all available bytes and concatenate the padded string to return string
			for(var i:int = 0; i < aLen; i++)
				str += padString(bArray[i].toString(2), 8, "0");
			
			// return binary string
			return str;
		}
		//////////////////////////
		public function gotMerkleblock(pay:ByteArray):void
		{
			log("merkleblock version:" ,  rotateBytes( pay.readUnsignedInt()));
			//rotateBytes( pay.readUnsignedInt())
			
			var ba:ByteArray = new ByteArray();
			ba.writeBytes(pay,pay.position, 32);
			pay.position += 32;
			log("merkleblock previous block:" ,ByteArrayUtil.toHexString(ba));
			ba = new ByteArray();
			ba.writeBytes(pay,pay.position, 32);
			pay.position += 32;
			
			log("merkleblock murkle root:" + ByteArrayUtil.toHexString(ba));
			
			//rotateBytes( pay.readUnsignedInt())
			log("merkleblock timestamp:" +  rotateBytes( pay.readUnsignedInt()));
			
			//rotateBytes( pay.readUnsignedInt())
			log("merkleblock bits:" +  rotateBytes( pay.readUnsignedInt()));
			
			//rotateBytes( pay.readUnsignedInt())
			log("merkleblock nounce	:" +  rotateBytes( pay.readUnsignedInt()));
			
			var totalTxs:uint =  rotateBytes( pay.readUnsignedInt());
			log("merkleblock total Transactions:" +totalTxs );
			
			var len:uint = this.getIntLength(pay);
			if(len == 1)return;
			log("merkleblock sent txs:", len);
			
			for(var i:uint = 0;i<len;++i)
			{
				
				ba = new ByteArray();
				ba.writeBytes(pay,pay.position, 32);
				pay.position += 32;
				log("merkleblock tx hash:" + ByteArrayUtil.toHexString(ba));
				
			}
			len = this.getIntLength(pay);
			log("merkleblock num of flags:", len);
			
			for(i = 0;i<len;++i)
			{
				log("merkleblock flag:" +   pay.readUnsignedByte(), "left:", pay.bytesAvailable);
				
				
			}
			
			
		}

	}
}






















