public Without Sharing class ManualCCECOutboundAPI {
    
    @InvocableMethod(label='Manual CCEC Creation')
    public static void SendCCEC(List<String> ccecid){
        for(string str : ccecid){
            ManualCCECOutbound(str); 
        }
    }
    @future(callout =true)
    public static void ManualCCECOutbound(string ccecid){
        CCECRecords obj=new CCECRecords();
        List<CCEC__c> ccecs = [SELECT Case__r.Owner.Id, Case__r.Owner.Type, Case__r.RecordType.Name, Case__r.Sub_Type__c, 
                               Case__r.CaseNumber, Case__r.Docket_Number__c, Case__r.Pick_Up_Ref_ID__r.CaseNumber, Case__r.Open_CCEC_Count__c, 
                               Comp_Code__c, Name, CCEC_OU_Assignment_Logic__r.name, Case__r.Type, 
                               CCEC_Instructions__c, CreatedBy.Organi__c, CreatedDate, Proactive_CCEC_Flag__c,Auto_CCEC_Flag__c,
                               CCEC_Received_OU__c, CreatedBy.Staff_Code__c, CSA_code__c,Exp_Closure_Dt__c, Case__r.Case_Name__c,
                               CCEC_reason__c, CCEC_OF__c, Status__c, CCEC_Closure_Date__c,CreatedBy.name,LastModifiedDate,
                               LastModifiedBy.Staff_Code__c, Total_CCEC_Remarks__c
                               FROM CCEC__c 
                               WHERE Id =: ccecid 
                               ORDER BY Name DESC 
                               LIMIT 1
                              ];
        try{
            if(ccecs != null && ccecs.size()>0){
                CCEC__c cc = ccecs[0];
                if(cc.Case__r.RecordType.Name == 'Service Request' && cc.Case__r.Type == 'Exception' && cc.Case__r.Sub_Type__c!= 'COD Remittance' && cc.Case__r.Sub_Type__c!= 'Bad POD')
                {
                    Exception_SF_Meta__mdt   LookupMastermdtRecords2 = [SELECT Id, crm_field_value__c, external_field_value__c 
                                                                        FROM Exception_SF_Meta__mdt 
                                                                        WHERE MasterLabel =: cc.Case__r.Sub_Type__c 
                                                                        LIMIT 1
                                                                       ];
                    if(LookupMastermdtRecords2!=null){
                        obj.identity = LookupMastermdtRecords2.external_field_value__c;
                    }
                }
                else{
                    obj.identity = '';  
                }
                if(cc.Case__r.Case_Name__c!=null){
                    obj.identifier = cc.Case__r.Case_Name__c;
                }
                else{
                    obj.identifier = '';
                }
                obj.compRefNo = cc.Case__r.CaseNumber;
                if(cc.Case__r.Docket_Number__c!= null){
                    obj.docketNo =cc.Case__r.Docket_Number__c;
                }
                else{
                    obj.docketNo = ''; 
                }
                if(cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber!= null){
                    obj.pickupSlipNo =cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber;
                }
                else{
                    obj.pickupSlipNo = '';
                }
                
                if(cc.Case__r.RecordType.Name == 'Complaint' && cc.Case__r.Sub_Type__c != null){
                    Lookup_Master__mdt LookupMastermdtRecords = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c 
                                                                 FROM Lookup_Master__mdt 
                                                                 WHERE MasterLabel =: cc.Case__r.Sub_Type__c 
                                                                 LIMIT 1
                                                                ];
                    if(LookupMastermdtRecords!=null){
                        obj.compCode = LookupMastermdtRecords.External_Field_Value__c;
                    }
                }
                else if( cc.Case__r.RecordType.Name == 'Service Request' && cc.Case__r.Type == 'Exception' && cc.Case__r.Sub_Type__c!= 'COD Remittance' && cc.Case__r.Sub_Type__c!= 'Bad POD'){
                    Exception_SF_Meta__mdt   LookupMastermdtRecords1 = [SELECT Id, crm_field_value__c, complaint_code__c 
                                                                        FROM Exception_SF_Meta__mdt 
                                                                        WHERE MasterLabel =: cc.Case__r.Sub_Type__c 
                                                                        LIMIT 1
                                                                       ];
                    if(LookupMastermdtRecords1!=null){ 
                        obj.compCode = LookupMastermdtRecords1.complaint_code__c;
                    }
                }
                else if(cc.Case__r.RecordType.Name == 'Query'){
                    Lookup_Master__mdt LookupMastermdtRecords2 = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c 
                                                                  FROM Lookup_Master__mdt 
                                                                  WHERE MasterLabel =: cc.Case__r.Type 
                                                                  LIMIT 1
                                                                 ];
                    if(LookupMastermdtRecords2!=null){
                        obj.compCode = LookupMastermdtRecords2.External_Field_Value__c;
                        system.debug('complaintCode = '+obj.compCode);
                    }
                }
                else if(cc.Case__r.Type == 'Non Delivery Reasons'){
                    obj.compCode = '9';
                }
                else{
                    obj.compCode = '';
                }
                
                obj.ccecRefNo =cc.Name;
                if(cc.CCEC_Instructions__c!= null){
                    obj.ccecInstructions =cc.CCEC_Instructions__c;
                }
                else{
                    obj.ccecInstructions = '';
                }
                if(cc.CreatedBy.Organi__c!=null){
                    obj.ccecRaisedOU =cc.CreatedBy.Organi__c;
                }
                else{
                    obj.ccecRaisedOU = '';
                }
                if(cc.CreatedDate != null){
                    obj.ccecDateTime =cc.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.ccecDateTime='';
                }
                if(cc.Proactive_CCEC_Flag__c==True){
                    obj.proactiveCCECFlag ='Y';
                }
                else{
                    obj.proactiveCCECFlag ='N';
                }
                if(cc.Auto_CCEC_Flag__c==True){
                    obj.autoCCECFlag ='Y';
                }
                else{
                    obj.autoCCECFlag ='N';
                }
                if(cc.CCEC_OU_Assignment_Logic__r.Name!=null){
                    obj.ccecActionOu = cc.CCEC_OU_Assignment_Logic__r.name;
                }
                else{
                    obj.ccecActionOu = '';
                }
                if(cc.CreatedBy.Staff_Code__c!=null){
                    obj.ccecCreatedBY =cc.CreatedBy.Staff_Code__c;
                }
                else{
                    obj.ccecCreatedBY = '';
                }
                if(cc.Case__r.Owner.Type=='User'){
                    user u = [SELECT Id, Staff_Code__c 
                              FROM user WHERE Id=: cc.Case__r.Owner.Id
                             ];
                    obj.csaCode = u.Staff_Code__c;
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
                obj.remarkSeq= '';
                obj.commentsBy = '';
                obj.openRemarks='';
                obj.remarksProvidedBy= '';
                obj.remarksDate= '';
                
                system.debug('obj'+obj);
                
                Http http = new Http(); 
                HttpRequest req = new HttpRequest();
                String authParams = API_credential__mdt.getInstance('CCECRecords').Other_Auth_Parameter__c;
                String[] authParamsSplitted = authParams.split('\\|');
                for(String authpar:authParamsSplitted){
                    String[] nameValue= authpar.split('\\:');
                    req.setHeader(nameValue[0], nameValue[1]);                   
                }
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setEndpoint(API_credential__mdt.getInstance('CCECRecords').Endpoint__c);
                req.setBody(JSON.serialize(obj));
                req.setMethod('POST');
                req.setTimeout(60000);
                HttpResponse result= http.send(req);
                System.debug('result.getBody()=='+result.getBody());
                String errormsg1;
                System.debug(result.getStatusCode());
                if(result.getStatusCode()==200){
                    try{ 
                        ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='CCEC Record';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        ic.eRecordID__c=cc.id;
                        ic.CaseNumber__c=cc.Case__r.CaseNumber;
                        ic.ccecNumber__c=cc.Name;
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(obj);
                        insert ic;    
                    }
                    catch(Exception e){
                        
                    }
                }
                else{
                    try
                    { 
                        ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='CCEC Record';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        ic.eRecordID__c=cc.id;
                        ic.ccecNumber__c=cc.Name;
                        ic.CaseNumber__c=cc.Case__r.CaseNumber;
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(obj);
                        insert ic;    
                    }
                    catch(Exception e){
                        
                    }
                }
            }
        }
        catch(Exception e){
            Integration_Log__c ic = new Integration_Log__c();
            ic.Component_Name__c='CCEC Record';
            ic.Error_Message__c=e.getMessage();
            ic.IsIntegration__c=true; 
            if(ccecs != null && ccecs.size()>0){
                ic.CaseNumber__c=ccecs[0].Case__r.CaseNumber;
                ic.ccecNumber__c=ccecs[0].Name;   
            }
            insert ic;
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
        //public string ccecReceivedOU{get;set;}
        public string ccecCreatedBY{get;set;}
        public string csaCode{get;set;}
        //public string csmCode{get;set;}
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