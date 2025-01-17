/*
Author     : Sumit Gupta (sgupta3@kloudrac.com)
Date       : Sep 22, 2021
Desc       : Test class related to batch class to update Case Owner through Account Team Member.
Class Name : CustomAccountTeamMemberCaseUpdate
*/
@isTest(seeAlldata = false)
public class CustomAccountTeamMemberCaseUpdateTest 
{
    
    static testMethod void test() 
    {
        
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
        insert acct;
        setAccounts.add(acct.id); 
        
        //create case
        Case c = new Case();
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
        insert c;
        
        
        
        Map<ID,ID> mapAccountIdUserId = new Map<ID,ID>();
        mapAccountIdUserId.put(acct.id,UserInfo.getUserId());
        String query = 'Select Id,AccountId from Case where Status != \'Closed\' AND AccountId IN :setAccounts';
        Test.startTest();
        CustomAccountTeamMemberCaseUpdate batchable = new CustomAccountTeamMemberCaseUpdate(query,mapAccountIdUserId,setAccounts);
        DataBase.executeBatch(batchable,10); 
        Test.stopTest();
    }
}