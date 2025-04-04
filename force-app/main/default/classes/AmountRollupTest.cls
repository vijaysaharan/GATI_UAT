@isTest
public class AmountRollupTest {
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

    @TestSetup
    static void makeData(){
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User testUser_1 = new User(
            Alias = 'syed96',
            Email ='syedshahid@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            Username = 'syedshahid@testorg.com', 
            LastName = 'syed001',  
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser_1;
        
        Organization_Master__c OrgMaster = new Organization_Master__c(
            Name = 'HYDN',
            RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Operation Unit').getRecordTypeId(),
            Service_User__c = UserInfo.getUserId()
        );
        insert OrgMaster;
        Account testAccount_1 = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId(),
            Customer_Category__c = 'MSME',
            Status__c = 'Customer',
            Associated_OU__c = OrgMaster.Id
        );
        insert testAccount_1;
    }
    
    @isTest
    public static void CreateAccount(){
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address", "lat" : "28.234","lng":"28.45"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        
        User testUser_1 = [SELECT Id FROM User WHERE Username = 'syedshahid@testorg.com' LIMIT 1];
        
        Account testAccount_1 = TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        testAccount_1.Amount__c = 100000;
        testAccount_1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
        testAccount_1.OwnerId = testUser_1.Id;
        update testAccount_1;
        
        Account testAccount_2 = TestFactory.getAccount('TestAccount10' , 'MSME', '521181', True);
        testAccount_2.ParentId = testAccount_1.Id;
        testAccount_2.Amount__c = 100000;
        testAccount_2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
        update testAccount_2;
        
        test.startTest();
        AmountRollupHandler.accountAmountRollup(New List<Account>{testAccount_2});
        
        testAccount_2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        update testAccount_2;
        
        AmountRollupHandler.accountAmountRollup(New List<Account>{testAccount_2});
        test.stopTest();
    }
    
    @isTest 
    public static void riskTestMethod(){
        List<Account> contractAccounts = new List<Account>();
        
        Account testAccount_1 = TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        testAccount_1.Amount__c = 100000;
        testAccount_1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
        contractAccounts.add(testAccount_1);
        update testAccount_1;
        
        Account testAccount_2 = TestFactory.getAccount('TestAccount10' , 'MSME', '521181', True);
        testAccount_2.ParentId = testAccount_1.Id;
        testAccount_2.Amount__c = 100000;
        testAccount_2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
        update testAccount_2;
        contractAccounts.add(testAccount_2);
        
        List<Account> customerAccounts = new List<Account>();
        Account testAccount_3 = new Account();
        testAccount_3.Name = 'Test1';
        testAccount_3.Risk_Covered_By__c = 'Test';
        testAccount_3.ParentId  = testAccount_1.Id;
        testAccount_3.BillingPostalCode = '324902';
        testAccount_3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
        customerAccounts.add(testAccount_3);
        
        Test.startTest();
        insert customerAccounts;
        
        contractAccounts.add(testAccount_3);        
        AmountRollupHandler.customerUserOwnerChange(contractAccounts);
        AmountRollupHandler.updateAccountType(contractAccounts);
        
        Test.stopTest();
    }
    
    @isTest
    public static void sendAmendmentTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"statusCode": 201}'));
        Account test_Account = [SELECT Id,Credit_Amount__c,Credit_Days__c,GATI_Customer_Code__c,GATI_Company_Code__c FROM Account LIMIT 1];
        
        test.startTest();
        test_Account.GATI_Customer_Code__c = '301202';
        test_Account.GATI_Company_Code__c = '102';
        test_Account.Credit_Amount__c = 100;
        test_Account.Credit_Days__c = 5;
        update test_Account;
        test.stopTest();
    }
}