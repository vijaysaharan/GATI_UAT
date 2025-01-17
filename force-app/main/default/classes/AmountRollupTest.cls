@isTest
public class AmountRollupTest {
     /*
     * Author : Ashish(akumar4@kloudrac.com)
     * Description : Roll up Amount and update to the parent
     * Trigger Name : AmountRollup
     *  Test Class Name : AmountRollupTest(86%)
     * Created Date : 02-05-2022
     * Modifeid Date : 06-05-2022
     */
    
    
    @isTest
    public static void CreateAccount(){
        String mockApiResponse = '{"results": [{"formatted_address": "Mock Address", "lat" : "28.234","lng":"28.45"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User owner1 = new User(Alias = 'syed96',Email='syedshahid@testorg.com',EmailEncodingKey='UTF-8', Username='syedshahid@testorg.com', LastName='syed001',  
                               LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        insert owner1;
        String recordTypeId = [Select id, name from recordType where name='Customer Code'].Id;
        String recordTypeId1 = [Select id, name from recordType where name='Partner'].Id;
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        acc1.Amount__c = 100000;
        acc1.RecordTypeId = recordTypeId;
        acc1.OwnerId = owner1.Id;
        update acc1;
        Account acc2=TestFactory.getAccount('TestAccount10' , 'MSME', '521181', True);
        acc2.ParentId = acc1.Id;
        acc2.Amount__c = 100000;
        acc2.RecordTypeId = recordTypeId;
        update acc2;
        test.startTest();
        AmountRollupHandler.accountAmountRollup(New List<Account>{acc2});
        acc2.RecordTypeId = recordTypeId1;
        update acc2;
        AmountRollupHandler.accountAmountRollup(New List<Account>{acc2});
        test.stopTest();
    }
    
    @isTest 
    public static void riskTestMethod(){
        List<Account> contractAccount = new List<Account>();
         String recordTypeId = [Select id, name from recordType where name='Contract'].Id;
         String recordTypeIdCustomerCode = [Select id, name from recordType where name='Customer Code'].Id;
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        acc1.Amount__c = 100000;
        acc1.RecordTypeId = recordTypeId;
        contractAccount.add(acc1);
        update acc1;
        Account acc2=TestFactory.getAccount('TestAccount10' , 'MSME', '521181', True);
        acc2.ParentId = acc1.Id;
        acc2.Amount__c = 100000;
        acc2.RecordTypeId = recordTypeId;
        update acc2;
        contractAccount.add(acc2);
        List<Account> acList = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Test1';
        a1.Risk_Covered_By__c = 'Test';
        a1.ParentId  = acc1.Id;
        a1.BillingPostalCode = '324902';
        a1.RecordTypeId = recordTypeIdCustomerCode;
        acList.add(a1);
        Test.startTest();
        insert acList;
        contractAccount.add(a1);
        AmountRollupHandler.customerUserOwnerChange(contractAccount);
        AmountRollupHandler.updateAccountType(contractAccount);
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