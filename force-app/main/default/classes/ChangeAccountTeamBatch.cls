global class ChangeAccountTeamBatch implements Database.Batchable<SObject>, Database.Stateful {
    public List<String> gatiCustomerCodes;
    public Map<String, String> gatiCustomerCodeToServiceResource;
    
    public ChangeAccountTeamBatch(List<String> gatiCustomerCodes) {
        this.gatiCustomerCodes = gatiCustomerCodes;
        this.gatiCustomerCodeToServiceResource = new Map<String, String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = 'SELECT Id, Gati_Customer_Code__c, Service_Resource__c ' + 'FROM Account ' + 'WHERE Gati_Customer_Code__c IN :gatiCustomerCodes';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext batchableContext, List<Account> scope) {
        List<User> activeUsers = [SELECT Id FROM User WHERE IsActive = true];
        Map<String, Id> activeUserIds = new Map<String, Id>();
        for (User u : activeUsers) {
            activeUserIds.put(u.Id, u.Id);
        }
        
        for (Account acc : scope) {
            String gatiCustomerCode = acc.Gati_Customer_Code__c;
            String serviceResource = acc.Service_Resource__c;
            
            // Update the Service_Resource__c field with the uploaded New User if it's active
            if (activeUserIds.containsKey(serviceResource)) {
                gatiCustomerCodeToServiceResource.put(gatiCustomerCode, serviceResource);
            }
        }
        
        // Query for related Cases based on Gati_Customer_Code__c
        List<Case> relatedCases = [SELECT Id, AccountId FROM Case WHERE Account.Gati_Customer_Code__c IN :gatiCustomerCodes];
        
        for (Case c : relatedCases) {
            String gatiCustomerCode = c.Account.Gati_Customer_Code__c;
            String serviceResource = gatiCustomerCodeToServiceResource.get(gatiCustomerCode);
            
            // Transfer the Case to the updated Service_Resource__c if available
            if (serviceResource != null) {
                c.OwnerId = serviceResource;
            }
        }
        
        update relatedCases;
    }
    
    public void finish(Database.BatchableContext batchableContext) {}
}