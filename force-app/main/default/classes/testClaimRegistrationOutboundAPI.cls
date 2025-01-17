@isTest
public class testClaimRegistrationOutboundAPI {
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31003","result":"successful", "sErrMsg":"","response":[{"crn":"00440384","result":"Posted Successfully "}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31003","result":"failed", "sErrMsg":"Check Mobile no only numeric #Check Email Id #","response":[]}');
            res.setStatusCode(300);
            return res;
        }
    }
    
    static testmethod void testClaimRegistration1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Account a1 = TestFactory.insertAccount2('term'+Datetime.now(),'101',Date.newInstance(2021,08,13),Date.newInstance(2021,08,16),12,'110011');
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = a1.Id;
        case1.Type='Exception';
        case1.Docket_Number__c='104655898';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        case1.Invoice_Number__c = '121212';
        case1.Invoice_Date__c =  Datetime.now();
        case1.Email_Id__c = 'test@gati.com';
        case1.Claim_Mobile_Number__c = 929292929;
        case1.Claim_Vaue__c = 120000;
        case1.Booking_Date__c = Date.today();
        case1.Actual_delivery_Date__c = Date.today();
        case1.Assured_Delivery_Date__c = Date.today();
        case1.OBN_In_Favour_Of__c = 'S';
        case1.Nature_of_Loss__c = 'D';
        case1.Loss_Description__c = 'No Comments';
        case1.Origin = 'Phone';
        insert case1;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test2 Customer accept';
        cv.PathOnClient = 'TestDocument.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;       
        cv.Origin = 'H';
        insert cv;
        Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = case1.Id;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = 'V';
        Insert cdl;
        test.startTest();
        try{
            Claim_Registration_OutboundAPI.calloutMethod(new List<String>{case1.Id});
        }catch(Exception e){}
        test.stopTest();
    }
    static testmethod void testClaimRegistration2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Account a1 = TestFactory.insertAccount2('term'+Datetime.now(),'101',Date.newInstance(2021,08,13),Date.newInstance(2021,08,16),12,'110011');
      
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = a1.Id;
        case1.Type='Exception';
        case1.Docket_Number__c='104655898';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        case1.Invoice_Number__c = '121212';
        case1.Invoice_Date__c = Datetime.now();
        case1.Email_Id__c = 'aaa@a.com';
        case1.Claim_Vaue__c = 120000;
        case1.Booking_Date__c = Date.today();
        case1.Actual_delivery_Date__c = Date.today();
        case1.Assured_Delivery_Date__c = Date.today();
        case1.OBN_In_Favour_Of__c = 'S';
        case1.Nature_of_Loss__c = 'D';
        case1.Loss_Description__c = 'No Comments';
        case1.Origin = 'Phone';
        insert case1;
        case1.Pre_Checks__c = true;
        case1.Total_Upload__c = 3;
        update case1;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test2 Customer accept';
        cv.PathOnClient = 'TestDocument.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;       
        cv.Origin = 'H';
        insert cv;
        Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = case1.Id;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = 'V';
        Insert cdl;

        test.startTest();
        try{
            Claim_Registration_OutboundAPI.calloutMethod(new List<String>{case1.Id});
        }catch(Exception e){}
    }
}