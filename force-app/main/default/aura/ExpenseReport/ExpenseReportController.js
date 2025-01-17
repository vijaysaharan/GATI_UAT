({
	doInit : function(component, event, helper) {
         var RecordId = component.get("v.recordId");
		 window.open('/apex/VisitPDF?Id='+RecordId);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})