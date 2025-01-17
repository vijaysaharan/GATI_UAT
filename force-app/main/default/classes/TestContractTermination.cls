@istest
public class TestContractTermination {
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('Contract_Termination').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"failed", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('Contract_Termination').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testmethod void testTermination(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Account a1 = TestFactory.insertAccount2('term'+Datetime.now(),'101',Date.newInstance(2021,08,13),Date.newInstance(2021,08,16),12,'110011');
        List<String> accList = new List<String>();
        accList.add(a1.Id);
        Contract_termination.calloutMethod(accList);
    }
    static testmethod void testTermination2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Account a1 = TestFactory.insertAccount2('term'+Datetime.now(),'101',Date.newInstance(2021,08,13),Date.newInstance(2021,08,16),12,'110011');
        List<String> accList = new List<String>();
        accList.add(a1.Id);
        Contract_termination.calloutMethod(accList);
    }
}