@isTest
public class MassEmailUtilityTest {
    @isTest
    public static void testSendEmail() {
        // Test data
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate LIMIT 1];
        Id orgWideDefaultId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        String userEmail = 'simam@kloudrac.com';
        String customerName = 'Syed Shahid Imam';
        Account testAccount = new Account(Name = 'Test Account', GATI_Customer_Code__c = 'Code1');
        Contact textContact = new Contact(FirstName='Test', LastName='Test',AccountId=testAccount.Id);
        
        Test.startTest();
        
        // Call the method to be tested
        MassEmailUtility.sendEmail(userEmail,testAccount.Id,textContact.Id,orgWideDefaultId,emailTemplate, null);
        Test.stopTest();
    }
}