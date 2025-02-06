@isTest
public class OUAssignController_Test {
    @testSetup
    static void setupTestData() {
        Id operationalUnitRTId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Operation_Unit').getRecordTypeId();
        Id pincodeRTId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Pincode').getRecordTypeId();

        Organization_Master__c ou1 = new Organization_Master__c(
            Name = 'OU1',
            RecordTypeId = operationalUnitRTId
        );
        Organization_Master__c ou2 = new Organization_Master__c(
            Name = 'OU2',
            RecordTypeId = operationalUnitRTId
        );
        insert new List<Organization_Master__c>{ou1, ou2};

        Organization_Master__c pincode1 = new Organization_Master__c(
            Name = '12345',
            RecordTypeId = pincodeRTId,
            Parent__c = ou1.Id
        );
        Organization_Master__c pincode2 = new Organization_Master__c(
            Name = '12345',
            RecordTypeId = pincodeRTId,
            Parent__c = ou2.Id
        );
        insert new List<Organization_Master__c>{pincode1, pincode2};

        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            PostalCode = '12345',
            Product__c = 'Express',
            Lead_Assigned_OU__c = ou1.Id
        );
        Lead testLeadNoPostal = new Lead(
            LastName = 'Test Lead No Postal',
            Company = 'Test Company',
            Product__c = 'Express',
            LeadSource = 'Email'
        );
        insert new List<Lead>{testLead, testLeadNoPostal};
    }

    @isTest
    static void testGetOperationalUnit_ValidPincode() {
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Test Lead' LIMIT 1];
        Organization_Master__c ou2 = [SELECT Id, Name FROM Organization_Master__c WHERE Name = 'OU2' LIMIT 1];

        Test.startTest();
        List<OUAssignController.OperationalUnitWrapper> result = OUAssignController.getOperationalUnit(testLead.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return 1 operational unit');
        System.assertEquals(ou2.Id, result[0].operationId, 'Should return OU2');
    }

    @isTest
    static void testGetOperationalUnit_NoPostalCode() {
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Test Lead No Postal' LIMIT 1];

        Test.startTest();
        List<OUAssignController.OperationalUnitWrapper> result = OUAssignController.getOperationalUnit(testLead.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return no results');
    }

    @isTest
    static void testGetOperationalUnit_UnassignedOU() {
        Lead testLead = new Lead(
            LastName = 'Unassigned Lead',
            Company = 'Test Company',
            PostalCode = '12345',
            Product__c = 'Express'
        );
        insert testLead;

        Test.startTest();
        List<OUAssignController.OperationalUnitWrapper> result = OUAssignController.getOperationalUnit(testLead.Id);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should return all matching OUs');
    }

    @isTest
    static void testUpdateAssignedOU_Success() {
        Lead testLead = [SELECT Id FROM Lead WHERE LastName = 'Test Lead' LIMIT 1];
        Organization_Master__c ou2 = [SELECT Id FROM Organization_Master__c WHERE Name = 'OU2' LIMIT 1];

        Test.startTest();
        Boolean result = OUAssignController.updateAssignedOU(testLead.Id, ou2.Id);
        Test.stopTest();

        Lead updatedLead = [SELECT Lead_Assigned_OU__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, result, 'Should return true for success');
        System.assertEquals(ou2.Id, updatedLead.Lead_Assigned_OU__c, 'Should update OU');
    }

    @isTest
    static void testUpdateAssignedOU_Failure() {
        String fakeId = Lead.SObjectType.getDescribe().getKeyPrefix() + '000000000000';
        Organization_Master__c ou2 = [SELECT Id FROM Organization_Master__c WHERE Name = 'OU2' LIMIT 1];

        Test.startTest();
        try {
            OUAssignController.updateAssignedOU(fakeId, ou2.Id);
            System.assert(false, 'Should throw exception');
        } catch (AuraHandledException e) {
            System.assert(true, 'Caught expected exception');
        }
        Test.stopTest();
    }
}