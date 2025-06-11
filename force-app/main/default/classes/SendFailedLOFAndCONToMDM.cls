public with sharing class SendFailedLOFAndCONToMDM implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    public Set<Id> quoteIds;
    public String authString;

    public SendFailedLOFAndCONToMDM () {}
    
    public SendFailedLOFAndCONToMDM (Set<Id> quoteIds){
        this.quoteIds = quoteIds;
    }

    public void execute (SchedulableContext sc) {
        Map<Id, Quote> quoteIdToQuote = new Map<Id, Quote> ([
            SELECT Id 
            FROM Quote 
            WHERE IntegrationMessage__c != null 
            AND IntegrationMessage__c NOT IN (
                'LOF Send Successfully.',
                'Contract Send Successfully.',
                'Customer is already associated with contract, more than one Contract association is not allowed.'
            )
            AND (Name LIKE '%LOF%' OR Name LIKE '%CON%')
        ]);

        if (!(quoteIdToQuote?.keySet()?.isEmpty() ?? true)) {
            SendFailedLOFAndCONToMDM batch = new SendFailedLOFAndCONToMDM(quoteIdToQuote.keySet());
            Database.executeBatch(batch, 1);
        }
    }
    
    public Database.QueryLocator start (Database.BatchableContext bc) {
        this.authString = generateAuthorizationToken();
        return Database.getQueryLocator('SELECT Id, OpportunityId, Opportunity.AccountId, Test_LOF_number__c,LOF_Amendment_Date__c,AmendedVersion__c FROM Quote WHERE Id IN :quoteIds');
    }
    
    public void execute (Database.BatchableContext bc, List<Quote> quoteList) {
        Set<Id> accountIds = new Set<Id>();
        
        for(Quote qt : quoteList){
            accountIds.add(qt.Opportunity.AccountId);
        }
        
        Map<Id, Account> accountToId = new Map<Id, Account> ([
            SELECT Id,GATI_Company_Code__c,GATI_Customer_Code__c,
            Remarks__c,Contract_Status__c,LOF_Number__c,Contract_Activation_Date__c
            FROM Account 
            WHERE Id IN :accountIds
        ]);
        
        for (Quote qt : quoteList) {
            String varMessage = '';
            GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
            input.account = accountToId.get(qt.Opportunity.AccountId);
            input.quoteData = qt;

            if (qt.Test_LOF_number__c.contains('CON')) {
                input.action = 'Update-CON-Account'; 
            } else {
                input.action = 'Create-LOF-Account';
            }

            input.authorizationHeader = authString;
            List<GatiMDMUtil.ActionOutput> response = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});

            if (response != null && response.size()>0 && response[0].subCodeCreationStatusCode == 204 && input.action == 'Update-CON-Account') {
                varMessage = 'Contract Send Successfully.';
            } else if (response != null && response.size()>0 && response[0].subCodeCreationStatusCode == 201 && input.action == 'Create-LOF-Account') {
                varMessage = 'LOF Send Successfully.';	
            } else if (response != null && response.size()>0) {
                varMessage = response[0].errorMessage;
            }

            qt.IntegrationMessage__c = varMessage;
            update qt;
        }
    }
    
    public void finish (Database.BatchableContext bc) {}
    
    private static String generateAuthorizationToken () {
        Map<String, String> payload = new Map<String, String>();
        payload.put('login', label.MDMAuthorizationUserName);
        payload.put('password', label.MDMAuthorizationPassword);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('Authorization_Token').EndPoint__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payload));        
        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String tokenType = (String) responseMap.get('tokenType');
            String accessToken = (String) responseMap.get('accessToken');
            return (tokenType + ' ' + accessToken);
        }
        return null;
    }
}