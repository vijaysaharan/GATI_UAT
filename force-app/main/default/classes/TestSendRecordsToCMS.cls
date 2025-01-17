@isTest
public class TestSendRecordsToCMS {
    
    @testSetup static void createData(){
        Account testAccount = new Account(name = 'syed' , Customer_Category__c = 'KEA' , Billingpostalcode = '842003', Customer_Code__c = 521180.001);
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            MobilePhone = '1234567890',
            MailingState = 'Rajsthan',
            MailingCity = 'Pallu',
            MailingStreet = 'street 7'
        );
        insert testContact;
    }
    
    static testmethod void testAccountandContact(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        SendRecordsToCMS.FlowInput in1 = new SendRecordsToCMS.FlowInput();
        in1.str1 = testAccount.Id;
        in1.str2 = testContact.Id;
        Test.startTest();
        SendRecordsToCMS.calloutMethod(new List<SendRecordsToCMS.FlowInput>{in1});
        Test.setMock(HttpCalloutMock.class, new TestSendRecordsToCMSMock());   
        Test.stopTest();    
    }
    
    static testmethod void testforAccount(){
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        SendRecordsToCMS.FlowInput in1 = new SendRecordsToCMS.FlowInput();
        in1.str1 = testAccount.Id;
        Test.startTest();    
        SendRecordsToCMS.calloutMethod(new List<SendRecordsToCMS.FlowInput>{in1});
        Test.setMock(HttpCalloutMock.class, new TestSendRecordsToCMSMock());   
        Test.stopTest();
    }
}