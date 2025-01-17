global class BatchTosyncPendingCCEC implements Database.Batchable<sObject>, Database.stateful
{
    //DateTime todaysDate = System.today();
    //Date todaysDateStr = Date.valueOf(todaysDate);//todaysDate.format('yyyy-MM-dd');
    List<string> finalCCECList = new List<string>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select id, Name from CCEC__c where CreatedDate = today';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List< CCEC__c> ccecList)
    {  
       string flowname = 'Manual_CCEC_Creation';
       map<string, object> mpp = new map<string, object>();
      List<Integration_log__c> il = [Select Id,CaseNumber__c,Component_Name__c, eRecordID__c, ccecNumber__c ,Error_message__c
                                     from Integration_log__c where Component_Name__c='CCEC Record' and CreatedDate = today];
        system.debug('ccecList '+ccecList);
        system.debug('intLog '+il);
        for(ccec__c cc : ccecList){
            for(Integration_log__c it : il){
                if(cc.Name != it.ccecNumber__c){
                   finalCCECList.add(cc.Id);
                } 
            }
        }
        system.debug('finalCCECList '+finalCCECList); 
        //callFlow(flowname, mpp);
    }
    global void finish(Database.BatchableContext BC)
    {
        system.debug('Hi from finsh');
        system.debug('finalccecList '+finalCCECList);
        ManualCCECOutboundAPI.SendCCEC(finalCCECList);
        
    }   
}
    /*public void callFlow(String flowName, map<string, object> inputs) {
        Flow.Interview myFlow = Flow.Interview.createInterview(flowname, inputs);
        myFlow.start();
    }*/