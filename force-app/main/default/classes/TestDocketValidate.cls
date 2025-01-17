@isTest
public class TestDocketValidate {
	public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('DocketNoVerification').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"177697167","companyId":"GKE","result":[{"DOCKET_NO":"177697167"}]}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testDocketValidate(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        try{
         	DocketValidate valid = new DocketValidate();
            valid.validate('177697167');
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        //DocketValidate.validate('111111111');
    }
}