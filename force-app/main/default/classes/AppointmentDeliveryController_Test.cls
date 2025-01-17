@isTest
public class AppointmentDeliveryController_Test {
    /**
     * Auther : Ashish Kumar(akumar4@kloudrac.com)
     * Description : This Apex Test class for update bulk Appointment Delivery Case
     * Apex Class : AppointmentDeliveryController
     * 
	*/
    @isTest
    private static void CreateTestDataForAppointment(){
        List<Map<String, String>> data = new List<Map<String, String>>();
        Map<string, string> map1= new Map<string, string>();
        map1.put('Docket_Number__c','228333211');
        map1.put('Appointment_Contact_Number__c','8052124483');
        map1.put('Appointment_Contact_Person__c','Ashis Madhukar');
        map1.put('Appointment_Date__c','2022-09-29 18:20:00');
        map1.put('Approval_Status__c','Y');
        map1.put('Approver_Remarks__c','Appointment Fixed');
        data.add(map1);

        Test.startTest();
        AppointmentDeliveryController.CsvData(data);

        Test.stopTest();

    }

    

}