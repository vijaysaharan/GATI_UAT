@isTest
public class TestChatWindowNameController {
    @isTest
    public static void testClass(){
        LiveChatTranscript l = new LiveChatTranscript();
        Contact c = new Contact();
        c.LastName = 'a';
        insert c;
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        l.ContactId = c.Id;
        l.LiveChatVisitorId = visitor.Id;
        insert l;
        Test.startTest();
        ChatWindowNameController.getContactInfo(l.Id);
        Test.stopTest();
    }
}