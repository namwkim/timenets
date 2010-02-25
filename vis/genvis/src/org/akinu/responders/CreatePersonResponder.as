package org.akinu.responders
{
	import mx.controls.Alert;
	import mx.rpc.IResponder;

	public class CreatePersonResponder implements IResponder
	{
		public function CreatePersonResponder()
		{
		}

		public function result(data:Object):void{
			Alert.show("Successfully created!");
		}
		
		public function fault(info:Object):void	{
			Alert.show("Failed to create a person!");
		}
		
	}
}