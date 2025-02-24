@isTest
public class MassEmailUtilityTest {
    @isTest
    public static void testSendEmail() {
        // Test data
        String userEmail = 'simam@kloudrac.com';
        String customerName = 'Syed Shahid Imam';
        Account testAccount1 = new Account(Name = 'Test Account 1', GATI_Customer_Code__c = 'Code1');
        
        Test.startTest();
        
        // Call the method to be tested
        MassEmailUtility.sendEmail(userEmail, customerName, testAccount1.Id, null);
        
        Test.stopTest();
    }
}