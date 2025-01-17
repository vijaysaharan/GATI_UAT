@isTest
public class PickupBulkUploadController_Test {
    @isTest
    private static void createTestDataForPickup(){
        List<Map<String, String>> data = new List<Map<String, String>>();
        Map<string, string> map1= new Map<string, string>();
        List<String> pincodes = new List<String>();
        pincodes.add('302015');
        map1.put('CustomerCode__c','521180.102');
        map1.put('AccountId','');
        map1.put('Origin','Bulk');
        map1.put('Status','New');
        map1.put('Volume__c','10');
        map1.put('Shipper_Name__c','Ashish');
        map1.put('Shipper_Pincode__c','302015');
        map1.put('Pickup_Address1__c','D76');
        map1.put('Pickup_Address2__c','Noida');
        map1.put('Pickup_Address1__c','Sector 63');
        map1.put('Mobile__c','8052124483');
        map1.put('Customer_Email__c','akumar4@kloudrac.com');
        map1.put('Actual_Weight__c','10');
        map1.put('Product__c','1');
        map1.put('No_Of_Packages__c','10');
        map1.put('Receiver_Pincode__c','302015');
        map1.put('Pickup_Date__c','2022-12-10 18:00:00');
        data.add(map1);   
        
        Test.startTest();
        PickupBulkUploadController.dummy();
        PickupBulkUploadController.csvData(data,pincodes,pincodes);        
        Test.stopTest();
    }
    
}