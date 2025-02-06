@isTest
public with sharing class CreateSubcodeControllerTest {
    @TestSetup
    static void makeData(){
        Id contractRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Contract').getRecordTypeId();
        Id customerCodeRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Code').getRecordTypeId();
        Account parentAccount = new Account(
            RecordTypeId = contractRecordType,
            Name = 'Parent Account',
            BillingCountry = 'India',
            BillingState = 'Rajasthan',
            BillingPostalCode = '3355201',
            BillingCity = 'Pallu',
            BillingStreet = 'Gali No. 2',
            GSTNumber__c = '27ABCDE1234F1Z5',
            PANNumber__c = 'ABCDE1234F'
        );
        insert parentAccount;
    }

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
    static void SendSubCodeToMDMTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        CreateSubcodeController.SendSubCodeToMDM(testAccount.Id);
        test.stopTest();
    }
}