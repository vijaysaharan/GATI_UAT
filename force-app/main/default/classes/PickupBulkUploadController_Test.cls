@isTest
public class PickupBulkUploadController_Test {
    @testSetup static void makeData(){
        Id pincodeLocationRecordId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        Account testAccount = new Account(
            Name = 'Test Name', 
            Customer_Code__c = 521180.105
        );
        insert testAccount;
        List<Organization_Master__c> testOrganisationMasters = new List<Organization_Master__c>();
        Organization_Master__c testOrganisationMaster_1 = new Organization_Master__c(
            Name = '302015',
            Status__c = 'V',
            Pincode_Status__c = 'O',
            Distance__c = 30,
            RecordTypeId = pincodeLocationRecordId
        );
        testOrganisationMasters.add(testOrganisationMaster_1);
        Organization_Master__c testOrganisationMaster_2 = new Organization_Master__c(
            Name = '201301',
            Status__c = 'V',
            Pincode_Status__c = 'O',
            Distance__c = 30,
            RecordTypeId = pincodeLocationRecordId
        );
        testOrganisationMasters.add(testOrganisationMaster_2);
        insert testOrganisationMasters;
    }
    
    @isTest static void createTestDataForPickup(){
        List<Map<String, String>> data = new List<Map<String, String>>();
        List<String> pincodes = new List<String>();
        pincodes.add('302015');
		pincodes.add('201301');        
        data.add(createPickupCase('521180.105', System.now().addDays(5)));
        data.add(createPickupCase('521180.105', System.now().addDays(12)));
        
        Test.startTest();
        PickupBulkUploadController.csvData(data,pincodes,pincodes);        
        Test.stopTest();
    }
    
    private static Map<String, String> createPickupCase(String customerCode, DateTime pickupDate) {
        Map<String, String> pickupCaseDetails = new Map<String, String>();
        pickupCaseDetails.put('Customer_Code',customerCode);
        pickupCaseDetails.put('AccountId','');
        pickupCaseDetails.put('Origin','Bulk');
        pickupCaseDetails.put('Status','New');
        pickupCaseDetails.put('Volume__c','10');
        pickupCaseDetails.put('Shipper_Name__c','Ashish');
        pickupCaseDetails.put('Shipper_Pincode__c','302015');
        pickupCaseDetails.put('Pickup_Address1__c','D76');
        pickupCaseDetails.put('Pickup_Address2__c','Noida');
        pickupCaseDetails.put('Pickup_Address1__c','Sector 63');
        pickupCaseDetails.put('Mobile__c','8052124483');
        pickupCaseDetails.put('Customer_Email__c','akumar4@kloudrac.com');
        pickupCaseDetails.put('Actual_Weight__c','10');
        pickupCaseDetails.put('Product__c','1');
        pickupCaseDetails.put('No_Of_Packages__c','10');
        pickupCaseDetails.put('Destination_Pincode','201301');
        pickupCaseDetails.put('Pickup_Date__c',String.valueOf(pickupDate));
        return pickupCaseDetails;
    }
}