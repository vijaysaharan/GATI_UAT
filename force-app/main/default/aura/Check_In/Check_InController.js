({
	updateGeoLocation : function(component, event, helper) {
        var action = component.get("c.checkForOwner");        
        var recId = component.get("v.recordId");

        action.setParams({
            "recordId": recId
        });

        action.setCallback(this, function(response) {
            console.log('Response=== ',response.getReturnValue());
            if (response.getState() === 'SUCCESS' && (response.getReturnValue() != null || response.getReturnValue() != undefined)) {
                var checkValue = response.getReturnValue();
                console.log('checkValue=== ',checkValue);
                if(checkValue == true){
                    helper.CheckGeoLocation(component, event, helper);
                }else{
                    helper.showToast(component, event, 'Error', 'You are Not Authorized to do Check In.');                                                 
                }
            } else {
                helper.showToast(component, event, 'Error' ,'Error In Checking For Created User : ' + response.responseText);                
            }
        });

        $A.enqueueAction(action);
        
       // helper.CheckGeoLocation(component, event, helper);
	} 
})