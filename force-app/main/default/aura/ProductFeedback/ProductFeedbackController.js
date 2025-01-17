({
    doinit : function(component, event, helper) {

component.find("ProductFeedback").getNewRecord(
    "Customer_Feedback_Process__c",
    null,
    false,
    $A.getCallback(function() {
        var rec = component.get("v.feedbackFields");
        var recordobj=component.get("v.feedbackRecord");
        
        var error = component.get("v.recordError");
        if (error || (rec === null)) {
            console.log("Error initializing record template: " + error);
            return;
        }
    //    console.log("rec values are "+ JSON.stringify(rec))
      //  console.log("record values are "+ JSON.stringify(recordobj))
        component.set("v.loaded",true);
    })
);


},
handleBlur: function (component,event,helper) {
    var datefield = event.getSource().get('v.value');
    let date = new Date();
    let date2 = new Date(datefield);
    date = new Date(date.toDateString());
    date2 = new Date(date2.toDateString());
    if(date2 < date){
        event.getSource().setCustomValidity("Please select Todays date!!"); 
    }else{
        
        event.getSource().setCustomValidity(""); 
    }
    
},
    handleLikeButtonClick:function(component,event,helper)
{
    var questions = component.get('v.Questions');  
    var rating1 = event.getSource().get('v.label');
    component.set("v.rating1",rating1);
    component.set("v.feedbackFields.Genie_Experience_rating__c",rating1);
},
    handleSubmit:function(component,event,helper)
{
    component.set("v.feedbackFields.Type__c","Product Feedback");
    component.set("v.feedbackFields.Used_Genie_Before__c",component.get("v.usedgenie"));
    component.set("v.feedbackFields.Is_Genie_easy_to_use__c",component.get("v.easytouse"));
    component.set("v.feedbackFields.challenges_faced__c",component.get("v.challange"));
    console.log(component.get("v.feedbackFields.Type__c"))
    let targetvalues=component.get("v.Experience");
    
    let ratings= component.get("v.Questions");
    var rec = component.get("v.feedbackFields");
   
    if(component.get("v.feedbackFields.Genie_Experience_rating__c")==null){
            alert('Please select you Genie Experience Rating!');
            return;
}
    if(component.get("v.feedbackFields.Used_Genie_Before__c")==""||component.get("v.feedbackFields.Is_Genie_easy_to_use__c")==""||component.get("v.feedbackFields.challenges_faced__c")==""){
            alert('Please fill all the required details!');
            return;
}
   
 /*  if(!rec.Rate_your_experience_with_GATI_Services__c)
   {
       alert("please enter value if experiennce");
   }
*/
console.log(targetvalues);
    if(helper.validateContactForm(component))
    {
          component.set("v.disable",true)
    helper.saveRecord(component,event,helper);
    }
    else
    {
        alert("Please reolve all errors");
    }


},
    GetValFromChild : function(cmp, event) {
        var message = event.getParam("val");
 
      console.log(message+' parent comp value')
        cmp.set("v.feedbackFields.Rate_your_experience_with_GATI_Services__c", message);
      
    }
})