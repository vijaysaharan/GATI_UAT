({
    getOptyId : function(component, event, helper) {
        var rid = component.get("v.recordId");
        var action = component.get("c.payHistoryData");
        action.setParams({optyId: rid});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var isValid = response.getReturnValue();
                if(isValid != null){
                    window.setTimeout(
                    $A.getCallback(function() {
                        alert(isValid);
                    }), 5000 );                    
                }
                $A.get('e.force:refreshView').fire();
                component.find('notify').showToast({
                    "variant": "success",
                    "title": "Success",
                    "message": "Quote Created!"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        component.find('notify').showToast({
                            "variant": "Error",
                            "title": "Error",
                            "message": errors[0].message
                        });
                    }
                } 
                else {
                    console.log("Unknown Error");
                    component.find('notify').showToast({
                        "variant": "Error",
                        "title": "Error",
                        "message": "no response recieved!"
                    });
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });
    $A.enqueueAction(action);
}
})