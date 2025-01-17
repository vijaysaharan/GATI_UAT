@istest
public class testGeneratepdf {
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
          //  System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
           // System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21003","result":"successful", "sErrMsg":"","response":{"contractNo":"HYDN/CON/12/2020/1020007","result":""}}');
            res.setStatusCode(200);
            return res;
        }
    }
        public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
           // System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
          //  System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21003","result":"successful", "sErrMsg":"","response":{"contractNo":"HYDN/CON/12/2020/1020007","result":"JVBERi0xLjQKJeLjz9MKMyAwIG9iago8PC9UeXBl"}}');
            res.setStatusCode(200);
            return res;
        }
    }
       static testmethod void testgeneratepdf1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
       Quote q1 = TestFactory.insertQuote('HYDN/CON/12/2020/1020007','name1','Print','BoundPaper','LETTER OF OFFER','102');
        List<String> qtList = new List<String>();
        qtList.add(q1.Id);
        Test.startTest();
        GeneratePDF.getPDFData(qtList);
        Test.stopTest();
    }
    static testmethod void testgeneratepdf2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Quote q1 = TestFactory.insertQuote('HYDN/CON/12/2020/1020007','name1','Print','BoundPaper','LETTER OF OFFER','102');
        List<String> qtList = new List<String>();
        qtList.add(q1.Id);
        Test.startTest();
        GeneratePDF.getPDFData(qtList);
        Test.stopTest();
    }

}