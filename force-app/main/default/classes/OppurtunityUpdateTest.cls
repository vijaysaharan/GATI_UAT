@isTest
public class OppurtunityUpdateTest {
    @istest static void upload()
    {
        Account acc1 = TestFactory.getAccount('TestAccount','KEA','521123',True);
        list<opportunity> oplist = TestFactory.getOpportunity(10,acc1.Id);
        insert oplist;
        Test.startTest();
        Opportunity_Update_Scheduler_Batch.scheduleIt();
        Test.stopTest();
    }
}