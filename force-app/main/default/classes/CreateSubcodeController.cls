public with sharing class CreateSubcodeController {
   @AuraEnabled
   public static void SendSubCodeToMDM(Id recordId){
    try {
        List<Account> currentAccount = [SELECT Id,Name,PANNumber__c,GSTNumber__c,BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry 
                                        FROM Account 
                                        WHERE Id =:recordId
                                       ];
        if(currentAccount != null && currentAccount.size() > 0){
            Account newAccount = currentAccount[0].clone(false, true, false, false);
            newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Code').getRecordTypeId();
            newAccount.ParentId = currentAccount[0].Id;
            newAccount.OwnerId = UserInfo.getUserId();
            insert newAccount;

            System.enqueueJob(new SubCodeAPICalloutQueueable(newAccount.Id));
        }
    }catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
}