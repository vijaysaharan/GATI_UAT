@IsTest
public class ChangeAccountOwnerBatchTest {
    
    @IsTest
    public static void testChangeAccountOwnerBatch() {
        Account testAccount = new Account(Name = 'Test Account',GATI_Customer_Code__c='200300');
        insert testAccount;
        
        List<Object> gatiCustomerCodes = new List<Object>();
        gatiCustomerCodes.add('200300');
        
        System.debug('gatiCustomerCodes'+gatiCustomerCodes);
        
        String newOwnerId = 'sam_21163@gatikweuat.com';
        
        Map<String, Boolean> wrap = new Map<String, Boolean>();
        wrap.put('EnforceNewOwnerHasReadAccess', true);
        wrap.put('KeepAccountTeam', true);
        wrap.put('KeepSalesTeam', true);
        wrap.put('TransferContacts', true);
        wrap.put('TransferContracts', true);
        wrap.put('TransferNotesAndAttachments', true);
        wrap.put('TransferOpenActivities', true);
        wrap.put('TransferOrders', true);
        wrap.put('TransferOwnedOpenCases', true);
        wrap.put('TransferOwnedOpenOpportunities', true);
        
        ChangeAccountOwnerBatch batch = new ChangeAccountOwnerBatch(gatiCustomerCodes, newOwnerId, wrap,'Customer Code');
        Database.executeBatch(batch);
    }
}