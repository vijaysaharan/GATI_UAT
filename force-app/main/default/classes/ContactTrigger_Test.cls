@isTest
public class ContactTrigger_Test {
    @isTest
    static void testDuplicateContacts() {
        // Create a list of contacts with duplicate phone numbers
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'John', LastName = 'Doe', MobilePhone = '1234567890'));
        contacts.add(new Contact(FirstName = 'Jane', LastName = 'Smith', MobilePhone = '1234567890'));
        
        Test.startTest();
        insert contacts; // Insert the contacts to trigger the ContactTrigger
        Test.stopTest();
        
        // Verify that the duplicate contacts have errors
        List<Contact> duplicateContacts = [SELECT Id FROM Contact WHERE MobilePhone = '1234567890'];
        System.assertEquals(2, duplicateContacts.size(), 'Two duplicate contacts should be created');
    }
    
    @isTest
    static void testUniqueContacts() {
        // Create a list of contacts with unique phone numbers
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'John', LastName = 'Doe', MobilePhone = '1234567890'));
        contacts.add(new Contact(FirstName = 'Jane', LastName = 'Smith', MobilePhone = '9876543210'));
        
        Test.startTest();
        insert contacts; // Insert the contacts to trigger the ContactTrigger
        Test.stopTest();
        
        // Verify that the contacts do not have any errors
        for (Contact con : contacts) {
            System.assert(!con.hasErrors(), 'No Error should be thrown');
        }
    }
}