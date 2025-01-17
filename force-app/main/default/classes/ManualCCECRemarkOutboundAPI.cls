public class ManualCCECRemarkOutboundAPI {

    @InvocableMethod(label='Manual CCEC Remark ')
    public static void SendCCEC(List<String> ccec1id){
        ManualCCECRemarkOutbound(ccec1id);
    }
    @future(callout =true)
    public static void ManualCCECRemarkOutbound(List<String> ccec1id){
        Integration_Log__c Il;
        CCECRecords obj=new CCECRecords();
        system.debug('ccecid'+ccec1id);
        
        CCEC__c cc = [select Case__r.Owner.Id, Case__r.Owner.Type, Case__r.RecordType.Name, Case__r.Sub_Type__c, Case__r.CaseNumber, Case__r.Docket_Number__c, 
                      Case__r.Pick_Up_Ref_ID__r.CaseNumber, Comp_Code__c, Name, CCEC_OU_Assignment_Logic__r.name, Case__r.Type, 
                      CCEC_Instructions__c, CreatedBy.Organi__c, CreatedDate, Proactive_CCEC_Flag__c,Auto_CCEC_Flag__c,
                      CCEC_Received_OU__c, CreatedBy.Staff_Code__c, CSA_code__c,Exp_Closure_Dt__c, Case__r.Case_Name__c,
                      CCEC_reason__c, CCEC_OF__c,  Status__c, CCEC_Closure_Date__c,CreatedBy.name,LastModifiedDate,LastModifiedBy.Staff_Code__c from CCEC__c where id =: ccec1id];
       try{ 
       CCEC_Remark__c ccecRemark = [select CCEC__r.Comp_Ref_No__c, CCEC__r.CCEC_Ref_No__c, CreatedDate,
                                           Comments_By__c, Remark_Seq__c,Open_Remarks__c, Remarks_Provided_By__c, Complaint_No__c 
                                           from CCEC_Remark__c where CCEC__c =: ccec1id AND Comments_By__c = 'CSA' order by Remark_Seq__c desc limit 1];
        
           //(cc.CreatedBy.name!='Platform Integration User' || cc.CreatedBy.name!='Integration User' ) &&
        if( cc.Case__r.RecordType.Name == 'Service Request' && cc.Case__r.Type == 'Exception' && cc.Case__r.Sub_Type__c!= 'COD Remittance' && cc.Case__r.Sub_Type__c!= 'Bad POD')
        {
            Exception_SF_Meta__mdt   LookupMastermdtRecords2 = [SELECT Id, crm_field_value__c, external_field_value__c from Exception_SF_Meta__mdt where MasterLabel =: cc.Case__r.Sub_Type__c LIMIT 1];
            if(LookupMastermdtRecords2!=null){
                obj.identity = LookupMastermdtRecords2.external_field_value__c;
                
            }
        }
        //obj.identity = cc.Case__r.Sub_Type__c;
        //}
        else
        {
            obj.identity = '';  
        }
        system.debug('identity = '+obj.identity);
        if(cc.Case__r.Case_Name__c!=null){
            obj.identifier = cc.Case__r.Case_Name__c;
        }
        else
        {
            obj.identifier = '';
        }
        
        system.debug('identifier = '+obj.identifier);
        if(cc.Case__r.Docket_Number__c!= null){
        obj.docketNo =cc.Case__r.Docket_Number__c;
        }
        else
        {
           obj.docketNo = ''; 
        }
        system.debug('compRefNo = '+obj.compRefNo);
        obj.docketNo =cc.Case__r.Docket_Number__c;
        system.debug('docketNo = '+obj.docketNo);
        //obj.pickUpSlipNo = cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber;
        if(cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber!= null){
            obj.pickupSlipNo =cc.Case__r.Pick_Up_Ref_ID__r.CaseNumber;
        }
        else{
            obj.pickupSlipNo = '';
        }
        system.debug('pickupSlipNo = '+obj.pickupSlipNo);
        //obj.compCode =cc.Comp_Code__c;
        //(cc.CreatedBy.name!='Platform Integration User' || cc.CreatedBy.name!='Integration User' ) && 
        if(cc.Case__r.RecordType.Name == 'Complaint')
        {
            Lookup_Master__mdt LookupMastermdtRecords = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c from Lookup_Master__mdt where MasterLabel =: cc.Case__r.Sub_Type__c LIMIT 1];
            if(LookupMastermdtRecords!=null){
                obj.compCode = LookupMastermdtRecords.External_Field_Value__c;
                
            }
            
        }
           //(cc.CreatedBy.name!='Platform Integration User' || cc.CreatedBy.name!='Integration User' ) &&
        else if(cc.Case__r.RecordType.Name == 'Query')
        {
            Lookup_Master__mdt LookupMastermdtRecords2 = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c from Lookup_Master__mdt where MasterLabel =: cc.Case__r.Type LIMIT 1];
            
            if(LookupMastermdtRecords2!=null){
                obj.compCode = LookupMastermdtRecords2.External_Field_Value__c;
                system.debug('complaintCode = '+obj.compCode);
            }
        }
        else
        {
            obj.compCode = '';
        }
        system.debug('complaintCode = '+obj.compCode);
        obj.ccecRefNo =cc.Name;
        system.debug('ccecRefNo = '+obj.ccecRefNo);
         if(cc.CCEC_Instructions__c!= null){
         obj.ccecInstructions =cc.CCEC_Instructions__c;
        }
        else
        {
            obj.ccecInstructions = '';
        }
        system.debug('ccecInstructions = '+obj.ccecInstructions);
        //obj.ccecRaisedOU =cc.CreatedBy.Organi__c;
        if(cc.CreatedBy.Organi__c!=null){
            obj.ccecRaisedOU =cc.CreatedBy.Organi__c;
        }
        else
        {
            obj.ccecRaisedOU = '';
        }        
        system.debug('ccecRaisedOU = '+obj.ccecRaisedOU);
        if(cc.CreatedDate != null){
            obj.ccecDateTime =cc.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
        }
        else
        {
            obj.ccecDateTime='';
        }
        system.debug('ccecDateTime = '+obj.ccecDateTime);
        if(cc.Proactive_CCEC_Flag__c==True)
        {
            obj.proactiveCCECFlag ='Y';
        }
        else{
            obj.proactiveCCECFlag ='N';
        }
        system.debug('proactiveCCECFlag = '+obj.proactiveCCECFlag);
        if(cc.Auto_CCEC_Flag__c==True)
        {
            obj.autoCCECFlag ='Y';
        }
        else{
            obj.autoCCECFlag ='N';
        }
        system.debug('autoCCECFlag = '+obj.autoCCECFlag);
        if(cc.CCEC_OU_Assignment_Logic__r.Name!=null){
            obj.ccecActionOu = cc.CCEC_OU_Assignment_Logic__r.name;
        }
        else{
            obj.ccecActionOu = '';
        }
        System.debug('ccec action ou = '+obj.ccecActionOU);
        
        //obj.ccecReceivedOU =cc.CCEC_Received_OU__c;
        //system.debug('ccecReceivedOU = '+obj.ccecReceivedOU);
        //obj.ccecCreatedBY =cc.CreatedBy.Staff_Code__c;
        if(cc.CreatedBy.Staff_Code__c!=null){
            obj.ccecCreatedBY =cc.CreatedBy.Staff_Code__c;
        }
        else
        {
            obj.ccecCreatedBY = '';
        }
        System.debug('ccecCreatedBY = '+obj.ccecCreatedBY);
        
        //obj.csaCode =cc.CSA_code__c;
        if(cc.Case__r.Owner.Type=='User'){
            user u = [select id, Staff_Code__c from user where id=: cc.Case__r.Owner.Id];
            obj.csaCode = u.Staff_Code__c;
        }
        else
        {
            obj.csaCode = '';
        }   
        system.debug('csaCode = '+obj.csaCode);
        //obj.csmCode = cc.CSM_Code__c;
        // obj.expClosureDt =cc.Exp_Closure_Dt__c;
        if(cc.Exp_Closure_Dt__c != null){
            obj.expClosureDt =cc.Exp_Closure_Dt__c.format('dd-MM-yyyy HH:mm:ss');
        }
        else{
            obj.expClosureDt='';
        }
        System.debug('expClosureDt = '+obj.expClosureDt);
        
        //obj.ccecReason =cc.CCEC_reason__c;
        //obj.ccecOf =cc.CCEC_OF__c;
        //obj.ccecStatus =cc.Status__c;
        if(cc.CCEC_reason__c != null){
            obj.ccecReason =cc.CCEC_reason__c;
        }
        else
        {
            obj.ccecReason = '';
        }
        System.debug('ccecReason = '+obj.ccecReason);
        if(cc.CCEC_OF__c!=null){
            obj.ccecOf = cc.CCEC_OF__c;
        }
        else
        {
            obj.ccecOf = '';
        }
        System.debug('ccec of = '+obj.ccecOf);
        if(cc.Status__c!=null){
            obj.ccecStatus =cc.Status__c;
        }
        else
        {
            obj.ccecStatus = '';
        }
        System.debug('ccecStatus = '+obj.ccecStatus);
        //obj.ccecClosureDate =cc.CCEC_Closure_Date__c;
        
        if(cc.CCEC_Closure_Date__c != null){
            obj.ccecClosureDate =cc.CCEC_Closure_Date__c.format('dd-MM-yyyy HH:mm:ss');
        }
        else{
            obj.ccecClosureDate='';
        }
        System.debug('ccecClosureDate = '+obj.ccecClosureDate);
        
        //obj.lastModifiedDate = cc.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
        if(cc.LastModifiedBy.Staff_Code__c != null){
            obj.lastModifiedby=cc.LastModifiedBy.Staff_Code__c;
        }
        else{
            obj.lastModifiedby= '';
        }
        System.debug('lastModifiedby ='+obj.lastModifiedby);       
        if(cc.LastModifiedDate != null){
            obj.lastModifiedDate = cc.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
        }
        else{
            obj.lastModifiedDate='';
        }
        System.debug('lastModifiedDate = '+obj.lastModifiedDate);
        
        
        //if(ccecRemark.size() > 0){
            if(ccecRemark.Remark_Seq__c!=null)
                {
                    obj.remarkSeq=String.valueOf(ccecRemark.Remark_Seq__c);  
                }
                else
                {
                    obj.remarkSeq= '';
                }
                system.debug('remarkSeq = '+obj.remarkSeq);
                //Mapping of related CCEC Remarks records
                //obj.complaintNo=ccecRemark.Complaint_No__c;
                //obj.ccecRefNo=ccecRemark.CCEC__r.Name;
                //system.debug('ccecRefNo = '+obj.ccecRefNo);
                if(ccecRemark.Comments_By__c!=null)
                {
                obj.commentsBy=ccecRemark.Comments_By__c;                    //ccecRemark.Comments_By__c
                }
                else
                {
                    ccecRemark.Comments_By__c = '';
                }
                    system.debug('commentsBy = '+obj.commentsBy);
                
                if(ccecRemark.Open_Remarks__c!=null){
                    obj.openRemarks=ccecRemark.Open_Remarks__c;
                }
                else
                {
                    obj.openRemarks='';
                }
                system.debug('openRemarks = '+obj.openRemarks + cc.Name);
                if(ccecRemark.Remarks_Provided_By__c!=null){
                    obj.remarksProvidedBy=ccecRemark.Remarks_Provided_By__c;
                }
                else
                {
                    obj.remarksProvidedBy= '';
                }
                system.debug('remarksProvidedBy = '+obj.remarksProvidedBy);
                /*obj.remarksDate=ccecRemark.CreatedDate;
system.debug('remarksDate = '+obj.remarksDate);*/
                if(ccecRemark.CreatedDate != null){
                    obj.remarksDate =ccecRemark.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else
                {
                    obj.remarksDate= '';
                }
                System.debug('remarksDate = '+obj.remarksDate);
     //  }

        
        system.debug('obj'+obj);
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest();
        String authParams = API_credential__mdt.getInstance('CCECRecords').Other_Auth_Parameter__c;
        String[] authParamsSplitted = authParams.split('\\|');
        for (String authpar:authParamsSplitted)
        {
            String[] nameValue= authpar.split('\\:');
            req.setHeader(nameValue[0], nameValue[1]);                   
        }
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setEndpoint(API_credential__mdt.getInstance('CCECRecords').Endpoint__c);
        req.setBody(JSON.serialize(obj));
        req.setMethod('POST');
        req.setTimeout(50000);
        HttpResponse result= http.send(req);
        System.debug('result.getBody()=='+result.getBody());
         String errormsg1;
        
        System.debug(result.getStatusCode());
        
            if(result.getStatusCode()==200)
            {
             try{             
                ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                
                
                errormsg1=responseObj.sErrMsg;
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c='CCEC and Remarks Record';
                ic.Error_Message__c=errormsg1;
                ic.IsIntegration__c=true; 
                ic.eRecordID__c=cc.id;
                ic.CaseNumber__c=cc.Case__r.CaseNumber;
                ic.Inbound_JSON__c=result.getBody();
                ic.Outbound_JSON__c=JSON.serialize(obj);
                insert ic;    
            }
            catch(Exception e){
                    
                }
        }
        else{
            try{             
                ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                
                
                errormsg1=responseObj.sErrMsg;
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c='CCEC and Remarks Record';
                ic.Error_Message__c=errormsg1;
                ic.IsIntegration__c=true; 
                ic.eRecordID__c=cc.id;
                ic.CaseNumber__c=cc.Case__r.CaseNumber;
                ic.Inbound_JSON__c=result.getBody();
                ic.Outbound_JSON__c=JSON.serialize(obj);
                insert ic;    
            }
            catch(Exception e){
                    
                }
        }
        
    }   
        catch(Exception e){
            
            Integration_Log__c ic = new Integration_Log__c();
            ic.Component_Name__c='CCEC and Remarks Record';
            ic.Error_Message__c=e.getMessage();
            ic.IsIntegration__c=true; 
            ic.CaseNumber__c=cc.Case__r.CaseNumber;
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