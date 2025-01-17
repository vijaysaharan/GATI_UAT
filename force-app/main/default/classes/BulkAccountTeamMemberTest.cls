@IsTest
public class BulkAccountTeamMemberTest {
    @IsTest(SeeAllData=false) 
    static void testCsvData() {
        // Create test data
        List<Map<String, String>> testData = new List<Map<String, String>>();
        Map<String, String> data1 = new Map<String, String>();

        // Create a test User record
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        UserRole userRole = [SELECT Id FROM UserRole LIMIT 1];
        Id rtId = [SELECT Id, Name FROM RecordType WHERE Name = 'Complaint' AND SObjectType = 'Case' LIMIT 1].Id;

        User testUser = new User(
            ProfileId = profile.Id,
            Alias = 'testuser',
            Email = 'testuser@example11.com',
            LastName = 'syed96',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Username = 'syedimam96@kloudrac.com',
            UserRoleId = userRole.Id,
            IsActive = true
        );
        insert testUser;
        
        data1.put('CUSTOMER CODE', '48215001');
        data1.put('NEWUSER', testUser.Username);
        testData.add(data1);
        // Add more test data as needed

        // Perform the CSV data processing
        Test.startTest();
        List<BulkAccountTeamMember.DatatoReturn> result;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Create test Account record
            Account acct = new Account();
            acct.Name = 'Test';
            acct.GATI_Customer_Code__c = '48215001';
            insert acct;

            // Create test Case record
            Case c = new Case();
            c.AccountId = acct.Id;
            c.RecordTypeId = rtId;
            c.Type = 'My Type';
            c.Origin = 'My Origin';
            c.Status = 'Open';
            c.Type = 'Pending Pickup';
            c.Sub_Type__c = 'MISSED PICKUP';
            c.Docket_Number__c = '1111';
            c.OwnerId = UserInfo.getUserId();
            insert c;

            // Perform the CSV data processing
            result = BulkAccountTeamMember.csvData(testData);
        }
        Test.stopTest();

        // Add assertions or additional test validation as needed
        System.assertEquals(1, result.size(), 'Result size should be 1');
        BulkAccountTeamMember.DatatoReturn dataReturn = result[0];
        System.assertEquals(true, dataReturn.done, 'Done should be true');
    }
}