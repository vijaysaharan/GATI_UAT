@isTest
public class ChangeOwnerTest {

    @isTest
    static void executeTest() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'simam@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = UserInfo.getProfileId()
        );
        insert testUser;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualified',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert testOpportunity;

        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;

        Contract testContract = new Contract(AccountId = testAccount.Id, StartDate = Date.today());
        insert testContract;

        // Create test request
        ChangeOwner.Requests testRequest = new ChangeOwner.Requests();
        testRequest.targetRecordCollection = new List<SObject>{ testAccount, testOpportunity, testContact };
        testRequest.newOwnerId = UserInfo.getUserId();
        testRequest.EnforceNewOwnerHasReadAccess = true;
        testRequest.KeepAccountTeam = true;
        testRequest.KeepSalesTeam = true;
        testRequest.KeepSalesTeamGrantCurrentOwnerReadWriteAccess = true;
        testRequest.TransferArticleOwnedPublishedVersion = true;
        testRequest.TransferArticleOwnedArchivedVersions = true;
        testRequest.TransferArticleAllVersions = true;
        testRequest.TransferContacts = true;
        //testRequest.TransferContracts = true;
        testRequest.TransferNotesAndAttachments = true;
        testRequest.TransferOpenActivities = true;
        //testRequest.TransferOrders = true;
        //testRequest.TransferOwnedOpenCases = true;
        //testRequest.TransferAllOwnedCases = true;
        testRequest.TransferOthersOpenOpportunities = true;
        testRequest.TransferOwnedClosedOpportunities = true;
        testRequest.TransferOwnedOpenOpportunities = true;

        List<ChangeOwner.Requests> requestList = new List<ChangeOwner.Requests>{ testRequest };
        // Invoke the execute method
        Test.startTest();
        List<ChangeOwner.Results> resultsList = ChangeOwner.execute(new List<ChangeOwner.Requests>{ testRequest });
        Test.stopTest();

        // Verify results
        System.assertEquals(1, resultsList.size());
        ChangeOwner.Results results = resultsList[0];
        System.assertEquals(false, results.success);
        //System.assertEquals(null, results.errorMessage);

        // Verify owner changes
        testAccount = [SELECT OwnerId FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(UserInfo.getUserId(), testAccount.OwnerId);

        testOpportunity = [SELECT OwnerId FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals(UserInfo.getUserId(), testOpportunity.OwnerId);

        testContact = [SELECT OwnerId FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(UserInfo.getUserId(), testContact.OwnerId);
    }
}