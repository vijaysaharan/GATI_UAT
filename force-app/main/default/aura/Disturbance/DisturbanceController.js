({
	doInit: function (component, event, helper) {
		  
        component.set('v.columns', [
            {label: 'Subject', fieldName: 'Name', type: 'text'},
            {label: 'Affected OU', fieldName: 'Affected_OU__c', type: 'Organization_Master__c'}
            
        ]);
	console.log('action');

        var action = component.get('c.getC');
		action.setParams({ recordId :component.get('v.recordId')});
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state+'this is state');
            
            if(state == 'SUCCESS'){
            console.log('consoel'+JSON.stringify(response.getReturnValue()));
            component.set("v.data", response.getReturnValue());
            }
    
		});
		$A.enqueueAction(action);

 
		
	}
})