@isTest
public class PickupComponentController_Test {
    @isTest
    private static void createOrganizationData(){
         Organization_Master__c org = new Organization_Master__c();
        org.Name = '201301';
        org.recordTypeID = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert org;
        
        Test.startTest();
        	PickupComponentController.getPickupDetails(org.Id);
        Test.stopTest();
    }
}