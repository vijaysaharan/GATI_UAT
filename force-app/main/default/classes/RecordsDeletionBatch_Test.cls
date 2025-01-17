@isTest(SeeAllData=true)
public class RecordsDeletionBatch_Test {
    @isTest
    private static void createTestData(){
        List<CaseTeamMember> lstTeam = [SELECT Id,Parent.CreatedById,Parent.OwnerId FROM CaseTeamMember limit 100];
        List<Lead> leadList = new List<Lead>();
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.LeadSource = 'Cross Sell';
        ld.Company = 'kloudrac Software';
        ld.Email= 'akumar4@kloudrac.com';
        ld.MobilePhone = '8052124483';
        ld.Customer_Potential__c = 200000;
        ld.Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 5 Lakh';
        ld.PostalCode = '201301';
        ld.Lead_Data__c = 'Customer';
        
        insert ld;
		leadList.add(ld);        
        Test.startTest();
        RecordsDeletionBatch obj = new RecordsDeletionBatch();
        obj.start(null);
        obj.execute(null, lstTeam);
        obj.finish(null);
        Test.stopTest();
    }
}