public class BatchMIS implements database.Batchable<sObject> {
public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id,Customer_Name__c,Customer_Code__c,Customer_Code__r.Name,OwnerId from MIS__c where Manual_MIS__c=true AND Trigger_Type__c =:'SL']);  	 
    }
    public void execute(Database.BatchableContext bc,List<MIS__c> MISList)
    { 		
        list <task> T=new list <task>();
          // Iterate through the whole query of MIS. && 
        // Create a Task that's associated with each MIS.
        for( MIS__c c : MISlist) {
            Task tsk             = new Task();
            tsk.OwnerId          = c.OwnerId;
            tsk.WhoId            = c.Id;
            tsk.WhatId           = c.Customer_Code__c;
            tsk.ActivityDate     = System.today();
            tsk.Status           = 'Open';
            tsk.Priority         = 'Normal';
            tsk.Subject ='MIS Remainder for '+c.Customer_Code__r.Name;
            T.add(tsk);
    }//close for-loop
        try {
        insert T;
    } catch (system.dmlexception e) {
        System.debug('Tasks not inserted: ' + e);
    }
    }//close execute method
         public void finish(Database.BatchableContext bc)
    {
        
    }//close finish method
}