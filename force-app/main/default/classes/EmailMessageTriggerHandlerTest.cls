@isTest
public class EmailMessageTriggerHandlerTest {
	@isTest
    public static void updateFirstResponseOnCaseTest(){
        Case newCase =  New Case();
        newCase.Subject = 'Test Email To Case';
        newCase.Priority = 'Normal';
        newCase.Origin = 'Email';
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        newCase.Description = 'Hi Test, You Are Sending Test.';
        insert newCase;
        List<EmailMessage> eList = new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.Subject = 'Test Subject';
        emailMsg.HtmlBody = 'Test Html Body';
        emailMsg.TextBody = 'Test Text Body';
        emailMsg.FromAddress = 'test@test.com';
        emailMsg.FromName = 'Test From Name';
        emailMsg.Status = '3';
        emailMsg.ParentId = newCase.Id;
        eList.add(emailMsg);
        EmailMessage emailMsg2 = new EmailMessage();
        emailMsg2.Subject = 'Test Subject';
        emailMsg2.HtmlBody = 'Test Html Body';
        emailMsg2.TextBody = 'Test Text Body';
        emailMsg2.ToAddress = 'test@test.com';        
        emailMsg2.Incoming = true;
        emailMsg2.FromName = 'Test From Name';
        emailMsg2.Status = '3';
        emailMsg2.ParentId = newCase.Id;
        eList.add(emailMsg2);
        test.StartTest();
        	insert eList;
        test.StopTest();
    }
}