({
    init : function(component, event, helper) {
        console.log('it on!!');
        var action = component.get('c.getContactInfo');
        action.setParams({
            recordId : component.get('v.recordId'),
        });
        console.log('Param set');
        action.setCallback(this, function(res){
            console.log('In call back');
            var state = res.getState();
            console.log(state);
            if (state === "SUCCESS") {
                 console.log('In success');
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: res.getReturnValue(),
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        })
        $A.enqueueAction(action);
    }
})