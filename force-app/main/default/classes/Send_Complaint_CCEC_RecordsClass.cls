/*
Author     : Sumit Gupta (sgupta3@kloudrac.com)
Date       : Mar 04, 2022
Desc       : 
Test Class Name : Send_Complaint_CCEC_RecordsClassTest
Updated Date : March 18, 2024
*/

public class Send_Complaint_CCEC_RecordsClass {
    public static void calloutMethod(List<String> caseid,String testCode){
        Set<Id> caseOwnerSet = New Set<Id>();
        List<Integration_Log__c> ic1 = new List<Integration_Log__c>();
        List<Complaint_CCECRecords> obj1 = new List<Complaint_CCECRecords>();
        Map<Id,List<CCEC__c>> caseToCcecMap = New Map<Id,List<CCEC__c>>();
        Map<Id,User> userList = new Map<Id,User>();
        Map<String,Lookup_Master__mdt> lookUpMasterMap = New Map<String,Lookup_Master__mdt>();
        
        List<Lookup_Master__mdt> lookUpMasterList = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c, MasterLabel
                                                    FROM Lookup_Master__mdt 
                                                    ];
        
        List<Case> caseList = [SELECT Error_message__c,Sub_Type__c,docket_Number__c,CustCode__c,Pick_Up_Ref_ID__r.CaseNumber,
                               Type,CreatedById,CreatedBy.Name,CreatedBy.Staff_Code__c,Complaint_Actionable_OU__r.Name,
                               OwnerId,Owner.Type,customer_Name__c,Mobile__c,Customer_Email__c,Pick_Up_Pincode__c,Priority,
                               Origin,Complaint_Status__c,Nature_of_Call__c,CaseNumber,ClosedDate,LastModifiedBy.Staff_Code__c,
                               LastModifiedDate,Escalated_Level__c,Escalation_Description__c,Expected_Escalation_Date__c,
                               Company_of__c,Complaint_Actionable_OU__r.Pincode__c,Expected_Closing_Date__c,CreatedDate,
                               RecordType.Name,CreatedBy.Organi__c,Sync_flag__c,Status 
                               FROM case 
                               WHERE Id IN: caseid
                              ];
        
        List<CCEC__c> ccecList = [SELECT CCEC_Instructions__c,Name,CreatedBy.Organi__c,CreatedDate,Case__c,
                                  CCEC_OU_Assignment_Logic__r.Name,Auto_CCEC_Flag__c,Proactive_CCEC_Flag__c,
                                  CreatedBy.Staff_Code__c,CSA_code__c,Exp_Closure_Dt__c,
                                  CCEC_reason__c,CCEC_OF__c,CCEC_Closure_Date__c,Status__c 
                                  FROM CCEC__c
                                  WHERE Case__c =: caseid
                                  ORDER BY Name DESC
                                 ];
        
        if(ccecList != null && ccecList.size()>0){
            for(CCEC__c ccec : ccecList){
                if(caseToCcecMap.containsKey(ccec.Case__c)){
                    caseToCcecMap.get(ccec.Case__c).add(ccec);
                }else{
                    caseToCcecMap.put(ccec.Case__C,new List<CCEC__c>{ccec});
                }
            }
        }
        
        if(caseList != null && caseList.size()>0){
            for(Case cs : caseList){
                caseOwnerSet.add(cs.OwnerId);
            }    
        }
        
        if(caseOwnerSet != null && caseOwnerSet.size()>0){
            for(User u : [SELECT Id, Name, Staff_Code__c FROM User WHERE Id IN: caseOwnerSet]){
                userList.put(u.Id,u);
            }
        }

        if(lookUpMasterList != null && lookUpMasterList.size()>0){
            for(Lookup_Master__mdt lm : lookUpMasterList){
                lookUpMasterMap.put(lm.MasterLabel,lm);
            }
        }
        
