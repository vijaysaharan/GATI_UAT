@isTest
public class BulkUploadLeadController_Test {
    /**
* Auther : Ashish Kumar(akumar4@kloudrac.com)
* Description : This Apex Test class for update bulk Lead Upload
* Apex Class : BulkUploadLeadController
* 
*/
    
    @isTest
    private static void cretaedTestDataForLead(){
        List<Map<String, String>> data = new List<Map<String, String>>();
        Map<string, string> map1= new Map<string, string>();
        map1.put('Title','Mr.');
        map1.put('Salutation','Mr.');
        map1.put('FirstName','Syed');
        map1.put('LastName','Shahid Test');
        map1.put('Status','New');
        map1.put('Lead_Data__c','Customer');
        map1.put('Campaign_Name__c','Campaign');
        map1.put('GATI_Company_Code__c','102');
        map1.put('Product__c','AIR');
        map1.put('Customer_Potential__c','1000000');
        map1.put('Designation__c','Salesforce Developer');
        map1.put('Company','Kloudrac Software Pvt. Ltd.');
        map1.put('Email','simam@kloudrac.com');
        
        map1.put('Phone','8052124483');
        map1.put('MobilePhone','8052124483');
        map1.put('Street','D-76, D Block');
        map1.put('City','Noida');
        map1.put('State','Uttar Pradesh');
        map1.put('PostalCode','201301');
        map1.put('Country','India');
        map1.put('Description','Its Description');
        map1.put('Cross_Sell_Lead_Status__c','Disqualified');
        map1.put('Lost_Reason__c','Others');
        map1.put('Description__c','Cross Sell Description');
        map1.put('Manually_Uploaded__c','true');
        data.add(map1);
        
        Test.startTest();
        try{
         BulkUploadLeadController.CsvData(data);   
        }catch(Exception e){}
        
        Test.stopTest();
        
    }
    
}