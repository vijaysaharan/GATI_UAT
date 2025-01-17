@isTest
public class Customer360Trigger_Test {
    @isTest
    private static void createTestDataCustomer360andSalesKRA(){
        Sales_KRA__c salesKRA1 = new Sales_KRA__c();
        salesKRA1.Name = 'TestSales';
        salesKRA1.Month__c = '10';
        salesKRA1.Year__c = '2022';
        salesKRA1.Remarks__c = 'test sales kra';
        salesKRA1.Target__c = 8907543;
        salesKRA1.Product__c = 'SUR EXPRESS';
        salesKRA1.Account_Type__c = 'MSME';
        salesKRA1.KAM_KAE__c = UserInfo.getUserId();
        salesKRA1.Zone__c = 'BOMZ';
        insert salesKRA1;
        Account a1 = new Account();
        a1.Name = 'Test1';
        a1.GATI_Company_Code__c = '102';
        a1.Billingpostalcode = '409012';
        a1.Contract_end_date__c = System.today().addDays(20);
        a1.Contract_Status__c = 'Extended';
        a1.Remarks__c = 'Extended';
        a1.Customer_Category__c = 'MSME';
        a1.OwnerId = UserInfo.getUserId();
        insert a1;
        
        Customer360__c cust = new Customer360__c();
        cust.Month_Year__c = 'Oct-22';
        cust.Customer_Code__c = a1.Id;
        cust.Product__c = 'SUR EXPRESS';
        cust.Customer360_Id__c = '12345678.102.Oct-22.SUR EXPRESS';
        insert cust;
        for(integer i=1;i<=12;i++){
            TargetUpdateOnCustomer360Batch.findMonthName(i);
        }
    }
}