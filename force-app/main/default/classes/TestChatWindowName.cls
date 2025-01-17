@isTest
public class TestChatWindowName {
    @isTest
    public static void testClass(){
        LiveChatTranscript l = new LiveChatTranscript();
        Contact c = new Contact();
        c.LastName = 'a';
        insert c;
        LiveChatVisitor lv = new LiveChatVisitor();
        insert lv;
        l.ContactId = c.Id;
        l.LiveChatVisitorId = lv.id;
        insert l;
        Test.startTest();
        ChatWindowNameController.getContactInfo(l.Id);
        Test.stopTest();
    }
}