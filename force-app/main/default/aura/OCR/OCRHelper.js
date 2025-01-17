({
    helperMethod : function(component,event,helper,vid,did) {
        var action = component.get("c.callserver");
        action.setParams({ versionid:vid,
                          docid:did});
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data=response.getReturnValue();
                console.log(JSON.stringify(data))
                var err=data.result+'';
                console.log(typeof(err)+' '+err);
                console.log('error '+data.response )
                
                if(err=='Error')
                {
                    console.log('here');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Lead cannot be created',
                        message:data.response,
                        duration:'4000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
                else
                {
                    component.set("v.ocrData",data)
                    var compEvent = component.getEvent("ParentNotify");
                    compEvent.setParams({"Values" : data });
					compEvent.fire();
                    
                    console.log('ajkdas');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Data Fetch has been completed successfully."
                    });
                 //   console.log(data);
                    toastEvent.fire();
                  
                }
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    }
    
    
})