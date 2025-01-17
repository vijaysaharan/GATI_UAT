({
    handleChange : function(component, event, helper) {
       var selectedOptionValue = event.getParam("value");
        component.set("v.visited",selectedOptionValue);
    },
    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleSave : function(component, event, helper) {
        component.set("v.isSpinner",true);
        var action = component.get("c.updatEventData");
        action.setParams({
            "recordId":component.get("v.recordId"),
            "visited": component.get("v.visited")
        });
        action.setCallback(this,function(resp){
            if(resp.getState()==="SUCCESS"){
                 component.set("v.isSpinner",false);
                var recordData = resp.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Visited updated successfully!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordData,
                    "slideDevName": "related"
                });
                navEvt.fire();
                 $A.get('e.force:refreshView').fire(); 
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ERROR',
                    message: 'ERROR Occure when Event update',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire()
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    }
})