package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class PageChangeEvent extends CairngormEvent
	{
		public static const PAGE_CHANGE:String = "PageChange";
		public var page:uint;
		public function PageChangeEvent(page:uint, data:*=null)
		{
			super(PAGE_CHANGE);
			this.page = page;
			this.data  = data;
		}
		override public function clone():Event{
			return new PageChangeEvent(page, data);
		}
		
	}
}