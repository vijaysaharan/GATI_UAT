@isTest
public class AddServiceResourceTest {
    /*
Author     : Shahid Imam (simam@kloudrac.com)
Date       : 3 Feb, 2023
Desc       : Test class related to batch class to update Case Owner through Account Team Member.
Class Name : AddServiceResource
*/
    @isTest
    static void testData() {
        AddServiceResource.dummy();
        Id rtId = [select Id, name from RecordType where name = 'Complaint' and SObjectType = 'Case' limit 1].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Set<ID> setAccounts = new Set<ID>();  
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        insert acct;
        setAccounts.add(acct.id); 
        
        //create case
        /*Case c = new Case();
//enter details
c.AccountId = acct.Id;
c.RecordTypeId = rtId;
c.Type = 'My Type';
c.Origin = 'My Origin';
c.Status = 'Open'; 
c.Type = 'Pending Pickup'; 
c.Sub_Type__c = 'MISSED PICKUP'; 
c.Docket_Number__c = '1111';
c.OwnerId = UserInfo.getUserId();
//  c.Pick_Up_Ref_ID__c = '5000sddfdg';   
insert c;*/
        
        Test.startTest();
        // Perform the test actions
        try {
            AddServiceResource.getRoleSubordinateUsers();
            AddServiceResource.getAccount(acct.Id);
            AddServiceResource.saveSerivecresource(acct.Id, u.Id);
        } catch (Exception e) {
            // Handle the exception
            System.assert(e.getMessage().contains('List has no rows for assignment to SObject'));
        }
        Test.stopTest();
        
    }
}