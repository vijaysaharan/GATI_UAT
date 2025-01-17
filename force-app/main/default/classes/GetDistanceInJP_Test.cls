@istest
public class GetDistanceInJP_Test {
    
    
    
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals('https://apis.mapmyindia.com', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Server":"Adv-5400","version":"202110.19.5222","results":{"distances":[[0,13393.9]],"code":"Ok","durations":[[0,1230.8]]},"responseCode":200}');
            res.setStatusCode(200);
            return res;
        }
        
    }
    
    
    
    
    @istest static void testGetDistance(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        List<string> ab = new List<String>();

    ab.add('a0Vp00000087kPHEAY'); // In progress to create JP record in TestFactory
       
    GetDistanceInJP.getDistanceMethod(ab);
       
        
    }
   
    
    
    
    
    
}