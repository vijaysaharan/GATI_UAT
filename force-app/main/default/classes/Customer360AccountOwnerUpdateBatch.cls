public with sharing class Customer360AccountOwnerUpdateBatch implements Database.Batchable<SObject>,Schedulable{
    public Database.QueryLocator start (Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Customer_Code__c,AccountOwner__c 
                                            FROM Customer360__c 
                                            WHERE AccountOwner__c = null
                                            OR CreatedDate = THIS_MONTH
        ]);
     }
  
     public void execute (Database.BatchableContext BC, List<Customer360__c> customer360Records) {
        List<Customer360__c> recordToOperate = IncentiveUtility.updateAccountOwner(customer360Records);
        if (recordToOperate != null && recordToOperate.size() > 0) {
           update recordToOperate;
        }
     }
  
     public void finish (Database.BatchableContext BC) {
        //SalesKRARollupUpdateBatch b = new SalesKRARollupUpdateBatch();
        if (!Test.isRunningTest()) {
            //Database.executeBatch(b,20);
            database.executeBatch(new CreateSalesKRAFromCustomer360(),2000);
        }
     }

     public void execute (SchedulableContext SC) {
        Customer360AccountOwnerUpdateBatch b = new Customer360AccountOwnerUpdateBatch();
        Database.executeBatch(b);
     }
}