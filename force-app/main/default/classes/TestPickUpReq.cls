@istest
public class TestPickUpReq {
    /*
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        
        public HTTPResponse respond(HTTPRequest req) {
            
           // System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS31005","result":"failed", "sErrMsg":"Pickup Address 3 Required","response":[]}');
            res.setStatusCode(300);
            return res;
        }
    }
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
           // System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            //System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS31005","result":"successful", "sErrMsg":"","response":[]}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testmethod void Test1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Case c1 = ServiceTestFactory.getCase7('GEMS');
        List<String> caseList = new List<String>();
        caseList.add(c1.Id);
       // test.startTest();
        Pickup_req_OutboundAPI.calloutMethod(caseList);
        test.stopTest();
    }
    static testmethod void Test2(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Case c1 = ServiceTestFactory.getCase7('GEMS');
        List<String> caseList = new List<String>();
        caseList.add(c1.Id);
        //test.startTest();
        Pickup_req_OutboundAPI.calloutMethod(caseList);
        test.stopTest();
    }*/
}