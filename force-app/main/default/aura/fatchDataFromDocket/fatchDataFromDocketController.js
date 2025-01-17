({
	handleInputChange: function(component, event, helper) {
        component.set("v.isButtonDisabled", false);
        var doc = component.get("v.DocketNumber");
        console.log('Docket Number',doc);
    },
    handleFetchData: function(component, event, helper) {
        component.set("v.isButtonDisabled", true); 
        var action = component.get("c.getAllDataWithDocketNumber"); 
        var recId = component.get("v.recordId");
        var docNum = component.get("v.DocketNumber");
        action.setParams({
            "recordId": recId,
            "docketNumber": docNum
        });
        console.log('recId'+recId);
        console.log('docNum',docNum);
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS' && (response.getReturnValue() != null || response.getReturnValue() != undefined)) {
                var responseVal = response.getReturnValue();
                if(responseVal.Status == '200'){
                 	helper.showToast(component, event, 'Success' ,responseVal.Message);   
                }else{
                    helper.showToast(component, event, 'Warning' ,responseVal.Message);
                }
            } else {
                component.set("v.isButtonDisabled", false);
                helper.showToast(component, event, 'Error' ,'Getting Error in Fatching : ' + response.responseText);                
            }
        });
        $A.enqueueAction(action);
    }
})