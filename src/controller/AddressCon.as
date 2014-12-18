package controller
{
	import com.adobe.crypto.SHA256;
	import com.king.encoder.Base58Encoder;
	
	import flame.crypto.ECDomainParameters;
	import flame.crypto.ECPoint;
	import flame.crypto.PrimeEllipticCurve;
	import flame.crypto.RIPEMD160;
	import flame.crypto.RandomNumberGenerator;
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
	import flash.net.dns.AAAARecord;
	import flash.utils.ByteArray;

	public class AddressCon
	{
		public  var point:ECPoint;
		public  var _curve:PrimeEllipticCurve;
		public  var params:ECDomainParameters;
		
		public function AddressCon()
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
			point = _curve.createPoint(params.x, params.y);
			
		}
		public function getRandomPrivateKey():BigInteger
		{
			var big:BigInteger = new BigInteger(RandomNumberGenerator.getNonZeroBytes(256), true).mod(params.n.subtract(BigInteger.ONE)).add(BigInteger.ONE);
			return big;
			
		}
		public function getRandomAddress(testNet:Boolean):String
		{
			return getFullBitAddress(getRandomPrivateKey(), testNet);
		}
		
		public function getPublicKey(privateKey:BigInteger):ByteArray
		{
			var bp:ECPoint = point.multiply(privateKey);
			
			var x:BigInteger = bp.x.toBigInteger();
			var y:BigInteger = bp.y.toBigInteger();
			var publicKey:ByteArray = new ByteArray();
			publicKey.writeByte(0x04);
			var xba:ByteArray = x.toByteArray();
			//trace("Length of x:", xba.length);
			var yba:ByteArray = y.toByteArray();
			//trace("Length of y:", yba.length);
			publicKey.writeBytes(xba, xba.length == 32? 0:1);
			publicKey.writeBytes(yba, yba.length == 32? 0:1);
			return publicKey;
			
		}
		public function getFullBitAddressBytes(publicKey:ByteArray, testnet:Boolean):ByteArray
		{
			
			var hash1:String = SHA256.hashBytes(publicKey);
			var ripe:RIPEMD160 = new RIPEMD160();
			var riped:ByteArray = ripe.computeHash(SHA256.digest);
			var versionRiped:ByteArray = new ByteArray();
			versionRiped.writeByte(testnet? 0x6F:0x00);
			versionRiped.writeBytes(riped);
			var hash2:String = SHA256.hashBytes(versionRiped);
			var hash3:String = SHA256.hashBytes(SHA256.digest);
			var checksum:String = hash3.substr(0,8);
			versionRiped.writeBytes(SHA256.digest, 0,4);
			versionRiped.position = 0;
			var finalAddress:String = Base58Encoder.encode(versionRiped);
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(finalAddress);
			return ba;
			
			
		}
		public function getFullBitAddress(privateKey:BigInteger, testnet:Boolean):String
		{	
			
			var publicKey:ByteArray = getPublicKey(privateKey);
			//trace("Public key:", ByteArrayUtil.toHexString(publicKey));
			var hash1:String = SHA256.hashBytes(publicKey);
			//trace(hash1);
			var ripe:RIPEMD160 = new RIPEMD160();
			var riped:ByteArray = ripe.computeHash(SHA256.digest);
			//trace(ByteArrayUtil.toHexString(riped));
			var versionRiped:ByteArray = new ByteArray();
			versionRiped.writeByte(testnet? 0x6F:0x00);
			versionRiped.writeBytes(riped);
			
			var hash2:String = SHA256.hashBytes(versionRiped);
			//trace(hash2);
			var hash3:String = SHA256.hashBytes(SHA256.digest);
			//trace(hash3);
			var checksum:String = hash3.substr(0,8);
			//trace(checksum);
			//trace(versionRiped.position);
			//versionRiped.writeBytes(ByteArrayUtil.fromHexString(checksum));
			versionRiped.writeBytes(SHA256.digest, 0,4);
			//trace("Riped:", ByteArrayUtil.toHexString(versionRiped), "bytes:", versionRiped.length);
			//trace(ByteArrayUtil.toHexString(cipher), "1ADF171F7316370DE4FDB0422B665895255FA79B4ED71D12FF2D581EF3A10454A34A2D7D113807B702183B72BFA680CE426CBBD9FE54B6FCCAB4FE7A8FCE8089C0E1545AB66CE721BC4DEDBD6830413FD6DDE830AAD73C46717C6F873F4EF43115469DB05F22A1E05CEEA82B6BE0C9C183C01D43B046E611162847D85223C7BDF521D7D39D5ADC30A7B17800F8499D89BD4F5C8E074299FA587AE61CA2374F592A8D4A93141754B32B6CCF40DF399A32AD4068C5842858C925D50D0BD0E864D0B03EEBF5018999F5F219713CE758B3B5CBC34122B93BF2FD77DD7890E5ABC6E736590657AC2D37DA8B84C4AD761A57E5F1E43F582279564436303BE6F6AFF4C6857A1C4EDC6E520DFE7BFB97CE7BC76D3F7C7997870926B8281BE43A0A05297E1504B7209D3DE397F5AA035C93B896A7DA869C785EEEF540B7731D044C816F9D2DA590D2C155A14C746CABFC30FB037BD31E87634AC9A61F2A26B2FA6208CA87425DD86502D1158BF6B00AF9450C46BCECCE9F3801AB9E1544C8440C8F73C73BC8CA2FE1F9DAE69F04EAAB77C12675396D5CA5ED3C3C2CEE6311B441F954DF0C02C18C7B83D19BA2AEEA757221BA90AB055525AE4B16DD69454B2045973A5FBAA91A1E1205E42B2225AD57A90944FBEAE1FD6B9D15993118DB22DEC4D8B265D904FF88C6B9F1910327C4DC11DAC96E7B9F0D8BDA635D9D1515693D71D037326D44CD5726EB33D1DF82A488F22A9CD6021CF3F703F2D269835987D6161BAA4F33C0EBB85DF0BECE89C074AFB6E3B6CDB2C19F0DA4E075FF18F12BEB62D837F804F6C5AA306CF3C6358ADEA047190070D2F09EEB283D9643132D1E9C349AE7C9034F7F02A5574D07230FDCA805C6BD45C9D8B675FB5A3D8F94DDDCEA506684DFC21DC10AA3872E08CD58351B16A71D91450E4A3E8442AED5FCB8C3DEC3939A4A0E73C621393C9CA5F36F0D7B4DEB16D332D905E7D66E16727989B51DCAAED3D53FCBAB70C1BF318E2D9880443721B3ABA77E307F9C659B47FFC02421171254868FFD9F75F2675C9387749E128F528E6A805834F317765E47E647947D99ADBC17CFBA7D6AC414B4E5BC92CC7E854F5AE7CAA1FF7330CB6A1581632AB5A06C4FDBAD9B237766C6D90B95F9B51316CFAE1C6F2AC7108BC05DD82716274E2113ECDACD8348E1E21B59A78890DC4EB9BE20A8F13B221E35C56D6EF4CF789597DC3CD6992C03685E64EB1B436F2F949C5BE46A6F9C012AE7E0E1BE26947C9A8DA948669C3B57B2515FE008AE9CDA2916716EA6201A6D37998A71098A381E81D1617EDE57E73FCC4CF4CAF5CCF37FF8E8767745C4A26AAB66A2EFC37283562C4D6784D5968DF3CDA67D7E69A3146021C1806DC3EB5891E5892B44B58763961C2F905EE33212D1DDD11C7990640F9DDCD9B0B736E226A92E60CEA46E5268B4D8F05402DA2B46DD747E0674D9B131D52EC2F67FB917DA3851AAAFC116673A2271122822D4AB8CD43D0D7333D0D089A7D4B591682C8E880B2DF04B7693BB0604761AA956120435FD1927424CF4371E30099D7A4889A49CAD59D0D29113803D040C4F3983A6BC3D8FDE2F4BA28B27D8D91869061F8306D4C2713A1CE1283AB6AAEC6DECC956105D2F6FEE1615B4D14782B5FE2AF8B7EA404988F1EB3318A7193B1C2C4E4859D5806D430B526931B4494EF547F513BBFB077F8483069F3BB8E2589AAAD945F79513A9920C3E7F1CFF3194A18755D692E605526F4058B26966AFAF3243D4EF0DABDB7B3852B1DA32AB143044245E97BF74962124C80898F2E566441F5CEB6F5724E6181B801623AFB69161407C6D98C6618A398A97FD7BBA22E3DAB38AA9374A295085177009CEB07413AB8B5889E72A6234AC989863E29D7760FBEA708A5C8E22E8C22FA421D8E5172D55D62AFFEC46108090577477ABDADF462661E51EA634740E16F0F62D591ADBAC688101245E23F0782F6613DC26EC668D26E7B1699DE856160BDF8EABE092A1123D749902F70DAA8EA17769BB3BFAE77C1F3254ED940F7C2ED24E7367AA405F2444D3D56ECC18E197556F00070F72837C687514CA6940A256514B854B09F29ABC50C76C82FEDD62FB8F6C73943ED75505625E3CA8A995945B6AFB5ADAE6CA9D425F35A3A037F99DDBE2EA59372257FAD190FC8D5AADCCE230D51E6F6E4991B3E93ACCDF14630743762DC9BF93253FE1FA62F7AF98CD3738727DDD05E452207F6C96C922B7FD1FEA39F6747934250BBDD23D8B82E722D825778418805BAC5C59303ACE7996C9B7C767F9A34A3D36CB6CE81E2A150DABC3684EC262D89DF30505502E87D118EA431A7DA998E1B26EFFCFC36BA6FC129868E9A4335E6D6A88249213C13464FFE2B3ACBD478D2D09E31EAA4D126B0DA2BFC84BCFF75F4BCF862877BAFBECEE61DFD1DBEE09250B45B9B1A4C63A87ABBB3E20A3579A72535B298285DFAF7D6C9BC322A5C264860F3F283B8D1F490F24A443D02B23280D03D790F4E6C750757D67D4FA204323311E3874674EDD5A65AA958A93E5B9C5C73E63FB15835E7C7D19F9CE2A58769C4081DDAC6CFD9EC8234622A8870F2E7087BE1585F9D64A0173843F2AF876A5F37309FEBBDB6EBAA67D051B4D090DE63BFDDAC6245122228CA473F7BACBE0BBCB5EC45112D0692D3C9C74EA9A11B21CD7224E4C6A2223FEA1E7184A0BD0D16CE4CEC0B744D3F2523D61B4517B2E8A9447FC2B08AA6AD924DB2404A27D34FEE1AC564C83659211159DE4BE1914D845D5C796A812052244337BC705795A54A60DDE5980B7933951E06FCEEE0A3D06BAADBA086B248A5FAE876BE1869A33EDA9854AFA7EF06F5AA775929A37287B3549");
			versionRiped.position = 0;
			var finalAddress:String = Base58Encoder.encode(versionRiped);
			//trace("final", finalAddress);
			//var backToRiped:ByteArray = Base58Encoder.decode(finalAddress);
			//trace("Back to Riped:", ByteArrayUtil.toHexString(backToRiped));
			return finalAddress;
		}
		public function getUnAddress(finalAddress:String):ByteArray
		{
			var backToRiped:ByteArray = Base58Encoder.decode(finalAddress);
			var ba:ByteArray = ByteArrayUtil.getBytes(backToRiped, 1, backToRiped.length -5);//1 for the first, 4 for the end check sum
			
			return ba;
		}
	}
}