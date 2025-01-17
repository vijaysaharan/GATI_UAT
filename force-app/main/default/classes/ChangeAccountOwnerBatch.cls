global class ChangeAccountOwnerBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.RaisesPlatformEvents {
    
    global final List<Object> gatiCustomerCodes;
    global final String newOwnerId;
    global final Boolean EnforceNewOwnerHasReadAccess;
    global final Boolean KeepAccountTeam;
    global final Boolean KeepSalesTeam;
    global final Boolean TransferContacts;
    global final Boolean TransferContracts;
    global final Boolean TransferNotesAndAttachments;
    global final Boolean TransferOpenActivities;
    global final Boolean TransferOwnedOpenOpportunities;
    global final String isContract;
    
    global ChangeAccountOwnerBatch(List<Object> gatiCustomerCodes, String newOwnerId, map<String,Boolean> wrap,String isContract) {
        this.gatiCustomerCodes = gatiCustomerCodes;
        this.newOwnerId = newOwnerId;
        this.EnforceNewOwnerHasReadAccess = wrap.get('EnforceNewOwnerHasReadAccess');
        this.KeepAccountTeam = wrap.get('KeepAccountTeam');
        this.KeepSalesTeam = wrap.get('KeepSalesTeam');
        this.TransferContacts = wrap.get('TransferContacts');
        this.TransferContracts = wrap.get('TransferContracts');
        this.TransferNotesAndAttachments = wrap.get('TransferNotesAndAttachments');
        this.TransferOpenActivities = wrap.get('TransferOpenActivities');
        this.TransferOwnedOpenOpportunities = wrap.get('TransferOwnedOpenOpportunities');
        this.isContract = isContract;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> listToPass = new List<String>();
        System.debug('GATI_Customer_Code__c'+listToPass);
        for (Object obj : gatiCustomerCodes) {
            listToPass.add((String)obj);
        }
        System.debug('listToPass'+listToPass);
        String query = '';
        if(isContract=='Contract Number'){
            query = 'SELECT Id, OwnerId, GATI_Customer_Code__c, Contract_Number__c FROM Account WHERE GATI_Contract_Number__c in :listToPass';
        }else{
         	query = 'SELECT Id, OwnerId, GATI_Customer_Code__c, Contract_Number__c FROM Account WHERE GATI_Customer_Code__c in :listToPass';   
        }
        System.debug('Batch Query==> '+query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('scope'+scope.size());
        if(scope != null && scope.size()>0){
            Map<Id,List<Account>> ownerIdToAccounts = New Map<Id,List<Account>>();
            for(Account ac : scope){
                if(ownerIdToAccounts.containsKey(ac.OwnerId)){
                    ownerIdToAccounts.get(ac.OwnerId).add(ac);
                }else{
                    ownerIdToAccounts.put(ac.OwnerId,new List<Account>{ac});
                }
            }
            if(ownerIdToAccounts!= null && !ownerIdToAccounts.isEmpty()){
            	for(Id ownerIdKey : ownerIdToAccounts.keySet()){
                	List<ChangeOwner.Requests> requestList = new List<ChangeOwner.Requests>(); 
                    ChangeOwner.Requests r = new ChangeOwner.Requests();
                    r.targetRecordCollection = ownerIdToAccounts.get(ownerIdKey);
                    r.newOwnerId = newOwnerId;
                    r.EnforceNewOwnerHasReadAccess = EnforceNewOwnerHasReadAccess;
                    r.KeepAccountTeam = KeepAccountTeam;
                    r.KeepSalesTeam = KeepSalesTeam;
                    r.TransferContacts = TransferContacts;
                    r.TransferContracts = TransferContracts;
                    r.TransferNotesAndAttachments = TransferNotesAndAttachments;
                    r.TransferOpenActivities = TransferOpenActivities;
                    r.TransferOwnedOpenOpportunities = TransferOwnedOpenOpportunities;
                    
                    List<ChangeOwner.Results> outputs = ChangeOwner.execute(new List<ChangeOwner.Requests>{r});
            	}
        	}
        }
             
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('Batch completed.');
    }
    
    @AuraEnabled public List<Account> failedRecords;
    @AuraEnabled public String failedRecordsCSV;
    @AuraEnabled public Integer numSuccessful;
    @AuraEnabled public Integer numFailed;
    
    public ChangeAccountOwnerBatch(List<Account> failedRecords, String failedRecordsCSV, Integer numSuccessful, Integer numFailed) {
        this.failedRecords = failedRecords;
        this.failedRecordsCSV = failedRecordsCSV;
        this.numSuccessful = numSuccessful;
        this.numFailed = numFailed;
    }
}