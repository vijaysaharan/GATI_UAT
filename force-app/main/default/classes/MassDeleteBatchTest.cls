@isTest
public class MassDeleteBatchTest {    
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account ', CreatedDate = System.today().addDays(-31)));
        insert accounts;
    }
    
    @isTest
    static void testBatchForAccount() {
        Test.startTest();
        MassDeleteBatch.runBatch('Account',String.valueOf(System.today()));
        Test.stopTest();
    }
}