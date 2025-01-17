@isTest
public with sharing class RoleHierarchyUtilityTest {
    @TestSetup
    public static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User user1 = new User(
                            Alias = 'testStd',
                            Email='stndrduser@testorg.com',
                            EmailEncodingKey='UTF-8', 
                            Username='syedtest@testorg.com', 
                            LastName='testuser1',  
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ProfileId = p.Id,
            				Zone__c = 'West',
            				IsActive = true,
                            TimeZoneSidKey='America/Los_Angeles');
        insert user1;
        Sales_KRA__c testKRA = new Sales_KRA__c(KAM_KAE__c = user1.Id,Product__c = 'MVATS',Account_Type__c='MSME',Year__c='2024',Target__c=0,Month__c='8');
        insert testKRA;
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingStreet = '123 Main St';
        acc.BillingCity = 'New York';
        insert acc;
    }

    @isTest
    public static void getRoleSubordinateUsersTest() {
        List<User> userData = [SELECT Id FROM User LIMIT 1];
        test.startTest();
        RoleHierarchyUtility.getRoleSubordinateUsers(userData[0].Id,new List<String>{'West'},true,true);
        RoleHierarchyUtility.getRoleSubordinateUsers(userData[0].Id,new List<String>{'West'},false,true);
        test.stopTest();
    }
    
    @isTest
    public static void getNotesDetailsTest() {
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        RoleHierarchyUtility.getNotesDetails(new List<Id>{acc[0].Id});
        test.stopTest();
    }

    @isTest
    public static void upsertNotesTest() {
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        Note nt = new Note();
        nt.Body = 'TEST';
        nt.Title = 'Comment';
        nt.ParentId = acc[0].Id;
        test.startTest();
        RoleHierarchyUtility.upsertNotes(new List<Note>{nt});
        test.stopTest();
    }
}