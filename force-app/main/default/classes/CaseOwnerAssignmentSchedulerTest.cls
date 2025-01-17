@isTest
public class CaseOwnerAssignmentSchedulerTest {
    @isTest
    static void testBatchableExecution() {
        Profile prof1 = [Select Id from Profile where name = 'System Administrator'];
        user u = new user();
        u.ProfileId = prof1.Id;
        u.LastName = 'API User';
        u.Email = 'test@test.com';
        u.Username = 'test@tes.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';     
        insert u; 
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            cases.add(new Case(Subject = 'Test Case ' + i, Origin = 'Email', OwnerId = u.Id));
        }
        insert cases;
        
        Test.startTest();
        CaseOwnerAssignmentScheduler scheduler = new CaseOwnerAssignmentScheduler();
        Database.executeBatch(scheduler, 1000);
        Test.stopTest();
    }
}