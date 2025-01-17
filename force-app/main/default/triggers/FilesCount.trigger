trigger FilesCount on ContentDocumentLink (after insert, before delete, after delete) {
    
    Set<id> cdlIds = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    
    if(Trigger.isAfter && Trigger.isInsert){  
        for(ContentDocumentLink cdl : trigger.new){
        cdlIds.add(cdl.LinkedEntityid);
    }
        List<Opportunity> opp = [select Id,Document_Count__c from Opportunity where Id IN:cdlIds];  
        for(Opportunity op : opp){
            oppIds.add(op.Id);
        }
        System.debug('-- check1--'+opp);
        List<ContentDocumentLink> cdlList = [select id,LinkedEntityid from ContentDocumentLink where LinkedEntityid IN:oppIds];
        System.debug('-- check2--'+cdlList);
        if(!cdlList.isEmpty() && cdlList.size()>0){
            opp[0].Document_Count__c = cdlList.size();
        }else{
            opp[0].Document_Count__c = 0;
        } 
        update opp; 
    }
    
    if(trigger.isdelete){ 
        System.debug('-- delete event--');
        Set<Id> cdltempIds = new Set<Id>();
        Set<Id> oppIdsTemp = new Set<Id>();
        for(ContentDocumentLink cdl : Trigger.old){
            cdltempIds.add(cdl.LinkedEntityid);
        }
        List<Opportunity> opp = [select Id,Document_Count__c from Opportunity where Id IN:cdltempIds];  
        for(Opportunity op : opp){
            oppIdsTemp.add(op.Id);
        }
       
        List<ContentDocumentLink> cdlList = [select id,LinkedEntityId from ContentDocumentLink where LinkedEntityid IN:oppIdsTemp];
        if(!cdlList.isEmpty() && cdlList.size()>0){
             opp[0].Document_Count__c = cdlList.size();
        }else{
            opp[0].Document_Count__c = 0;
        } 
        update opp; 
    }

}