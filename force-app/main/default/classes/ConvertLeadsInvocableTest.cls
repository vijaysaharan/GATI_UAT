@isTest
private class ConvertLeadsInvocableTest {   
    
    
    @isTest
    static void test_convert_lead_yes_opportunity() {
        Organization_Master__c om = new Organization_Master__c(Name = '335524');
        insert om;
        
        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            company = 'Salesforce',
            PostalCode = '335524',
            Product__c = 'Express',
            Turnover_of_the_Company__c = 100,
            Expected_Business_Per_Month__c = 100
        );
        
        insert ld;
        
        Test.startTest();
        
        ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, masterLabel FROM LeadStatus WHERE isConverted = true LIMIT 1 ].masterLabel;
        request.createOpportunity = true;
        request.opportunityName = 'Test Opportunity';
        request.ownerId = UserInfo.getUserId();
        request.sendEmailToOwner = true;
        
        List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads( new List<ConvertLeadsInvocable.LeadConvertRequest>{ request } );
        
        Test.stopTest();
        
        System.assert( results != null );
        System.assertEquals( 1, results.size() );
        
        ConvertLeadsInvocable.LeadConvertResult result = results[0];
        
        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId ] );
        System.assertEquals( 1, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );
        
    }
    
    @isTest
    static void test_convert_lead_no_opportunity() {
        Organization_Master__c om = new Organization_Master__c(Name = '335524');
        insert om;
        
        Account acct = new Account(
            name = 'Salesforce'
        );
        
        insert acct;
        
        Contact cont = new Contact(
            accountId = acct.id,
            firstName = 'Marc',
            lastName = 'Benioff'
        );
        
        insert cont;
        
        Lead ld = new Lead(
            firstName = 'Marc',
            lastName = 'Benioff',
            company = 'Salesforce',
            PostalCode = '335524',
            Product__c = 'Express',
            Turnover_of_the_Company__c = 100,
            Expected_Business_Per_Month__c = 100
        );
        
        insert ld;
        
        Test.startTest();
        
        ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, masterLabel FROM LeadStatus WHERE isConverted = true LIMIT 1 ].masterLabel;
        request.createOpportunity = false;
        request.accountId = acct.id;
        request.contactId = cont.id;
        request.overwriteLeadSource = true;
        
        List<ConvertLeadsInvocable.LeadConvertResult> results = ConvertLeadsInvocable.convertLeads( new List<ConvertLeadsInvocable.LeadConvertRequest>{ request } );
        
        Test.stopTest();
        
        System.assert( results != null );
        System.assertEquals( 1, results.size() );
        
        ConvertLeadsInvocable.LeadConvertResult result = results[0];
        
        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId AND id = :acct.id ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId AND id = :cont.id ] );
        System.assertEquals( 0, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );
        
    }
    
}