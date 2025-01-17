@isTest
private class createCaseFromDocketNumberTest {

    @isTest
    static void testCreateCase() {
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('docketNo', '1234');
        requestBody.put('Type', 'Delayed Connection');
        requestBody.put('Sub_Type__c', 'STC COOLING');
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        String mockApiResponse = '{"requid":"GS21004","result":"successful","sErrMsg":"","response":[{"docketNo":"202560616","companyId":"GKE","result":[{"CONSIGNEE_MOBILE_NO":"8976546778","STOCK_OU":"HYDN","DOCKET_NO":"202560616","CONSIGNOR_EMAIL":"nishant@tirupaticolorpens.com","CONSIGNEE_PINCODE":"500002","DOCKET_TYPE":"OWNERS RISK","COD_TYPE":"G","DECL_CARGO_VAL":5000,"CONSIGNOR_NAME":"TESTMATRIX","BOOKING_STN":"HYDN","DOCKET_STATUS":"BOOKED","CONTRACT_NO":"HYDN/CON/08/2021/1020034","ASSURED_DLY_DT":"2021-10-16","CONSIGNOR_MOBILE_NO":"8789098989","ACTUAL_WT":15,"BKG_DT":"2021-10-14","CUSTOMER_CODE":"31023301","DELIVERY_STN":"CHR","CONSIGNOR_PINCODE":"500014","PROD_SERV_CODE":"21","CHARGED_WT":15,"NO_OF_PKGS":1,"CONSIGNEE_NAME":"TESTMATRIX","APPROVED_DLY_DT":"2021-10-14","DEBIT_STATUS":"NO"}],"sErrMsg":""}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        Test.startTest();
        createCaseFromDocketNumber.createCase();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateCaseFailed() {
        RestContext.response = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('docketNo', '1234');
        requestBody.put('Type', 'Delayed Connection');
        requestBody.put('Sub_Type__c', 'STC COOLING');
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        String mockApiResponse = '{"requid":"GS21004","result":"failed","sErrMsg":"","response":[{"docketNo":"202560616","companyId":"GKE","result":[],"sErrMsg":""}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        Test.startTest();
        createCaseFromDocketNumber.createCase();
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private String mockResponse;

        public MockHttpResponseGenerator(String mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}