public with sharing class SendRecordsToCMS {
    @InvocableMethod(label='Show Outputs')
    public static void calloutMethod(List<FlowInput> inputs){
        if(inputs != null && inputs.size() > 0){
            String inputVar = JSON.serialize(inputs);
            SendRecordsToCMS.cmsCallOut(inputVar);
        }
    }
    
    public static void cmsCallOut(String inputs){
        List<CustomerMaster> cmsList = new List<CustomerMaster>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        List<FlowInput> flowInputs = (List<FlowInput>) JSON.deserialize(inputs, List<FlowInput>.class);
		for(FlowInput fi : flowInputs){
            accountIds.add(fi.str1);
            if(fi.str2 != null){
                contactIds.add(fi.str2);
            }
        }
        
        Map<Id, Account> accountIdToDetails = new Map<Id, Account>([SELECT GATI_Company_Code__c, GATI_Customer_Code__c,Customer_Name__c,owner.name,
                                                                    Industry,Market_Type__r.name,lastModifiedBy.Staff_Code__c,
                                                                    Risk_Coverage__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                                    Market_Cide__c,owner.Staff_Code__c,AI_OU__r.Name,
                                                                    Customer_Status__c,Customer_Block_Reason__c,
                                                                    Registration_Status__c,Customer_Block_Unblock_Staff_Code__c,
                                                                    AIC_TBB__c,AIC_BOD__c,
                                                                    BOD__c,SDC__c,State__c,Contact_Person__c,
                                                                    Type,Phone,Email__c,Mobile__c,
                                                                    Payment_mode__c,Credit_Days__c,Credit_Amount__c FROM Account WHERE Id IN: accountIds
                                                                   ]);
        Map<Id, Contact> contactIdToDetails = new Map<Id, Contact>([SELECT Company_Code__c, Name, In_state_of__c,LastModifiedBy.Staff_Code__c,
                                                                    AccountId,MailingCity,MailingStreet,MailingPostalCode,Receiver_Flag__c,
                                                                    MailingState, Phone, Email, Staff_Category__c, STATUS__c,createdby.Staff_Code__c,
                                                                    Gati_Con_eid__c,remarks__c,Vendor_Tino__c,distance__c,
                                                                    MobilePhone,owner.name,Attached_OU__r.name, STAFF_STATUS__c 
                                                                    FROM Contact WHERE Id IN: contactIds
                                                                   ]);                                                    
        
        for(FlowInput fi : flowInputs){
            if(accountIdToDetails != null && accountIdToDetails.containsKey(fi.str1)){
                CustomerMaster customerMasterObj = new CustomerMaster();
                Account accountDetail = accountIdToDetails.get(fi.str1);
                if(accountDetail != null){        
                    customerMasterObj.accountOwnerStaffCode = accountDetail.owner.Staff_Code__c;
                    customerMasterObj.accountId = accountDetail.Id;
                    customerMasterObj.companyId = accountDetail.GATI_Company_Code__c;  
                    customerMasterObj.customerCode = accountDetail.GATI_Customer_Code__c;
                    customerMasterObj.customerName = accountDetail.Customer_Name__c;
                    customerMasterObj.industry = accountDetail.Industry;
                    customerMasterObj.marketType = accountDetail.Market_Type__r.name;
                    customerMasterObj.riskCoverage = accountDetail.Risk_Coverage__c;
                    customerMasterObj.marketCode = accountDetail.Market_Cide__c;
                    customerMasterObj.customerBlockStatus = accountDetail.Customer_Status__c;
                    customerMasterObj.registrationStatus = accountDetail.Registration_Status__c;
                    customerMasterObj.aicTBB = accountDetail.AIC_TBB__c;
                    if(accountDetail.BOD__c == true){
                        customerMasterObj.bod = '1';
                    }           
                    customerMasterObj.aicBOD = accountDetail.AIC_BOD__c;
                    customerMasterObj.sdc = accountDetail.SDC__c;
                    customerMasterObj.businessAddress1 = accountDetail.BillingStreet;
                    customerMasterObj.state = accountDetail.State__c;
                    customerMasterObj.busContactPerson = accountDetail.Contact_Person__c;
                    customerMasterObj.type = accountDetail.Type;
                    customerMasterObj.phoneNumber = accountDetail.Phone;
                    customerMasterObj.mobileNumber = accountDetail.Mobile__c;
                    customerMasterObj.email = accountDetail.Email__c;
                    customerMasterObj.paymentMode = accountDetail.Payment_mode__c;
                    customerMasterObj.creditDays = accountDetail.Credit_Days__c;
                    customerMasterObj.creditAmount = accountDetail.Credit_Amount__c;
                    customerMasterObj.pincode = accountDetail.billingPostalCode ;
                    customerMasterObj.lastModifiedBy = accountDetail.lastModifiedBy.Staff_Code__c;
                    customerMasterObj.city = accountDetail.BillingCity;
                    customerMasterObj.customerBlockReason = accountDetail.Customer_Block_Reason__c;
                    customerMasterObj.customerBlockUnblockStaffCode = accountDetail.Customer_Block_Unblock_Staff_Code__c;
                    customerMasterObj.accountOwnerName = accountDetail.owner.name;
                    customerMasterObj.aiou = accountDetail.AI_OU__r.Name;
                }
                if(fi.str2 != null && contactIdToDetails.containsKey(fi.str2)){
                    Contact contactDetail = contactIdToDetails.get(fi.str2);            
                    ContactDetails contact = new ContactDetails();
                    contact.custVendorCode =contactDetail.Gati_Con_eid__c;
                    contact.createdBy=contactDetail.createdby.Staff_Code__c;
                    contact.vendorState=contactDetail.MailingState;
                    contact.custVendorName=contactDetail.Name;
                    contact.vendorPhoneNo =contactDetail.Phone;
                    contact.vendorEmail=contactDetail.Email; 
                    contact.vendorCity=contactDetail.MailingCity;
                    contact.vendorStatus=contactDetail.Staff_Category__c;
                    contact.status=contactDetail.STATUS__c;
                    contact.remarks=contactDetail.remarks__c;
                    contact.vendorAdd1=contactDetail.MailingStreet;
                    contact.vendorTino=contactDetail.Vendor_Tino__c;
                    contact.distance=contactDetail.distance__c;
                    contact.ouCode=contactDetail.Attached_OU__r.name;
                    contact.vendorMobileNo=contactDetail.MobilePhone;
                    contact.vendorPincode=contactDetail.MailingPostalCode;
                    contact.vendorReceiverFlag=contactDetail.Receiver_Flag__c;
                    contact.lastUpdatedBy=contactDetail.lastModifiedBy.Staff_Code__c;
                    customerMasterObj.customerVendorDetails.add(contact);           
                }
                cmsList.add(customerMasterObj);
            }
        }
        
        System.debug('cmsList'+json.serialize(cmsList));
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest();
        String authParams = API_credential__mdt.getInstance('SendRecordsToCMS').Other_Auth_Parameter__c;
        String[] authParamsSplitted = authParams.split('\\|');
        for (String authpar:authParamsSplitted){
            String[] nameValue= authpar.split('\\:');
            req.setHeader(nameValue[0], nameValue[1]);                   
        }
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setEndpoint(API_credential__mdt.getInstance('SendRecordsToCMS').Endpoint__c);
        req.setBody(JSON.serialize(cmsList));
        req.setMethod('POST');
        req.setTimeout(120000);
        HttpResponse res1;
        if(!Test.isRunningTest()){
            res1 = http.send(req);
            System.debug('STATUS CODE '+res1.getStatusCode());
        }
    }  
    
    public class CustomerMaster{
        public string accountId{get;set;}
        public string companyId{get;set;}
        public string customerCode{get;set;}
        public string customerName{get;set;}
        public string accountOwnerName{get;set;}
        public string accountOwnerStaffCode{get;set;}
        public string industry{get;set;}
        public string lastModifiedBy{get;set;}
        public string marketType{get;set;}
        public string riskCoverage{get;set;}
        public string business_contact_person_email{get;set;}
        public string business_contact_person_phone{get;set;}
        public string marketCode{get;set;}
        public string customerBlockStatus{get;set;}
        public string customerBlockReason{get;set;}
        public string customerBlockUnblockStaffCode{get;set;}
        public string customerStatus{get;set;}
        public string registrationStatus{get;set;}
        public boolean aicTBB{get;set;}
        public String bod{get;set;}
        public boolean aicBOD{get;set;}
        public boolean sdc{get;set;}
        public string aiou{get;set;}
        public string businessAddress1{get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public string pinCode{get;set;}
        public string busContactPerson{get;set;}
        public string type{get;set;}
        public string phoneNumber{get;set;}
        public string mobileNumber{get;set;}
        public string email{get;set;}
        public string paymentMode{get;set;}
        public decimal creditDays{get;set;}
        public decimal creditAmount{get;set;}  
        list <ContactDetails> customerVendorDetails;
        public CustomerMaster(){
            customerVendorDetails = new list<ContactDetails>();
        }
    }
    
    public class ContactDetails{
        public string custVendorCode{get;set;}
        public string vendorState{get;set;}
        public string custVendorName{get;set;}
        public string vendorAdd1{get;set;}
        public string vendorCity{get;set;}
        public string vendorPhoneNo{get;set;}
        public string vendorEmail{get;set;}
        public string vendorStatus{get;set;}
        public string remarks{get;set;}
        public string status{get;set;}
        public string vendorMobileNo{get;set;}
        public string createdBy{get;set;}
        public string lastUpdatedBy{get;set;}
        public string vendorPincode{get;set;}
        public string vendorReceiverFlag{get;set;}
        public string ouCode{get;set;}
        public string vendorTino{get;set;}
        public decimal distance{get;set;}        
    }
    public class responseWrapper{
        public String requid;    
        public String result;    
        public String sErrMsg;
        public list<Response> resp; 
    }
    public class Response{
        public string customerCode;
        public string companyId;
        public string result;
    }
    public class FlowInput{
        @InvocableVariable public Id str1;        
        @InvocableVariable public Id str2;       
    }
}