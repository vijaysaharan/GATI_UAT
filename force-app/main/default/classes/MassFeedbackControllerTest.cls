@IsTest
public class MassFeedbackControllerTest {
    @IsTest
    static void testCsvData() {
        List<Map<String, String>> testData = new List<Map<String, String>>();
        Map<String, String> rowData1 = new Map<String, String>{
            'CUSTOMER CODE' => 'Code1',
            'NEWUSER' => 'user1@example.com'
        };
        Map<String, String> rowData2 = new Map<String, String>{
            'CUSTOMER CODE' => 'Code2',
            'NEWUSER' => 'user2@example.com'
        };
        testData.add(rowData1);
        testData.add(rowData2);

        Account testAccount1 = new Account(Name = 'Test Account 1', GATI_Customer_Code__c = 'Code1');
        Account testAccount2 = new Account(Name = 'Test Account 2', GATI_Customer_Code__c = 'Code2');
        List<Account> testAccounts = new List<Account>{ testAccount1, testAccount2 };
        insert testAccounts;

        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'user1@example.com', AccountId = testAccount1.Id, Contact_type__c = 'CSAT');
        //Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'user2@example.com', AccountId = testAccount2.Id, Contact_type__c = 'CSAT');
        List<Contact> testContacts = new List<Contact>{ testContact1 };
        insert testContacts;
        Test.startTest();
        Boolean result = MassFeedbackController.csvData(testData);
        Test.stopTest();
    }
}