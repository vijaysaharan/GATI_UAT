({
	CallServer : function(component,event,helper) {
        var action= component.get("c.getData");
        action.setParams({
            recordId:component.get("v.recordId"),
            ObjectName:component.get("v.sObjectName"),
            fields:component.get("v.Fields")
        });
        action.setCallback(this,function(response){
            var state= response.getState();
            if(state=='SUCCESS')
            {
               var res= response.getReturnValue();
               // alert("response"+ response.getReturnValue())
             var url=  component.get('v.iframeUrl');
                url= url+'?puser='+res.username;
                console.log(url);
            }
            else
                if(state=='INCOMPLETE')
                {
                    
                }
            else if(state=='ERROR')
            {
                var errors= response.getError();
                alert('error'+' '+errors)
            }
        });
        $A.enqueueAction(action);
		
	}
})