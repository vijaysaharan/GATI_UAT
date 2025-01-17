({
    closeAction : function(component, event, helper) {
        //console.log('Received cancel event from LWC child component');
        $A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
    }
})