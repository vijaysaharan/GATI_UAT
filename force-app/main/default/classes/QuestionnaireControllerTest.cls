@isTest
public class QuestionnaireControllerTest {
    @TestSetup
    static void makeData(){
        ConsigneeFeedback__c cf =  new ConsigneeFeedback__c();
        cf.ConsigneeName__c='TEST';
        cf.Date__c=System.today();
        cf.Comments__c = 'Test';
        cf.ContactPerson__c = 'test contact';
        cf.Email__c = 't@test.com';
        insert cf;
    }
    
    @isTest
    public static void testGetQuestions() {
        List<Questionare__c> questions = new List<Questionare__c>();
        questions.add(new Questionare__c(Name = 'Question 1',Sequence__c=1, IsActive__c = true));
        questions.add(new Questionare__c(Name = 'Question 2',Sequence__c=2, IsActive__c = true));
        insert questions;

        Test.startTest();
        List<Questionare__c> result = QuestionnaireController.getQuestions();
        Test.stopTest();
    }

    @isTest
    public static void testInsertConsigneeFeedback() {
        ConsigneeFeedback__c feedback = new ConsigneeFeedback__c(ConsigneeName__c = 'Test Feedback');
        
        Test.startTest();
        String feedbackId = QuestionnaireController.insertConsigneeFeedback(feedback);
        String feedbackId1 = QuestionnaireController.insertConsigneeFeedback(Null);
        Test.stopTest();
    }

    @isTest
    public static void testInsertConsigneeQuestionnaire() {
        List<ConsigneeQuestionnaire__c> questionnaires = new List<ConsigneeQuestionnaire__c>();
        questionnaires.add(new ConsigneeQuestionnaire__c(ConsigneeFeedback__c = [Select id From ConsigneeFeedback__c limit 1].Id));
        questionnaires.add(new ConsigneeQuestionnaire__c(ConsigneeFeedback__c = [Select id From ConsigneeFeedback__c limit 1].Id));

        Test.startTest();
        Boolean result = QuestionnaireController.insertConsigneeQuestionnaire(questionnaires);
        Boolean result1 = QuestionnaireController.insertConsigneeQuestionnaire(Null);
        Test.stopTest();
    }
    
    @isTest
    public static void testinsertLeadFromConsignee() {
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
            ld.GATI_Company_Code__c = '103';
            ld.Product__c = '100000005;100000009';
            ld.Lead_Data__c = 'Customer';
        
        Map<String,Lead> ldmap = new Map<String,Lead>();
        ldMap.put('1',ld);
        
        Test.startTest();
        try{
            QuestionnaireController.insertLeadFromConsignee(ldMap);
        }catch(Exception e){}
        QuestionnaireController.insertLeadFromConsignee(Null);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetPicklistOptions(){
        Test.startTest();
        QuestionnaireController.getPicklistOptions('Lead','Monthly_Spent_on_express_Logistic__c');
        Test.stopTest();
    }
    
    @isTest
    public static void testgetAllStaffCode(){
        Test.startTest();
        QuestionnaireController.getAllStaffCode('10573');
        QuestionnaireController.getAllStaffCode('12345');
        Test.stopTest();
    }
}