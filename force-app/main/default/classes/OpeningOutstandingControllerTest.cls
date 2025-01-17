@isTest
public class OpeningOutstandingControllerTest {
    public static List<Customer360__c> cust = new List<Customer360__c>();

    static void setUp()
    {
        Account acc=new Account();
        acc.Name='3 M INDIA LIMITED';
        acc.GATI_Customer_Code__c='16668001';
        acc.GATI_Company_Code__c='102';
        insert acc;
        
        Customer360__c cus1 = new Customer360__c();
        //cus1.Customer360_Id__c='16668001.102.NOV-2021.AIR EXPRESS';
        cus1.Customer_Code__c=acc.id;
        Datetime myDateTime = DateTime.parse('02/03/2022 11:46 AM');
        cus1.CreatedDate=myDateTime;
        cus1.Product__c='AIR EXPRESS';
        cus1.Processed__c=false;
        cus1.Current_Month_OS__c=1;
        cus1.Month_Opening_Outstanding__c=1;
        cust.add(cus1);
        
        Customer360__c cus2 = new Customer360__c();
        //cus2.Customer360_Id__c='16668001.102.NOV-2021.AIR EXPRESS';
        cus2.Customer_Code__c=acc.id;
        Datetime myDateTime1 = DateTime.parse('01/03/2022 11:46 AM');
        cus2.CreatedDate=myDateTime1;
        cus2.Product__c='AIR EXPRESS';
        cus2.Processed__c=false;
        cus2.Current_Month_OS__c=1;
        cus2.Month_Opening_Outstanding__c=1;
        cust.add(cus2);
        

        Customer360__c cus3 = new Customer360__c();
        //cus3.Customer360_Id__c='16668001.102.NOV-2021.SUR EXPRESS';
        cus3.Customer_Code__c=acc.id;
        Datetime myDateTime2 = DateTime.parse('02/05/2022 11:46 AM');
        cus3.CreatedDate=myDateTime2;
        cus3.Product__c='SUR EXPRESS';
        cus3.Processed__c=false;
        cus3.Current_Month_OS__c=1;
        cus3.Month_Opening_Outstanding__c=1;
        cust.add(cus3);
        
        Customer360__c cus4 = new Customer360__c();
        //cus4.Customer360_Id__c='16668001.102.NOV-2021.SUR EXPRESS';
        cus4.Customer_Code__c=acc.id;
        Datetime myDateTime3 = DateTime.parse('01/05/2022 11:46 AM');
        cus4.CreatedDate=myDateTime3;
        cus4.Product__c='SUR EXPRESS';
        cus4.Processed__c=false;
        cus4.Current_Month_OS__c=1;
        cus4.Month_Opening_Outstanding__c=1;
        cust.add(cus4);
                
    }

    static testmethod void testcheck() {        
        Test.startTest();
        OpeningOutstandingController objclass = new OpeningOutstandingController();
        OpeningOutstandingSchedular objSch = new OpeningOutstandingSchedular();
        objSch.execute(null);
        objclass.execute(null,cust);
        database.executeBatch(objclass);
        Test.stopTest();
        
    }
    
}