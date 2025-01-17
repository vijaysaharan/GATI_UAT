({
	doint: function (component, event, helper) {
		var recordTypeId = component.get("v.pageReference").state.recordTypeId;
		console.log("record type id is" + recordTypeId);
		component.set("v.recordtypeid", recordTypeId);
		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            component.set("v.focusedTabId",response.tabId)
        })
        .catch(function(error) {
            console.log(error);
        });        

	},
	refresh: function (component, event, helper) {
		var recordTypeId = component.get("v.pageReference").state.recordTypeId;
		component.set("v.recordtypeid", recordTypeId);
		$A.get("e.force:refreshView").fire();
	},
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        setTimeout(function(){workspaceAPI.closeTab({tabId: component.get("v.focusedTabId")}); },1000);
        //workspaceAPI.closeTab({tabId: component.get("v.focusedTabId")});
        /*workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log(focusedTabId);
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });*/
    }
});