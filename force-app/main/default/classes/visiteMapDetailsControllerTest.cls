@isTest
public class visiteMapDetailsControllerTest {

    @isTest
    public static void testGetLocations() {
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Organization_Master__c om = new Organization_Master__c();
        om.Name = '335524';
        om.RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert om;
        Lead l = new Lead();
        l.Email='test87645@gmail.com';
        l.LastName ='Test Lead';
        l.Status ='New';
        l.PostalCode =om.Name;
        l.MobilePhone ='9000986578';
        l.Company ='Test Industries';
        l.Working_start_Date__c=system.today()-3;
        insert l;
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = UserInfo.getUserId(),
            Visit_Start_DateTime__c = System.now(),
            Source_Address__c = '1st Floor, Sector 63, Noida, Uttar Pradesh 201301, India',
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
        cc.Check_In_Address__c = '1st Floor, Sector 63, Noida, Uttar Pradesh 201301, India';
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = l.Id;
        cc.OwnerId = user;
        insert cc;
        Expense__c rec = new Expense__c();
        rec.Customer_Connect__c = cc.Id;
        rec.Visit__c = testVisit.Id;
        rec.RecordTypeId =  Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        rec.From_Date__c = Date.newInstance(cc.Visit_Start_Date__c.year(), cc.Visit_Start_Date__c.month(), cc.Visit_Start_Date__c.day());
        rec.Employee_Name__c = cc.OwnerId;
        insert rec;

        Test.startTest();
        List<visiteMapDetailsController.LocationWrapper> locations = new List<visiteMapDetailsController.LocationWrapper>();
        try{
         	locations = visiteMapDetailsController.getLocations(testVisit.Id);   
        }catch(Exception e){
        }
        Test.stopTest();

        //visiteMapDetailsController.LocationWrapper centerLocation = locations[0];
        //visiteMapDetailsController.LocationWrapper customerConnectLocation = locations[1];
    }
    
    @isTest
    static void getiframeUrlTest(){
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = UserInfo.getUserId(),
            Visit_Start_DateTime__c = System.now(),
            Source_Address__c = '1st Floor, Sector 63, Noida, Uttar Pradesh 201301, India',
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408,
            Destination_Geo_Coordinate__Latitude__s = 28.603447907914237,
            Destination_Geo_Coordinate__Longitude__s = 77.34438116931993
        );
        insert testVisit;
        Test.startTest();
        try{
            visiteMapDetailsController.getiframeUrl(testVisit.Id);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}