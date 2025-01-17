public with sharing class FetchDataFromDocketController implements Queueable, Database.AllowsCallouts {
    public Set<Id> caseIds;
    
    public FetchDataFromDocketController(Set<Id> caseIds){
        this.caseIds = caseIds;
    }
    
    public void execute(QueueableContext context){
        Map<String,List<Case>> docketNumberToCases = New Map<String,List<Case>>();
        List<Case> caseList = New List<Case>();
        String docketString = '';
        Map<string,Object> results = New Map<string,Object>();
        
        if(caseIds != null && caseIds.size()>0){
            caseList = [SELECT Id,Description,Subject 
                        FROM Case
                        WHERE Id IN: caseIds
                       ];
        }
        if(caseList != null && caseList.size()>0){
            for(Case cs : caseList){
                Pattern pattern1 = Pattern.compile('\\b\\d{9}\\b');
                String uppercaseSubject = cs.subject != null ? cs.subject.toUpperCase() : '';
                String uppercaseBody = cs.Description != null ? cs.Description.toUpperCase() : '';
                String foundValue = null;
                Matcher matcherSubject = pattern1.matcher(uppercaseSubject);
                Matcher matcherBody = pattern1.matcher(uppercaseBody);
                if (matcherSubject.find()) {
                    foundValue = matcherSubject.group();
                }else if(matcherBody.find()){
                    foundValue = matcherBody.group();
                }
                System.debug('foundValue'+foundValue);
                
                if(foundValue != null && foundValue != ''){
                    if(docketNumberToCases.containsKey(foundValue)){
                        docketNumberToCases.get(foundValue).add(cs);
                    }else{
                        docketNumberToCases.put(foundValue,new List<Case>{cs});
                    }
                }
            }   
        }
        if(docketNumberToCases != null){
            for(String doc : docketNumberToCases.keySet()){
                docketString += doc+',';
            }
        }
        if(docketString != null && docketString != ''){
            results = BulkServiceRequests.apiCall(docketString);
        }
        if(results != null){
            mappingToCaseBulk(docketNumberToCases,results);
        }
    }
    
    public static void handleUserAssignment(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        Set<Id> caseListForDocket = New Set<Id>();
        Set<String> suppliedMailsSet = new Set<String>();
        Set<String> assignmentEmails = new Set<String>();
        List<RoundRobinAssigner.RoundRobinAssignment> ListForGroupAndId = New List<RoundRobinAssigner.RoundRobinAssignment>();
        Map<String,Id> emailToUser = New Map<String,Id>();
        Map<String,Id> assignmentEmailToUser = New Map<String,Id>();
        Map<String,EmailToCase_Assignment__mdt> emailToGroupData = New Map<String,EmailToCase_Assignment__mdt>();
        List<RecordType> recordType = [SELECT Id,DeveloperName 
                                       FROM RecordType 
                                       WHERE SobjectType = 'Case' 
                                       AND DeveloperName = 'Complaint'
                                      ];
        List<EmailToCase_Assignment__mdt> allGroupData = [SELECT Id, DeveloperName, Label, Email__c 
                                                          FROM EmailToCase_Assignment__mdt
                                                          WHERE Email__c != null
                                                         ];
        for(Case cs : newCaseMap.values()){
            if(cs.SuppliedEmail != null && recordType != null && recordType.size()>0 && cs.RecordTypeId == recordType[0].Id && cs.Origin == 'Email'){
                suppliedMailsSet.add(cs.SuppliedEmail);
                suppliedMailsSet.add(cs.SuppliedEmail.split('@').get(1).trim());
            }
            if(cs.Email_Address_For_Assignment__c != null && recordType != null && recordType.size()>0 && cs.RecordTypeId == recordType[0].Id && cs.Origin == 'Email'){
                assignmentEmails.addAll(cs.Email_Address_For_Assignment__c.split(';'));
            }
        }
        
        List<CS_Domain_Mapping__c> domainToUserMapping = [SELECT Id, Name, User__c 
                                                          FROM CS_Domain_Mapping__c 
                                                          WHERE Name IN: suppliedMailsSet
                                                          AND User__r.IsActive = true
                                                         ];
        List<User> userList = [SELECT Id, Email
                               FROM User
                               WHERE Email IN :assignmentEmails
                               AND IsActive = true
                               AND UserPermissionsSupportUser = true
                              ];
        
        if(allGroupData != null && allGroupData.size()>0){
            for(EmailToCase_Assignment__mdt emData : allGroupData){
                emailToGroupData.put(emData.Email__c,emData);
            }
        }

        if(userList != null && userList.size() > 0){
            for(User us : userList){
                assignmentEmailToUser.put(us.Email, us.Id);
            }
        }
        
        if(domainToUserMapping != null && domainToUserMapping.size()>0){
            for(CS_Domain_Mapping__c dm : domainToUserMapping){
                emailToUser.put(dm.Name.trim(),dm.User__c);
            }
        }
        
        for(Case cs : newCaseMap.values()){
            if(cs.Email_Address_For_Assignment__c != null && cs.Email_Address_For_Assignment__c != oldCaseMap.get(cs.Id).Email_Address_For_Assignment__c && recordType != null && recordType.size()>0 && cs.RecordTypeId == recordType[0].Id && cs.Origin == 'Email'){
                caseListForDocket.add(cs.Id);
                /*Boolean isOwnerAssigned = false;
                List<String> emailsList = cs.Email_Address_For_Assignment__c.split(';');
                for(String emailCheck : emailsList){
                    if(emailCheck.contains('@allcargologistics.com') && assignmentEmailToUser.containsKey(emailCheck)){
                        cs.OwnerId = assignmentEmailToUser.get(emailCheck);
                        isOwnerAssigned = true;
                        break;
                    }
                }*/   
                String emailDomain = cs.SuppliedEmail != null ? cs.SuppliedEmail.split('@').get(1) : null;
                if(emailToUser.containsKey(cs.SuppliedEmail)){
                    cs.OwnerId = emailToUser.get(cs.SuppliedEmail);
                }
                else if(emailToUser.containsKey(emailDomain)){
                    cs.OwnerId = emailToUser.get(emailDomain);
                }
                else{
                    RoundRobinAssigner.RoundRobinAssignment GroupAndIdForRoundRobin = New RoundRobinAssigner.RoundRobinAssignment();
                    GroupAndIdForRoundRobin.fieldName = 'OwnerId';
                    GroupAndIdForRoundRobin.groupName = 'RetailSupport';
                    GroupAndIdForRoundRobin.recordId = cs;
                    ListForGroupAndId.add(GroupAndIdForRoundRobin);   
                }
            }
        }
        
        if(caseListForDocket != null && caseListForDocket.size()>0){
            //handleDocketNumberOfMail(caseListForDocket);
            FetchDataFromDocketController caseDocketNumber = new FetchDataFromDocketController(caseListForDocket);
            System.enqueueJob(caseDocketNumber);
        }
        
        if(ListForGroupAndId != null && ListForGroupAndId.size()>0){
            RoundRobinAssigner.assign(ListForGroupAndId, false);
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getAllDataWithDocketNumber(Id recordId,String docketNumber){
        Map<String,String> returnData = New Map<String,String>();
        Map<String,Object> results = New Map<String,Object>();
        Case currentCase = [SELECT Id From Case Where Id =: recordId];
        Map<String,List<Case>> dataMap = New Map<String,List<Case>>();
        try{
            if(docketNumber != null && docketNumber != ''){
                dataMap.put(docketNumber,New List<Case>{currentCase});
                results = BulkServiceRequests.apiCall(docketNumber);
                if(results != null){
                    returnData = mappingToCaseBulk(dataMap,results);
                }
            }
            return returnData;
        }catch(Exception e){
            System.debug('e.getMessage()'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static Map<String,String> mappingToCaseBulk(Map<String,List<Case>> dataMap, Map<string,Object> results){
        Map<String,String> returnString = New Map<String,String>();
        List<Case> returnCaseList = New List<Case>();
        Map<String,Case> docketToCase = New Map<String,Case>();
        Map<String,String> docketToSTOCKOU = New Map<String,String>();
        Map<String,String> docketToSTOCKRECEIVINGOU = New Map<String,String>();
        Map<String,String> docketToDELIVERYSTN = New Map<String,String>();
        Map<String,String> docketToBOOKINGSTN = New Map<String,String>();
        Map<String,Decimal> docketToAccount = New Map<String,Decimal>();
        Map<String,Object> apiResult = results;
        Set<String> oudata = New Set<String>();
        Map<String,Organization_Master__c> OrgMasterMap = New Map<String,Organization_Master__c>();
        Map<Decimal,Account> AccountMap = New Map<Decimal,Account>();
        Set<Decimal> accSet = New Set<Decimal>();
        if(apiResult.get('result') == 'successful' && apiResult.get('response') != null){
            List<Object> apiResponse = (List<Object>) apiResult.get('response');
            if(apiResponse != null && apiResponse.size()>0){
                for(Object apiData : apiResponse){
                    Case newCase = New Case();
                    List<Object> result = (List<Object>) ((Map<String,Object>)apiData).get('result');
                    if(result != null && result.size()>0){
                        String accId= (String)((Map<String,Object>)result[0]).get('CUSTOMER_CODE');
                        String delstn = (String)((Map<String,Object>)result[0]).get('DELIVERY_STN');
                        String booking = (String)((Map<String,Object>)result[0]).get('BOOKING_STN');
                        String stockUO = (String)((Map<String,Object>)result[0]).get('STOCK_OU');
                        String stockRecieveOU = (String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU');
                        if(stockRecieveOU != null && stockRecieveOU != ''){
                            oudata.add(stockRecieveOU);
                            docketToSTOCKRECEIVINGOU.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),stockRecieveOU);
                        }
                        if(delstn != null && delstn != ''){
                            oudata.add(delstn);
                            docketToDELIVERYSTN.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),delstn);
                        }
                        if(booking != null && booking != ''){
                            oudata.add(booking);
                            docketToBOOKINGSTN.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),booking);
                        }
                        if(stockUO != null && stockUO != ''){
                            oudata.add(stockUO);
                            docketToSTOCKOU.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')),stockUO);
                        }
                        newCase.Docket_Number__c =  String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO'));
                        newCase.Consignee_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_MOBILE_NO');
                        newCase.Risk_Coverage__c = (String)((Map<String,Object>)result[0]).get('DOCKET_TYPE');
                        newCase.Decl_Cargo_value__c = (Decimal)((Map<String,Object>)result[0]).get('DECL_CARGO_VAL');
                        newCase.Consignor_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_NAME');
                        newCase.Docket_Status__c = (String)((Map<String,Object>)result[0]).get('DOCKET_STATUS');
                        newCase.No_of_Packages_Delivered__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS_DELIVERED');
                        newCase.Assured_Delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('ASSURED_DLY_DT'));
                        newCase.Consignor_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_MOBILE_NO');
                        newCase.Actual_Weight_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('ACTUAL_WT');
                        newCase.COD_Type__c = (String)((Map<String,Object>)result[0]).get('COD_TYPE');
                        newCase.POD_Type__c = (String)((Map<String,Object>)result[0]).get('POD_TYPE');
                        newCase.Booking_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('BKG_DT'));
                        newCase.Consignor_Pincode__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('CONSIGNOR_PINCODE'));
                        newCase.PROD_SERV_CODE__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('PROD_SERV_CODE'));
                        newCase.Charged_Wt__c = String.valueOf((Decimal)((Map<String,Object>)result[0]).get('CHARGED_WT'));
                        newCase.No_Of_Packages_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS');
                        newCase.Consignee_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_NAME');
                        if((String)((Map<String,Object>)result[0])?.get('APPROVED_DLY_DT') != null){
                            newCase.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0])?.get('APPROVED_DLY_DT'));
                        }
                        newCase.Docket_Validation__c= 'Valid';
                        newCase.Company_of__c  = ((Map<String,Object>)apiData).get('companyId') == 'GKE'?'102':'101';
                        if(accId != null && accId != '' && newCase.Company_of__c != null && newCase.Company_of__c != ''){
                            accSet.add(Decimal.valueOf(accId+'.'+newCase.Company_of__c));
                            docketToAccount.put(String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO')), Decimal.valueOf(accId+'.'+newCase.Company_of__c));
                        }
                        If ((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'N') {
                            newCase.PDC_BLOCK__c = '0';
                        }Else If((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'Y'){
                            newCase.PDC_BLOCK__c = '1';
                        }
                        docketToCase.put((String)((Map<String,Object>)apiData).get('docketNo'),newCase);
                    }
                }
                returnString.put('Message','Docket Number Updated.');
                returnString.put('Status','200');
            }
            else{
                returnString.put('Message','No Data For this Docket Number.');
                returnString.put('Status','201');
            }
        }
        else{
            returnString.put('Message','Error In Fetching Data.');
            returnString.put('Status','400');
        }
        list<Organization_Master__c> org= [select id,name,Ref_Code__C from Organization_Master__c where ref_code__c IN: oudata];
        List<Account> accData = [Select Id,Customer_Code__c from Account where Customer_Code__c IN: accSet];
        if(org != null && org.size()>0){
            for(Organization_Master__c om : org){
                OrgMasterMap.put(om.Ref_Code__C,om);
            }
        }
        if(accData != null && accData.size()>0){
            for(Account acc : accData){
                AccountMap.put(acc.Customer_Code__c,acc);
            }
        }
        if(docketToCase != null && dataMap != null){
            for(String docket : dataMap.keySet()){                
                List<Case> csvUploadedData = dataMap.get(docket);
                if(csvUploadedData != null && csvUploadedData.size()>0){
                    for(Case csv : csvUploadedData){
                        Case caseDetail = New Case();
                        if(docketToCase.containsKey(docket)){
                            caseDetail = docketToCase.get(docket).clone(false, false, false, false);   
                        }
                        csv.Docket_Number__c = caseDetail.Docket_Number__c;
                        csv.Consignee_Mobile_No__c = caseDetail.Consignee_Mobile_No__c;
                        csv.Risk_Coverage__c = caseDetail.Risk_Coverage__c;
                        csv.Decl_Cargo_value__c = caseDetail.Decl_Cargo_value__c;
                        csv.Consignor_Name__c = caseDetail.Consignor_Name__c;
                        csv.Docket_Status__c = caseDetail.Docket_Status__c;
                        csv.No_of_Packages_Delivered__c = caseDetail.No_of_Packages_Delivered__c;
                        csv.Assured_Delivery_Date__c = caseDetail.Assured_Delivery_Date__c;
                        csv.Consignor_Mobile_No__c = caseDetail.Consignor_Mobile_No__c;
                        csv.Actual_Weight_Booked__c = caseDetail.Actual_Weight_Booked__c;
                        csv.COD_Type__c = caseDetail.COD_Type__c;
                        csv.POD_Type__c = caseDetail.POD_Type__c;
                        csv.Booking_Date__c = caseDetail.Booking_Date__c;
                        csv.Consignor_Pincode__c = caseDetail.Consignor_Pincode__c;
                        csv.PROD_SERV_CODE__c = caseDetail.PROD_SERV_CODE__c;
                        csv.Charged_Wt__c = caseDetail.Charged_Wt__c;
                        csv.No_Of_Packages_Booked__c = caseDetail.No_Of_Packages_Booked__c;
                        csv.Consignee_Name__c = caseDetail.Consignee_Name__c;
                        csv.Actual_delivery_Date__c = caseDetail.Actual_delivery_Date__c;
                        csv.Docket_Validation__c = caseDetail.Docket_Validation__c;
                        csv.Company_of__c = caseDetail.Company_of__c;
                        csv.PDC_BLOCK__c = caseDetail.PDC_BLOCK__c;
                        if(docketToSTOCKOU.containsKey(docket) && OrgMasterMap.containsKey(docketToSTOCKOU.get(docket))){
                            csv.Stock_OU__c = OrgMasterMap.get(docketToSTOCKOU.get(docket)).Id;
                        }
                        if(docketToSTOCKRECEIVINGOU.containsKey(docket) && OrgMasterMap.containsKey(docketToSTOCKRECEIVINGOU.get(docket))){
                            csv.Stock_Receiving_OU__c = OrgMasterMap.get(docketToSTOCKRECEIVINGOU.get(docket)).Id;
                        }
                        if(docketToDELIVERYSTN.containsKey(docket) && OrgMasterMap.containsKey(docketToDELIVERYSTN.get(docket))){
                            csv.Delivery_OU__c = OrgMasterMap.get(docketToDELIVERYSTN.get(docket)).Id;
                        }
                        if(docketToBOOKINGSTN.containsKey(docket) && OrgMasterMap.containsKey(docketToBOOKINGSTN.get(docket))){
                            csv.Booking_OU__c = OrgMasterMap.get(docketToBOOKINGSTN.get(docket)).Id;
                        }
                        if(docketToAccount.containsKey(docket) && AccountMap.containsKey(docketToAccount.get(docket))){
                            csv.AccountId = AccountMap.get(docketToAccount.get(docket)).Id;
                        }
                        returnCaseList.add(csv);
                    }
                }
            }
        }
        if(returnCaseList != null && returnCaseList.size()>0){
            try{
                update returnCaseList;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return returnString;
    }
    
    public static void deleteAssignmentCase(List<Case> caseList){
        List<Case> caseToDelete = new List<Case>();
        for(Case cs : caseList){
            if(cs.Subject != null && cs.Subject.contains('Case transferred to you') && cs.Origin == 'Email'){
                caseToDelete.add(new Case(Id = cs.Id));
            }
        }
        if(caseToDelete != null && caseToDelete.size()>0){
            delete caseToDelete;
        }
    }
}