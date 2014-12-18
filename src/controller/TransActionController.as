package controller
{
	import com.adobe.crypto.SHA256;
	import com.hurlant.util.der.DER;
	import com.hurlant.util.der.IAsn1Type;
	import com.hurlant.util.der.Integer;
	
	import flame.crypto.ECCParameters;
	import flame.crypto.ECDSA;
	import flame.crypto.ECPoint;
	import flame.crypto.RIPEMD160;
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import model.BlockVO;
	import model.InVO;
	import model.OutPointVO;
	import model.OutRecord;
	import model.OutVO;
	import model.txVO;

	public class TransActionController
	{
		
		public var btil:BitCoinUtil;
		
		public const SCRIPT_VERIFY_NONE:uint = 0;
		public const SCRIPT_VERIFY_P2SH:uint = (1 << 0);
		public const SCRIPT_VERIFY_STRICTENC:uint = (1 << 1);
		private var SIGHASH_ALL:uint = 1;
		private var SIGHASH_NONE:uint = 2;
		private var SIGHASH_SINGLE:uint = 3;
		private var SIGHASH_ANYONECANPAY:uint = 0x80;
		
		
		
		
		//enum txnouttype
		//{
		private var TX_NONSTANDARD:uint = 0;
		// 'standard' transaction types:
		private var TX_PUBKEY:uint = 0;
		private var TX_PUBKEYHASH:uint = 0;
		private var TX_SCRIPTHASH:uint = 0;
		private var TX_MULTISIG:uint = 0;
		//};
		//opcodetype 
		// push value
		public const OP_0:uint = 0x00;
		public const OP_FALSE:uint = OP_0;
		public const OP_PUSHDATA1:uint = 0x4c;
		public const OP_PUSHDATA2:uint = 0x4d;
		public const OP_PUSHDATA4:uint = 0x4e;
		public const OP_1NEGATE:uint = 0x4f;
		public const OP_RESERVED:uint = 0x50;
		public const OP_1:uint = 0x51;
		public const OP_TRUE:uint=OP_1;
		public const OP_2:uint = 0x52;
		public const OP_3:uint = 0x53;
		public const OP_4:uint = 0x54;
		public const OP_5:uint = 0x55;
		public const OP_6:uint = 0x56;
		public const OP_7:uint = 0x57;
		public const OP_8:uint = 0x58;
		public const OP_9:uint = 0x59;
		public const OP_10:uint = 0x5a;
		public const OP_11:uint = 0x5b;
		public const OP_12:uint = 0x5c;
		public const OP_13:uint = 0x5d;
		public const OP_14:uint = 0x5e;
		public const OP_15:uint = 0x5f;
		public const OP_16:uint = 0x60;
		
		// control
		public const OP_NOP:uint = 0x61;
		public const OP_VER:uint = 0x62;
		public const OP_IF:uint = 0x63;
		public const OP_NOTIF:uint = 0x64;
		public const OP_VERIF:uint = 0x65;
		public const OP_VERNOTIF:uint = 0x66;
		public const OP_ELSE:uint = 0x67;
		public const OP_ENDIF:uint = 0x68;
		public const OP_VERIFY:uint = 0x69;
		public const OP_RETURN:uint = 0x6a;
		
		// stack ops
		public const OP_TOALTSTACK:uint = 0x6b;
		public const OP_FROMALTSTACK:uint = 0x6c;
		public const OP_2DROP:uint = 0x6d;
		public const OP_2DUP:uint = 0x6e;
		public const OP_3DUP:uint = 0x6f;
		public const OP_2OVER:uint = 0x70;
		public const OP_2ROT:uint = 0x71;
		public const OP_2SWAP:uint = 0x72;
		public const OP_IFDUP:uint = 0x73;
		public const OP_DEPTH:uint = 0x74;
		public const OP_DROP:uint = 0x75;
		public const OP_DUP:uint = 0x76;
		public const OP_NIP:uint = 0x77;
		public const OP_OVER:uint = 0x78;
		public const OP_PICK:uint = 0x79;
		public const OP_ROLL:uint = 0x7a;
		public const OP_ROT:uint = 0x7b;
		public const OP_SWAP:uint = 0x7c;
		public const OP_TUCK:uint = 0x7d;
		
		// splice ops
		public const OP_CAT:uint = 0x7e;
		public const OP_SUBSTR:uint = 0x7f;
		public const OP_LEFT:uint = 0x80;
		public const OP_RIGHT:uint = 0x81;
		public const OP_SIZE:uint = 0x82;
		
		// bit logic
		public const OP_INVERT:uint = 0x83;
		public const OP_AND:uint = 0x84;
		public const OP_OR:uint = 0x85;
		public const OP_XOR:uint = 0x86;
		public const OP_EQUAL:uint = 0x87;
		public const OP_EQUALVERIFY:uint = 0x88;
		public const OP_RESERVED1:uint = 0x89;
		public const OP_RESERVED2:uint = 0x8a;
		
		// numeric
		public const OP_1ADD:uint = 0x8b;
		public const OP_1SUB:uint = 0x8c;
		public const OP_2MUL:uint = 0x8d;
		public const OP_2DIV:uint = 0x8e;
		public const OP_NEGATE:uint = 0x8f;
		public const OP_ABS:uint = 0x90;
		public const OP_NOT:uint = 0x91;
		public const OP_0NOTEQUAL:uint = 0x92;
		
		public const OP_ADD:uint = 0x93;
		public const OP_SUB:uint = 0x94;
		public const OP_MUL:uint = 0x95;
		public const OP_DIV:uint = 0x96;
		public const OP_MOD:uint = 0x97;
		public const OP_LSHIFT:uint = 0x98;
		public const OP_RSHIFT:uint = 0x99;
		
		public const OP_BOOLAND:uint = 0x9a;
		public const OP_BOOLOR:uint = 0x9b;
		public const OP_NUMEQUAL:uint = 0x9c;
		public const OP_NUMEQUALVERIFY:uint = 0x9d;
		public const OP_NUMNOTEQUAL:uint = 0x9e;
		public const OP_LESSTHAN:uint = 0x9f;
		public const OP_GREATERTHAN:uint = 0xa0;
		public const OP_LESSTHANOREQUAL:uint = 0xa1;
		public const OP_GREATERTHANOREQUAL:uint = 0xa2;
		public const OP_MIN:uint = 0xa3;
		public const OP_MAX:uint = 0xa4;
		public const OP_WITHIN:uint = 0xa5;
		// crypto
		public const OP_RIPEMD160:uint = 0xa6;
		public const OP_SHA1:uint = 0xa7;
		public const OP_SHA256:uint = 0xa8;
		public const OP_HASH160:uint = 0xa9;
		public const OP_HASH256:uint = 0xaa;
		public const OP_CODESEPARATOR:uint = 0xab;
		public const OP_CHECKSIG:uint = 0xac;
		public const OP_CHECKSIGVERIFY:uint = 0xad;
		public const OP_CHECKMULTISIG:uint = 0xae;
		public const OP_CHECKMULTISIGVERIFY:uint = 0xaf;
		// expansion
		public const OP_NOP1:uint = 0xb0;
		public const OP_NOP2:uint = 0xb1;
		public const OP_NOP3:uint = 0xb2;
		public const OP_NOP4:uint = 0xb3;
		public const OP_NOP5:uint = 0xb4;
		public const OP_NOP6:uint = 0xb5;
		public const OP_NOP7:uint = 0xb6;
		public const OP_NOP8:uint = 0xb7;
		public const OP_NOP9:uint = 0xb8;
		public const OP_NOP10:uint = 0xb9;
		// template matching params
		public const OP_SMALLINTEGER:uint = 0xfa;
		public const OP_PUBKEYS:uint = 0xfb;
		public const OP_PUBKEYHASH:uint = 0xfd;
		public const OP_PUBKEY:uint = 0xfe;
		public const OP_INVALIDOPCODE:uint = 0xff;
		
		
		
		public function TransActionController()
		{
			
		}
		public function sendMoneyTo(bitAddress:String, amount:BigInteger):Boolean
		{
			var tx:txVO = new txVO();
			//var totalGathered:BigInteger =  btil.getOutToSpend();
			
			
			 
			return true;
		}
		public function getFeesInBlock(block:BlockVO):BigInteger
		{
			var sum:BigInteger = new BigInteger(0, true);
			//we start at block 1 because block 0 is generation block. coinbase
			for(var i:uint = 1;i<block.n_tx;++i)
			{
				sum.add(getFeesInTransaction(block.txns[i]));
			}
			return sum;
		}
		public function getFeesInTransaction(tx:txVO):BigInteger
		{
			var fees:BigInteger = new BigInteger(0, true);
			var totallIn:BigInteger = new BigInteger(0, true);
			var totallOut:BigInteger = new BigInteger(0, true);
			var i:uint = 0;
			for(i = 0;i<tx.vin_sz;++i)
			{
				var txin:InVO = tx._in[i];
				var transHash:ByteArray = txin.prev_out.hash;
				var spot:uint = txin.prev_out.n;
				
				var outrecord:OutRecord = getOutRecord(transHash, spot);
				if(outrecord == null)
				{
					trace("Didn't find the out");
					return null;
				}
				  
				trace("BlockNum:",outrecord.blockNum, "Startpos:", outrecord.outStart, "outNum:", outrecord.outNum, "Values:", outrecord.value.toString());
				totallIn.add(outrecord.value);
			}
			//do the outs now
			for(i = 0;i<tx.vin_sz;++i)
			{
				var outvo:OutVO = tx._out[i];
				var outValue:BigInteger = new BigInteger(btil.reverseByteAry( outvo.value ), true);
				totallOut.add(outValue);
			}
			
			fees = totallIn.subtract(totallOut);
			
			trace("this is total in:", totallIn.toString(10));
			
			return fees;
		}
		public function evalInput(trans:txVO, inputToTest:uint):Boolean
		{
			
			var inVO:InVO = trans._in[inputToTest];
		//	trace("in signature length:", inVO.signature_script.length, ByteArrayUtil.toHexString(inVO.signature_script));
			var prevOutVO:OutVO = getOutTrans(inVO.prev_out.hash, inVO.prev_out.n);
			if(prevOutVO == null)
			{
				trace("nuts");
				return false;
			}
			//trace("prev out script Length:", prevOutVO.scriptPubKey.length, ByteArrayUtil.toHexString(prevOutVO.scriptPubKey));
			var topItem:ByteArray;
			var nextTopItem:ByteArray;
			
			var stack:Vector.<ByteArray> = new Vector.<ByteArray>();
			//step one add signiture and public key to together
			var script:ByteArray = ByteArrayUtil.copy(inVO.signature_script);
			script.position = script.length;
			script.writeBytes(ByteArrayUtil.copy(prevOutVO.scriptPubKey));
			//where do I get public key 
		//	trace("final Script Length:", script.length, ByteArrayUtil.toHexString(script));
			script.position = 0;
			
			if (script.length > 10000)
				return false;
			
			var nOpCount:uint = 0;
			var pc:uint = 0;
			var pend:uint = script.length;
			var opcode:uint;
			var i:uint;
			var lastOPCodeSeperator:uint = 0;
			var stackItem:ByteArray;
			while (pc < pend)
			{
				opcode = script.readUnsignedByte();
				trace("opcode:", opcode.toString(16));
				pc++;
				
				
				if (opcode >= 0x01 && opcode <= 0x4b)
				{
					
					//push data onto the stack
					stackItem = new ByteArray();
					for(i = 0;i<opcode;++i)
					{
						stackItem.writeByte(script.readUnsignedByte());
						pc++;
					}
				//	trace("Adding stckItem:", ByteArrayUtil.toHexString(stackItem));
					stack.push(stackItem);
				}else if( opcode == OP_0)
				{
					//An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)
					stack.push(new ByteArray());
				}else if( opcode == OP_PUSHDATA1)
				{
					//the next byte contains the number of bytes to be pushed onto the stack.
					var amount:uint = script.readUnsignedByte();
				//	trace("OP_PUSHDATA1:", amount);
					pc++;
					stackItem = new ByteArray();
					for(i = 0;i<amount;++i)
					{
						stackItem.writeByte(script.readUnsignedByte());
						pc++;
					}
					
					
					stack.push(stackItem);
				}
				else if(opcode == OP_DUP)
				{
					//trace("OP_DUP 0x76");
					//Duplicates the top stack item.
					var dup:ByteArray = ByteArrayUtil.copy(stack[stack.length-1]);
					stack.push(dup);
				}
				else if(opcode == OP_HASH160)
				{
					//The input is hashed twice: first with SHA-256 and then with RIPEMD-160.
					var topitem:ByteArray = stack.pop();
					var ripme:RIPEMD160 = new RIPEMD160();
					
					SHA256.hashBytes(topitem);
					var hashedItem:ByteArray = ripme.computeHash(SHA256.digest);
					//trace("OP_HASH160:", ByteArrayUtil.toHexString(hashedItem));
					
					stack.push(hashedItem);
					
				}else if(opcode == OP_EQUAL)
				{
					//trace("OP_EQUAL");
					//Same as OP_EQUAL, but runs OP_VERIFY afterward.
					topItem = stack.pop();
					nextTopItem = stack.pop();
					//trace(ByteArrayUtil.toHexString(topItem) , ByteArrayUtil.toHexString(nextTopItem));
					var resultbyte:uint = (ByteArrayUtil.toHexString(topItem) == ByteArrayUtil.toHexString(nextTopItem))? 1:0;
					var resultBytes:ByteArray = new ByteArray();
					resultBytes.writeByte(resultbyte);
					stack.push(resultBytes);
					
					
				}
				else if(opcode == OP_EQUALVERIFY)
				{
					//trace("OP_EQUALVERIFY");
					//Same as OP_EQUAL, but runs OP_VERIFY afterward.
					topItem = stack.pop();
					nextTopItem = stack.pop();
					//trace(ByteArrayUtil.toHexString(topItem) , ByteArrayUtil.toHexString(nextTopItem));
					if(ByteArrayUtil.toHexString(topItem) != ByteArrayUtil.toHexString(nextTopItem))
					{
						trace("not good, does not veryify");
					}else
					{
						//now the verify
						//Marks transaction as invalid if top stack value is not true. True is removed, but false is not.
						trace("IS good");
					}
					
				}else if(opcode == OP_CODESEPARATOR)
				{
					lastOPCodeSeperator = pc;
				}
				else if(opcode == OP_CHECKSIG)
				{
					if(stack.length < 2)
					{
						return false;
					}
					
					//step one,the public key and the signature are popped from the stack, in that order. 
					//If the hash-type value is 0, then it is replaced by the last_byte of the signature. Then the last byte of the signature is always deleted.
					var pubKey:ByteArray = stack.pop();
					var sig:ByteArray = stack.pop();
					
					//trace("this is sig:", ByteArrayUtil.toHexString(sig));
					var lastByte:uint = sig[sig.length-1];
					var trimmedSig:ByteArray = new ByteArray();
					trimmedSig.writeBytes(sig, 0, sig.length-1);
					//trace("this is trimmedSig:", ByteArrayUtil.toHexString(trimmedSig));
					//A new subscript is created from the instruction from the most recently parsed OP_CODESEPARATOR 
					//(last one in script) to the end of the script. 
					//If there is no OP_CODESEPARATOR the entire script becomes the subscript (hereby referred to as subScript)
					var temp:ByteArray;
					
					var subScript:ByteArray = ByteArrayUtil.copy(prevOutVO.scriptPubKey);
					temp = new ByteArray();
					temp.writeBytes(subScript, lastOPCodeSeperator);
					subScript = temp;
					
					//The sig is deleted from subScript.
					//this is not normal to have present
					
					//All OP_CODESEPARATORS are removed from subScript
					temp = new ByteArray();
					for(i = 0;i< subScript.length;++i)
					{
						if(subScript[i] != OP_CODESEPARATOR)
						{
							
							temp.writeByte(subScript[i]);
						}else
						{
							temp.writeByte(subScript[i]);
							//trace("Has code seperator? - need to figure out what to do here");
						}
					}
					subScript = temp;
					//trace("Subscript from prev:", ByteArrayUtil.toHexString(subScript));
					
					//The hashtype is removed from the last byte of the sig and stored
					//A copy is made of the current transaction (hereby referred to txCopy)
					//The scripts for all transaction inputs in txCopy are set to empty scripts (exactly 1 byte 0x00)
					var txCopy:ByteArray = btil.txToByteArry(trans, true);
					txCopy.position = 0;
					
					//The script for the current transaction input in txCopy is set to subScript (lead in by its length as a var-integer encoded!)
					var txtCopy:txVO = btil.getTxn(txCopy,false);
					txtCopy._in[inputToTest].script_length = subScript.length;
					txtCopy._in[inputToTest].signature_script = ByteArrayUtil.copy(subScript);
					//trace("Subscript from prev:", ByteArrayUtil.toHexString(txtCopy._in[inputToTest].signature_script));
					
					//Now depending on the hashtype various things can happen to txCopy, these will be discussed individually.
					//trace("Last byte:", lastByte.toString(16));
					
					if(lastByte == SIGHASH_ALL)
					{
						// nothing more needs to be done
						//
						var publicKeyPoint:ECPoint = btil.unpack(ByteArrayUtil.toHexString(pubKey));
						var transBytes:ByteArray = btil.txToByteArry(txtCopy);
						var lastByteReversed:uint = btil.rotateBytes(lastByte);
						//trace("Lastbyte rotated:", lastByteReversed.toString(16));
						transBytes.writeUnsignedInt(btil.rotateBytes(lastByte));
						//trace("trans before hash:", ByteArrayUtil.toHexString(transBytes));
						transBytes.position  = 0;
						SHA256.hashBytes(transBytes);
						SHA256.hashBytes(SHA256.digest);
						//trace("final hash", ByteArrayUtil.toHexString(SHA256.digest));
						var eccParams:ECCParameters = new ECCParameters();
						eccParams.keySize = 256;
						eccParams.algorithmName = "flame.crypto::ECDSA";
						
						eccParams.x = publicKeyPoint.x.toBigInteger().toByteArray();
						eccParams.y = publicKeyPoint.y.toBigInteger().toByteArray();
						if(eccParams.x.length > 32) ByteArrayUtil.removeBytes(eccParams.x,0,1);
						if(eccParams.y.length > 32) ByteArrayUtil.removeBytes(eccParams.y,0,1);
						
						//trace("public key x:", ByteArrayUtil.toHexString(eccParams.x), "y:", ByteArrayUtil.toHexString(eccParams.y));
						var ecdsa:ECDSA = new ECDSA(eccParams);
						ecdsa._domainParameters = BitCoinUtil.params;
						ecdsa._curve = BitCoinUtil._curve;
						sig.position = 0;
						var der:DER = new DER();
						var sidUnDERed:IAsn1Type = DER.parse(sig);
						
						var der1:Integer =  sidUnDERed[0];
						var der2:Integer =  sidUnDERed[1];
						var der1Bytes:ByteArray = der1.toByteArray();
						var der2Bytes:ByteArray = der2.toByteArray();
						
						if(der1Bytes.length > 32) ByteArrayUtil.removeBytes(der1Bytes,0,1);
						if(der2Bytes.length > 32) ByteArrayUtil.removeBytes(der2Bytes,0,1);
						
						
						var sigTrimmed:ByteArray = new ByteArray();
						sigTrimmed.writeBytes(der1Bytes);
						sigTrimmed.writeBytes(der2Bytes);
						//trace("Sig        :", ByteArrayUtil.toHexString(sig));
						//trace("Sig Length:", sigTrimmed.length, " trimmed:", ByteArrayUtil.toHexString(sigTrimmed));
						var n:BigInteger = new BigInteger(der1.toByteArray());
						var r:BigInteger = new BigInteger(der2.toByteArray());
						//trace("Sig part one:",n.toString(16),"Sig part two:", r.toString(16));
						
						var isValid:Boolean =  ecdsa.verifyHash(SHA256.digest, sigTrimmed);
						
						trace("is valid:",isValid);
						if(!isValid)
						{
							trace("crap");
						}else
						{
							trace("YUP, it's good");
							return true;
						}
						trace("end");
					}else if(lastByte == SIGHASH_NONE)
					{
						trace("incomplete");
					}else if(lastByte == SIGHASH_SINGLE)
					{
						trace("incomplete");
					}else if(lastByte == SIGHASH_ANYONECANPAY)
					{
						trace("incomplete");
					}
				}else
				{
					trace("oops, need opcode", opcode);
					return false;
				}
			}
			return false;
		}
		public function getOutRecord(transHash:ByteArray, spot:uint):OutRecord
		{
			var recoredID:ByteArray = OutRecord.recordIDHash(transHash, spot);
			var recoredStr:String = ByteArrayUtil.toHexString(recoredID);
			trace("getOutRecord: transhhash:", ByteArrayUtil.toHexString(transHash), "index:", spot, "recordid:",recoredStr );
				
			var transRecord:File = BitCoinUtil.TRANSFOLDER.resolvePath(recoredStr.substr(0,2) + ".dat");
			if(transRecord.exists == false)
			{
				trace("oops, trans problem");
				return null;
			}
			var storedTrans:uint = transRecord.size / OutRecord.defaultRecordSize;
			var i:uint;
			var j:uint;
			var fs:FileStream = new FileStream();
			fs.open(transRecord, FileMode.READ);
			for(i = 0;i<storedTrans;++i)
			{
				fs.position = i * OutRecord.defaultRecordSize;
				
				var transRecordBytes:ByteArray = new ByteArray();
				var outrecord:OutRecord = new OutRecord();
				fs.readBytes(transRecordBytes, 0, OutRecord.defaultRecordSize);
				outrecord.fromBytes(transRecordBytes);
				//trace("getOutRecord", ByteArrayUtil.toHexString(outrecord.recordIDhash), ByteArrayUtil.toHexString(recoredID));
				if(ByteArrayUtil.isEqual(outrecord.recordIDhash, recoredID))
				{
					fs.close();
					return outrecord;
				}
			}
			fs.close();
			return null;
		}
		public function getOutTrans(transHash:ByteArray, spot:uint):OutVO
		{
			if(spot == 16777216)
			{
				trace("Stop");
			}
			var hashStr:String = ByteArrayUtil.toHexString(transHash);
			var outrecord:OutRecord = getOutRecord(transHash, spot);
			if(outrecord == null)
			{
				trace("Didn't find the out");
				return null;
			}
			var bname:String = btil.getBlockName(btil.rotateBytes(outrecord.blockNum), false);
			var bfile:File =  BitCoinUtil.mainDirectory.resolvePath(bname);
			if(!bfile.exists)
			{
				trace("happens a lot because transactions can happen in the block ");
				trace("Crap, should have block");
				return null;
			}
			var theWholeBlock:ByteArray = new ByteArray();
			var fs2:FileStream = new FileStream();
			fs2.open(bfile, FileMode.READ);
			fs2.readBytes(theWholeBlock);//is this right?
			fs2.close();
			theWholeBlock.position = outrecord.outStart;
			var out:OutVO = btil.getOutput(theWholeBlock, false);
			return out;
			
		}
	}
}