@isTest
public class CreateSalesKRAFromCustomer360Test {
    @testSetup static void makeData(){
        List<Account> accList = new List<Account>();
        Account testAccount1 = new Account(Name = 'Test Account 1', Customer_Category__c = 'Retail');
        accList.add(testAccount1);
        Account testAccount2 = new Account(Name = 'Test Account 2', Customer_Category__c = 'MSME');
        accList.add(testAccount2);
        insert accList;
        
        List<Customer360__c> cusList = new List<Customer360__c>();
        Customer360__c test360_1 = new Customer360__c(
            Customer_Code__c = testAccount1.Id,
            AccountOwner__c = UserInfo.getUserId(),
            MTD__c = 200,
            Product__c = 'AIR EXPRESS',
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            As_on_date__c = System.Today(),
            Customer360_Id__c = '15226034.102.OCT-2022.SUR EXPRESS'
        );
        cusList.add(test360_1);
        Customer360__c test360_2 = new Customer360__c(
            Customer_Code__c = testAccount2.Id,
            AccountOwner__c = UserInfo.getUserId(),
            MTD__c = 200,
            Product__c = 'STANDARD',
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            Customer360_Id__c = '15226035.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-32)
        );
        cusList.add(test360_2);
        Customer360__c test360_3 = new Customer360__c(
            Customer_Code__c = testAccount1.Id,
            AccountOwner__c = UserInfo.getUserId(),
            MTD__c = 200,
            Current_Month_OS__c = 200,
            Product__c = 'STANDARD',
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,            
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            Customer360_Id__c = '15226036.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-92)
        );
        cusList.add(test360_3);
        Customer360__c test360_4 = new Customer360__c(
            Customer_Code__c = testAccount2.Id,
            AccountOwner__c = UserInfo.getUserId(),
            MTD__c = 200,
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            Product__c = 'AIR EXPRESS',
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            Customer360_Id__c = '15226037.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-182)
        );
        cusList.add(test360_4);
        insert cusList;
        Sales_KRA__c testKRA = new Sales_KRA__c(KAM_KAE__c = UserInfo.getUserId(),
                                                Product__c = 'AIR EXPRESS',
                                                Account_Type__c = 'MSME',
                                                Month__c = '7',
                                                Year__c = '2024',
                                                Zone__c = 'BLRZ',
                                                Unique__c = UserInfo.getUserId() + 'MSME' + 'AIR EXPRESS' + '7' + '2024',
                                                OwnerId = UserInfo.getUserId(),
                                                Target__c = 0,
                                                Achievement_Amount_INR__c = 100
                                               );
        insert testKRA;
    }
    
    @isTest public static void createSalesKRATest(){
        test.startTest();
        //CreateSalesKRAFromCustomer360 sc = new CreateSalesKRAFromCustomer360(null, null);
        CreateSalesKRAFromCustomer360 sc = new CreateSalesKRAFromCustomer360();
        sc.execute(null);
        database.executeBatch(new CreateSalesKRAForLastMonthBatch(),2000);
        test.stopTest();
    }
}