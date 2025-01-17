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
                    component.set("v.showPopup", true);
                }else{
                    helper.showToast(component, event, 'Error', 'You are Not Authorized to do Check Out.');                                                 
                }
            } else {
                helper.showToast(component, event, 'Error' ,'Error In Checking For Created User : ' + response.responseText);                
            }
        });

        $A.enqueueAction(action); 
        
        //component.set("v.showPopup", true);
    } ,
    handleOptionChange: function(component, event, helper) {
        var selectedValue = component.get("v.selectedOption");
        if (selectedValue === "Yes") {
            component.set("v.showUserLookup", true);
            component.set("v.showContinue", false);
        } else {
            component.set("v.showUserLookup", false);
            component.set("v.showContinue", true);
        }
    },
    handleAccompaniedWithChange: function(component, event, helper) {
        var SelectedIdVal = component.get("v.selectedUserId");
        var dissionVal = component.get("v.DissionValue");
        
        if(!SelectedIdVal && dissionVal != '' && dissionVal != null){
            component.set("v.showContinue", false);
        }else{
            component.set("v.showContinue", true);
        }
    },
    handleDissionChange: function(component, event, helper) {
        var dissionVal = component.get("v.DissionValue");
        var SelectedIdVal = component.get("v.selectedUserId");
        if(!SelectedIdVal && dissionVal != '' && dissionVal != null){
            component.set("v.showContinue", false);
        }else{
            component.set("v.showContinue", true);
        }
    },
    handleContinue: function(component, event, helper) {
        component.set("v.isButtonDisabled", true);
        helper.CheckGeoLocation(component, event, helper);
    },
})