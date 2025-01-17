@isTest
public class CreateWeeklyCsvOfCustomerConnectTest {
    public class MyWebServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response": "Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
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
        cc.CreatedDate = System.today().addDays(-2);
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
        cc1.CreatedDate = System.today().addDays(-2);
        cc1.Visit__c = testVisit.Id;
        cc1.OwnerId = user;
        lstCus.add(cc1);
        insert lstCus;
    }
    
    @isTest
    static void creates3RecordTest(){
        Test.setMock(HttpCalloutMock.class, new MyWebServiceMock());
        test.startTest();
        Date sDate = System.today().addDays(-10);
        Date eDate = System.today().addDays(10);
        CreateWeeklyCsvOfCustomerConnect sc = new CreateWeeklyCsvOfCustomerConnect();
		sc.execute(null);
        test.stopTest();
    }
}