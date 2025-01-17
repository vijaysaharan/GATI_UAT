({
    itemSelected : function(component, event, helper) {
       
        helper.itemSelected(component, event, helper);
    }, 
    serverCall :  function(component, event, helper) {
       // var value= event.getSource().get("v.value");
        //console.log(value);
        helper.serverCall(component, event, helper);
    },
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    } 
})