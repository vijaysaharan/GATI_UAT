@isTest
public class MapPlotTest {

    @isTest
    public static void getAllRelatedAccountTest(){
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address", "lat" : "28.234","lng":"28.45"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        List<Account> accList = new List<Account>();
        Account acc1=new Account(
            Name='TestAccount' , 
            Customer_Category__c='KEA',
            Geolocation_Address__Latitude__s=28.6130176,
            Geolocation_Address__Longitude__s=77.3521408, 
            Billingpostalcode='521180', 
            GATI_Company_Code__c = '102',
            Address__c = 'Test Address',
            OwnerId = UserInfo.getUserId()
        );
        accList.add(acc1);
        Account acc2=new Account(
            Name='TestAccount' , 
            Customer_Category__c='Strategic',
            Geolocation_Address__Latitude__s=29.6130176,
            Geolocation_Address__Longitude__s=78.3521408, 
            Billingpostalcode='521180', 
            GATI_Company_Code__c = '102',
            Address__c = 'Test Address'
        );
        accList.add(acc2);
        Account acc3=new Account(
            Name='TestAccount' , 
            Customer_Category__c='Retail',
            Geolocation_Address__Latitude__s=null,
            Geolocation_Address__Longitude__s=null, 
            Billingpostalcode='521180', 
            GATI_Company_Code__c = '102',
            Address__c = 'Test Address'
        );
        accList.add(acc3);
        insert accList;
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
        l.Geolocation_Address__Latitude__s = 28.465743;
        l.Geolocation_Address__Longitude__s = 74.235436;
        l.Working_start_Date__c=system.today()-3;
        l.Product__c = '100000005';
        insert l;
        String user = UserInfo.getUserId();
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Check_In_Address__c = 'Test Customer Address';
        cc.Check_In_Location__Latitude__s = 28.603447907914237;
        cc.Check_In_Location__Longitude__s =  77.34438116931993;
        cc.Visit_End_Date__c =System.now();
        cc.Check_In_Time__c = System.now();
        cc.Customer_Code__c = acc1.Id;
        cc.Lead__c = l.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.OwnerId = user;
        insert cc;
        
        Test.startTest();
        MapPlot.getAllRelatedAccount(cc.Id);
        try{
           List<MapPlot.LocationWrapper> result  = MapPlot.getAllRelatedAccount(acc1.Id);
        }catch(exception e){}
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