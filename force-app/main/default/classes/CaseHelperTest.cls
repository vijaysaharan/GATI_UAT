@isTest
public class CaseHelperTest {
    public class MyWebServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response": "Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void exceptionCaseTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Account a = new Account(name = 'syed' , Customer_Category__c = 'KEA' , Billingpostalcode = '842003', Customer_Code__c = 521180.001);
        insert a;
        
        Id rtId = [select Id, name from RecordType where name = 'Complaint' and SObjectType = 'Case' limit 1].Id;        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User user1 = new User(Alias = 'testStd',Email='stndrduser@testorg.com',EmailEncodingKey='UTF-8', Username='syedtest@testorg.com', LastName='testuser1',  
                              LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        insert user1;
        
        AccountTeamMember accTeam= new AccountTeamMember();
        accTeam.AccountId=a.Id;
        accTeam.UserId=user1.Id;
        accTeam.AccountAccessLevel = 'Read';
        accTeam.CaseAccessLevel = 'None';
        accTeam.OpportunityAccessLevel = 'None';
        accTeam.TeamMemberRole = 'Service Resource';
        insert accTeam;
        
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            MobilePhone = '1234567890',
            MailingState = 'Rajsthan',
            MailingCity = 'Pallu',
            MailingStreet = 'street 7'
        );
        insert contact;
        List<Case> caseList = New List<Case>();
        Case case4 = new Case();
        case4.OwnerId = user1.Id;
        case4.Subject = 'Case 4';
        case4.CustomerCode__c = 521180.001;
        case4.AccountId = null;
        case4.Origin='Email';
        case4.Docket_Number__c='989898';
        case4.Pick_Up_Ref_No__c ='1234568';
        case4.Docket_Validation__c = 'Valid';
        case4.Type='Pick Up';
        case4.Sub_Type__c= 'INTERCHANGED/WRONG';
        case4.Mobile__c = '9876895647';
        case4.Pickup_Status__c = 'RPO';
        case4.ContactId = contact.Id;
        caseList.add(case4);
        
