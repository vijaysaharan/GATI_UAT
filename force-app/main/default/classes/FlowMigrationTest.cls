@isTest
public class FlowMigrationTest {
    @isTest
    static void testCcecCreation() {
        
        Contact c = new Contact();
        c.MailingStreet = 'dummy';
        c.LastName = 'dummy';
        insert c;
        
        Organization_Master__c o = new Organization_Master__c();
        o.Name = 'BOMS';
        o.Operational_Status__c ='O';
        o.Status__c ='V';
        o.recordTypeID = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Operation Unit').getRecordTypeId();
        insert o;
        
        // Create test cases
        List<Case> caseList = new List<Case>();
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Emial';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Pending Pickup';
        case1.Sub_Type__c= 'MISSED PICKUP';
        case1.CCEC_Action_OU__c= o.id;
        case1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        caseList.add(case1);
        //insert case1;
        checkRecurisveRun.ccecCreation = true;
        
        Case case2 = new Case();
        case2.CCEC_Action_OU__c= o.id;
        case2.CustomerCode__c = 521180.001;
        case2.AccountId = null;
        case2.Origin='Emial';
        case2.Docket_Number__c='12534';
        case2.Pick_Up_Ref_No__c ='23498';
        case2.Docket_Validation__c = 'Valid';
        case2.Type='Pending Pickup';
        case2.Sub_Type__c= 'LATE PICKUP';
        case2.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        caseList.add(case2);
        
        checkRecurisveRun.ccecCreation = true;
        Case case3 = new Case();
        case3.CCEC_Action_OU__c= o.id;
        case3.CustomerCode__c = 521180.001;
        case3.AccountId = null;
        case3.Origin='Emial';
        case3.Docket_Number__c='12534';
        case3.Pick_Up_Ref_No__c ='23498';
        case3.Docket_Validation__c = 'Valid';
        case3.Type='VARIANCE IN ADD';
        //case25.Sub_Type__c= 'COD DD LOST';
        case3.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
        caseList.add(case3);
        
        try{
            insert caseList;
            
        }Catch(Exception ex){}
        
        // Call the method to test
        Test.startTest();
        FlowMigration.ccecCreation(new Map<Id, Case>(caseList));
        Test.stopTest();
        /*
        // Verify that CCEC__c records were created
        List<CCEC__c> ccecs = new List<CCEC__c>();
        CCEC__c ccec = new CCEC__c();
        ccec.Case__c = case2.Id;
        ccec.Auto_CCEC_Creation__c = true;
        ccec.Auto_CCEC_Flag__c = true;
        ccec.Instruction__c = 'fillinstructions3';
        ccec.CCEC_OF__c = 'CCECOF';
        ccec.CCEC_OU_Assignment_Logic__c = case2.CCEC_Action_OU__c;
        ccec.Status__c = 'OP';
        ccec.CCEC_OU_Assignment_Logic__c = case2.Delivery_OU__c;
        ccecs.add(ccec);
        insert ccecs;
        //System.assertEquals(3, ccecs.size());*/
        
        // Verify the results
        List<CCEC__c> ccecList = [SELECT Id, Auto_CCEC_Creation__c, Auto_CCEC_Flag__c, Instruction__c, CCEC_OF__c, CCEC_OU_Assignment_Logic__c, Case__c, Status__c FROM CCEC__c];
        
    }
}