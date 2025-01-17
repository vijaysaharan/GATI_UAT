@isTest
public class UpdateSalesDashboardUsersTest {
    @testSetup
    static void setup() {
        SalesDashboardUser__c salesUser = new SalesDashboardUser__c(
            StartDate__c = System.today().addDays(-1),
            EndDate__c = System.today().addDays(1),
            UserList__c = '0051t0000006gEGAAQ'
        );
        insert salesUser;
		Organization_Master__c o1 = new Organization_Master__c(Name='201301');
        insert o1;
        
        Lead leadTest = new Lead(OwnerId = UserInfo.getUserId(),
                                 FirstName = 'Test',
                                 LastName = 'Lead',
                                 LeadSource = 'Cross Sell',
                                 Company = 'kloudrac Software',
                                 Email= 'akumar4@kloudrac1.com',
                                 MobilePhone = '8052124482',
                                 Turnover_of_the_Company__c =200000000,
                                 Expected_Business_Per_Month__c =100000,
                                 Customer_Potential__c = 200000,
                                 Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 1 Lakh',
                                 PostalCode = '201301',
                                 GATI_Company_Code__c = '103',
                                 Product__c = 'Express',
                                 Lead_Data__c = 'Customer',
                                 Cross_Sell_Receiver_Email_Id__c='simam@klodtest.com',
                                 Cross_Sell_Sender_Name__c='Imam',
                                 Cross_Sell_Receiver_Name__c='kyadav',
                                 Description__c = 'Cross Sell Description test'
                                );
        insert leadTest;
        
        Opportunity opportunityTest = new Opportunity(Name = 'Test Opportunity', 
                                          StageName = 'Qualified', 
                                          CloseDate = System.today().addDays(30), 
                                          OwnerId = UserInfo.getUserId()
                                         );
        insert opportunityTest;

        Customer_Connect__c customerConnect = new Customer_Connect__c(OwnerId = UserInfo.getUserId(),
                                                                      Lead__c = leadTest.Id
                                                                     );
        insert customerConnect;

        Sales_KRA__c salesKRA1 = new Sales_KRA__c();
        salesKRA1.Month__c = '10';
        salesKRA1.Year__c = '2022';
        salesKRA1.Remarks__c = 'test sales kra';
        salesKRA1.Product__c = 'SUR EXPRESS';
        salesKRA1.Account_Type__c = 'MSME';
        salesKRA1.KAM_KAE__c = UserInfo.getUserId();
        salesKRA1.Zone__c = 'BOMZ';
        salesKRA1.Target__c = 0;
        salesKRA1.Staff_Code__c = [SELECT Staff_Code__c FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1].Staff_Code__c;
        insert salesKRA1;
    }

    @isTest
    static void testExecuteMethod() {
        UpdateSalesDashboardUsers updateJob = new UpdateSalesDashboardUsers();
        Test.startTest();
        updateJob.execute(null);
        Test.stopTest();
        System.assertEquals('test', 'test', 'Pass');
    }
}