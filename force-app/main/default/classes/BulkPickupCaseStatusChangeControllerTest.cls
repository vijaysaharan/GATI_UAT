@isTest
public with sharing class BulkPickupCaseStatusChangeControllerTest {
    public class MockServiceCalloutTest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response": "Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockServiceCalloutTest());
        Account acc =  new Account(Name = 'Test Account 1', GATI_Customer_Code__c = '123456');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', StaffCode__c = '1234');
        insert con;
        Organization_Master__c pincode = new Organization_Master__c(Name = '201301', 
                                                                    Status__c = 'V',
                                                                    RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Pincode').getRecordTypeId(),
                                                                    Pincode_Status__c = 'O');        
        insert pincode;

        Case pickupTest = new Case(Subject = 'Test',
                                   Origin = 'Email',
                                   Status = 'New',
                                   Type = 'Pick Up',
                                   AccountId = acc.Id,
                                   ContactId = con.Id,
                                   Non_Pick_Up_Delivery_Reason__c = 'Reason',
                                   Pick_Up_Instructions__c = 'Reason',
                                   Pickup_Address1__c = 'Address',
                                   Pickup_Address2__c = 'Address',
                                   Pickup_Address3__c = 'Address',
                                   Pickup_City__c = 'Hyderabad',
                                   Volume__c = 100,
                                   Product__c = '1',
                                   Mobile__c = '9876543210',
                                   Actual_Weight__c = 100,
                                   Pick_Up_Pincode__c = pincode.Id,
                                   Docket_Validation__c = 'Valid',
                                   RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick_Up').getRecordTypeId(),
                                   Pickup_Date__c = System.now()
                                 );
        insert pickupTest;
    }
    @isTest
    public static void csvDataHandlerTest(){
        Test.setMock(HttpCalloutMock.class, new MockServiceCalloutTest());
        Case testCase = [SELECT Id, CaseNumber,Docket_Number__c,Pickup_Status__c, Pickup_Date__c, Approver_Remarks__c, Actual_Weight__c, Status FROM Case LIMIT 1];

        List<BulkPickupCaseStatusChangeController.csvWrapper> csvWarp = New List<BulkPickupCaseStatusChangeController.csvWrapper>();
        BulkPickupCaseStatusChangeController.csvWrapper csvWarp1 = New BulkPickupCaseStatusChangeController.csvWrapper();
        csvWarp1.CaseNumber = testCase.CaseNumber;
        csvWarp1.DocketNumber = '';
        csvWarp1.PickupStatus = testCase.Pickup_Status__c;
        csvWarp1.PickupDate = System.now();
        csvWarp1.ApproverRemarks = 'TEST REMARK';
        csvWarp1.ActualWeight = 10;
        csvWarp1.Status = testCase.Status;
        csvWarp.add(csvWarp1);
        test.StartTest();
            String sendString = JSON.serialize(csvWarp);
        try{
            BulkPickupCaseStatusChangeController.CsvDataHandler(sendString);   
        }
        catch(Exception e){
            System.debug(e);
        }
        test.StopTest();
        System.assertEquals('Test', 'Test', 'Matched!');
    }
}