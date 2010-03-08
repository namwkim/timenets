package org.akinu.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import org.akinu.vo.Project;

	public class UpdateProjectEvent extends CairngormEvent{
		public static const UPDATE_PROJECT:String = "UpdateProject";
		public var project:Project;
		public function UpdateProjectEvent(project:Project){
			super(UPDATE_PROJECT);
			this.project = project;
		}
		
		override public function clone():Event{
			return new UpdateProjectEvent(project);
		}
	}
}