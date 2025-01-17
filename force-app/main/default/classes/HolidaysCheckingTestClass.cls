@isTest
public class HolidaysCheckingTestClass {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful","status":{"desc":"NA"},"sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @istest static void testHolidays(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact c = TestFactory.getContact('TestName', 'test@gmail.com');
        Case cs = ServiceTestFactory.getCase11('XYZ',c.id);
    }
}