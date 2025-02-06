public class GatiMDMIntegration {
    public static GatiMDMUtil.ActionOutput sendApprovalRequest(GatiMDMUtil.ActionInput input){
        GatiMDMUtil.GatiMDMRequestContentWrapper existing_cust_id = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper additional_Approver_Requested_by_User = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper query_Fired = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        
        existing_cust_id.content = input.approval_existing_cust_id;
        additional_Approver_Requested_by_User.content = input.approval_additional_approver_requested_by_user;
        query_Fired.content = input.approval_query_fired;
        
        GatiMDMUtil.GatiMDMApprovalRequestWrapper approvalRequest = new GatiMDMUtil.GatiMDMApprovalRequestWrapper();
        approvalRequest.EXISTING_CUST_ID = existing_cust_id;
        approvalRequest.Additional_Approver_Requested_by_User = additional_Approver_Requested_by_User;
        approvalRequest.Query_Fired = query_Fired;
        
        GatiMDMUtil.GatiMDMRequestRootWrapper approvalRequestRoot = new GatiMDMUtil.GatiMDMRequestRootWrapper();
        approvalRequestRoot.content = (Object)approvalRequest;
        
        String requestBody = JSON.serialize(approvalRequestRoot);
        
        HttpRequest request = new Httprequest();
        request.setMethod('PUT');
        request.setEndpoint(MDMSetting__mdt.getInstance('Approval_Request_End_Point').EndPoint__c + input.opportunityId);
        request.setBody(requestBody);
        request.setHeader('Authorization', input.authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        GatiMDMUtil.ActionOutput output = new GatiMDMUtil.ActionOutput();
        output.approvalStatusCode = response.getStatusCode();
        return output;
    }
    
    public static GatiMDMUtil.ActionOutput sendCsRequest(GatiMDMUtil.ActionInput input){
        GatiMDMUtil.GatiMDMRequestContentWrapper CUST_CODE = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper CompanyID = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Customer_First_Name = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Customer_Association_Type = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Staff_Code = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Staff_Name = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Email_ID = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Operating_Unit = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper OU_Type = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Customer_Category = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Status = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Remarks = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        
        // Geting related object data
        
        Account atmAccount = [SELECT GATI_Customer_Code__c,Name,Associated_OU__r.Name,
                              Associated_OU__r.Type__c,Customer_Category__c,Remarks__c,
                              GATI_Status__c,GATI_Company_Code__c 
                              FROM ACCOUNT 
                              WHERE Id = :input.accountTeamMember.AccountId
                              LIMIT 1
                             ];
        
        String statusToSend;
        if ( atmAccount.GATI_Status__c == 'V') {
            statusToSend = 'Valid';
        } else {
            statusToSend = 'Invalid';
        }
        
        User atmUser = [SELECT Staff_Code__c,Name,Email 
                        FROM USER 
                        WHERE Id = :input.accountTeamMember.UserId 
                        LIMIT 1
                       ];
        
        
        // Mappign will be here
        String companyName = getCompanyName(atmAccount.GATI_Company_Code__c);
        CUST_CODE.content = atmAccount.GATI_Customer_Code__c+'|'+companyName;
        CompanyID.content = companyName;
        Customer_First_Name.content = atmAccount.Name;
        Customer_Association_Type.content = 'CS-Level-1';
        Staff_Code.content = atmUser.Staff_Code__c;
        Staff_Name.content = atmUser.Name;
        Email_ID.content = atmUser.Email;
        Operating_Unit.content = atmAccount.Associated_OU__r.Name;
        OU_Type.content = atmAccount.Associated_OU__r.Type__c;
        Customer_Category.content = atmAccount.Customer_Category__c;
        Status.content = statusToSend;
        Remarks.content = atmAccount.Remarks__c ;
        
        GatiMDMUtil.GatiMDMCsMappingWrapper csRequest = new GatiMDMUtil.GatiMDMCsMappingWrapper();
        csRequest.CUST_CODE = CUST_CODE;
        csRequest.CompanyID = CompanyID;
        csRequest.Customer_First_Name = Customer_First_Name;
        csRequest.Customer_Association_Type = Customer_Association_Type;
        csRequest.Staff_Code = Staff_Code;
        csRequest.Staff_Name = Staff_Name;
        csRequest.Email_ID = Email_ID;
        csRequest.Operating_Unit = Operating_Unit;
        csRequest.OU_Type = OU_Type;
        csRequest.Customer_Category = Customer_Category;
        csRequest.Status = Status;
        csRequest.Remarks = Remarks;
        
        GatiMDMUtil.GatiMDMRequestRootWrapper csRequestRoot = new GatiMDMUtil.GatiMDMRequestRootWrapper();
        csRequestRoot.content = (Object)csRequest;
        
        String requestBody = JSON.serialize(csRequestRoot,false);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('CS_Update_End_Point').EndPoint__c + atmAccount.GATI_Customer_Code__c + '\'');
        request.setBody(requestBody);
        request.setHeader('Authorization', input.authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        GatiMDMUtil.ActionOutput output = new GatiMDMUtil.ActionOutput();
        output.cmStatusCode = response.getStatusCode();
        return output;
        
    }
    
    public static GatiMDMUtil.ActionOutput sendSubCodeCreationRequest(GatiMDMUtil.ActionInput input){
        GatiMDMUtil.GatiMDMRequestContentWrapper EXISTING_CUST_ID = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper CompanyID = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Existing_Contract_Number = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper Sub_Code_Requested = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper account_ID_Requested = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper bd_Staff_Code_Requested = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        GatiMDMUtil.GatiMDMRequestContentWrapper opportunity_Id_Requested = new GatiMDMUtil.GatiMDMRequestContentWrapper();
        
        // Geting related object data
        Account parentAccount = [SELECT GATI_Customer_Code__c,Contract_Number__c,GATI_Company_Code__c,Owner.Staff_Code__c
                                 FROM Account 
                                 WHERE Id =: input.account.ParentId
                                ];
        
        // Getting Opportunity data
        List<Quote> quoteDetail = [SELECT OpportunityId 
                                   FROM quote 
                                   WHERE Test_LOF_number__c like :parentAccount.Contract_Number__c 
                                   AND Opportunity.Opportunity_Type_Contract__c='New Contract'
                                   LIMIT 1
                                  ];
        
        // Mappign will be here
        String companyName = getCompanyName(parentAccount.GATI_Company_Code__c);
        EXISTING_CUST_ID.content = parentAccount.GATI_Customer_Code__c;
        CompanyID.content = companyName;
        Existing_Contract_Number.content = parentAccount.Contract_Number__c;
        Sub_Code_Requested.content = 'Y';
        account_ID_Requested.content = input.account.Id;
        bd_Staff_Code_Requested.content = parentAccount.Owner.Staff_Code__c != null ? parentAccount.Owner.Staff_Code__c : null;
        opportunity_Id_Requested.content = (quoteDetail != null && quoteDetail.size()>0) ? quoteDetail[0].OpportunityId : null;
        
        GatiMDMUtil.GatiMDMSubCodeCreationWrapper subCodeCreationRequest = new GatiMDMUtil.GatiMDMSubCodeCreationWrapper();
        subCodeCreationRequest.EXISTING_CUST_ID = EXISTING_CUST_ID;
        subCodeCreationRequest.CompanyID = CompanyID;
        subCodeCreationRequest.Existing_Contract_Number = Existing_Contract_Number;
        subCodeCreationRequest.Sub_Code_Requested = Sub_Code_Requested;
        subCodeCreationRequest.account_ID = account_ID_Requested;
        subCodeCreationRequest.bd_Staff_Code = bd_Staff_Code_Requested;
        subCodeCreationRequest.opportunity_ID = opportunity_Id_Requested;
        
        GatiMDMUtil.GatiMDMRequestRootWrapper subCodeCreationRequestRoot = new GatiMDMUtil.GatiMDMRequestRootWrapper();
        subCodeCreationRequestRoot.content = (Object)subCodeCreationRequest;
        
        String requestBody = JSON.serialize(subCodeCreationRequestRoot,false);
        System.debug('requestBody '+requestBody);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('Sub_Code_Creation_End_Point').EndPoint__c);
        request.setBody(requestBody);
        request.setHeader('Authorization', input.authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        GatiMDMUtil.ActionOutput output = new GatiMDMUtil.ActionOutput();
        output.subCodeCreationStatusCode = response.getStatusCode();
        return output;
    }
    
    public static GatiMDMUtil.ActionOutput sendLOFCreateWithAccount(Account accRecord, String authorizationToken, Quote quoteData){
        String companyName = getCompanyName(accRecord.GATI_Company_Code__c);
        Map<String, Object> lofNumberMap = new Map<String, Object>();
        lofNumberMap.put('content', (quoteData.Test_LOF_number__c.contains('.') ? quoteData.Test_LOF_number__c.split('\\.')[0] : quoteData.Test_LOF_number__c));
        Map<String, Object> custCodeMap = new Map<String, Object>();
        custCodeMap.put('content', (accRecord.GATI_Customer_Code__c + '|'+companyName).unescapeHtml4()); 
        Map<String, Object> companyId = new Map<String, Object>();
        companyId.put('content', companyName);        
        Map<String, Object> amendmentVersion = new Map<String, Object>();
        amendmentVersion.put('content', String.valueOf(quoteData.AmendedVersion__c));        
        Map<String, Object> contentMap = new Map<String, Object>();
        contentMap.put('LOF_Number', lofNumberMap);
        contentMap.put('CUST_CODE', custCodeMap);
        contentMap.put('CompanyID', companyId);
        if(quoteData.AmendedVersion__c != null){
            contentMap.put('LOF_Amendment_Version', amendmentVersion);   
        }
        Map<String, Object> mainMap = new Map<String, Object>();
        mainMap.put('content', contentMap);
        String requestBody = JSON.serialize(mainMap);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('Create_LOF_Account').EndPoint__c);
        request.setBody(requestBody);
        request.setHeader('Authorization', authorizationToken);
        request.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HttpResponse response = http.send(request);
        GatiMDMUtil.ActionOutput output = new GatiMDMUtil.ActionOutput();
        output.subCodeCreationStatusCode = response.getStatusCode();
        if(response.getStatusCode() != 201 && ((List<Object>)((Map<String,Object>) JSON.deserializeUntyped(response.getBody())).get('errors')) != null && ((List<Object>)((Map<String,Object>) JSON.deserializeUntyped(response.getBody())).get('errors')).size() > 0){
            output.errorMessage = (String)((Map<String,Object>)((List<Object>)((Map<String,Object>) JSON.deserializeUntyped(response.getBody())).get('errors'))[0]).get('message');   
        }
        else if(response.getStatusCode() != 201){
            output.errorMessage = 'No Response';
        }
        return output;
    }
    
    public static GatiMDMUtil.ActionOutput sendCONUpdatedAccount(Account accRecord, String authorizationToken, Quote quoteData){
        String companyName = getCompanyName(accRecord.GATI_Company_Code__c);
        GatiMDMUtil.ActionOutput output = new GatiMDMUtil.ActionOutput();
        String sequenceNumber = '';
        String endPoint = MDMSetting__mdt.getInstance('Create_LOF_Account').EndPoint__c;
        HttpRequest requestGet = new Httprequest();
        requestGet.setMethod('GET');
        requestGet.setEndpoint((endPoint.substring(0,endPoint.length() - 1))+'?filter=CUST_CODE=\''+accRecord.GATI_Customer_Code__c+'%7C'+companyName+'\'');
        requestGet.setHeader('Authorization', authorizationToken);
        requestGet.setHeader('Content-Type', 'application/json');
        Http httpGet = new Http();
        HttpResponse responseGet = httpGet.send(requestGet);
        if(responseGet.getStatusCode() == 200 && ((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')) != null && ((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')).size() > 0){
            sequenceNumber = (String)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows'))[0]).get('content')).get('CUST_CONTR_SEQ_NUM')).get('content');
            List<Quote> quoteLOFData = [SELECT Id,AmendedVersion__c,LOF_Amendment_Date__c 
                                        FROM Quote 
                                        WHERE OpportunityId =: quoteData.OpportunityId 
                                        AND Name LIKE '%LOF%' 
                                        ORDER BY CreatedDate DESC
                                       ];
            Map<String, Object> lofNumberMap = new Map<String, Object>();
            lofNumberMap.put('content', (accRecord.LOF_Number__c.contains('.') ? accRecord.LOF_Number__c.split('\\.')[0] : accRecord.LOF_Number__c));
            Map<String, Object> contractNumberMap = new Map<String, Object>();
            contractNumberMap.put('content', (quoteData.Test_LOF_number__c.contains('.') ? quoteData.Test_LOF_number__c.split('\\.')[0] : quoteData.Test_LOF_number__c));
            Map<String, Object> custCodeMap = new Map<String, Object>();
            custCodeMap.put('content', accRecord.GATI_Customer_Code__c+'|'+companyName);
            Map<String, Object> contractDateMap = new Map<String, Object>();
            contractDateMap.put('content', accRecord.Contract_Activation_Date__c);
            Map<String, Object> contractAmendmentDateMap = new Map<String, Object>();
            contractAmendmentDateMap.put('content', quoteData.LOF_Amendment_Date__c);
            
            Map<String, Object> amendmentVersion = new Map<String, Object>();
            amendmentVersion.put('content', String.valueof(quoteData.AmendedVersion__c));
            Map<String, Object> amendmentLOFVersion = new Map<String, Object>();
            if(quoteLOFData != null && quoteLOFData.size() > 0){             	
                amendmentLOFVersion.put('content', String.valueof(quoteLOFData[0].AmendedVersion__c));
            }
            
            Map<String, Object> statusMap = new Map<String, Object>();
            statusMap.put('content', accRecord.Contract_Status__c);
            Map<String, Object> remarksMap = new Map<String, Object>();
            remarksMap.put('content', accRecord.Remarks__c);
            Map<String, Object> contentMap = new Map<String, Object>();
            contentMap.put('LOF_Number', lofNumberMap);
            contentMap.put('CUST_CODE', custCodeMap);
            contentMap.put('Contract_Number', contractNumberMap);
            if(accRecord.Contract_Activation_Date__c != null){
                contentMap.put('Contract_Date', contractDateMap);
            }
            if(quoteData.LOF_Amendment_Date__c != null){
                contentMap.put('Contract_Amendment_Date', contractAmendmentDateMap);   
            }
            if(quoteData.AmendedVersion__c != null){
                contentMap.put('Contract_Amendment_Version', amendmentVersion);   
            }
            if(quoteLOFData != null && quoteLOFData.size() > 0){
                contentMap.put('LOF_Amendment_Version', amendmentLOFVersion);
            }
            if(accRecord.Contract_Status__c != null){
                contentMap.put('Status', statusMap);
            }
            if(accRecord.Remarks__c != null){
                contentMap.put('Remarks', remarksMap);   
            }
            Map<String, Object> mainMap = new Map<String, Object>();
            mainMap.put('content', contentMap);
            String requestBody = JSON.serialize(mainMap);
            HttpRequest request = new Httprequest();
            request.setMethod('PUT');
            request.setEndpoint(MDMSetting__mdt.getInstance('Create_LOF_Account').EndPoint__c+sequenceNumber);
            request.setBody(requestBody);
            request.setHeader('Authorization', authorizationToken);
            request.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse response = http.send(request);        
            output.subCodeCreationStatusCode = response.getStatusCode();
            if(response.getStatusCode() != 204 && !Test.isRunningTest()){
                output.errorMessage = (String)((Map<String,Object>)((List<Object>)((Map<String,Object>) JSON.deserializeUntyped(response.getBody())).get('errors'))[0]).get('message');
            }
        }
        else if(((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')) == null || (((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')) != null && ((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')).size() == 0)){
            output.errorMessage = 'No Response';
        }
        else{
            output.errorMessage = (String)((Map<String,Object>)((List<Object>)((Map<String,Object>) JSON.deserializeUntyped(responseGet.getBody())).get('errors'))[0]).get('message');
        }
        return output;
    }
    
    public static GatiMDMUtil.ActionOutput deleteServiceResourceFromMDM(GatiMDMUtil.ActionInput input){
        String companyName = getCompanyName(input.companyCode);
        String sequenceNumber = '';
        String endPoint = MDMSetting__mdt.getInstance('Delete_CS_Mapping').EndPoint__c;
        HttpRequest requestGet = new Httprequest();
        requestGet.setMethod('GET');
        requestGet.setEndpoint(endPoint+'?filter=CUST_CODE=\''+input.customerCode+'%7C'+companyName+'\'andStaff_Code=\''+input.staffCode+'\'');
        requestGet.setHeader('Authorization', input.authorizationHeader);
        requestGet.setHeader('Content-Type', 'application/json');
        Http httpGet = new Http();
        HttpResponse responseGet = httpGet.send(requestGet);
        if(responseGet.getStatusCode() == 200 && ((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')) != null && ((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows')).size() > 0){
            sequenceNumber = (String)((Map<String, Object>)((Map<String, Object>)((Map<String, Object>)((List<Object>)((Map<String, Object>) JSON.deserializeUntyped(responseGet.getBody())).get('rows'))[0]).get('content')).get('CUST_CS_SE_SEQ_NUM')).get('content');
        } 
        
        //Delete CS Mapping
        if(sequenceNumber != null && sequenceNumber != ''){
            HttpRequest requestDelete = new Httprequest();
            requestDelete.setMethod('DELETE');
            requestDelete.setEndpoint(endPoint+'/'+sequenceNumber);
            requestDelete.setHeader('Authorization', input.authorizationHeader);
            requestDelete.setHeader('Content-Type', 'application/json');
            Http httpDelete = new Http();
            HttpResponse responseDelete = httpDelete.send(requestDelete);
        }
        return null;
    }
    
    private static String getCompanyName(String companyCode){
        if(companyCode == '101'){
            return 'GICE';
        }
        else if(companyCode == '103'){
            return 'ACL';
        }
        else if(companyCode == '104'){
            return 'ECU';
        }
        else if(companyCode == '105'){
            return 'UCL';
        }
        else{
            return 'GKE';
        }
    }
}