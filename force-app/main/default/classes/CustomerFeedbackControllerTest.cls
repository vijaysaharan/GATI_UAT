@IsTest
public class CustomerFeedbackControllerTest {
    @IsTest
    static void testConstructor_AccountId() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Set the current page parameter for accountId
        System.currentPageReference().getParameters().put('accountId', testAccount.Id);
        
        // Create an instance of the customerFeedbackController class
        customerFeedbackController controller = new customerFeedbackController();
        
        // Assert the values
        System.assertEquals(testAccount.Id, controller.accountId);
        System.assertEquals(testAccount.Name, controller.accountName);
        System.assertEquals(null, controller.contactId);
        System.assertEquals(null, controller.contactName);
        System.assertEquals(null, controller.Designation);
        System.assertEquals(null, controller.contactEmail);
        System.assertEquals(null, controller.contactPhone);
    }
    
    @IsTest
    static void testConstructor_ContactId() {
        // Create test contact
        Contact testContact = new Contact(FirstName = 'Syed', LastName = 'Shahid', Designation__c = 'Salesforce Developer', Email = 'simam@kloudracc.com', MobilePhone = '8766485617');
        insert testContact;
        
        // Set the current page parameter for contactId
        System.currentPageReference().getParameters().put('contactId', testContact.Id);
        
        // Create an instance of the customerFeedbackController class
        customerFeedbackController controller = new customerFeedbackController();
        
        // Assert the values
        System.assertEquals(null, controller.accountId);
        System.assertEquals(null, controller.accountName);
        System.assertEquals(testContact.Id, controller.contactId);
        System.assertEquals(testContact.FirstName + ' ' + testContact.LastName, controller.contactName);
        System.assertEquals(testContact.Designation__c, controller.Designation);
        System.assertEquals(testContact.Email, controller.contactEmail);
        System.assertEquals(testContact.MobilePhone, controller.contactPhone);
    }
    
    @IsTest
    static void testConstructor_NoParameters() {
        // Create an instance of the customerFeedbackController class
        customerFeedbackController controller = new customerFeedbackController();
        
        // Assert the values
        System.assertEquals(null, controller.accountId);
        System.assertEquals(null, controller.accountName);
        System.assertEquals(null, controller.contactId);
        System.assertEquals(null, controller.contactName);
        System.assertEquals(null, controller.Designation);
        System.assertEquals(null, controller.contactEmail);
        System.assertEquals(null, controller.contactPhone);
    }
}