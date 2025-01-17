@isTest(SeeAllData=true)
public class GeoLocation_Test {
    @isTest
    private static void geoLocationTestData(){
         Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Lead ld = [select id,OwnerId from lead limit 1];
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Visit_End_Date__c =System.now()+1;
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = ld.Id;
        insert cc;
        
        Journey_Plan__c jp = new Journey_Plan__c();
        jp.Customer_Connects__c = cc.Id;
        insert jp;
         PageReference testPage = Page.GeoLocation; 
       	Test.setCurrentPage(testPage);
        ApexPages.StandardController controller = new  ApexPages.StandardController(cc);
        testPage.getParameters().put('Id', String.valueOf(cc.Id));
        GeoLocation obj = new GeoLocation(controller);
        
    }
}