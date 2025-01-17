({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var arr = [];
        var lst1 = component.get("v.lstContactToRemove1");
        var lst2 = component.get("v.lstContactToRemove2");
        // alert('===========' +lst1+ '============='+lst2);
        if(lst1!=null && lst1 != 'undefined' && lst1 !='')
            arr.push(lst1);
        if(lst2!=null && lst2 != 'undefined' && lst2 !='')
            arr.push(lst2);
        console.log('arr: ' +arr);
        var action = component.get("c.fetchLookUpValues");
        
        // call the apex class method 
        
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : component.get("v.lstSelectedRecords")
            
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    getContactDetail: function(component,ContactId)
    {
        console.log('ContactId In Helper' +ContactId);
        var action = component.get("c.ContactDetail");
        action.setParams({
            conId:ContactId
        });
        action.setCallback(this,function(response){
            var state =  response.getState();
            console.log('===========state: ' +state);
            if(state==='SUCCESS')
            {
                console.log('===========state2 ' +state);
                var listSelectedItems =  component.get("v.lstSelectedRecords");
                var ContactRecord = response.getReturnValue();
                listSelectedItems.push(ContactRecord);
                component.set("v.lstSelectedRecords" , listSelectedItems); 
                
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');  
            }
        });
        $A.enqueueAction(action);
    }
})