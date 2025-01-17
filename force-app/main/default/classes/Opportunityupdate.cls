global class Opportunityupdate Implements Database.Batchable <SObject> {
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([SELECT Id FROM Opportunity where Day_only(RFQ_Date__c)= :Date.today() and RFQ__c=true]);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for(Opportunity opporecord: scope)
        {
            opporecord.StageName='Qualified';
            opporecord.RFQ_Date__c= Null;
            opporecord.Loss_Reason__c= Null;
            opporecord.RFQ__c= false;
            
        }
        update scope;
    }
    global void finish(Database.BatchableContext bc) {
    }
}