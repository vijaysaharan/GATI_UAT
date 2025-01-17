/*
Author     : Sumit Gupta (sgupta3@kloudrac.com)
Date       : Mar 04, 2022
Desc       : 
Class Name : Send_Complaint_CCEC_RecordsQueueable
*/

@isTest(SeeAllData = false)
public class Send_Complaint_CCEC_RecordsQueueableTest {
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31003","result":"successful", "sErrMsg":"","response":[{"crn":"00440384","result":"Posted Successfully "}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void myUnitTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        List<string> caseId1 = new List<string>();
         Contact cont = TestFactory.getContact('Harit', 'a@a.com');
         Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
		 caseId1.add(ccec1.Id);  
            
        Test.startTest();
        System.enqueueJob(new Send_Complaint_CCEC_RecordsQueueable(caseId1));
        Test.stopTest();  
    }
}