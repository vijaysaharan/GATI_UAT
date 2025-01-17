({
    helperMethod : function() {
            if(resultsToast)
            {
                if (result.state === "SUCCESS") {
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved."
                    });
                    resultsToast.fire();                
                } else if (result.state === "ERROR") {
                    console.log('Error: ' + JSON.stringify(result.error));
                    resultsToast.setParams({
                        "title": "Error",
                        "message": "There was an error saving the record: " + JSON.stringify(result.error)
                    });
                    resultsToast.fire();
                } else {
                    console.log('Unknown problem, state: ' + result.state + ', error: ' + JSON.stringify(result.error));
                }}
    }
    ,
    saveRecord : function(component, event, helper) {
        var tempRec=component.find("PostIssueResolutionFeedback")
        tempRec.saveRecord($A.getCallback(function(result) {
            console.log(result.state);
            var resultsToast = $A.get("e.force:showToast");
                        if (result.state === "SUCCESS") {
                    component.set("v.AllowInput",false);
                 //   alert("message The record was saved.")
                    
                }
            else{
                  console.log('Error: ' + JSON.stringify(result.error));
               console.log (result.error[0].pageErrors[0].statusCode)
                if(result.error[0].pageErrors[0].statusCode=='NOT_FOUND')
                {
                    alert("message The record was saved.");
                     component.set("v.AllowInput",false);
                }
            }
            
        } ))
        },
     validateContactForm: function(component) {
        var validContact = true;
         // Show error messages if required fields are blank
        var allValid = component.find('feedbackfield').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            // Verify we have an account to attach it to
            var account = component.get("v.feedbackRecord");
            if($A.util.isEmpty(account)) {
                validContact = false;
                console.log("Quick action context doesn't have a valid account.");
            }
        return(validContact);
        }
	}
                                          })