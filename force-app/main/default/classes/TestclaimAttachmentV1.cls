@isTest
public class TestclaimAttachmentV1 {
 
    static testmethod void test_InsertCaseandAttachment(){
        Organization_Master__c o1=TestFactory.getOrganizationMasterextid('1231','12012');
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"12345","Stock_OU__c": "HYDN", "Stock_Receiving_OU__c":"HYDN", "Delivery_OU__c": "HYDN","Pick_Up_Ref_No__c":"12345678"},"RecordType":"Service request","callrecievedOU":"12012","callforwardedOU":"12012","ccecActionOU":"12012","PickUpPincode":"12012","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }],"complaintActionOU":"HYDN","Companyof":"HYDN","Gemrefno":"HYDN"}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
   static testmethod void test_Invaliddata(){
        Organization_Master__c o1=TestFactory.getOrganizationMasterextid('1231','120172');
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"45247"},"callrecievedOU":"12012","callforwardedOU":"12012","customercode":"567813","ccecActionOU":"12012","PickUpPincode":"12012","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
     static testmethod void testUpdateAttachments(){
          Contact cc = TestFactory.getContact('abc','a@a.com');
        Case c = ServiceTestFactory.getCaseServiceRequestType2('Claim','NEW',cc.Id);
        Case c1 = [select CaseNumber from case where id=:c.Id ];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"CaseNumber":"'+c1.casenumber+'"},"attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	    
    }
    
      static testmethod void testInvalidCaseNumber(){
        String casenumber= '67698';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"CaseNumber":"'+casenumber+'"},"attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();   
    
    }
    
   static testmethod void testRecordTypeComplaint(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"45247"},"RecordType":"Complaint","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
	
     static testmethod void testRecordTypeQuery(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"45247"},"RecordType":"Query","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
    static testmethod void testRecordTypeServiceReq(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"45247","Type":"Pick Up"},"RecordType":"Service Request","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
    static testmethod void newtest1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"Type": "Claim","Claim_Reg_By__c":"Magiel","Claim_Acceptance__c": "Y","Claim_Status__c": "accept","HO_Approval__c": "approved","OBN_No__c": "78709","OBN_Status__c": "pending","OBN_Issued_date__c": "2021-08-14","Liability_Status__c": "Liability","OBN_Issued_Amount__c": "7000","Claim_Setteled_Amount__c": "7888","CMS_No__c": "89012","CMS_Paid_Date__c": "2021-08-14","Docket_Number__c": "145336142", "Customer_Email__c": "rishabh1561999@gmail.com","Customer_Name__c": "rishabh","No_of_Packages_Delivered__c": "23","No_Of_Packages_Booked__c": "26","Actual_Weight_Delivered__c" : "192","Actual_Weight_Booked__c" : "205","Invoice_Number__c" : "63728","Invoice_Date__c" : "2021-08-14","Booking_Date__c" : "2021-08-14","Contents_as_per_invoice__c" : "56","POD_Type__c" : "pod","Remarks_give_on_POD__c" : "Yes","Actual_delivery_Date__c" : "2021-08-14","Nature_of_Loss__c":"D", "Decl_Cargo_value__c":"56000", "Risk_Coverage__c":"coverage", "Mobile__c":"9123145521", "Insurance_policy_No__c":"5688", "Insurance_policy_expiry_Date__c":"2021-08-14", "Insurer_Name__c":"Magiel", "Survey_Requirement__c":"Yes", "Claim_Vaue__c":"4123", "Net_Loss_Amount__c":"5468", "Loss_Description__c":"Description", "OBN_In_Favour_Of__c":"S", "Address__c":"Rajendar Nagar ", "Remarks_If_any__c":"Remarks", "CS_Check__c":"Yes", "Direct_Debit__c":"No", "DEPS_Info__c":"Yes", "CS_Remarks__c":"Remarks", "Origin":"GEMS", "Claim_Submitted_Date__c":"2021-08-12", "CRN__c":"800658", "Booking_OU__r" :{"REF_Code__c": "AGR"},"Delivery_OU__r":{"REF_Code__c": "AJM"}, "OU_Code__r":{"REF_Code__c": "AGR"} },"RecordType":"Service Request","customercode": "567813","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt"},{"Body": "d29ybGQ=","ContentType": "text/plain",   "Name": "hello.txt" }  ]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
     static testmethod void newtest2(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj":{"Type":"Partial Delivery","Sub_Type__c":"Short at delivery ou","Description":"","Subject":"Complaint Escalation from Mobile App","Origin":"Mobile App","Priority":"High","Customer_Email__c":"harr15.wilson@gmail.com","Customer_Name__c":"Prashant singh","Mobile__c":"9898303627","Complaint_Date__C":" 2022-02-16T17:18:17+05:30","Pick_Up_Ref_No__c":"00202079","Docket_Number__c": "400097001","Delivery_OU__c" : "a0Dp00000060LgGEAU","Pincode__c":"577201"},"RecordType":"Complaint","ccecActionOU":"HYDN","complaintActionOU":"BBI","customercode": "80224588.102","Docket_Validation__c" : "Valid","Type" : "Pick Up","CaseNumber" : null},"customercode":"80224588","recordType":"Complaint","callrecievedOU":"HYDN","callforwardedOU":"HYDN","ccecActionOU":"HYDN","complaintActionOU":"HYDN","pickUpPincode":"577201"}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();    
    	     
    }
    
      
}