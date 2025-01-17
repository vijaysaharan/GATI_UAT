@RestResource(urlMapping='/CaseAttachmentv1/*')
global without sharing class ClaimAttachmentAPIVersion1 {
    @HttpPost
    global static Wrapperclass doPost() {
        CaseAndAttachment caseAndAttachmentObj = (CaseAndAttachment)System.JSON.deserialize(RestContext.request.requestBody.tostring(),CaseAndAttachment.class);
        Case caseRecordObj;
        List<case> clist;
        try{
            if(caseAndAttachmentObj != null && caseAndAttachmentObj.caseObj != null){
                caseRecordObj = caseAndAttachmentObj.caseObj;
                System.debug('caseRecordObj'+caseRecordObj);
                if(caseRecordObj.CaseNumber == null || caseRecordObj.CaseNumber ==''){
                    if(CaseAndAttachmentObj.callrecievedOU!=null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.callrecievedOU];
                        if(om.size()>0){
                            caseRecordObj.Call_received_OU__c = om[0].id;
                        }else{
                            caseRecordObj.Call_received_OU__c = null;  
                        }    
                    }
                    if(CaseAndAttachmentObj.Companyof != null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.Companyof];
                        if(om.size()>0){
                            caseRecordObj.Company_of__c = om[0].id;
                        }else{
                            caseRecordObj.Company_of__c = null;  
                        }    
                    } 
                    if(CaseAndAttachmentObj.Gemrefno != null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.Gemrefno];
                        if(om.size()>0){
                            caseRecordObj.Gems_Ref_No__c = om[0].id;
                        }else{
                            caseRecordObj.Gems_Ref_No__c = null;  
                        }    
                    }
                    if(CaseAndAttachmentObj.callforwardedOU !=null){
                        list<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.callforwardedOU];
                        if(om.size()>0){
                            caseRecordObj.Call_forwarded_OU__c =om[0].id;
                        }else{
                            caseRecordObj.Call_forwarded_OU__c=null;  
                        }
                    }
                    
                    // code is changed here for Stock OU / Stock Receving OU and Delivery OU
                    if(caseRecordObj.Stock_OU__c != null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c =: caseRecordObj.Stock_OU__c];
                        if(!om.isEmpty()){
                            caseRecordObj.Stock_OU__c = om[0].id;
                        }else{
                            caseRecordObj.Stock_OU__c = null;
                        }
                    }
                    if(caseRecordObj.Stock_Receiving_OU__c != null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c =: caseRecordObj.Stock_Receiving_OU__c];
                        if(!om.isEmpty()){
                            caseRecordObj.Stock_Receiving_OU__c = om[0].id;
                        }else{
                            caseRecordObj.Stock_Receiving_OU__c = null;
                        }
                    }
                    if(caseRecordObj.Delivery_OU__c != null){
                        List<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c =: caseRecordObj.Delivery_OU__c];
                        if(!om.isEmpty()){
                            caseRecordObj.Stock_Receiving_OU__c = om[0].id;
                        }else{
                            caseRecordObj.Delivery_OU__c = null;
                        }
                    }
                    
                    if(CaseAndAttachmentObj.ccecActionOU !=null) {
                        System.debug(CaseAndAttachmentObj.ccecActionOU);
                        list<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.ccecActionOU];
                        if(om.size()>0){
                            System.debug(om[0].id);
                            caseRecordObj.CCEC_Action_OU__c=om[0].id; 
                        }else{
                            caseRecordObj.CCEC_Action_OU__c=null;  
                        }
                    }  
                    if(CaseAndAttachmentObj.complaintActionOU !=null) {
                        list<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.complaintActionOU];
                        if(om.size()>0){
                            caseRecordObj.Complaint_Actionable_OU__c=om[0].id; 
                        }else{
                            caseRecordObj.Complaint_Actionable_OU__c=null;  
                        }
                    }  
                    if(CaseAndAttachmentObj.PickUpPincode !=null){
                        // Organization_Master__c om = new Organization_Master__c(REF_Code__c=CaseAndAttachmentObj.PickUpPincode);
                        list<Organization_Master__c> om = [select id from Organization_Master__c where REF_Code__c=:CaseAndAttachmentObj.PickUpPincode];
                        caseRecordObj.Pick_Up_Pincode__c =om[0].id;
                    }
                    if(CaseAndAttachmentObj.customercode!=null){
                        //  Account acc = new Account(Customer_Code__c= Decimal.valueof(CaseAndAttachmentObj.customercode));
                        List<account> acc = [select id from account where Customer_Code__c = : Decimal.valueof(CaseAndAttachmentObj.customercode)];
                        if(acc != null && acc.size() > 0){
                            caseRecordObj.AccountId = acc[0].id; 
                        }
                    }   
                    
                    if(CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c != null){
                        //caseRecordObj.Pick_Up_Ref_ID__r = new Case(CaseName = CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c);
                        List<Case> ca = [select Id, PickUp_OU__c from Case where CaseNumber =: CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c];
                        if(ca != null && ca.size()>0){
                            caseRecordObj.Pick_Up_Ref_ID__c = ca[0].Id;
                            caseRecordObj.PickUp_OU__c = ca[0].PickUp_OU__c;   
                        }
                    }
                    
                    if(CaseAndAttachmentObj.recordType!=null){
                        if(CaseAndAttachmentObj.recordType.containsIgnoreCase('Complaint')){
                            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
                            caseRecordObj.recordTypeId = recordTypeId;
                        }
                        else if(CaseAndAttachmentObj.recordType.containsIgnoreCase('Query')){
                            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query').getRecordTypeId();
                            caseRecordObj.recordTypeId = recordTypeId;
                        }
                        else if(CaseAndAttachmentObj.recordType.containsIgnoreCase('Service Request') && caseRecordObj.Type=='Pick Up'){
                            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick_Up').getRecordTypeId();
                            caseRecordObj.recordTypeId = recordTypeId;
                        }
                        else if(CaseAndAttachmentObj.recordType.containsIgnoreCase('Service Request') && caseRecordObj.Type=='Claim'){
                            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claim').getRecordTypeId();
                            caseRecordObj.recordTypeId = recordTypeId;
                        }
                        else if(CaseAndAttachmentObj.recordType.containsIgnoreCase('Service Request')) {
                            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
                            caseRecordObj.recordTypeId = recordTypeId;
                        }
                        
                    }
                    else { 
                        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query').getRecordTypeId();
                        caseRecordObj.recordTypeId = recordTypeId;
                    }
                    
                    if(CaseAndAttachmentObj.recordType != null && (CaseAndAttachmentObj.recordType.containsIgnoreCase('Complaint') || CaseAndAttachmentObj.recordType.containsIgnoreCase('Query')) && (CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c != null || CaseAndAttachmentObj.caseObj.Docket_Number__c != null)){
                        caseRecordObj.Docket_Validation__c = 'Valid';
                    }
                    Database.SaveResult result = Database.insert(caseRecordObj,false);
                    if(result.errors!=null && !result.errors.isEmpty()){
                        System.debug(result.geterrors().toString());
                        wrapperclass wc = new wrapperclass();
                        wc.Status ='Not Inserted';
                        // wc.error = result.geterrors().toString();
                        Integration_Log__c ic = new Integration_Log__c();
                        for(Database.Error er: result.geterrors()) {
                            wc.error= er.getMessage() ;
                            ic.Error_Message__c=wc.error;
                        }
                        
                        ic.Component_Name__c='Case Insertion - G2C';
                        ic.IsIntegration__c=false;
                        
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=RestContext.request.requestBody.tostring();
                        ic.Outbound_JSON__c=JSON.serialize(wc);
                        insert ic;
                        System.debug(JSON.serialize(wc));
                        System.debug(ic);
                        return wc;    
                    }                    
                    if(caseRecordObj.Id!=null){
                        List<ContentDocumentLink> attachmentToInsert = new List<ContentDocumentLink>();                        
                        if(caseAndAttachmentObj.attachments != null && caseAndAttachmentObj.attachments.size() > 0){
                            for(Attach attachObj : caseAndAttachmentObj.attachments){
                                ContentVersion conVer = new ContentVersion();
                                conVer.ContentLocation = 'S'; 
                                conVer.PathOnClient =attachObj.ContentType ; 
                                conVer.Title = attachObj.name; 
                                conVer.VersionData = EncodingUtil.base64Decode(attachObj.body); 
                                insert conVer;
                                
                                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;                               
                                
                                ContentDocumentLink cDe = new ContentDocumentLink();
                                cDe.ContentDocumentId = conDoc;
                                cDe.LinkedEntityId = caseRecordObj.Id; 
                                cDe.ShareType = 'I';
                                cDe.Visibility = 'AllUsers';
                                attachmentToInsert.add(cDe);                                
                            }                            
                        }                        
                        if(!attachmentToInsert.isEmpty()){
                            insert attachmentToInsert;
                        }
                    }
                    if(result.isSuccess()){
                        Case cs = [select CaseNumber,id from case where  id=:result.id]; 
                        //Case cs = [select Case_Name__c from case where  id=:result.id]; 
                        wrapperclass wc = new wrapperclass();
                        wc.CaseName=cs.CaseNumber;
                        wc.Status ='Inserted';
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Case Insertion - G2C';
                        ic.IsIntegration__c=true;
                        ic.CaseNumber__c=cs.CaseNumber;
                        ic.eRecordID__c = cs.id;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=RestContext.request.requestBody.tostring();
                        ic.Outbound_JSON__c=JSON.serialize(wc);
                        insert ic;
                        System.debug(JSON.serialize(wc));
                        System.debug(ic);
                        return wc;
                    }
                }
                else if(caseRecordObj.CaseNumber != null) {
                    clist = [select id,CaseNumber from case where CaseNumber =:caseRecordObj.CaseNumber ];
                    if(clist.size()>0 ){
                        List<ContentDocumentLink> attachmentToInsert = new List<ContentDocumentLink>();
                        
                        if(caseAndAttachmentObj.attachments != null && caseAndAttachmentObj.attachments.size() > 0){
                            for(Attach attachObj : caseAndAttachmentObj.attachments){
                                ContentVersion conVer = new ContentVersion();
                                conVer.contentLocation = 'S'; 
                                conVer.pathOnClient =attachObj.ContentType ; 
                                conVer.title = attachObj.name; 
                                conVer.versionData = EncodingUtil.base64Decode(attachObj.body); 
                                insert conVer;
                                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;                                
                                ContentDocumentLink cDe = new ContentDocumentLink();
                                cDe.ContentDocumentId = conDoc;
                                cDe.LinkedEntityId = clist[0].Id; 
                                cDe.ShareType = 'I';
                                cDe.Visibility = 'AllUsers';
                                attachmentToInsert.add(cDe);
                            }
                            
                        }
                        if(!attachmentToInsert.isEmpty()){
                            insert attachmentToInsert;
                        }
                        wrapperclass wc = new wrapperclass();
                        wc.CaseName=clist[0].CaseNumber;
                        wc.Status ='Updated';
                        return wc;
                    }
                    else{
                        wrapperclass wc = new wrapperclass();
                        wc.CaseName=null;
                        wc.Status ='Not Updated';
                        wc.error ='Invalid Case Number';
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Case Insertion - G2C';
                        ic.IsIntegration__c=false;
                        ic.Error_Message__c=wc.error;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=RestContext.request.requestBody.tostring();
                        ic.Outbound_JSON__c=JSON.serialize(wc);
                        insert ic;
                        System.debug(JSON.serialize(wc));
                        System.debug(ic);
                        return wc;
                    } 
                }
            }    
        }
        catch(Exception e)
        {
            Integration_Log__c ic = new Integration_Log__c();
            ic.Component_Name__c='Case Insertion - G2C';
            ic.IsIntegration__c=true;
            ic.Error_Message__c=e.getMessage();
            if (ic.Error_Message__c.length() > 250) {
                ic.Split_Error_Message__c = ic.Error_Message__c.substring(250);
                ic.Error_Message__c = ic.Error_Message__c.substring(0, 250);
            }
            ic.eObject__c = 'Case';
            ic.Inbound_JSON__c=RestContext.request.requestBody.tostring();
            ic.Outbound_JSON__c = RestContext.request.requestBody.tostring();
            insert ic;
            System.debug(ic);
            //New Changes If Not inserted
            wrapperclass wc = new wrapperclass();
            wc.Status ='Not Inserted';
            wc.error= e.getMessage();
            return wc; 
        }
        return null;
    }
    
    private class CaseAndAttachment {
        Case caseObj;
        list<Attach> attachments;
        String customercode;
        String recordType;
        String callrecievedOU;
        String callforwardedOU;
        String ccecActionOU;
        String complaintActionOU;
        String pickUpPincode;
        String Companyof;
        String Gemrefno;
        //  String Type;
    } 
    private class Attach {
        String body;
        String contentType;
        String name;
    }
    
    global class Wrapperclass {
        String caseName {get;set;}
        String status {get;set;}
        String error {get;set;}  
    }
}