({
    saveRecord : function(component, event, helper) {
        var tempRec=component.find("forceRecord")
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var resultsToast = $A.get("e.force:showToast");
            if (result.state === "SUCCESS") {
                //  alert("message The record was saved.")
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Lead has been created successfully."
                });
                console.log(result);
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.recordId,
                    
                });
                navEvt.fire();
                
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type:'error',
                    mode: 'dismissible',
                    message: 'Error: ' + JSON.stringify(result.error[0].message)
                    
                    
                });
                toastEvent.fire();
            }
            
        } ))
    },
    validateContactForm: function(component) {
        //  alert("validate");
        var validContact = true;
        // Show error messages if required fields are blank
        var allValid = component.find('leadfield').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            // Verify we have an account to attach it to
            var account = component.get("v.leadRecord");
            if($A.util.isEmpty(account)) {
                validContact = false;
                console.log("Quick action context doesn't have a valid account.");
            }
            return(validContact);
        }
    }
})