        for(case c : caseList){            
            try{
                Complaint_CCECRecords obj = new Complaint_CCECRecords();
                if(c.Owner.Type=='User' && userList != null && userList.containsKey(c.OwnerId)){
                    user u = userList.get(c.OwnerId);
                    obj.complaintAssignedTo = u.Staff_Code__c;
                    obj.csaCode = u.Staff_Code__c;
                }
                else{
                    obj.complaintAssignedTo = '';
                    obj.csaCode = '';
                }
                if(c.RecordType.Name == 'Complaint' && lookUpMasterMap != null && (lookUpMasterMap.containsKey(c.Type) || lookUpMasterMap.containsKey(c.RecordType.Name))){
                    if(lookUpMasterMap.containsKey(c.Type)){
                        obj.compParentCode = lookUpMasterMap.get(c.Type).External_Field_Value__c;
                    }
                    else if(lookUpMasterMap.containsKey(c.RecordType.Name)){
                        obj.compParentCode = lookUpMasterMap.get(c.RecordType.Name).External_Field_Value__c;
                    }
                }
                else if(c.RecordType.Name == 'Query'){
                    obj.compParentCode = '7';
                }
                
                if(c.RecordType.Name == 'Complaint' && lookUpMasterMap != null && lookUpMasterMap.containsKey(c.Sub_Type__c)){
                    obj.complaintCode = lookUpMasterMap.get(c.Sub_Type__c).External_Field_Value__c;
                }
                else if(c.RecordType.Name == 'Query' && lookUpMasterMap != null && lookUpMasterMap.containsKey(c.Type)){
                    obj.complaintCode = lookUpMasterMap.get(c.Type).External_Field_Value__c;system.debug('complaintCode = '+obj.complaintCode);
                }
                
                if((c.RecordType.Name == 'Complaint' || c.RecordType.Name == 'Query') && c.Priority!=null && lookUpMasterMap != null && lookUpMasterMap.containsKey(c.Priority)){
                    obj.priority = lookUpMasterMap.get(c.Priority).External_Field_Value__c;
                }
                else{
                    obj.priority = '';
                }
                
                if(c.Docket_Number__c!= null){
                    obj.docketNo =c.Docket_Number__c;
                }
                else{
                    obj.docketNo = '';
                }
                
                if(c.CustCode__c!=null){
                    obj.CustCode =c.CustCode__c;
                }
                else{
                    obj.CustCode = '';
                }
                
                if(c.Pick_Up_Ref_ID__r.CaseNumber!= null){
                    obj.pickupSlipNo =c.Pick_Up_Ref_ID__r.CaseNumber;
                }
                else{
                    obj.pickupSlipNo = '';
                }
                obj.parentCategory =c.Type;
                if(c.Sub_Type__c!= null && c.RecordType.Name == 'Complaint'){
                    obj.compDesc =c.Sub_Type__c;    
                }
                else if(c.RecordType.Name == 'Query'){
                    obj.compDesc = c.Type;
                }
                else{
                    obj.compDesc= '';
                }
                
                if(c.CreatedBy.Staff_Code__c !=null){
                    obj.complaintRaisedBy =c.CreatedBy.Staff_Code__c;
                }
                else if(c.origin=='Web' || c.origin=='Website'){
                    obj.complaintRaisedBy ='Y';
                }
                else if(c.origin=='WhatsApp' ){
                    obj.complaintRaisedBy ='W';
                }
                else{
                    obj.complaintRaisedBy = '';
                }
                
                if(c.CreatedBy.Organi__c!=null){
                    obj.compRaisedOu =c.CreatedBy.Organi__c;
                }
                else{
                    obj.compRaisedOu = '';
                }
                
                if(c.CreatedDate!=null){
                    obj.complaintDate =c.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.complaintDate='';
                }
                
                if(c.Expected_Closing_Date__c!=null){
                    obj.expectedCloseDt =c.Expected_Closing_Date__c.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.expectedCloseDt='';
                }

                if(caseToCcecMap != null && caseToCcecMap.containsKey(c.Id) && caseToCcecMap.get(c.Id).size()>0){
                    CCEC__c cc = caseToCcecMap.get(c.Id)[0];
                    if(cc.CCEC_OU_Assignment_Logic__r.name!=null){
                        obj.ccecActionOU = cc.CCEC_OU_Assignment_Logic__r.name;
                    }
                    else{
                        obj.ccecActionOU = '';
                    }
                    if(cc.CCEC_Instructions__c!=null){
                        obj.ccecInstruction =cc.CCEC_Instructions__c;
                    }
                    else{
                        obj.ccecInstruction = '';
                    }
                    obj.ccecRefNo = cc.Name;
                    
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
                        obj.proactiveCcecFlag ='Y';
                    }
                    else{
                        obj.proactiveCcecFlag ='N';
                    }
                    
                    if(cc.Auto_CCEC_Flag__c==True){
                        obj.autoCcecFlag ='Y';
                    }
                    else{
                        obj.autoCcecFlag ='N';
                    }
                    
                    if(cc.CreatedBy.Staff_Code__c!=null){
                        obj.ccecCreatedBY =cc.CreatedBy.Staff_Code__c;
                    }
                    else{
                        obj.ccecCreatedBY = '';
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
                }
                
                if(c.Complaint_Actionable_OU__r.Name!=null){
                    obj.complaintOu =c.Complaint_Actionable_OU__r.Name;
                }
                else{
                    obj.complaintOu = ''; 
                }
                
                obj.complaintAssignedDt= c.createddate.format('dd-MM-yyyy HH:mm:ss');
                
                if(c.Customer_Name__c!=null){
                    obj.customerName =c.Customer_Name__c;
                }
                else{
                    obj.customerName = '';
                }
                
                if(c.Mobile__c!=null){
                    obj.customerMobile =c.Mobile__c;
                }
                else{
                    obj.customerMobile = '';
                }
                
                if(c.Customer_Email__c!=null){
                    obj.customerEmail =c.Customer_Email__c;
                }
                else{
                    obj.customerEmail = '';
                }
                
                if(c.Complaint_Actionable_OU__r.Pincode__c!=null){
                    obj.pincode =c.Complaint_Actionable_OU__r.Pincode__c;
                }
                else{
                    obj.pincode = '';
                }
                
                if(c.Origin != null && lookUpMasterMap != null && lookUpMasterMap.containsKey(c.Origin)){
                    obj.source = lookUpMasterMap.get(c.Origin).External_Field_Value__c;
                }
                
                obj.complaintStatus =c.Complaint_Status__c;
                obj.natureOfCall =c.Nature_of_Call__c;
                obj.complaintRefNo =c.CaseNumber;
                
                if(c.ClosedDate != null){
                    obj.complaintClosuredt =c.ClosedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.complaintClosuredt='';
                }
                
                if(c.LastModifiedBy.Staff_Code__c != null){
                    obj.lastModifiedby=c.LastModifiedBy.Staff_Code__c;
                }
                else{
                    obj.lastModifiedby= '';
                }
                
                if(c.LastModifiedDate != null){
                    obj.lastUpdatedDate =c.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.lastUpdatedDate='';
                }
                
                if(c.Escalated_Level__c!=null){
                    obj.escalationLevel =c.Escalated_Level__c ;
                }
                else{
                    obj.escalationLevel = '';
                }
                
                if(c.Escalation_Description__c =='Complaint raised' || c.Escalation_Description__c==null){
                    obj.escalationDescription = '';
                }
                else{
                    obj.escalationDescription =c.Escalation_Description__c;   
                }
                
                if(c.Expected_Escalation_Date__c != null){
                    obj.expEscDtTime =c.Expected_Escalation_Date__c.format('dd-MM-yyyy HH:mm:ss');
                }
                else{
                    obj.expEscDtTime='';
                }
                
                if(c.Company_of__c!=null){
                    obj.companyOf =c.Company_of__c;
                }
                else{
                    obj.companyOf = '';
                }
                
                Http http = new Http(); 
                HttpRequest req = new HttpRequest();
                String authParams = API_credential__mdt.getInstance('ComplaintCCECRecords').Other_Auth_Parameter__c;
                String[] authParamsSplitted = authParams.split('\\|');
                for (String authpar:authParamsSplitted){
                    String[] nameValue= authpar.split('\\:');
                    req.setHeader(nameValue[0], nameValue[1]);                   
                }
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setEndpoint(API_credential__mdt.getInstance('ComplaintCCECRecords').Endpoint__c);
                req.setBody(JSON.serialize(obj));
                req.setTimeout(60000);
                req.setMethod('POST');
                HttpResponse result = new HttpResponse();
                if(Test.isRunningTest()){
                    result.setHeader('Content-Type', 'application/json');
                    result.setBody('{"requid":"SG31006","result":"successful", "sErrMsg":"","response":[{"complaintRefNo":"00439524","result":"Posted Successfully "}]}');
                    System.debug('testCode'+testCode);
                    if(testCode == '200'){
                        result.setStatusCode(200);   
                    }
                    else if(testCode == '201'){
                        result.setStatusCode(201);
                    }else if(testCode != '200' && testCode != '201'){
                        result.setStatusCode(null);
                    }
                }else{
                    result= http.send(req);   
                }
                String errormsg1;
                
                if(result != null && result.getStatusCode()==200){
                    ResponseWrapper responseObj = new ResponseWrapper();
                    responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    try{ 
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Send Complaint with CCEC Record';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        ic.eRecordID__c=c.id;
                        ic.CaseNumber__c=c.CaseNumber;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(obj);
                        ic1.add(ic);
                    }
                    catch(Exception e){}   
                }
                else{
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    try{ 
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Send Complaint with CCEC Record';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        ic.eRecordID__c=c.id;
                        ic.CaseNumber__c=c.CaseNumber;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(obj);
                        ic1.add(ic);
                    }
                    catch(Exception e){}   
                }
            }
            catch(Exception e){
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c='Send Complaint with CCEC Record';
                ic.Error_Message__c=e.getMessage();
                ic.IsIntegration__c=true;
                ic.CaseNumber__c=c.CaseNumber;
                ic.eRecordID__c = c.Id;
                ic.eObject__c = 'Case';
                ic1.add(ic);
            }
        }
        
