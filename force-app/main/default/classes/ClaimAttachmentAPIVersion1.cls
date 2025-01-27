@RestResource(urlMapping='/CaseAttachmentv1/*')
global without sharing class ClaimAttachmentAPIVersion1 {
    @HttpPost
    global static ResponseWrapper doPost() {
        Case caseRecordObj;
        List<case> newCaseRecord;
        CaseAndAttachment caseAndAttachmentObj = (CaseAndAttachment)System.JSON.deserialize(RestContext.request.requestBody.tostring(),CaseAndAttachment.class);
        try{
            if(caseAndAttachmentObj != null && caseAndAttachmentObj.caseObj != null){
                caseRecordObj = caseAndAttachmentObj.caseObj;
                if(caseRecordObj.CaseNumber == null || caseRecordObj.CaseNumber ==''){
                    Set<String> refCodes = new Set<String>();
                    Map<String, Organization_Master__c> refCodeToOrganizationMaster = new Map<String,Organization_Master__c>();
                    List<Organization_Master__c> organizationMasters = new List<Organization_Master__c>();
                    if(CaseAndAttachmentObj.callrecievedOU != null){
                        refCodes.add(CaseAndAttachmentObj.callrecievedOU);
                    }
                    if(CaseAndAttachmentObj.Companyof != null){
                        refCodes.add(CaseAndAttachmentObj.Companyof);
                    } 
                    if(CaseAndAttachmentObj.Gemrefno != null){
                        refCodes.add(CaseAndAttachmentObj.Gemrefno);
                    }
                    if(CaseAndAttachmentObj.callforwardedOU !=null){
                        refCodes.add(CaseAndAttachmentObj.callforwardedOU);
                    }
                    /*if(caseRecordObj.Stock_OU__c != null){
                        refCodes.add(caseRecordObj.Stock_OU__c);
                    }
                    if(caseRecordObj.Stock_Receiving_OU__c != null){
                        refCodes.add(caseRecordObj.Stock_Receiving_OU__c);
                    }
                    if(caseRecordObj.Delivery_OU__c != null){
                        refCodes.add(caseRecordObj.Delivery_OU__c);
                    }*/                 
                    if(CaseAndAttachmentObj.ccecActionOU !=null) {
                        refCodes.add(caseAndAttachmentObj.ccecActionOU);
                    }  
                    if(CaseAndAttachmentObj.complaintActionOU !=null) {
                        refCodes.add(caseAndAttachmentObj.complaintActionOU);
                    }  
                    if(CaseAndAttachmentObj.PickUpPincode !=null){
                        refCodes.add(caseAndAttachmentObj.pickUpPincode);
                    }
                    if(CaseAndAttachmentObj.customercode!=null){
                        List<account> accRecord = [SELECT Id FROM Account WHERE Customer_Code__c = :Decimal.valueof(CaseAndAttachmentObj.customercode)];
                        caseRecordObj.AccountId = (accRecord != null && accRecord.size() > 0) ? accRecord[0].Id : null;
                    }
                    if(CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c != null){
                        List<Case> pickupCase = [SELECT Id, PickUp_OU__c FROM Case WHERE CaseNumber = :CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c];
                        caseRecordObj.Pick_Up_Ref_ID__c = (pickupCase != null && pickupCase.size() > 0) ? pickupCase[0].Id : null;
                        caseRecordObj.PickUp_OU__c = (pickupCase != null && pickupCase.size() > 0) ? pickupCase[0].PickUp_OU__c : null;
                    }                    
                    if(refCodes != null && refCodes.size() > 0){
                        organizationMasters = [SELECT Id, REF_Code__c FROM Organization_Master__c WHERE REF_Code__c IN :refCodes];
                        if(organizationMasters != null && organizationMasters.size() > 0){
                            for(Organization_Master__c om : organizationMasters){
                                refCodeToOrganizationMaster.put(om.REF_Code__c, om);
                            }
                        }
                    }
                    caseRecordObj.Call_received_OU__c = CaseAndAttachmentObj.callrecievedOU != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.callrecievedOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.callrecievedOU).Id) : null) : null;
                    caseRecordObj.Company_of__c = CaseAndAttachmentObj.Companyof != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.Companyof) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.Companyof).Id) : null) : null;
                    caseRecordObj.Gems_Ref_No__c = CaseAndAttachmentObj.Gemrefno != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.Gemrefno) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.Gemrefno).Id) : null) : null;
                    caseRecordObj.Call_forwarded_OU__c = CaseAndAttachmentObj.callforwardedOU != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.callforwardedOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.callforwardedOU).Id) : null) : null;
                    caseRecordObj.CCEC_Action_OU__c = caseAndAttachmentObj.ccecActionOU != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.ccecActionOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.ccecActionOU).Id) : null) : null;
                    caseRecordObj.Complaint_Actionable_OU__c = caseAndAttachmentObj.complaintActionOU != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.complaintActionOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.complaintActionOU).Id) : null) : null;
                    caseRecordObj.Pick_Up_Pincode__c = caseAndAttachmentObj.pickUpPincode != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.pickUpPincode) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.pickUpPincode).Id) : null) : null;
                    
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
                    Database.SaveResult caseInsertResult = Database.insert(caseRecordObj,false);
                    if(caseInsertResult.errors != null && !caseInsertResult.errors.isEmpty()){
                        ResponseWrapper responseWrap = new ResponseWrapper();
                        responseWrap.Status = 'Not Inserted';

                        Integration_Log__c logMessage = new Integration_Log__c();
                        for(Database.Error er: caseInsertResult.geterrors()) {
                            responseWrap.error = er.getMessage() ;
                            logMessage.Error_Message__c=responseWrap.error;
                        }                        
                        logMessage.Component_Name__c = 'Case Insertion - G2C';
                        logMessage.IsIntegration__c = false;                        
                        logMessage.eObject__c = 'Case';
                        logMessage.Inbound_JSON__c =  RestContext.request.requestBody.tostring().length() > 131070 ? RestContext.request.requestBody.tostring().substring(0,131070) : RestContext.request.requestBody.tostring();
                        logMessage.Outbound_JSON__c = JSON.serialize(responseWrap);
                        insert logMessage;

                        return responseWrap;    
                    }                    
                    if(caseRecordObj.Id!=null){
                        List<ContentDocumentLink> contentLinkToInsert = new List<ContentDocumentLink>();                       
                        if(caseAndAttachmentObj.attachments != null && caseAndAttachmentObj.attachments.size() > 0){
                            List<ContentVersion> newContentVersionList = new List<ContentVersion>();
                            Set<Id> contentVersionIds = new Set<Id>();
                            List<ContentVersion> contentVersions = new List<ContentVersion>();                            
                            for(Attach attachObj : caseAndAttachmentObj.attachments){
                                ContentVersion newContentVersion = new ContentVersion();
                                newContentVersion.contentLocation = 'S'; 
                                newContentVersion.pathOnClient =attachObj.ContentType ; 
                                newContentVersion.title = attachObj.name; 
                                newContentVersion.versionData = EncodingUtil.base64Decode(attachObj.body); 
                                newContentVersionList.add(newContentVersion);                   
                            }
                            if(newContentVersionList != null && newContentVersionList.size() > 0){
                                insert newContentVersionList;
                                for(ContentVersion cv : newContentVersionList){
                                    if(cv.Id != null){
                                        contentVersionIds.add(cv.Id);
                                    }
                                }
                            }
                            if(contentVersionIds != null && contentVersionIds.size() > 0){
                                contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
                            }  
                            if(contentVersions != null && contentVersions.size() > 0){
                                for(ContentVersion cv : contentVersions){
                                    ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                                    newContentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
                                    newContentDocumentLink.LinkedEntityId = caseRecordObj.Id; 
                                    newContentDocumentLink.ShareType = 'I';
                                    newContentDocumentLink.Visibility = 'AllUsers';
                                    contentLinkToInsert.add(newContentDocumentLink);
                                }
                            }                       
                        }                                                
                        if(contentLinkToInsert != null && contentLinkToInsert.size() > 0){
                            insert contentLinkToInsert;
                        }
                    }
                    if(caseInsertResult.isSuccess()){
                        Case newCaseCreated = [SELECT CaseNumber, Id FROM Case WHERE  Id= :caseInsertResult.Id]; 
                        ResponseWrapper responseWrap = new ResponseWrapper();
                        responseWrap.caseId = newCaseCreated.Id;
                        responseWrap.CaseName = newCaseCreated.CaseNumber;
                        responseWrap.Status ='Inserted';

                        Integration_Log__c logMessage = new Integration_Log__c();
                        logMessage.Component_Name__c = 'Case Insertion - G2C';
                        logMessage.IsIntegration__c = true;
                        logMessage.CaseNumber__c = newCaseCreated.CaseNumber;
                        logMessage.eRecordID__c = newCaseCreated.Id;
                        logMessage.eObject__c = 'Case';
                        logMessage.Inbound_JSON__c =  RestContext.request.requestBody.toString().length() > 131070 ? RestContext.request.requestBody.toString().substring(0,131070) : RestContext.request.requestBody.toString();
                        logMessage.Outbound_JSON__c = JSON.serialize(responseWrap);
                        insert logMessage;

                        return responseWrap;
                    }
                }
                else if(caseRecordObj.CaseNumber != null) {
                    newCaseRecord = [SELECT Id, CaseNumber FROM Case WHERE CaseNumber = :caseRecordObj.CaseNumber];
                    if(newCaseRecord.size()>0 ){
                        List<ContentDocumentLink> contentLinkToInsert = new List<ContentDocumentLink>();
                        if(caseAndAttachmentObj.attachments != null && caseAndAttachmentObj.attachments.size() > 0){
                            List<ContentVersion> newContentVersionList = new List<ContentVersion>();
                            Set<Id> contentVersionIds = new Set<Id>();
                            List<ContentVersion> contentVersions = new List<ContentVersion>();
                            
                            for(Attach attachObj : caseAndAttachmentObj.attachments){
                                ContentVersion newContentVersion = new ContentVersion();
                                newContentVersion.contentLocation = 'S'; 
                                newContentVersion.pathOnClient =attachObj.ContentType ; 
                                newContentVersion.title = attachObj.name; 
                                newContentVersion.versionData = EncodingUtil.base64Decode(attachObj.body); 
                                newContentVersionList.add(newContentVersion);
                            }
                            if(newContentVersionList != null && newContentVersionList.size() > 0){
                                insert newContentVersionList;
                                for(ContentVersion cv : newContentVersionList){
                                    if(cv.Id != null){
                                        contentVersionIds.add(cv.Id);
                                    }
                                }
                            }
                            if(contentVersionIds != null && contentVersionIds.size() > 0){
                                contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
                            }  
                            if(contentVersions != null && contentVersions.size() > 0){
                                for(ContentVersion cv : contentVersions){
                                    ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                                    newContentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
                                    newContentDocumentLink.LinkedEntityId = newCaseRecord[0].Id; 
                                    newContentDocumentLink.ShareType = 'I';
                                    newContentDocumentLink.Visibility = 'AllUsers';
                                    contentLinkToInsert.add(newContentDocumentLink);
                                }
                            }                          
                        }
                        if(contentLinkToInsert != null && contentLinkToInsert.size() > 0){
                            insert contentLinkToInsert;
                        }
                        ResponseWrapper wc = new ResponseWrapper();
                        wc.CaseName=newCaseRecord[0].CaseNumber;
                        wc.Status ='Updated';
                        return wc;
                    }
                    else{
                        ResponseWrapper responseWrap = new ResponseWrapper();
                        responseWrap.CaseName = null;
                        responseWrap.Status ='Not Updated';
                        responseWrap.error ='Invalid Case Number';

                        Integration_Log__c logMessage = new Integration_Log__c();
                        logMessage.Component_Name__c = 'Case Insertion - G2C';
                        logMessage.IsIntegration__c = false;
                        logMessage.Error_Message__c = responseWrap.error;
                        logMessage.eObject__c = 'Case';
                        logMessage.Inbound_JSON__c =  RestContext.request.requestBody.tostring().length() > 131070 ? RestContext.request.requestBody.tostring().substring(0,131070) : RestContext.request.requestBody.tostring();
                        logMessage.Outbound_JSON__c = JSON.serialize(responseWrap);
                        insert logMessage;

                        return responseWrap;
                    } 
                }
            }    
        }
        catch(Exception e){
            Integration_Log__c logRecord = new Integration_Log__c();
            logRecord.Component_Name__c='Case Insertion - G2C';
            logRecord.IsIntegration__c=true;
            logRecord.Error_Message__c=e.getMessage();
            if (logRecord.Error_Message__c.length() > 250) {
                logRecord.Split_Error_Message__c = logRecord.Error_Message__c.substring(250);
                logRecord.Error_Message__c = logRecord.Error_Message__c.substring(0, 250);
            }
            logRecord.eObject__c = 'Case';
            logRecord.Inbound_JSON__c= RestContext.request.requestBody.tostring().length() > 131070 ? RestContext.request.requestBody.tostring().substring(0,131070) : RestContext.request.requestBody.tostring();
            logRecord.Outbound_JSON__c =  RestContext.request.requestBody.tostring().length() > 131070 ? RestContext.request.requestBody.tostring().substring(0,131070) : RestContext.request.requestBody.tostring();
            insert logRecord;
            ResponseWrapper responseWrap = new ResponseWrapper();
            responseWrap.Status ='Not Inserted';
            responseWrap.error= e.getMessage();
            return responseWrap; 
        }
        return null;
    }
    
    private class CaseAndAttachment {
        Case caseObj;
        List<Attach> attachments;
        String customercode;
        String recordType;
        String callrecievedOU;
        String callforwardedOU;
        String ccecActionOU;
        String complaintActionOU;
        String pickUpPincode;
        String Companyof;
        String Gemrefno;
    } 
    private class Attach {
        String body;
        String contentType;
        String name;
    }
    
    global class ResponseWrapper {
        String caseId {get;set;}
        String caseName {get;set;}
        String status {get;set;}
        String error {get;set;}  
    }
}