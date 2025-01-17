public without sharing class BulkServiceRequests {
    @AuraEnabled    
    public static Map<String,String> CsvDataHandler(String csvDataList) {
        Map<String,String> returnMap = New Map<String,String>();
        Map<string,Object> results = New Map<string,Object>();
        Map<String,List<csvWrapper>> dataMap = New Map<String,List<csvWrapper>>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        String lineBreak = '\n';
        String successHeader = 'Type,DocketNumber,Description,Status,Message\n';
        String successData = '';
        String errorHeader = 'Type,DocketNumber,Description,Status,Message\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);

        try {
            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );
            List<Case> insertedCaseData = New List<Case>();
            //List<String> csvStringList = New List<String>();
            String docketString = '';
            for (csvWrapper csv : dataWrapper) {
                //csvStringList.add(JSON.serialize(csv));
                Case caseObj = New Case();
                if(dataMap.containsKey(csv.DocketNumber)){
                    dataMap.get(csv.DocketNumber).add(csv);
                }
                else{
                    dataMap.put(csv.DocketNumber, new List<csvWrapper>{csv});
                }
                docketString += csv.DocketNumber+',';
            }

            if(docketString != null && docketString != ''){
                results = apiCall(docketString);
            }

            if(results != null && dataMap != null){
                insertedCaseData = mappingToCase(dataMap,results);
            }

            /*
            if(csvStringList != null && csvStringList.size()>0){
                BulkQueriesUploaderBatch batch = New BulkQueriesUploaderBatch(csvStringList);
                Database.executeBatch(batch, 50);
            }*/
            
            if(insertedCaseData != null && insertedCaseData.size()>0){
                List<Database.SaveResult> saveResults = Database.insert(insertedCaseData,false);
                if(saveResults != null && saveResults.size()>0){
                    for(Integer i=0;i<saveResults.size(); i++){
                        Database.SaveResult sr = saveResults[i];
                        csvWrapper csv = dataWrapper[i];
                        if (sr.isSuccess()) {
                            successData += csv.Type+','+csv.DocketNumber+','+csv.Description+',Success,'+sr.getId()+' Inserted RecordId'+lineBreak;
						} else {
                            String error = '';
							for(Database.Error err : sr.getErrors()) {
                                error = err.getStatusCode() +' - ' + err.getMessage();
							}
                            errorData += csv.Type+','+csv.DocketNumber+','+csv.Description+',Error,'+error+lineBreak;
						}
                    }
                    if(successData != '' && successData != null){
                        returnMap.put('successData',successData);
                    }
                    if(errorData != '' && errorData != null){
                        returnMap.put('errorData',errorData);
                    }
                }
            }
            System.debug('returnMap'+returnMap);
            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Case> mappingToCase(Map<String,List<csvWrapper>> dataMap, Map<string,Object> results){
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
                    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
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
                    if(((Map<String,Object>)result[0]).get('APPROVED_DLY_DT') != null )
                        newCase.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('APPROVED_DLY_DT'));
                    newCase.Docket_Validation__c= 'Valid';
                    newCase.Priority= 'Normal';
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
                List<csvWrapper> csvUploadedData = dataMap.get(docket);
                if(csvUploadedData != null && csvUploadedData.size()>0){
                    for(csvWrapper csv : csvUploadedData){
                        Case caseDetail = New Case();
                        caseDetail = docketToCase.get(docket).clone(false, false, false, false);
                        caseDetail.Type = csv.Type;
                        caseDetail.Description = csv.Description;                        
                        if(docketToSTOCKOU.containsKey(csv.DocketNumber) && OrgMasterMap.containsKey(docketToSTOCKOU.get(csv.DocketNumber))){
                            caseDetail.Stock_OU__c = OrgMasterMap.get(docketToSTOCKOU.get(csv.DocketNumber)).Id;
                        }
                        if(docketToSTOCKRECEIVINGOU.containsKey(csv.DocketNumber) && OrgMasterMap.containsKey(docketToSTOCKRECEIVINGOU.get(csv.DocketNumber))){
                            caseDetail.Stock_Receiving_OU__c = OrgMasterMap.get(docketToSTOCKRECEIVINGOU.get(csv.DocketNumber)).Id;
                        }
                        if(docketToDELIVERYSTN.containsKey(csv.DocketNumber) && OrgMasterMap.containsKey(docketToDELIVERYSTN.get(csv.DocketNumber))){
                            caseDetail.Delivery_OU__c = OrgMasterMap.get(docketToDELIVERYSTN.get(csv.DocketNumber)).Id;
                        }
                        if(docketToBOOKINGSTN.containsKey(csv.DocketNumber) && OrgMasterMap.containsKey(docketToBOOKINGSTN.get(csv.DocketNumber))){
                            caseDetail.Booking_OU__c = OrgMasterMap.get(docketToBOOKINGSTN.get(csv.DocketNumber)).Id;
                        }
                        if(docketToAccount.containsKey(csv.DocketNumber) && AccountMap.containsKey(docketToAccount.get(csv.DocketNumber))){
                            caseDetail.AccountId = AccountMap.get(docketToAccount.get(csv.DocketNumber)).Id;
                        }
                        returnCaseList.add(caseDetail);
                    }
                }
            }
        }
        return returnCaseList;
    }

    public class csvWrapper{
        @AuraEnabled public String Type;
        @AuraEnabled public String Description;
        @AuraEnabled public String DocketNumber;
    }

    class docketverify{
        string requestedBy;
        string docketNo;
    }

    public static Map<String,Object> apiCall(String docketNo){
        Map<String,Object> returnDataFromApi = New Map<String,Object>();
        User CurrentUser=[Select id,name,FederationIdentifier,ADID__c,Profile.Name from user where id=:UserInfo.getUserId()];
        string fed;
        fed=CurrentUser.ADID__c;
        if(CurrentUser.Profile.Name=='System Administrator'){
            fed='crmproj2';
        }
        if(fed==null){
            //throw new IllegalArgumentException('Federation ID was not found on user');
        }
        else {
            docketverify docket= new docketverify();
            docket.docketNo=docketNo;
            docket.requestedBy=fed;
            
            Http http = new Http();              
            HttpRequest req1 = new HttpRequest();
            map<string,Object> obj = new map<string,Object>();
            String AuthParams = API_credential__mdt.getInstance('DocketNoVerification').Other_Auth_Parameter__c;
            String[] AuthParamsSplitted = AuthParams.split('\\|');
            for (String Authpar:AuthParamsSplitted)
            {
                String[] nameValue= Authpar.split('\\:');
                req1.setHeader(nameValue[0], nameValue[1]);
            }
            req1.setTimeout(2*60*1000);
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json');
            req1.setEndpoint(API_credential__mdt.getInstance('DocketNoVerification').Endpoint__c);
            req1.setMethod('POST');
            req1.setBody(JSON.serialize(docket));
            Httpresponse res=http.send(req1);
            set<string> oudata= new set<String>();
            String CustomerData;
            String CompanyCode;
            map<string,string> ous= new map<string,string>();  
            if(res.getStatusCode()==200)
            {
                returnDataFromApi = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            }
        }
        return returnDataFromApi;
    }
}