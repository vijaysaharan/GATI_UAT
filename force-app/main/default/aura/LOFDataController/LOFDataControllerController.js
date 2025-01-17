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
                    "message": "GATI Company is required. Can you please add it against the Contract and retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            } /*else if(component.get("v.OpptyRecord.Account.PANNumber__c") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "PAN number is required. Can you please add it against the Contract and retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }*/
            //Opportunity.Account.Customer_Category__c,"Retail"
                else if(component.get("v.OpptyRecord.Account.PANNumber__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail" & component.get("v.OpptyRecord.Account.Partner_Sub_Category__c")!= "Parent Cluster Code" & component.get("v.OpptyRecord.CreatedDate") > "2023-02-28"){
                    component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "PAN number is required. Please update PAN number at account."
                });
                $A.get("e.force:closeQuickAction").fire();
                }
            else if(component.get("v.OpptyRecord.Account.Associated_OU__r.Name") ==null){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Operation Unit is required. Can you please add it against the Contract and retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
                else if(component.get("v.OpptyRecord.Account.Nature_of_business__c ") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select Value for Nature of Business and Retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
               else if(component.get("v.OpptyRecord.Account.Registration_Status__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select Value for Registration Status and Retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
               else if(component.get("v.OpptyRecord.Account.Customer_Type_KYC__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select Value for Customer Type KYC and Retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
                   else if(component.get("v.OpptyRecord.Account.Risk_Covered_By__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select Value for Risk Covered By and Retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
                   else if(component.get("v.OpptyRecord.Account.Market_Type__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please select Value for Market Type and Retry"
                });
                $A.get("e.force:closeQuickAction").fire();
            }
                       
                   else if(component.get("v.OpptyRecord.Account.Market_Cide__c") ==null & component.get("v.OpptyRecord.Account.Customer_Category__c")=="Retail"){
                component.find('notify').showToast({
                    "variant": "Error",
                    "title": "Error",
                    "message": "Please provide for Market Code and Retry"
                });
            }else if(component.get("v.OpptyRecord.Account.Contract_type__c") ==null){
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
	/*getOptyId : function(component, event, helper) {
		var rid = component.get("v.recordId");
        var action = component.get("c.getPayHistoryData");
        action.setParams({optyId: rid});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                alert("Quote Created!");
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
	},*/
    isRefreshed: function(component, event, helper) {
        //location.reload();
    }
})