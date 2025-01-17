({
	CallServer : function(component,event,helper) {
        debugger;
        var recId ='';
        var objectName ='';
        if (component.get("v.isCMSCanvas"))
        {
        	recId = component.get("v.recordId");
        	objectName = component.get("v.ObjectName");
    	}
        var action= component.get("c.getData");
        action.setParams({
            CanvasName:component.get("v.CanvasName"),
            recId:recId,
            objectName:objectName
        });
        
        action.setCallback(this,function(response){
            var state= response.getState();
            if(state=='SUCCESS')
            {
               var res= response.getReturnValue();
               // alert("response"+ response.getReturnValue())
               component.set("v.canvasParameters", 
                   JSON.stringify({"requid":res.requid,
                                   "authorization":res.authorization,
                                   "puser":res.puser,
                                   "action":(typeof res.action === 'undefined') ? null : res.action,
                                   "cid":(typeof res.cid === 'undefined') ? null : res.cid,
                                   "p1":(typeof res.p1 === 'undefined') ? null : res.p1,
                                   "p2":(typeof res.p2 === 'undefined') ? null : res.p2,
                                   "p3":(typeof res.p3 === 'undefined') ? null : res.p3,
                                  "p4":(typeof res.p4 === 'undefined') ? null : res.p4,
                                  "p5":(typeof res.p5 === 'undefined') ? null : res.p5,
                                  "p6":(typeof res.p6 === 'undefined') ? null : res.p6}));
                component.set("v.serverCallSuccess",true);
            }
            else if(state=='ERROR')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info',
                    message: response.getError()[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
		
	}
})