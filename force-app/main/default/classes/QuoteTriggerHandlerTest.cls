@isTest
public class QuoteTriggerHandlerTest {
    @testSetup static void createData(){
        Account accTest = new Account(Name = 'Test',
                                      Customer_Category__c = 'Retail'
                                     );
        insert accTest;
        Opportunity oppTest = new Opportunity(Name = 'Test Opportunity',
                                              AccountId = accTest.Id,
                                              StageName = 'Qualified',
                                              GSTIN_Documents__c = true,
                                              PAN_Card_Document__c = true,
                                              CloseDate = System.today().addDays(5)
                                             );
        insert oppTest;
    }
    @isTest
    public static void quoteCreationValidationTest(){
        Opportunity oppTest = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quoteTest = new Quote(Name = 'Test Quote',
                                    OpportunityId = oppTest.Id                                    
                                   );
        test.startTest();
        try{
            insert quoteTest;
        }catch(Exception e){}
        test.stopTest();
    }
}