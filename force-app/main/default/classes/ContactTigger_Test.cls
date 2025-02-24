@isTest
public class ContactTigger_Test {
    @isTest
    static void testDuplicateContacts() {
        // Create a list of contacts with duplicate phone numbers
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'John', LastName = 'Doe', Phone = '1234567890'));
        contacts.add(new Contact(FirstName = 'Jane', LastName = 'Smith', Phone = '1234567890'));
        
        // Insert the contacts
        Test.startTest();
        insert contacts;
        Test.stopTest();
    }
    
    @isTest
    static void testUniqueContacts() {
        // Create a list of contacts with unique phone numbers
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'John', LastName = 'Doe', Phone = '1234567890'));
        contacts.add(new Contact(FirstName = 'Jane', LastName = 'Smith', Phone = '9876543210'));
        
        // Insert the contacts
        Test.startTest();
        insert contacts;
        Test.stopTest();
        
        // Verify that the contacts do not have any errors
        for (Contact con : contacts) {
            System.assert(!con.hasErrors(), 'No Error should be thrown');
        }
    }
    
}