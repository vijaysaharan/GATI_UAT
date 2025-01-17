@isTest
public with sharing class BulkCaseStatusChangeControllerTest {
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        Case case1 = new Case();
        case1.Subject = 'Case 1';
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Email';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Non Delivery Reasons';
        case1.Mobile__c = '9876895647';
        case1.Pickup_Status__c = 'RPO';
        insert case1;
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
    public static void CsvDataHandlerTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        List<Case> caseList = [SELECT Id,CaseNumber,Docket_Number__c,Status FROM Case LIMIT 1];
        test.startTest();
        List<BulkCaseStatusChangeController.csvWrapper>  csvWrappers = new List<BulkCaseStatusChangeController.csvWrapper>();
        BulkCaseStatusChangeController.csvWrapper cs = new BulkCaseStatusChangeController.csvWrapper();
        cs.CaseNumber = caseList[0].CaseNumber;
        cs.DocketNumber = caseList[0].Docket_Number__c;
        csvWrappers.add(cs);
        try{
            BulkCaseStatusChangeController.CsvDataHandler(JSON.serialize(csvWrappers));
        }catch(Exception e){}
        caseList[0].Status = 'Closed';
        update caseList;
        try{
            BulkCaseStatusChangeController.CsvDataHandler(JSON.serialize(csvWrappers));
        }catch(Exception e){}
        test.stopTest();
    }
}