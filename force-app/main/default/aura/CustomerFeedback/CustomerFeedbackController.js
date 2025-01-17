({
    doinit : function(component, event, helper) {
        let ques=['How would you rate us on our ability to communicate and respond on time ?',
                  'Based on your interaction, how would you rate us on our pick up services ?',
                  'Based on your interaction, how would you rate us on our timeliness of deliveries ?',
                  'Were the services offered, inline with your changing business needs and requirements overtimes ?',
                  'Rate our ability of generating accurate invoices?',
                  'Rate us on ease of navigation on our website ?',
                  'How would rate your overall experience with Gati services ?'
                 ];
        var quesdata=[];
        let apis=['Rate_us_on_our_ability_and_respond_time__c','Pick_up_Experience__c','Delivery_Experience__c','Business_needs_and_requirements_overtime__c','Invoicing_Experience__c','Rate_ease_of_navigation_on_our_website__c','Rate_your_overall_experience_with_Gati_s__c'];
        
        ques.map((data,index)=>{
            let a={}
                 a.label=data;
                 //a.apis[index]='';
                 let val=apis[index];
                 a.api=val;
                 a.Rating='';
                 quesdata.push(a);
    })
    console.log(JSON.stringify(quesdata));
    component.set("v.Questions",quesdata);
    
    var exp={};
 exp.Rating='';
 exp.Label=''
 component.set("v.Experience",exp);
component.find("CustomerFeedback").getNewRecord(
    "Customer_Feedback_Process__c",
    null,
    false,
    $A.getCallback(function() {
        var rec = component.get("v.feedbackFields");
        var recordobj=component.get("v.feedbackRecord");
        // add here line 72
        component.set("v.feedbackFields.Account__c",component.get("v.accountId"));
        component.set("v.feedbackFields.Contact__c",component.get("v.contactId"));
        component.set("v.feedbackFields.Organization_Name__c",component.get("v.accountName"));
        component.set("v.feedbackFields.Feedback_Given_By__c",component.get("v.contactName"));
        component.set("v.feedbackFields.Designation__c",component.get("v.Designation"));
        component.set("v.feedbackFields.Email__c",component.get("v.contactEmail"));
        component.set("v.feedbackFields.Mobile_no__c",component.get("v.contactPhone"));
        /*var d = new Date();
        var mon =d.getMonth()+1;
        var dateString = d.getFullYear() + '-' + mon + '-'+d.getDate()
        console.log('dateString',dateString)*/
        var timezone = $A.get("$Locale.timezone");
        // Returns the date string in the format "2015-11-25"
        $A.localizationService.getToday(timezone, function(today){
            console.log(today);
            component.set("v.feedbackFields.Date__c", today);
        });
        
        var error = component.get("v.recordError");
        if (error || (rec === null)) {
            console.log("Error initializing record template: " + error);
            return;
        }
        //console.log("rec values are "+ JSON.stringify(rec))
        //console.log("record values are "+ JSON.stringify(recordobj))
        component.set("v.loaded",true);
    })
);
},
    handleLikeButtonClick:function(component,event,helper)
{
    var questions = component.get('v.Questions');
    var rating = event.getSource().get('v.label');
    var index = event.getSource().get('v.title');
    
    if(index =='EXP'){
        let exp=component.get("v.Experience");  
        console.log(exp);
        exp.Rating=rating;
        component.set("v.Experience",exp);
        component.set("v.feedbackFields.Rate_your_experience_with_GATI_Services__c",rating);
    }
    else{
        questions[index].Rating = rating;
        
        component.set('v.Questions',questions);
    }
},
    handleSubmit:function(component,event,helper)
{
    component.set("v.feedbackFields.Type__c","Customer Feedback");
    component.set("v.feedbackFields.Recommend_Gati__c",component.get("v.recommendgati"));
    console.log(component.get("v.feedbackFields.Type__c"));
    console.log('Recommend_Gati:',component.get("v.feedbackFields.Recommend_Gati__c"));
    
    let targetvalues=component.get("v.Experience");
    
    let ratings= component.get("v.Questions");
    var rec = component.get("v.feedbackFields");
    
    for(let i of ratings){
        let api=i.api;
        rec[api]=i.Rating;
        
        if(!i.Rating){
            alert(`Please enter input for  ${i.label} `);
            return;
        }
        
    }
    console.log(targetvalues);
    //component.set("v.feedbackFields", rec);
    helper.saveRecord(component,event,helper);
    
    /*if(helper.validateContactForm(component)){
        component.set("v.disable",true)
        helper.saveRecord(component,event,helper);
    }
    else{
        alert("Please reolve all errors");
    } */ 
},
    GetValFromChild : function(cmp, event) {
        var message = event.getParam("val");
        
        console.log(message+' parent comp value')
        cmp.set("v.feedbackFields.Rate_your_experience_with_GATI_Services__c", message);
        
    }
})