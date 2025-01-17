({
    doinit : function(component, event, helper) {
	var urlParams = new URLSearchParams(window.location.search);
    console.log(urlParams.get("staffcode"));
       component.set("v.staffcode",urlParams.get("staffcode").toString());
component.find("FrontLineFeedback").getNewRecord(
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
    component.set("v.feedbackFields.Customer_Service_Experience__c",rating1);
},
    handleSubmit:function(component,event,helper)
{
    component.set("v.feedbackFields.Type__c","Front Line Feedback");
    component.set("v.feedbackFields.Agent_Polite__c",component.get("v.agentpolite"));
    
    component.set("v.feedbackFields.staffcode__c",component.get("v.staffcode"));
    //for date
    const today = new Date();
    component.set("v.feedbackFields.Date__c",today);
    console.log("staff code" + component.get("v.feedbackFields.staffcode__c"));
    component.set("v.feedbackFields.Problem_solved_in_First_call__c",component.get("v.problemsolved"));
    component.set("v.feedbackFields.Knowledgeable_Representative__c",component.get("v.knowledgeable"));
    component.set("v.feedbackFields.Time_Connecting_with_Agent__c",component.get("v.timeconnecting"));
    component.set("v.feedbackFields.Agent_mention_Gati_selfcare__c",component.get("v.gatiselfcare"));
    console.log(component.get("v.feedbackFields.Type__c"));
    let targetvalues=component.get("v.Experience");
    
    let ratings= component.get("v.Questions");
    var rec = component.get("v.feedbackFields");
   
    if(component.get("v.feedbackFields.Customer_Service_Experience__c")==null){
            alert('Please select you Customer Service rating!');
            return;
}
    if(component.get("v.feedbackFields.Agent_Polite__c")==""||component.get("v.feedbackFields.Problem_solved_in_First_call__c")==""||component.get("v.feedbackFields.Knowledgeable_Representative__c")==""||component.get("v.feedbackFields.Time_Connecting_with_Agent__c")==""||component.get("v.feedbackFields.Agent_mention_Gati_selfcare__c")==""){
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