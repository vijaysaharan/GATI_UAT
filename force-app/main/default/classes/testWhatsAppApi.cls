@istest
public class testWhatsAppApi {
   

    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals('https://bot.surbo.io/opt/v1/transaction_message_push', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response_code": 0, "response_message": "message successfully published.", "msg_id": "47c07fdd9a7e44fa8ff69b9c82e6779a"}');
            res.setStatusCode(200);
            return res;
        }
    
    }
    
    @istest static void testWhatsApp(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        List<FlowInput> fList = new List<FlowInput>();
         test.startTest();
        FlowInput f = new FlowInput();
        f.str1 = '9731687426';
        f.str2 = '4127237~virat~abc~aaa~agag';
        fList.add(f);
        
        WhatsAppApi.calloutMethod(fList);
       // WhatsAppApiCall.WhatsAppCallOut('9731687426','4127237~virat~abc~aaa~agag');
        Test.stopTest();
       
    }
    
     

    
}