@isTest
public class TestAddServiceResourceBatch {
    
    @isTest
    static void testGetAccount() {
        
        Id rtId = [select Id, name from RecordType where name = 'Complaint' and SObjectType = 'Case' limit 1].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'testStd',Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', Username='testuser1@testorg.com', LastName='testuser1',  
                             LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',isActive = true);
        insert user;  
        
        
        Set<ID> setAccounts = new Set<ID>();  
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        insert acct;
        System.debug('Account : '+ acct);
        setAccounts.add(acct.id);
        
        List<AccountTeamMember> accTeamList = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId=:acct.Id];
        AccountTeamMember acctemObj = new AccountTeamMember();
        acctemObj.AccountId = acct.Id;
        System.debug('AccountId : '+ acctemObj.AccountId);
        acctemObj.UserId = user.Id;
        System.debug('UserId : '+ acctemObj.UserId);
        acctemObj.AccountAccessLevel = 'Read';
        acctemObj.CaseAccessLevel = 'None';
        acctemObj.OpportunityAccessLevel = 'None';
        acctemObj.TeamMemberRole = 'Service Resource';
        accTeamList.add(acctemObj);
        insert accTeamList;
        
        List<Case> caseList = [SELECT Id,OwnerId FROM CASE WHERE AccountId =:acct.Id AND Status!='Closed'];
        Case c = new Case();
        //enter details
        c.AccountId = acct.Id;
        c.RecordTypeId = rtId;
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'Open'; 
        c.Type = 'Delayed Connection'; 
        c.Sub_Type__c = 'STC COOLING'; 
        c.Docket_Number__c = '1111';
        c.OwnerId = user.Id;
        System.debug('OwnerId'+c.OwnerId);
        caseList.add(c);
        insert caseList;
        
        // Set up test variables
        String recordId = acct.Id;
        String userId = user.Id;
        
        System.assertEquals(1, accTeamList.size());
        System.assertEquals(user.Id, accTeamList[0].UserId);
        System.assertEquals('Service Resource', accTeamList[0].TeamMemberRole);  
        System.assertEquals(1, caseList.size());
        System.assertEquals(user.Id, caseList[0].OwnerId);
        
        test.startTest();
        AddServiceResourceBatch batch = new AddServiceResourceBatch();
        batch.recordId = recordId;
        batch.userId = userId;
        System.debug('userId '+userId);
        System.debug('recordId '+userId);
        Id batchId = Database.executeBatch(new AddServiceResourceBatch(),1);
        System.debug('batchId '+batchId);
        test.stopTest();
        
    }
    
}