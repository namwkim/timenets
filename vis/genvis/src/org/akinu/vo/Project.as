package org.akinu.vo
{

	[RemoteClass(alias="Project")]
	[Bindable]	
	public class Project
	{
		public var id:String;
		public var name:String;
		public var description:String;
		public var people:Array;
		public var events:Array;
		

	}
}