        Case case1 = new Case();
        case1.OwnerId = user1.Id;
        case1.Subject = 'Case 1';
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Email';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        case1.Mobile__c = '9876895647';
        case1.Pickup_Status__c = 'RPO';
        caseList.add(case1);
        insert caseList;
        case4.Pickup_Status__c = 'POP';
        try{
            update case4;
        }catch(Exception e){}
    }
    
    @isTest
    static void testShareCase() {
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        User owner1 = new User(Alias = 'syed96',Email='syedshahid@testorg.com',EmailEncodingKey='UTF-8', Username='syedshahid@testorg.com', LastName='syed001',  
                               LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        insert owner1;
        
        User owner2 = new User(Alias = 'imam96',Email='imamsyed@testorg.com',EmailEncodingKey='UTF-8', Username='imamsyed@testorg.com', LastName='imam002',  
                               LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        insert owner2;
        
        Organization_Master__c tOM = New Organization_Master__c (
        	Name='Test',
            RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Operation Unit').getRecordTypeId()
        );
        insert tOM;
        List<Case> caseList = New List<Case>();
        Case case1 = new Case();
        case1.OwnerId = owner1.Id;
        case1.Subject = 'Case 3';
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Email';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        case1.Stock_Receiving_OU__c = tOM.Id;  
        caseList.add(case1);
        
        Case case2 = new Case();
        case2.OwnerId = owner2.Id;
        case2.Subject = 'Case 4';
        case2.CustomerCode__c = 521180.001;
        case2.AccountId = null;
        case2.Origin='Email';
        case2.Docket_Number__c='543215';
        case2.Pick_Up_Ref_No__c ='1234567';
        case2.Docket_Validation__c = 'Valid';
        case2.Type='Delayed Connection';
        case2.Sub_Type__c= 'INTERCHANGED/WRONG';
        case2.Stock_OU__c = tOM.Id;
        caseList.add(case2);
        
        Case case3 = new Case();
        case3.OwnerId = owner2.Id;
        case3.Subject = 'Case 5';
        case3.CustomerCode__c = 521180.001;
        case3.AccountId = null;
        case3.Origin='Email';
        case3.Docket_Number__c='543216';
        case3.Pick_Up_Ref_No__c ='1234567';
        case3.Docket_Validation__c = 'Valid';
        case3.Type='Bill back of Expenses';
        case3.Sub_Type__c= 'INTERCHANGED/WRONG';
        case3.Approval_Status__c = 'Pending';
        case3.Delivery_OU__c = tOM.Id;
        case3.Mobile__c = '9876895647';
        caseList.add(case3);
        insert caseList;
        case3.Approval_Status__c = 'Y';
        try{
        	update case3;    
        }catch(Exception e){}
        
        Test.startTest();
        Map<Id, Case> newMap = new Map<Id, Case>{case1.Id => case1, case2.Id => case2};
            Map<Id, Case> oldMap = new Map<Id, Case>{case1.Id => case1, case2.Id => case2};
                CaseHelper.shareCase(newMap, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testDupCaseError() {
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        List<Case> caseList = new List<Case>();
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.Subject = 'Case 6';
        case1.AccountId = null;
        case1.Origin='Email';
        case1.Type='Exception';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        case1.Mobile__c = '9876895647';
        caseList.add(case1);
        
        Case case2 = new Case();
        case2.CustomerCode__c = 521180.001;
        case2.Subject = 'Case 7';
        case2.AccountId = null;
        case2.Origin='Email';
        case2.Type='Exception';
        case2.Docket_Number__c='543217';
        case2.Pick_Up_Ref_No__c ='1234567';
        case2.Docket_Validation__c = 'Valid';
        case2.Sub_Type__c= 'Likely to fail';
        case2.Complaint_Status__c = 'C';
        case2.Status='Closed';
        case2.Mobile__c = '9876895647';
        case2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pick Up').getRecordTypeId();
        caseList.add(case2);
        
        Case case3 = new Case();
        case3.CustomerCode__c = 521180.001;
        case3.Subject = 'Case 8';
        case3.AccountId = null;
        case3.Origin='Email';
        case3.Type='Non Delivery Reasons';
        case3.Docket_Number__c='123456789';
        case3.Pick_Up_Ref_No__c ='23498';
        case3.Docket_Validation__c = 'Valid';
        case3.Sub_Type__c= 'INTERCHANGED/WRONG';
        case3.Mobile__c = '9876895647';
        caseList.add(case3);
        Case case4 = new Case();
        case4.CustomerCode__c = 521180.001;
        case4.Subject = 'Case 9';
        case4.AccountId = null;
        case4.Origin='Email';
        case4.Type='Non Delivery Reasons';
        case4.Docket_Number__c='123456789';
        case4.Pick_Up_Ref_No__c ='23498';
        case4.Docket_Validation__c = 'Valid';
        case4.Sub_Type__c= 'INTERCHANGED/WRONG';
        case4.Mobile__c = '9876895647';
        caseList.add(case4);
        
        Test.startTest();
        try{
            insert caseList;
        }catch(Exception e){}
        CaseHelper.dupCaseError(caseList);
        CaseHelper.checkPickupRefno(caseList);
        CaseHelper.exceptionCreation(caseList);
        CaseHelper.caseCloseAutoCCECClose(caseList);
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    static void testPopulateContactFields() {
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Contact contact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            MobilePhone = '1234567890',
            MailingState = 'Rajsthan',
            MailingCity = 'Pallu',
            MailingStreet = 'street 7'
        );
        insert contact;
        
        List<Case> caseList = new List<Case>();
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.Subject = 'Case 8';
        case1.AccountId = null;
        case1.ContactId = contact.Id;
        case1.Origin='Email';
        case1.Type='Exception';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Pick Up';
        case1.Sub_Type__c= 'Likely to fail';
        case1.Customer_Email__c= contact.Email;
        case1.SuppliedPhone = contact.MobilePhone;
        
        case1.Pickup_Address1__c = contact.MailingStreet;
        case1.Pickup_Address2__c = contact.MailingCity;
        case1.Pickup_Address3__c = contact.MailingState;
        
        caseList.add(case1);
        insert caseList;
        Test.startTest();
        CaseHelper.populateContactFields(caseList);
        Test.stopTest();
    }
    
    @isTest
    public static void PreventDuplicateCasesForQueryTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.Subject = 'Case 10';
        case1.Docket_Number__c='12534';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='VARIANCE IN ADD';
        case1.Mobile__c = '9876895647';
        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
        insert case1;
        Case case2 = new Case();
        case2.CustomerCode__c = 521180.001;
        case2.Subject = 'Case 11';
        case2.Docket_Number__c='12534';
        case2.Docket_Validation__c = 'Valid';
        case2.Type='VARIANCE IN ADD';
        case2.Mobile__c = '9876895627';
        case2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
        test.startTest();
        try{
            insert case2;
        }catch(Exception e){}
    }
    
    @isTest
    public static void PreventDuplicateCasesForServiceRequestTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.Subject = 'Case 10';
        case1.Docket_Number__c='12534';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Non Delivery Reasons';
        case1.Mobile__c = '9876895647';
        case1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        insert case1;
        Case case2 = new Case();
        case2.CustomerCode__c = 521180.001;
        case2.Subject = 'Case 11';
        case2.Docket_Number__c='12534';
        case2.Docket_Validation__c = 'Valid';
        case2.Type='Non Delivery Reasons';
        case2.Mobile__c = '9876895627';
        case2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        test.startTest();
        try{
            insert case2;
        }catch(Exception e){}
    }
}