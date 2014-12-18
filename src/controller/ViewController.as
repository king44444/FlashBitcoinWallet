package controller
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	import com.bit101.components.List;
	import com.bit101.components.Panel;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	import com.bit101.components.Text;
	import com.bit101.components.VBox;
	import com.greensock.TweenLite;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	public class ViewController extends Sprite
	{
		private var yspace:uint = 20;
		private var borderspace:uint = 15;
		private var lo:SharedObject;
		
		private var pan:Panel = new Panel(this as DisplayObjectContainer, borderspace, borderspace+3);
		
		private var hbox:HBox = new HBox(pan, borderspace);
		
		private var vbox:VBox = new VBox(hbox, borderspace, borderspace);
		private var titlelbl:Label = new Label(vbox, 0,0, "LockRed.com");
		
		private var coinTotalLbl:Label = new Label(vbox, 0,0, "Total Bitcoins:0");
		private var totalTrans:Label = new Label(vbox, 0,0, "Total Transactions:0");
		private var onTestNetCheckBox:CheckBox = new CheckBox(vbox, 0,0, "On Testnet (requires restart)", checkHit);
		private var blockLbl:Label = new Label(vbox, 0,0, "Block downloaded:0");
		private var blockpro:ProgressBar = new ProgressBar(vbox);
		
		private var maxconnectionsLabel:Label = new Label(vbox, 0,0, "Max Peers:0 (requires restart)");
		public var connectionsSlider:Slider = new Slider(Slider.HORIZONTAL, vbox, 0,0, checkHit);
		private var connectionsLabel:Label = new Label(vbox, connectionsSlider.x,connectionsSlider.y + yspace, "Peers Connected:0");
		
		private var vbox2:VBox = new VBox(hbox, borderspace, borderspace);
		private var bitAddressLbl:Label = new Label(vbox2, 0,0, "Receive Addresses");
		private var bitAddressTxt:List = new List(vbox2, 0,0, ["loading","","","","","","","","",""]);
		private var addyBtn:PushButton = new PushButton(vbox2, 0,0, "copy address", copyaddy);
		
		
		private var sendToLbl:Label = new Label(vbox, 0,0,"Send to address:");
		private var sendTotxt:Text = new Text(vbox);
		private var sendBtn:PushButton = new PushButton(vbox, 0,0,"Send", sendHit);
		
		/*
		private var coinTotalLbl:Label = new Label(pan, 15,yspace/2, "total Bitcoins:0");
		private var onTestNetCheckBox:CheckBox = new CheckBox(pan, coinTotalLbl.x, coinTotalLbl.y + yspace, "On Testnet (requires restart)", checkHit);
		private var blockLbl:Label = new Label(pan, onTestNetCheckBox.x,onTestNetCheckBox.y + yspace, "Block downloaded:0");
		private var maxconnectionsLabel:Label = new Label(pan, blockLbl.x, blockLbl.y + yspace, "Max Peers:0 (requires restart)");
		private var connectionsSlider:Slider = new Slider(Slider.HORIZONTAL, pan, maxconnectionsLabel.x, maxconnectionsLabel.y + yspace -10, checkHit);
		private var connectionsLabel:Label = new Label(pan, connectionsSlider.x,connectionsSlider.y + yspace, "Peers Connected:0");
		
		
		private var bitAddressLbl:Label = new Label(pan, 200, 15, "Receive Addresses");
		private var bitAddressTxt:List = new List(pan, bitAddressLbl.x, bitAddressLbl.y + yspace-10, ["loading","","","","","","","","",""]);
		private var totalTrans:Label = new Label(pan, bitAddressTxt.x, bitAddressTxt.height + bitAddressTxt.y + yspace, "Total Transactions:0");
		*/
		
		public var btil:BitCoinUtil;
		public var arbit:ardbit;
		public var log:Function;
		private var tick:TweenLite;
		
		public function ViewController()
		{
			super();
		}
		public function init(arbit:ardbit):void
		{
			lo = SharedObject.getLocal("bitcoinAS3");
			this.arbit = arbit;
			this.btil = arbit.util;
			
			setupUI();
			
			
		}
		private function sendHit(e:Event):void
		{
			//validate the address
			
		}
		private function setupUI():void
		{
			connectionsSlider.minimum = 1;
			connectionsSlider.maximum = 10;
			connectionsSlider.tick = 1;
			var fulladdress:Array = new Array();
			
			for(var i:uint = 0;i<btil.fullAddress.length;++i)
			{
				fulladdress.push(btil.fullAddress[i]);
			}
			bitAddressTxt.alternateRows = true;
			bitAddressTxt.height = (bitAddressTxt.listItemHeight * (btil.fullAddress.length/2)) +15;
			bitAddressTxt.width = 220;
			bitAddressTxt.items = fulladdress;
			
			sendTotxt.height = 50;
			//totalTrans.y = bitAddressTxt.height + bitAddressTxt.y + yspace;
			
			if(lo.data.maxConnections == null)
			{
				//load defaults
				saveSettings();
			}
			
			
			updateView();
			
			//pan.showGrid = true;
			pan.shadow = true;
			pan.width = 470;
			pan.height = 300;
			hbox.spacing = 30;
			
		}
		private function checkHit(e:Event):void
		{
			saveSettings();
		}
		public function updateView():void
		{
			var blks:uint = Math.max(btil.getBlockHeight(), 1);
			blockLbl.text = "Block downloaded:" + blks;
			blockpro.value = blks  / Math.max(btil.highestBlock, blks);
			maxconnectionsLabel.text = "Max Peers:"+lo.data.maxConnections+" (requires restart)";
			onTestNetCheckBox.selected = lo.data.useTestNet;
			connectionsSlider.value = lo.data.maxConnections;
			connectionsLabel.text = "Peers Connected:"+arbit.clientSockets.length;
			
			if(tick)tick.kill();
			
			tick = TweenLite.delayedCall(5, updateView);
			
		}
		private function saveSettings():void
		{
			
			lo.data.useTestNet = onTestNetCheckBox.selected;
			lo.data.maxConnections = connectionsSlider.value;
			
			lo.flush();
			updateView();
			
		}
		public function copyaddy(e:Event):void
		{
			var address:String = bitAddressTxt.selectedItem as String;
			if(address == null)return;
			
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, address);
			
		}
		
		
	}
}