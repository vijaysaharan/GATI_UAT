trigger AttachmentCount on Attachment (after insert, after delete) {
    if(Trigger.isAfter && Trigger.isInsert){        
        List<Opportunity> opp = [select id,Document_Count__c from Opportunity where id =: Trigger.New[0].ParentId];  
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId=:opp[0].Id]; 
        if(!attList.isEmpty() && attList.size()>0){
             opp[0].Document_Count__c = attList.size();
        }else{
            opp[0].Document_Count__c = 0;
        } 
        update opp; 
    }
    
    
    if(Trigger.isAfter &&  Trigger.isDelete){
        List<Opportunity> opp = [select id,Document_Count__c from Opportunity where id =: Trigger.Old[0].ParentId];  
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId=:opp[0].Id]; 
        if(!attList.isEmpty() && attList.size()>0){
            opp[0].Document_Count__c = attList.size();
        }else{
            opp[0].Document_Count__c = 0;
        } 
        update opp;  
    }
  
   
    
}