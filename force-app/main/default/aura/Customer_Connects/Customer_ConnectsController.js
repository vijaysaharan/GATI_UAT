({
    doInit : function(component, event, helper) {
        //   var accountId = sessionStorage.getItem("accountId");
        
        var myPageRef = component.get("v.pageReference");
        var accountid;
        //console.log('myPageRef',JSON.stringify(myPageRef,null,2));
        if (myPageRef){
         	accountid = myPageRef.state.c__id;
            if(myPageRef.state.c__parentId){
                var checkAccOrLead = myPageRef.state.c__parentId;
                //console.log('checkAccOrLead.substring(0,3) ',checkAccOrLead.substring(0,3));
                if(checkAccOrLead.substring(0,3) == '001'){
                    //console.log('Account');
                    component.set("v.accountId",checkAccOrLead);
                    component.set("v.leadId",null);
                }else{
                    //console.log('Lead');
                    component.set("v.accountId",null);
                    component.set("v.leadId",checkAccOrLead);
                }
            }
        }
        
        if(accountid)
        {
            component.set('v.accId',accountid)
        }
        
    },
    refresh: function (component, event, helper) {
		var recordTypeId = component.get("v.pageReference").state.c__id;
		component.set("v.recordtypeid", recordTypeId);
		$A.get("e.force:refreshView").fire();
	}
    
})