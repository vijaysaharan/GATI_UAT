({
    handleLoadedRecord: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           	var Amount= component.get("v.OpptyRecord.Commited_Gati_Potentail__c");
            var AmountBP = component.get("v.OpptyRecord.Amount_Business_potentital__c");
            var numLineItems = component.get("v.OpptyRecord.No_of_Line_Items__c");
            if(numLineItems == 0){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "No Line Items present!"
                });
                $A.get("e.force:closeQuickAction").fire();
            }else if(component.get("v.OpptyRecord.Account.GATI_Company_Code__c") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "GATI Company is required."
                });
                $A.get("e.force:closeQuickAction").fire();
            } else if(component.get("v.OpptyRecord.Account.GATI_Customer_Code__c") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "GATI Customer Code is required."
                });
                $A.get("e.force:closeQuickAction").fire();
            } else if(component.get("v.OpptyRecord.Account.PANNumber__c") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "PAN number is required."
                });
                $A.get("e.force:closeQuickAction").fire();
            }else if(component.get("v.OpptyRecord.Account.Associated_OU__r.Name") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Operation Unit is required."
                });
                $A.get("e.force:closeQuickAction").fire();
            }
                else if(component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "You are not authorized to generate a quote."
                });
                $A.get("e.force:closeQuickAction").fire();
            } else if(component.get("v.OpptyRecord.Account.Contract_type__c") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select a valid contract type and retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }else if(Amount==null||AmountBP==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Commited Gati Potentail and Amount(Business Potential) are required!"
                });
                $A.get("e.force:closeQuickAction").fire();
            }else{
                helper.getOptyId(component, event, helper);
            }
        } else if(eventParams.changeType === "ERROR") {
            
        }
    },
    isRefreshed: function(component, event, helper) {
        //location.reload();
    }
})