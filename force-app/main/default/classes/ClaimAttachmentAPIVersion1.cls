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
                    Set<Decimal> customerCodes = new Set<Decimal>();
                    List<Organization_Master__c> organizationMasters = new List<Organization_Master__c>();
                    List<Account> accountList = new List<Account>();
                    Map<String, Organization_Master__c> refCodeToOrganizationMaster = new Map<String,Organization_Master__c>();
                    Map<String,Object> apiResult = new Map<String,Object>();
                    Map<String, String> docketToSTOCKRECEIVINGOU = new Map<String, String>();
                    Map<String, String> docketToDELIVERYSTN = new Map<String, String>();
                    Map<String, String> docketToBOOKINGSTN = new Map<String, String>();
                    Map<String, String> docketToSTOCKOU = new Map<String, String>();
                    Map<String, Decimal> docketToAccount = new Map<String, Decimal>();
                    Map<Decimal, Account> AccountMap = new Map<Decimal, Account>();
                    
                    if(CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && CaseAndAttachmentObj?.caseObj?.Docket_Number__c != ''){
                        apiResult = BulkServiceRequests.apiCall(CaseAndAttachmentObj?.caseObj?.Docket_Number__c);
                    }
                    
                    if(apiResult != null && apiResult.get('result') == 'successful' && apiResult.get('response') != null){
                        List<Object> apiResponse = (List<Object>) apiResult.get('response');
                        if(apiResponse != null && apiResponse.size()>0){
                            Object apiData = apiResponse[0];
                            List<Object> result = (List<Object>) ((Map<String,Object>)apiData).get('result');
                            String accId= (String)((Map<String,Object>)result[0]).get('CUSTOMER_CODE');
                            String delstn = (String)((Map<String,Object>)result[0]).get('DELIVERY_STN');
                            String booking = (String)((Map<String,Object>)result[0]).get('BOOKING_STN');
                            String stockUO = (String)((Map<String,Object>)result[0]).get('STOCK_OU');
                            String stockRecieveOU = (String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU');
                            if(stockRecieveOU != null && stockRecieveOU != ''){
                                refCodes.add(stockRecieveOU);
                                docketToSTOCKRECEIVINGOU.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),stockRecieveOU);
                            }
                            if(delstn != null && delstn != ''){
                                refCodes.add(delstn);
                                docketToDELIVERYSTN.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),delstn);
                            }
                            if(booking != null && booking != ''){
                                refCodes.add(booking);
                                docketToBOOKINGSTN.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),booking);
                            }
                            if(stockUO != null && stockUO != ''){
                                refCodes.add(stockUO);
                                docketToSTOCKOU.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),stockUO);
                            }
                            String companyCode  = ((Map<String,Object>)apiData).get('companyId') == 'GKE'?'102':'101';
                            if(accId != null && accId != '' && companyCode != null && companyCode != ''){
                                customerCodes.add(Decimal.valueOf(accId+'.'+companyCode));
                                docketToAccount.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')), Decimal.valueOf(accId+'.'+companyCode));
                            }
                            caseRecordObj.Docket_Number__c =  String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO'));
                            caseRecordObj.Consignee_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_MOBILE_NO');
                            caseRecordObj.Risk_Coverage__c = (String)((Map<String,Object>)result[0]).get('DOCKET_TYPE');
                            caseRecordObj.Decl_Cargo_value__c = (Decimal)((Map<String,Object>)result[0]).get('DECL_CARGO_VAL');
                            caseRecordObj.Consignor_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_NAME');
                            caseRecordObj.Docket_Status__c = (String)((Map<String,Object>)result[0]).get('DOCKET_STATUS');
                            caseRecordObj.No_of_Packages_Delivered__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS_DELIVERED');
                            caseRecordObj.Assured_Delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('ASSURED_DLY_DT'));
                            caseRecordObj.Consignor_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_MOBILE_NO');
                            caseRecordObj.Actual_Weight_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('ACTUAL_WT');
                            caseRecordObj.COD_Type__c = (String)((Map<String,Object>)result[0]).get('COD_TYPE');
                            caseRecordObj.POD_Type__c = (String)((Map<String,Object>)result[0]).get('POD_TYPE');
                            caseRecordObj.Booking_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('BKG_DT'));
                            caseRecordObj.Consignor_Pincode__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('CONSIGNOR_PINCODE'));
                            caseRecordObj.PROD_SERV_CODE__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('PROD_SERV_CODE'));
                            caseRecordObj.Charged_Wt__c = String.valueOf((Decimal)((Map<String,Object>)result[0]).get('CHARGED_WT'));
                            caseRecordObj.No_Of_Packages_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS');
                            caseRecordObj.Consignee_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_NAME');
                            if(((Map<String,Object>)result[0]).get('APPROVED_DLY_DT') != null )
                                caseRecordObj.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('APPROVED_DLY_DT'));
                            caseRecordObj.Docket_Validation__c= 'Valid';
                            caseRecordObj.Priority= 'Normal';
                            caseRecordObj.Company_of__c  = ((Map<String,Object>)apiData).get('companyId') == 'GKE'?'102':'101';
                            
                            if ((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'N') {
                                caseRecordObj.PDC_BLOCK__c = '0';
                            }
                            else if((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'Y'){
                                caseRecordObj.PDC_BLOCK__c = '1';
                            }
                        }
                    }
                    
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
                    if(CaseAndAttachmentObj.ccecActionOU !=null) {
                        refCodes.add(caseAndAttachmentObj.ccecActionOU);
                    }  
                    if(CaseAndAttachmentObj.complaintActionOU !=null) {
                        refCodes.add(caseAndAttachmentObj.complaintActionOU);
                    }  
                    if(CaseAndAttachmentObj.PickUpPincode !=null){
                        refCodes.add(caseAndAttachmentObj.pickUpPincode);
                    }
                    
                    organizationMasters = [SELECT Id, Name, Ref_Code__c 
                                           FROM Organization_Master__c 
                                           WHERE ref_code__c IN :refCodes
                                          ];
                    accountList = [SELECT Id, Customer_Code__c 
                                   FROM Account 
                                   WHERE Customer_Code__c IN :customerCodes
                                  ];
                    
                    if(organizationMasters != null && organizationMasters.size()>0){
                        for(Organization_Master__c om : organizationMasters){
                            refCodeToOrganizationMaster.put(om.Ref_Code__C,om);
                        }
                    }
                    
                    if(accountList != null && accountList.size()>0){
                        for(Account acc : accountList){
                            AccountMap.put(acc.Customer_Code__c, acc);
                        }
                    }                    
                    
                    if(CaseAndAttachmentObj.customercode != null){
                        List<Account> accRecord = [SELECT Id FROM Account WHERE Customer_Code__c = :Decimal.valueof(CaseAndAttachmentObj.customercode)];
                        caseRecordObj.AccountId = (accRecord != null && accRecord.size() > 0) ? accRecord[0].Id : null;
                    }
                    else if(CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && AccountMap.containsKey(docketToAccount.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c))){
                        caseRecordObj.AccountId = AccountMap.get(docketToAccount.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c)).Id;
                    }
                    
                    if(CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c != null){
                        List<Case> pickupCase = [SELECT Id, PickUp_OU__c FROM Case WHERE CaseNumber = :CaseAndAttachmentObj.caseObj.Pick_Up_Ref_No__c];
                        caseRecordObj.Pick_Up_Ref_ID__c = (pickupCase != null && pickupCase.size() > 0) ? pickupCase[0].Id : null;
                        caseRecordObj.PickUp_OU__c = (pickupCase != null && pickupCase.size() > 0) ? pickupCase[0].PickUp_OU__c : null;
                    }                    
                    
                    caseRecordObj.Call_received_OU__c = CaseAndAttachmentObj.callrecievedOU != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.callrecievedOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.callrecievedOU).Id) : null) : null;
                    caseRecordObj.Gems_Ref_No__c = CaseAndAttachmentObj.Gemrefno != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.Gemrefno) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.Gemrefno).Id) : null) : null;
                    caseRecordObj.Call_forwarded_OU__c = CaseAndAttachmentObj.callforwardedOU != null ? (refCodeToOrganizationMaster.containsKey(CaseAndAttachmentObj.callforwardedOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.callforwardedOU).Id) : null) : null;
                    caseRecordObj.CCEC_Action_OU__c = caseAndAttachmentObj.ccecActionOU != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.ccecActionOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.ccecActionOU).Id) : null) : null;
                    caseRecordObj.Complaint_Actionable_OU__c = caseAndAttachmentObj.complaintActionOU != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.complaintActionOU) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.complaintActionOU).Id) : null) : null;
                    caseRecordObj.Pick_Up_Pincode__c = caseAndAttachmentObj.pickUpPincode != null ? (refCodeToOrganizationMaster.containsKey(caseAndAttachmentObj.pickUpPincode) ? (refCodeToOrganizationMaster.get(caseAndAttachmentObj.pickUpPincode).Id) : null) : null;
                    
                    if(CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && caseRecordObj.Stock_OU__c == null && docketToSTOCKOU.containsKey(CaseAndAttachmentObj?.caseObj?.Docket_Number__c) && refCodeToOrganizationMaster.containsKey(docketToSTOCKOU.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c))){
                        caseRecordObj.Stock_OU__c = refCodeToOrganizationMaster.get(docketToSTOCKOU.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c)).Id;
                    }
                    if(caseRecordObj.Stock_Receiving_OU__c == null && CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && docketToSTOCKRECEIVINGOU.containsKey(CaseAndAttachmentObj?.caseObj?.Docket_Number__c) && refCodeToOrganizationMaster.containsKey(docketToSTOCKRECEIVINGOU.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c))){
                        caseRecordObj.Stock_Receiving_OU__c = refCodeToOrganizationMaster.get(docketToSTOCKRECEIVINGOU.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c)).Id;
                    }
                    if(caseRecordObj.Delivery_OU__c == null && CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && docketToDELIVERYSTN.containsKey(CaseAndAttachmentObj?.caseObj?.Docket_Number__c) && refCodeToOrganizationMaster.containsKey(docketToDELIVERYSTN.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c))){
                        caseRecordObj.Delivery_OU__c = refCodeToOrganizationMaster.get(docketToDELIVERYSTN.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c)).Id;
                    }
                    if(caseRecordObj.Booking_OU__c == null && CaseAndAttachmentObj?.caseObj?.Docket_Number__c != null && docketToBOOKINGSTN.containsKey(CaseAndAttachmentObj?.caseObj?.Docket_Number__c) && refCodeToOrganizationMaster.containsKey(docketToBOOKINGSTN.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c))){
                        caseRecordObj.Booking_OU__c = refCodeToOrganizationMaster.get(docketToBOOKINGSTN.get(CaseAndAttachmentObj?.caseObj?.Docket_Number__c)).Id;
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
                    if(caseRecordObj.Id != null){
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