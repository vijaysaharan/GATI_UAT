({
	showToast: function(component, event, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": title,
            "message": message
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})