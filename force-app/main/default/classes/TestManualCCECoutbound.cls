@isTest
public class TestManualCCECoutbound {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[]}');
            res.setStatusCode(201);
            return res;
        }
    }
    @isTest
    static void TestMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Contact cont = TestFactory.getContact('Harit', 'a@a.com');
        Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
     @isTest
    static void TestMethod3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.startTest();
        Contact cont = TestFactory.getContact('Harit', 'a@a.com');
        Case c1=ServiceTestFactory.getCase11('CRM',cont.id);
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
    @isTest
    static void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Case c1=ServiceTestFactory.getCase9('CRM');
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        List<Id> ccecList = new List<Id>();
        ccecList.add(ccec1.Id);
        ManualCCECOutboundAPI.SendCCEC(ccecList);  
        Test.stopTest();     
    }
}