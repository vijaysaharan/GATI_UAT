@isTest
public class visitStartAndEndControllerTest {
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
        insert l;
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = u.Id,
            Mode__c = 'Two wheeler',
            Visit_Start_DateTime__c = System.now(),
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408,
            Destination_Geo_Coordinate__Latitude__s = 28.603447907914237,
            Destination_Geo_Coordinate__Longitude__s = 77.34438116931993
        );
        insert testVisit;
        String user = u.Id;
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Check_In_Time__c = System.now();
        cc.Check_Out_Time__c = System.now();
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
        insert cc;
    }
    @isTest
    public static void getPicklistOptionsTest(){
        Test.startTest();
        visitStartAndEndController.getPicklistOptions('Opportunity','StageName');
        Test.stopTest();
    }
    
    @isTest
    public static void getTravelPriceForCurrentUserTest(){
        Test.startTest();
        visitStartAndEndController.getTravelPriceForCurrentUser();
        Test.stopTest();
    }
    
    @isTest
    static void testCheckForButton() {
        User testUser = new User(
            ProfileId = UserInfo.getProfileId(),
            FirstName = 'TestUserName',
            LastName = 'LastNameOfTest',
            Email = 'testuser@example.com',
            Username = 'testuser210723@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.startTest();
        System.runAs(testUser) {
            String result = visitStartAndEndController.checkForButton();
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateTodaysVisit() {
        Visit__c testVisit = new Visit__c(
            Mode__c = 'Two wheeler',
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408
        );
        
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address"}]}';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));

        Test.startTest();
        visitStartAndEndController.createTodaysVisit(testVisit);
        Test.stopTest();
        
    }

    @isTest
    static void testEndTodaysVisit() {
        Visit__c testVisit = [Select Id from Visit__c limit 1];
        Customer_Connect__c cc = [Select Id,AcompaniedWith__c From Customer_Connect__c limit 1];
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));

        Test.startTest();
         visitStartAndEndController.endTodaysVisit(28.603447907914237, 77.34438116931993, testVisit.Id,'Office','Test');
        Test.stopTest();
    }
    
    @isTest
    static void getCustomerConnectDataTest(){
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Mode__c = 'Two wheeler',
            Employee_Name__c = UserInfo.getUserId(),
            Visit_Start_DateTime__c = System.now(),
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408
        );
        insert testVisit;
        
        Test.startTest();
         visitStartAndEndController.ReturnVisitCustomer rtn = visitStartAndEndController.getCustomerConnectData();
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