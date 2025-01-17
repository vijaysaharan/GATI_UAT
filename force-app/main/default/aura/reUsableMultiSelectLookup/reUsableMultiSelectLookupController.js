({
    firstTimeLoad: function(component, event, helper) {
        console.log('=============ContactId' +component.get("v.ContactId"));
        var lstSelectedRecord = component.get("v.lstSelectedRecords");
        var lstSelectedEmail = component.get("v.lstEnteredEmail");
        var ContactId = component.get("v.ContactId");
        if(ContactId!= null && ContactId!='undefined' &&  ContactId != '' )
            helper.getContactDetail(component,ContactId);
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        var ReadOnly  = component.get("v.IsReadOnly");
        console.log('ReadOnly: '+ReadOnly)
        if(component.get("v.IsReadOnly"))
        {
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'customcls');
           
        }
        
    },
    
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        console.log('On blur');
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        
        if(getInputkeyWord.length > 0){
            
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
            if(event.getParams().keyCode == 13)
            {
                var listSelectedItems =  component.get("v.lstEnteredEmail");
                listSelectedItems.push(getInputkeyWord);
                component.set("v.lstEnteredEmail" , listSelectedItems); 
                component.set("v.SearchKeyWord",null);
                var forclose = component.find("lookup-pill");
                $A.util.addClass(forclose, 'slds-show');
                $A.util.removeClass(forclose, 'slds-hide');
                
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');    
            }
            
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        var AllPillsEmail = component.get("v.lstEnteredEmail"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        for(var i = 0; i < AllPillsEmail.length; i++)
        {
            console.log('@@AllPillsList[i]: ' +AllPillsEmail[i]);
            console.log('@@selectedPillId: ' +selectedPillId);
            if(AllPillsEmail[i] == selectedPillId){
                AllPillsEmail.splice(i, 1);
                component.set("v.lstEnteredEmail", AllPillsEmail);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
})