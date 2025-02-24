@isTest
public class ChatWindowNameControllerTest {
@testSetup
static void setupTestData() {
    // Create test LiveChatVisitors
    List<LiveChatVisitor> visitors = new List<LiveChatVisitor>{
        new LiveChatVisitor(),
        new LiveChatVisitor(),
        new LiveChatVisitor()
    };
    insert visitors;

    // Create test Contacts
    List<Contact> contacts = new List<Contact>{
        new Contact(FirstName = 'John', LastName = 'Doe'),
        new Contact(FirstName = 'Jane', LastName = 'Smith'),
        new Contact(FirstName = 'Alice', LastName = 'Brown')
    };
    insert contacts;

    // Create test LiveChatTranscripts
    List<LiveChatTranscript> transcripts = new List<LiveChatTranscript>{
        new LiveChatTranscript(ContactId = contacts[0].Id, LiveChatVisitorId = visitors[0].Id),
        new LiveChatTranscript(ContactId = contacts[1].Id, LiveChatVisitorId = visitors[1].Id),
        new LiveChatTranscript(ContactId = contacts[2].Id, LiveChatVisitorId = visitors[2].Id)
    };
    insert transcripts;
}

    @isTest
    static void testGetContactInfoWithValidIds() {
        // Get test LiveChatTranscripts
        List<LiveChatTranscript> transcripts = [SELECT Id FROM LiveChatTranscript];
        List<String> transcriptIds = new List<String>();
        for (LiveChatTranscript tc : transcripts) {
            transcriptIds.add(tc.Id);
        }

        // Call the method
        Test.startTest();
        List<String> contactNames = ChatWindowNameController.getContactInfo(transcriptIds);
        Test.stopTest();

        // Assert the results
        System.assertEquals(3, contactNames.size(), 'Expected 3 contact names');
        System.assert(contactNames.contains('John Doe'), 'Expected John Doe in the list');
        System.assert(contactNames.contains('Jane Smith'), 'Expected Jane Smith in the list');
        System.assert(contactNames.contains('Alice Brown'), 'Expected Alice Brown in the list');
    }

    @isTest
    static void testGetContactInfoWithEmptyIds() {
        // Call the method with an empty list
        Test.startTest();
        List<String> contactNames = ChatWindowNameController.getContactInfo(new List<String>());
        Test.stopTest();

        // Assert the results
        System.assertEquals(0, contactNames.size(), 'Expected no contact names for empty input');
    }

    @isTest
    static void testGetContactInfoWithNoMatchingRecords() {
        // Call the method with non-existent IDs
        List<String> nonExistentIds = new List<String>{'aNonExistentId1', 'aNonExistentId2'};

        Test.startTest();
        List<String> contactNames = ChatWindowNameController.getContactInfo(nonExistentIds);
        Test.stopTest();

        // Assert the results
        System.assertEquals(0, contactNames.size(), 'Expected no contact names for non-matching IDs');
    }
}