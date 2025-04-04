public Without Sharing class ManualCCECOutboundAPI {
    
    @InvocableMethod(label='Manual CCEC Creation')
    public static void SendCCEC(List<String> ccecid){
        if(ccecid != null){
            ManualCCECOutbound(ccecid);
        }
    }
    
    @future(callout = true)
    public static void ManualCCECOutbound(List<String> ccecIds){
        List<CCEC__c> ccecDetails = [SELECT Case__r.Owner.Id, Case__r.Owner.Type, Case__r.RecordType.Name, Case__r.Sub_Type__c, 
                                     Case__r.CaseNumber, Case__r.Docket_Number__c, Case__r.Pick_Up_Ref_ID__r.CaseNumber, 
                                     Case__r.Open_CCEC_Count__c, Comp_Code__c, Name, CCEC_OU_Assignment_Logic__r.Name, Case__r.Type, 
                                     CCEC_Instructions__c, CreatedBy.Organi__c, CreatedDate, Proactive_CCEC_Flag__c,Auto_CCEC_Flag__c,
                                     CCEC_Received_OU__c, CreatedBy.Staff_Code__c, CSA_code__c,Exp_Closure_Dt__c, Case__r.Case_Name__c,
                                     CCEC_reason__c, CCEC_OF__c, Status__c, CCEC_Closure_Date__c, CreatedBy.name, LastModifiedDate,
                                     LastModifiedBy.Staff_Code__c, Total_CCEC_Remarks__c 
                                     FROM CCEC__c 
                                     WHERE Id IN :ccecIds
                                    ];
        
        if(!(ccecDetails != null && ccecDetails.size() > 0)){
            return;
        }
        
        Set<Id> ownerIds = new Set<Id>();
        List<User> userList = new List<User>();
        List<Integration_Log__c> integrationLogs = new List<Integration_Log__c>();
        Map<Id, User> userIdToStaffCode = new Map<Id, User>();
        Map<String, Lookup_Master__mdt> lookupMasterByDevName = new Map<String, Lookup_Master__mdt>();
        Map<String, Exception_SF_Meta__mdt> exceptionSfMetaByDevName = new Map<String, Exception_SF_Meta__mdt>();
        
        for(CCEC__c ccecDetail : ccecDetails){
            if(ccecDetail.Case__r.OwnerId != null && ccecDetail.Case__r.Owner.Type == 'User'){
                ownerIds.add(ccecDetail.Case__r.OwnerId);
            }
        }
        
        for(Lookup_Master__mdt uMaster : [SELECT Id, MasterLabel, CRM_Field_Value__c, External_Field_Value__c FROM Lookup_Master__mdt]){
            lookupMasterByDevName.put(uMaster.MasterLabel, uMaster);
        }
        
        for(Exception_SF_Meta__mdt eSF : [SELECT Id, MasterLabel, crm_field_value__c, complaint_code__c FROM Exception_SF_Meta__mdt]){
            exceptionSfMetaByDevName.put(eSF.MasterLabel, eSF);
        }
        
        if(!ownerIds.isEmpty()){
            userList = [SELECT Id, Staff_Code__c FROM User WHERE Id IN :ownerIds];
        }
        
        if(!userList.isEmpty()){
            for(User u : userList){
                if(u.Staff_Code__c != null){
                    userIdToStaffCode.put(u.Id, u);
                }
            }
        }

        String authParams = API_credential__mdt.getInstance('CCECRecords').Other_Auth_Parameter__c;
        String endPoint = API_credential__mdt.getInstance('CCECRecords').Endpoint__c;
        
        for(CCEC__c cc : ccecDetails){
            CCECRecords obj = new CCECRecords();
            try{
                obj.compRefNo = cc.Case__r.CaseNumber;
                obj.ccecRefNo = cc.Name;
                
                if(cc.Case__r.RecordType.Name == 'Service Request' && cc.Case__r.Type == 'Exception' && cc.Case__r.Sub_Type__c!= 'COD Remittance' && cc.Case__r.Sub_Type__c!= 'Bad POD' && exceptionSfMetaByDevName.containsKey(cc.Case__r.Sub_Type__c)){
                    obj.identity = exceptionSfMetaByDevName.get(cc.Case__r.Sub_Type__c).external_field_value__c;
                }
                else{
                    obj.identity = '';  
                }
                
                if(cc.Case__r.Case_Name__c != null){
                    obj.identifier = cc.Case__r.Case_Name__c;
                }
                else{
                    obj.identifier = '';
                }
                
                if(cc.Case__r.Docket_Number__c!= null){
                    obj.docketNo = cc.Case__r.Docket_Number__c;
                }
                else{
                    obj.docketNo = ''; 
                }
                
                if(cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber!= null){
                    obj.pickupSlipNo = cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber;
                }
                else{
                    obj.pickupSlipNo = '';
                }
                
                if(cc.Case__r.RecordType.Name == 'Complaint' && lookupMasterByDevName.containsKey(cc.Case__r.Sub_Type__c)){
                    obj.compCode = lookupMasterByDevName.get(cc.Case__r.Sub_Type__c).External_Field_Value__c;
                }
                else if( cc.Case__r.RecordType.Name == 'Service Request' && cc.Case__r.Type == 'Exception' && cc.Case__r.Sub_Type__c != 'COD Remittance' && cc.Case__r.Sub_Type__c != 'Bad POD' && exceptionSfMetaByDevName.containsKey(cc.Case__r.Sub_Type__c)){
                    obj.compCode = exceptionSfMetaByDevName.get(cc.Case__r.Sub_Type__c).complaint_code__c;
                }
                else if(cc.Case__r.RecordType.Name == 'Query' && lookupMasterByDevName.containsKey(cc.Case__r.Type)){
                    obj.compCode = lookupMasterByDevName.get(cc.Case__r.Type).External_Field_Value__c;
                }
                else if(cc.Case__r.Type == 'Non Delivery Reasons'){
                    obj.compCode = '9';
                }
                else{
                    obj.compCode = '';
                }
                
                if(cc.CCEC_Instructions__c!= null){
                    obj.ccecInstructions = cc.CCEC_Instructions__c;
                }
                else{
                    obj.ccecInstructions = '';
                }
                
                if(cc.CreatedBy.Organi__c != null){
                    obj.ccecRaisedOU = cc.CreatedBy.Organi__c;
                }
                else{
                    obj.ccecRaisedOU = '';
                }
                
                if(cc.CreatedDate != null){
                    obj.ccecDateTime = cc.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.ccecDateTime = '';
                }
                
                if(cc.Proactive_CCEC_Flag__c == true){
                    obj.proactiveCCECFlag = 'Y';
                }
                else{
                    obj.proactiveCCECFlag = 'N';
                }
                
                if(cc.Auto_CCEC_Flag__c == true){
                    obj.autoCCECFlag ='Y';
                }
                else{
                    obj.autoCCECFlag ='N';
                }
                
                if(cc.CCEC_OU_Assignment_Logic__r.Name != null){
                    obj.ccecActionOu = cc.CCEC_OU_Assignment_Logic__r.name;
                }
                else{
                    obj.ccecActionOu = '';
                }
                
                if(cc.CreatedBy.Staff_Code__c != null){
                    obj.ccecCreatedBY = cc.CreatedBy.Staff_Code__c;
                }
                else{
                    obj.ccecCreatedBY = '';
                }
                
                if(userIdToStaffCode.containsKey(cc.Case__r.OwnerId)){
                    obj.csaCode = userIdToStaffCode.get(cc.Case__r.OwnerId).Staff_Code__c;
                }
                else{
                    obj.csaCode = '';
                }
                
                if(cc.Exp_Closure_Dt__c != null){
                    obj.expClosureDt =cc.Exp_Closure_Dt__c.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.expClosureDt='';
                }
                
                if(cc.CCEC_reason__c != null){
                    obj.ccecReason =cc.CCEC_reason__c;
                }
                else{
                    obj.ccecReason = '';
                }
                
                if(cc.CCEC_OF__c!=null){
                    obj.ccecOf = cc.CCEC_OF__c;
                }
                else{
                    obj.ccecOf = '';
                }
                
                if(cc.Status__c!=null){
                    obj.ccecStatus =cc.Status__c;
                }
                else{
                    obj.ccecStatus = '';
                }
                
                if(cc.CCEC_Closure_Date__c != null){
                    obj.ccecClosureDate =cc.CCEC_Closure_Date__c.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.ccecClosureDate='';
                }
                
                if(cc.LastModifiedBy.Staff_Code__c != null){
                    obj.lastModifiedby=cc.LastModifiedBy.Staff_Code__c;
                }
                else{
                    obj.lastModifiedby= '';
                }
                
                if(cc.LastModifiedDate != null){
                    obj.lastModifiedDate = cc.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.lastModifiedDate='';
                }
                
                obj.remarkSeq = '';
                obj.commentsBy = '';
                obj.openRemarks = '';
                obj.remarksProvidedBy = '';
                obj.remarksDate = '';
                
                System.debug('Request Body '+obj);
                
                Http http = new Http(); 
                HttpRequest req = new HttpRequest();
                String[] authParamsSplitted = authParams.split('\\|');
                for(String authpar : authParamsSplitted){
                    String[] nameValue= authpar.split('\\:');
                    req.setHeader(nameValue[0], nameValue[1]);                   
                }
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setEndpoint(endPoint);
                req.setBody(JSON.serialize(obj));
                req.setMethod('POST');
                req.setTimeout(60000);
                HttpResponse result = http.send(req);
                String errorMessage;
                System.debug('Response Code - '+result.getStatusCode());
                if(result.getStatusCode()==200){
                    try{
                        ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                        errorMessage = responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c = 'CCEC Record';
                        ic.Error_Message__c   = errorMessage;
                        ic.IsIntegration__c = true; 
                        ic.eRecordID__c = cc.id;
                        ic.CaseNumber__c = cc.Case__r.CaseNumber;
                        ic.ccecNumber__c = cc.Name;
                        ic.Inbound_JSON__c = result.getBody();
                        ic.Outbound_JSON__c = JSON.serialize(obj);
                        integrationLogs.add(ic);    
                    }catch(Exception e){}
                }
                else{
                    try{ 
                        ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                        errorMessage = responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c = 'CCEC Record';
                        ic.Error_Message__c = errorMessage;
                        ic.IsIntegration__c = true; 
                        ic.eRecordID__c = cc.id;
                        ic.ccecNumber__c = cc.Name;
                        ic.CaseNumber__c = cc.Case__r.CaseNumber;
                        ic.Inbound_JSON__c = result.getBody();
                        ic.Outbound_JSON__c = JSON.serialize(obj);
                        integrationLogs.add(ic);    
                    }catch(Exception e){}
                }                
            }
            catch(Exception e){
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c = 'CCEC Record';
                ic.Error_Message__c = e.getMessage();
                ic.IsIntegration__c = true; 
                ic.CaseNumber__c = cc.Case__r.CaseNumber;
                ic.ccecNumber__c = cc.Name;
                integrationLogs.add(ic);
            }
        }
        
        if(!integrationLogs.isEmpty()){
            Database.insert(integrationLogs, false);
        }
    }
    
    public class CCECRecords{
        public string identity{get;set;}
        public string identifier{get;set;}
        public string compRefNo{get;set;}
        public string docketNo{get;set;}
        public string pickUpSlipNo{get;set;}
        public string compCode{get;set;}
        public string ccecRefNo{get;set;}
        public string ccecInstructions{get;set;}
        public string ccecRaisedOU{get;set;}
        public string ccecDateTime{get;set;}
        public string proactiveCCECFlag{get;set;}
        public string autoCCECFlag{get;set;}
        public string ccecActionOu{get;set;}
        public string ccecCreatedBY{get;set;}
        public string csaCode{get;set;}
        public string expClosureDt{get;set;}
        public string ccecReason{get;set;} //mandatory
        public string ccecOf{get;set;}
        public string ccecStatus{get;set;}
        public string ccecClosureDate{get;set;}
        public string lastModifiedBy{get;set;}
        public string lastModifiedDate{get;set;}
        
        //CCEC REMARKS FIELDS
        public string commentsBy{get;set;}
        public string remarkSeq{get;set;}
        public string openRemarks{get;set;}
        public string remarksProvidedBy{get;set;}
        public string remarksDate{get;set;}        
    }
    
    public class ResponseWrapper{
        public String requid;    
        public String result;   
        public String sErrMsg;        
    }
}