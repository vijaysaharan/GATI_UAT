@isTest
public class Test_GoogleApiApex {
    @isTest
    static void testParseJSONResponse() {
        Decimal testLat = 37.7749;
        Decimal testLong = -122.4194;

        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));

        Test.startTest();
        String address = GoogleApiApex.parseJSONResponse(testLat, testLong);
        Test.stopTest();
        System.assertEquals('Mock Address', address);
    }
    
    @isTest
    static void testParseJSONResponseByAddress() {
        String testStreet = '123 Test Street';
        String testPostalCode = '12345';
        String testCity = 'Test City';
        String testState = 'Test State';
        String testCountry = 'Test Country';

        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address"}]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));

        Test.startTest();
        String address = GoogleApiApex.parseJSONResponseByAddress(testStreet, testPostalCode, testCity, testState, testCountry);
        Test.stopTest();
        System.assertEquals('Mock Address', address);
    }
    
    @isTest
    static void testGetLatLongFromAddress() {
        String testAddress = 'Ward no 7, Chandari Bari, Purabsar, Rawatsar, Hanumangarh, Rajasthan 335524';

        String mockApiResponse = '{"results":[{"formatted_address":"Mock Address","geometry":{"location":{"lat":37.7749,"lng":-122.4194}}}],"status":"OK"}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));

        Test.startTest();
        Map<String, Object> result = GoogleApiApex.getLatLongFromAddress(testAddress);
        Test.stopTest();
        System.assertEquals(37.7749, result.get('lat'));
        System.assertEquals(-122.4194, result.get('lng'));
        System.assertEquals('Mock Address', result.get('formatted_address'));
    }
    
    @isTest
    static void testGetDistanceBetweenLatLog() {
        Decimal orgLat = 12.345678;
        Decimal orgLog = 98.765432;
        Decimal desLat = 23.456789;
        Decimal desLog = 87.654321;
        
        String mockResponseBody = '{ "routes": [ { "distanceMeters": 1234567 } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1(mockResponseBody, 200));
		Test.startTest();
        Integer res = GoogleApiApex.getDistanceBetweenLatLog(orgLat, orgLog, desLat, desLog);
		Test.stopTest();
    }
    
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;

        public MockHttpResponseGenerator1(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody);
            response.setStatusCode(statusCode);
            return response;
        }
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