@isTest(SeeAllData=True)
public class CustomerConnectUpdateCheckIn_Test {
    @isTest
    private static void createCustomerConnect(){
        Customer_Connect__c cc = [SELECT Id from Customer_Connect__c limit 1];
        Test.startTest();
        try{
        CustomerConnectUpdateCheckIn.updateCheckInTime(cc.Id);
        }Catch(Exception ex){
            System.debug('--- error--'+ex.getMessage());
        }
        Test.stopTest();
    }
	@isTest
    public static void getRevenueDetailsOfAccountTest(){
        Account acc1 = new Account();
        acc1.Name = 'testing1';
        acc1.AccountNumber = '74691';
        insert acc1;
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
        update acc1;
        Account acc = new Account();
        acc.Name = 'testing';
        acc.AccountNumber = '74692';
        acc.ParentId = acc1.Id;
        insert acc; 
        String monthYear = System.now().format('MMMM').substring(0,3).toUpperCase()+'-'+System.now().year();
        
        Customer360__c test360 = new Customer360__c(Customer_Code__c = acc.Id,
                                                    Month_Year__c = monthYear,
                                                    As_on_date__c = System.today(),
                                                    Product__c = 'AIR EXPRESS',
                                                    Customer360_Id__c = '30166101.102.'+monthYear+'-testing'
                                                   );
        insert test360;
        test.startTest();
        CustomerConnectUpdateCheckIn.getRevenueDetailsOfAccount(acc.Id);
        CustomerConnectUpdateCheckIn.getRevenueDetailsOfAccount(acc1.Id);
        test.stopTest();
    }
}