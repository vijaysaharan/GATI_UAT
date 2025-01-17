@isTest
public class GeoLocationController_Test {
    
     @testSetup
    static void setupTestData() { 
        User u = new User(
            Id = UserInfo.getUserId()
        );
        u.Grade__c = 'M1';
        update u;
        Travel_Policy__c tr = new Travel_Policy__c(
            Name = 'M1',
            TwoWheelerEntitlement__c = 3.5,
            FourWheelerEntitlement__c = 10.5

        );
        insert tr;
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Organization_Master__c om = new Organization_Master__c();
        om.Name = '335524';
        om.RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert om;
        Lead l = new Lead();
        l.Email='test23456543@gmail.com';
        l.LastName ='Test Lead';
        l.Status ='New';
        l.PostalCode =om.Name;
        l.MobilePhone ='9870006578';
        l.Company ='Test Industries';
        l.Working_start_Date__c=system.today()-3;
        l.Product__c = 'AIR';
        insert l;
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = u.Id,
            Mode__c = 'Two wheeler',
            Visit_Start_DateTime__c = System.now(),
            Source_Address__c = 'Test Address',
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408,
            Destination_Geo_Coordinate__Latitude__s = 28.603447907914237,
            Destination_Geo_Coordinate__Longitude__s = 77.34438116931993
        );
        insert testVisit;
        String user = u.Id;
        List<Customer_Connect__c> lstCus = New List<Customer_Connect__c>();
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Check_In_Time__c = System.now();
        cc.Check_In_Location__Latitude__s = 28.78456;
        cc.Check_In_Location__Longitude__s = 29.78456;
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = l.Id;
        cc.Visit__c = testVisit.Id;
        cc.OwnerId = user;
        cc.Accompanied__c = 'Yes';
        cc.AcompaniedWith__c = user;
        lstCus.add(cc);
        Customer_Connect__c cc1 = new Customer_Connect__c();
        cc1.Call_Type__c = 'Sales Call';
        cc1.Sub_Type__c = 'Contract Signoff';
        cc1.Visit_Start_Date__c = System.now();
        cc1.Visit_Status__c = 'Planned';
        cc1.Visit_Mode__c = 'Virtual Meet';
        cc1.Lead__c = l.Id;
        cc1.Visit__c = testVisit.Id;
        cc1.OwnerId = user;
        lstCus.add(cc1);
        insert lstCus;
    }
    @isTest
    public static void checkForOwnerTest(){
        Customer_Connect__c cc = [Select Id From Customer_Connect__c Limit 1];
        GeoLocationController.checkForOwner(cc.Id);
    }
    
    @isTest
    private static void geoLocationDataCreate(){
        Customer_Connect__c cc = [Select Id,AcompaniedWith__c From Customer_Connect__c limit 1];
        Customer_Connect__c cc1 = [Select Id,AcompaniedWith__c From Customer_Connect__c Where Customer_Code__c = null limit 1];
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        Test.startTest();
        GeoLocationController.CheckGeoLocation(cc.Id);
        GeoLocationController.CheckGeoLocationCheckOut(cc.Id);
        GeoLocationController.UpdateGeoLocationWrapper res = GeoLocationController.UpdateCheckInLocationCheckOut(cc.Id,21.45324,80.1121,'No',cc.AcompaniedWith__c,'Test','Test2');
        GeoLocationController.UpdateCheckInLocation(cc1.Id,21.24245,80.11231);
        Test.stopTest();
        
    }
    
    @isTest
    public static void createExpenseFromCustomerConnectTest(){
        Customer_Connect__c cc = [Select Id,AcompaniedWith__c From Customer_Connect__c limit 1];
        String mockResponseBody = '{ "routes": [ { "distanceMeters": 1234567 } ] }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1(mockResponseBody, 200));
        
        Test.startTest();
        GeoLocationController.createExpenseFromCustomerConnect(cc.Id,cc.AcompaniedWith__c);
        Test.stopTest();
    }
    
    @isTest
    public static void updateAccountLocationTest(){
        Customer_Connect__c cc = [Select Id From Customer_Connect__c limit 1];
        Test.startTest();
        GeoLocationController.updateAccountLocation(cc.Id);
        GeoLocationController.updateLeadLocation(cc.Id);
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