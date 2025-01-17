({
	myAction: function(component, event, helper) {
		var Url=component.get("v.Url");
        var StaffCode=component.get("v.record.Staff_Code__c");
        if(StaffCode==null)
        {
            StaffCode=component.get("v.StaffCode");
        }
        component.set("v.Url",(Url+"?puser=PIY_"+StaffCode));
	},
    onRefreshView: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(component.get('c.myAction'));
		$A.get('e.force:refreshView').fire();
}
})