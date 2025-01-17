({
    handleClickSave : function(component, event, helper) {
        var action = component.get("c.assignOU");
        var res = component.get("v.selectedLookUpRecords")[0].val;
        console.log('--- ou--',component.get("v.selectedLookUpRecords")[0].val);
        action.setParams({
            recordId:component.get("v.recordId"),
            ouId : res
        });
        action.setCallback(this,function(resp){ 
            console.log('-- error --',resp.getError());
            if(resp.getState()==="SUCCESS"){
                console.log('-- after success error--',resp.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'OU Assigned successfully!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
               var dismissActionPanel = $A.get("e.force:closeQuickAction");
               dismissActionPanel.fire(); 
               //location.reload();
            }
        });
        $A.enqueueAction(action);
    },
    handleClickCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire(); 
    }
})