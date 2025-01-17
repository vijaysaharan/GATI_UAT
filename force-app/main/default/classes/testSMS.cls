@istest
public class testSMS {
    
    
    
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals('https://japi.instaalerts.zone/httpapi/JsonReceiver', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ackid":"2097158823261808300","time":"2021-11-25 12:23:26","status":{"code":"200","desc":"Request accepted"}}');
            res.setStatusCode(200);
            return res;
        }
        
    }
    
    
    
    
    @istest static void testsmsapi1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        test.startTest();
        SmsAlertOutbound.SMSCallOut('9731687426','Your pickup request with reference number {#var#} has been successfully registered on {#var#} and is scheduled for {#var#}.Please check for details of prohibited items. https://www.gati.com/tools/prohibited-goods-for-shipping/ Gati-KWE');
        Test.stopTest();
        
    }
   
    
    
    
    
    
}