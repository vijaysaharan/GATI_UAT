public class Pickup_req_OutboundAPINew implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public List<Case> cases;
    
    public Pickup_req_OutboundAPINew(List<Case> cases) {
        this.cases = cases;
    }
    
    public Iterable<SObject> start(Database.BatchableContext context) {
        return this.cases;
    }
    
    public void execute(Database.BatchableContext context, List<Case> scope) {
        List<pickuppayload> requestPayloads = new List<pickuppayload>();
        List <Case> case2 = [Select ID,Error_message__c,sync_flag__c,CaseOwner__c,Shipper_Name__c,Customer_Code__c,Pickup_Address1__c,Pickup_Address2__c,Pickup_Address3__c,
                             Pick_Up_Pincode__r.Name,Pickup_OU__r.name,Mobile__c,Receiver_Pincode__c,Pickup_Date__c,Shipper_Location__c,Customer_Email__c,Pick_Up_Instructions__c,
                             Product__c,No_Of_Packages__c,Actual_Weight__c,Volume__c,Type_of_Package__c,Origin,CreatedDate,CreatedBy.Staff_Code__c,Pick_Up_Ref_No__c,LastModifiedDate,
                             LastModifiedBy.Staff_Code__c,Approver_Remarks__c,Approval_Status__c,Sub_Type__c,First_Schedule__c,Pickup_Status__c,Pickup_City__c,Pickup_Coordinates__c,
                             Company_of__c,Case_Name__c,CaseNumber from Case where ID IN: scope];
        Set<String> OriginSet = new Set<String>();
        for (Case caseRecord : case2) {
            if(caseRecord.Origin != Null){
                OriginSet.add(caseRecord.Origin);
            }
        }
        System.debug('scope ==>'+case2);
        Map<String,Lookup_Master__mdt> lookupMasterToOrigin = new Map<String,Lookup_Master__mdt>();
        Lookup_Master__mdt[] lookupMaster = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c,MasterLabel FROM Lookup_Master__mdt WHERE MasterLabel IN :OriginSet];
        for (Lookup_Master__mdt lookup : lookupMaster) {
            lookupMasterToOrigin.put(lookup.MasterLabel, lookup);
        }
        for (Case caseRecord : case2) {
            pickuppayload reqBody = new pickuppayload();
            
            reqBody.customerCode = caseRecord.Customer_Code__c != null ? String.valueOf(caseRecord.Customer_Code__c) : '99999';
            reqBody.shipperName = caseRecord.Shipper_Name__c;
            reqBody.pickUpAddress1 = caseRecord.Pickup_Address1__c;
            reqBody.pickUpAddress2 = caseRecord.Pickup_Address2__c;
            reqBody.pickUpAddress3 = caseRecord.Pickup_Address3__c != null ? caseRecord.Pickup_Address3__c : '';
            reqBody.shipperPincode = caseRecord.Pick_Up_Pincode__r != null ? caseRecord.Pick_Up_Pincode__r.Name : '';
            reqBody.location = caseRecord.Shipper_Location__c != null ? caseRecord.Shipper_Location__c : '';
            reqBody.pickupOu = caseRecord.Pickup_OU__r != null ? caseRecord.Pickup_OU__r.Name : '';
            reqBody.mobileNo = caseRecord.Mobile__c != null ? caseRecord.Mobile__c : '';
            reqBody.emailId = caseRecord.Customer_Email__c != null ? caseRecord.Customer_Email__c : '';
            reqBody.receiverPincode = caseRecord.Receiver_Pincode__c;
            reqBody.pickUpDate = caseRecord.Pickup_Date__c.format('dd-MM-yyyy HH:mm:ss');
            reqBody.pickUpInstructions = caseRecord.Pick_Up_Instructions__c != null ? caseRecord.Pick_Up_Instructions__c : '';
            reqBody.product = caseRecord.Product__c;
            reqBody.noOfPackages = caseRecord.No_Of_Packages__c != null ? String.valueOf(caseRecord.No_Of_Packages__c) : '';
            reqBody.actualWeight = caseRecord.Actual_Weight__c != null ? String.valueOf(caseRecord.Actual_Weight__c) : '';
            reqBody.volume = caseRecord.Volume__c != null ? String.valueOf(caseRecord.Volume__c) : '';
            reqBody.typeOfPackage = caseRecord.Type_of_Package__c != null ? caseRecord.Type_of_Package__c : '';
            
            if (caseRecord.Origin != null) {
                if (lookupMasterToOrigin.containsKey(caseRecord.Origin)) {
                    reqBody.source = lookupMasterToOrigin.get(caseRecord.Origin).External_Field_Value__c;
                }
            }
            
            reqBody.createdDate = caseRecord.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
            
            if (caseRecord.Origin == 'Web' || caseRecord.Origin == 'Website' || caseRecord.Origin == 'Simplyfy360' ||
                caseRecord.Origin == 'Simply360' || caseRecord.Origin == 'WhatsApp' || caseRecord.Origin == 'Email') {
                    reqBody.pickUpCreatedBy = 'Customer';
                }
            else if(caseRecord.CreatedBy.Staff_Code__c!=null){
                reqBody.pickUpCreatedBy=caseRecord.CreatedBy.Staff_Code__c;  
            }
            reqBody.pickUpRefNo=caseRecord.CaseNumber;
            
            if(caseRecord.LastModifiedDate!=null){
                reqBody.lastModifiedDate=caseRecord.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
            }else{
                reqBody.lastModifiedDate='';
            }
            system.debug(reqBody.lastModifiedDate);
            
            if (caseRecord.LastModifiedBy.Staff_Code__c != null) {
                reqBody.lastModifiedBy = caseRecord.LastModifiedBy.Staff_Code__c;
            }
            
            if (caseRecord.Approval_Status__c != null) {
                reqBody.approverStatus = caseRecord.Approval_Status__c;
            } else {
                reqBody.approverStatus = '';
            }
            if (caseRecord.Sub_Type__c != null) {
                reqBody.Pick_up_type = caseRecord.Sub_Type__c;
            } else {
                reqBody.Pick_up_type = '';
            }
            System.debug(reqBody.Pick_up_type);
            
            if (caseRecord.Approver_Remarks__c != null) {
                reqBody.approverRemarks = caseRecord.Approver_Remarks__c;
            } else {
                reqBody.approverRemarks = '';
            }
            System.debug(reqBody.approverRemarks);
            
            if (caseRecord.First_Schedule__c != null) {
                reqBody.firstSchedule = caseRecord.First_Schedule__c == null ? null : caseRecord.First_Schedule__c.format('dd-MM-yyyy HH:mm:ss');
            } else {
                reqBody.firstSchedule = '';
            }
            system.debug(reqBody.firstSchedule);
            
            if (caseRecord.Pickup_Status__c != null) {
                reqBody.pickupStatus = caseRecord.Pickup_Status__c;
            } else {
                reqBody.pickupStatus = '';
            }
            
            if (caseRecord.Pickup_City__c != null) {
                reqBody.shipperCity = caseRecord.Pickup_City__c;
            } else {
                reqBody.shipperCity = '';
            }
            
            if (caseRecord.Pickup_Coordinates__c == null) {
                reqBody.latLong = '';
            } else {
                Location loc = caseRecord.Pickup_Coordinates__c;
                System.debug(loc + ': ' + reqBody.latLong);
                reqBody.latLong = String.valueOf(loc.latitude) + ',' + String.valueOf(loc.longitude);
                System.debug(loc + ': ' + reqBody.latLong);
            }
            reqBody.companyOf = caseRecord.Company_of__c;
            
            if (caseRecord.Case_Name__c != null) {
                reqBody.caseName = caseRecord.Case_Name__c;
            } else {
                reqBody.caseName = '';
            }
            if (caseRecord.CaseOwner__c != null) {
                reqBody.CaseOwner = caseRecord.CaseOwner__c;
            } else {
                reqBody.CaseOwner = '';
            }
            
            requestPayloads.add(reqBody);
        }
        
        if (!requestPayloads.isEmpty()) {
            Http http = new Http();              
            HttpRequest req1 = new HttpRequest();
            String AuthParams = API_credential__mdt.getInstance('Pickup_Request').Other_Auth_Parameter__c;
            String[] AuthParamsSplitted = AuthParams.split('\\|');
            for (String Authpar:AuthParamsSplitted){
                String[] nameValue= Authpar.split('\\:');
                req1.setHeader(nameValue[0], nameValue[1]);                   
            }
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json');
            req1.setEndpoint(API_credential__mdt.getInstance('Pickup_Request').Endpoint__c);
            req1.setBody(JSON.serialize(requestPayloads));
            req1.setMethod('POST');
            req1.setTimeout(50000);
            System.debug(req1);
            HttpResponse res1= http.send(req1);
            
            System.debug('res1.getBody()=='+res1.getBody());
            String errormsg1;
            System.debug(res1.getStatusCode());
            
            
            List<Integration_Log__c> integrationLog = new List<Integration_Log__c>();
            for (Case caseRecord : scope) {
                if(res1.getStatusCode()==200){
                    
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(res1.getBody(), ResponseWrapper.class);
                    
                    try{
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='PickUp log';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        // ic.eRecordID__c=c.id;
                        ic.CaseNumber__c=caseRecord.CaseNumber;
                        ic.eRecordID__c = caseRecord.id;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=res1.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(requestPayloads);
                        integrationLog.add(ic);
                    }
                    catch(Exception e){} 
                }else{
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(res1.getBody(), ResponseWrapper.class);
                    
                    errormsg1=responseObj.sErrMsg;
                    Integration_Log__c ic = new Integration_Log__c();
                    ic.Component_Name__c='PickUp log';
                    ic.Error_Message__c=errormsg1;
                    ic.IsIntegration__c=true; 
                    // ic.eRecordID__c=c.id;
                    ic.CaseNumber__c=caseRecord.CaseNumber;
                    ic.eRecordID__c = caseRecord.id;
                    ic.eObject__c = 'Case';
                    ic.Inbound_JSON__c=res1.getBody();
                    ic.Outbound_JSON__c=JSON.serialize(requestPayloads);
                    integrationLog.add(ic);
                }
            }
            insert integrationLog;
            System.debug('integrationLog ==>'+integrationLog);
        }
    }
    
    public void finish(Database.BatchableContext context) {}
    
    // Inner class for request payload structure
    public class pickuppayload {
        public string shipperName{get;set;}
        public String customerCode{get;set;}
        public string pickUpAddress1{get;set;}
        public string pickUpAddress2{get;set;}
        public string pickUpAddress3{get;set;}
        public string shipperPincode{get;set;}   
        public string location{get;set;}
        public string pickupOu{get;set;}
        public string mobileNo{get;set;}
        public string emailId{get;set;}
        public string receiverPincode{get;set;}
        public string pickUpDate{get;set;}
        public string pickUpInstructions{get;set;}
        public string product{get;set;}
        public string noOfPackages{get;set;}
        public string actualWeight{get;set;}
        public string volume{get;set;}
        public string typeOfPackage{get;set;}
        public string source{get;set;}
        public string createdDate{get;set;}
        public string pickUpCreatedBy{get;set;}
        public string pickUpRefNo{get;set;}
        public string lastModifiedDate{get;set;}
        public string lastModifiedBy{get;set;}
        public string approverStatus{get;set;}
        public string approverRemarks{get;set;}
        public string firstSchedule{get;set;} 
        public string pickupStatus{get;set;}    
        public string shipperCity{get;set;}     
        public string latLong{get;set;}       
        public string companyOf {get;set;}   
        public string caseName{get;set;}  
        public string Pick_up_type{get;set;}
        public string CaseOwner{get;set;}
    }
    
    public class ResponseWrapper{
        public String requid;
        public String result; 
        public String sErrMsg;
    }
}