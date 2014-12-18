package model
{
	public class Work
	{
		
		public var data:String;
		public var hash1:String;
		public var target:String;
		public var midstate:String;
		
		public function Work(data:String = "", hash1:String= "", target:String= "", midstate:String= "")
		{
			this.data = data;
			this.hash1 = hash1;
			this.target = target;
			this.midstate = midstate;
		}
		
		
		
	}
}