({
    doInit : function(component, event, helper) {
        //   var accountId = sessionStorage.getItem("accountId");
        
        var myPageRef = component.get("v.pageReference");
        var accountid;
        if (myPageRef)
         accountid = myPageRef.state.c__id;
        
        if(accountid)
        {component.set('v.accId',accountid)
        }
        
    },
    refresh: function (component, event, helper) {
		var recordTypeId = component.get("v.pageReference").state.c__id;
		component.set("v.recordtypeid", recordTypeId);
		$A.get("e.force:refreshView").fire();
	}
    
})