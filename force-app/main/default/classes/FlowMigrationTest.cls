@isTest
public class FlowMigrationTest {
	 @isTest
    public static void updateTaskandApprovalTest(){
         User user1=TestFactory.getUser('Test', 'Test', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                       'Test'  + '@sdkksdhfhdsjhf.com', 'Test' + '@asjgdgsad.com');
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Emial';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='ADD Extension';
        //case1.Sub_Type__c= 'MISSED PICKUP';
        case1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        case1.OwnerId = user1.id;
        insert case1;
    }   
}