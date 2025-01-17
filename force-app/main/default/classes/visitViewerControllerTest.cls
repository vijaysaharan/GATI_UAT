@isTest
public class visitViewerControllerTest {
	@isTest
    public static void getLocationsTest() {
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Organization_Master__c om = new Organization_Master__c();
        om.Name = '335524';
        om.RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert om;
        Lead l = new Lead();
        l.Email='test@gmail.com';
        l.LastName ='Test Lead';
        l.Status ='New';
        l.PostalCode =om.Name;
        l.MobilePhone ='9876986578';
        l.Company ='Test Industries';
        l.Working_start_Date__c=system.today()-3;
        insert l;
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = UserInfo.getUserId(),
            Visit_Start_DateTime__c = System.now(),
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408,
            Destination_Geo_Coordinate__Latitude__s = 28.603447907914237,
            Destination_Geo_Coordinate__Longitude__s = 77.34438116931993
        );
        insert testVisit;
        String user = UserInfo.getUserId();
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Visit_End_Date__c =System.now()+1;
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = l.Id;
        cc.OwnerId = user;
        insert cc;
        
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address,address2,address3,address4"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        
    	Test.startTest();
        visitViewerController.getLocations('','');
        Test.stopTest();
    }
    
    @isTest
    public static void getRoleSubordinateUsersTest(){
        Test.startTest();
        visitViewerController.getRoleSubordinateUsers();
        Test.stopTest();
    }
    
    @isTest
    public static void getPicklistOptionsTest(){
        Test.startTest();
        visitViewerController.getPicklistOptions('Account','Customer_Category__c');
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