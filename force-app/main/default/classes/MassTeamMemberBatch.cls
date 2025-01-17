global class MassTeamMemberBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.RaisesPlatformEvents{
    
    global final List<String> gatiCustomerCodes;
    global final String newOwnerId;
    global final Boolean EnforceNewOwnerHasReadAccess;
    global final Boolean TransferOwnedOpenCases;
    Map<Id, Id> mapAccountIdUserId = new Map<Id, Id>();
    
    global MassTeamMemberBatch(List<String> gatiCustomerCodes, Map<Id, Id> getmapAccountIdUserId, map<String,Boolean> wrap) {
        this.gatiCustomerCodes = gatiCustomerCodes;
        this.newOwnerId = newOwnerId;
        this.EnforceNewOwnerHasReadAccess = wrap.get('EnforceNewOwnerHasReadAccess');
        this.TransferOwnedOpenCases = wrap.get('TransferOwnedOpenCases');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> listToPass = new List<String>();
        for (Object obj : gatiCustomerCodes) {
            listToPass.add((String)obj);
        }
        String query = 'SELECT Id, OwnerId, GATI_Customer_Code__c, Contract_Number__c FROM Account WHERE GATI_Customer_Code__c in :listToPass';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug('Batch Excute method');
        List<Account> accountsToUpdate = new List<Account>();
        List<ChangeAccountTeam.Requests> requestList = new List<ChangeAccountTeam.Requests>(); 
        ChangeAccountTeam.Requests r = new ChangeAccountTeam.Requests();
        r.targetRecordCollection = scope;
        r.newOwnerId = newOwnerId;
        
        r.EnforceNewOwnerHasReadAccess = EnforceNewOwnerHasReadAccess;
        r.TransferOwnedOpenCases = TransferOwnedOpenCases;   
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Batch completed.');
    }
}