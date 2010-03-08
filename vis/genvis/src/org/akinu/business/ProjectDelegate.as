package org.akinu.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.akinu.vo.Project;
	
	public class ProjectDelegate
	{
		private var _responder:IResponder;
		private var _service:Object;
		public function ProjectDelegate(responder:IResponder=null)
		{
			_responder 	= responder;
			_service	= ServiceLocator.getInstance().getRemoteObject("projectService");
		}
		public function updateProject(project:Project):void{
			var call:AsyncToken = AsyncToken(_service.update_project({project:project}));
			if (_responder!=null) call.addResponder(_responder);
		}
	}
}