@isTest
public class Send_Complaint_CCEC_RecordsClassTest {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31006","result":"successful", "sErrMsg":"","response":[{"complaintRefNo":"00439524","result":"Posted Successfully "}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Case case1 = new Case();
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
        insert case1;
    }
    
    @isTest
    public static void calloutTest(){
        List<Case> csList = [SELECT Id FROM Case];
        test.startTest();
        try{
            Send_Complaint_CCEC_RecordsClass.calloutMethod(new List<String>{csList[0].Id},'201');
        }catch(Exception e){}
        try{
 			Send_Complaint_CCEC_RecordsClass.calloutMethod(new List<String>{csList[0].Id},null);           
        }catch(Exception e){}
        try{
            System.enqueueJob(new Send_Complaint_CCEC_RecordsQueueable(new List<String>{csList[0].Id}));
        }catch(Exception e){}
        test.stopTest();
    }
}