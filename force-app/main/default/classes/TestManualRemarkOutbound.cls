@isTest
public class TestManualRemarkOutbound {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":["contractNo:"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator3 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[]}');
            res.setStatusCode(201);
            return res;
        }
    }
    /*@isTest
	static void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Case c1=ServiceTestFactory.getCase8('CRM');
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECRemarkOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }*/
    @isTest
    static void TestMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Contact cont = TestFactory.getContact('Harit', 'a@a.com');
        Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        ccec1.Proactive_CCEC_Flag__c =true;
        update ccec1;
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECRemarkOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
    @isTest
    static void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Test.startTest();
        Contact cont = TestFactory.getContact('Harit Sahitya', 'a@ar.com');
        Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing2', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECRemarkOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
     @isTest
    static void TestMethod3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
        Test.startTest();
        Contact cont = TestFactory.getContact('Harit Sahitya', 'a@ar.com');
        Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing2', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECRemarkOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
}
/*[{"name": "CCEC-16256","firstResponsetimeSlab": "8-12Hrs","feedback": "2","cPTadherence": "NO","cCECStatus": "OP","cCECclosureDate": null,"commentsBy": "OU","remarkSeq": 3,"openRemarks": "Testing Hemant to CRM from OU","remarksProvidedBy": "PNQO_20856","remarksDate": "2021-10-27T19:16:52Z","newCcecFlag": null,"newCcecOu": null},{"name": "CCEC-16257","firstResponsetimeSlab": "8-12Hrs","feedback": "2","cPTadherence": "NO","cCECStatus": "OP","cCECclosureDate": null,"commentsBy": "OU","remarkSeq": 3,"openRemarks": "testing Hemant. ","remarksProvidedBy": "PAT_20856","remarksDate": "2021-10-27T19:15:45Z","newCcecFlag": null,"newCcecOu": null}]
*/