        try{
            List<Database.SaveResult> res = Database.insert(ic1,false);
        }
        catch(Exception e){}
    }
    
    public class Complaint_CCECRecords{
        public string docketNo{get;set;} 
        public string pickupSlipNo{get;set;} 
        public string compParentCode{get;set;} 
        public string parentCategory{get;set;} 
        public string complaintCode{get;set;}
        public string compDesc{get;set;} 
        public string complaintRaisedBy{get;set;} 
        public string compRaisedOu{get;set;}
        public string complaintDate{get;set;} 
        public string expectedCloseDt{get;set;} 
        public string ccecActionOU{get;set;} 
        public string complaintOu{get;set;} 
        public string complaintAssignedTo{get;set;} 
        public string complaintAssignedDt{get;set;} 
        public string customerName{get;set;} 
        public string customerMobile{get;set;} 
        public string customerEmail{get;set;} 
        public String pincode{get;set;} 
        public string priority{get;set;} 
        public string source{get;set;} 
        public string ccecInstruction{get;set;} 
        public string complaintStatus{get;set;} 
        public string natureOfCall{get;set;} 
        public string complaintRefNo{get;set;} 
        public string complaintClosuredt{get;set;} 
        public string lastModifiedby{get;set;} 
        public string lastUpdatedDate{get;set;} 
        public string escalationLevel{get;set;} 
        public string escalationDescription{get;set;} 
        public string expEscDtTime{get;set;}
        public string companyOf{get;set;} 
        
        
        //CCEC FIELDS
        public string ccecRefNo{get;set;} 
        public string ccecRaisedOU{get;set;} 
        public string ccecDateTime{get;set;} 
        public string proactiveCcecFlag{get;set;} 
        public string autoCcecFlag{get;set;} 
        public string ccecCreatedBY{get;set;} 
        public string csaCode{get;set;} 
        public string expClosureDt{get;set;} 
        public string ccecReason{get;set;} 
        public string ccecOf{get;set;} 
        public string ccecStatus{get;set;} 
        public string ccecClosureDate{get;set;} 
        public string CustCode{get;set;}
        
    }
    public class ResponseWrapper{
        public String requid;    
        public String result;   
        public String sErrMsg; 
        
    }
}