@RestResource(urlMapping='/createCase/*')
global with sharing class createCaseFromDocketNumber {
    
    @HttpPost
    global static void createCase() {
        RestContext.response.addHeader('Content-Type', 'application/json');
        String requestBody = RestContext.request.requestBody.toString();
        Map<String,Object> recordData = (Map<String,Object>) JSON.deserializeUntyped(requestBody);
        insertCase(recordData);
    }    
    
    private static void insertCase(Map<String,Object> caseInsertData){
        try{
            String data = (String)caseInsertData.get('docketNo');
            Map<String,Object> apiResult = caseComponent.docketValidation(data);
            If(apiResult.get('result') == 'successful' && apiResult.get('response') != null){
                List<Object> apiResponse = (List<Object>) apiResult.get('response');
                List<Object> result = (List<Object>) ((Map<String,Object>)apiResponse[0]).get('result');
                Map<String,String> successResponse = New Map<String,String>();
                if(result != null && result.size()>0){
                    Case newCase = new Case();
                    String accId= (String)((Map<String,Object>)result[0]).get('CUSTOMER_CODE');
                    String delstn = (String)((Map<String,Object>)result[0]).get('DELIVERY_STN');
                    String booking = (String)((Map<String,Object>)result[0]).get('BOOKING_STN');
                    String stockUO = (String)((Map<String,Object>)result[0]).get('STOCK_OU');
                    newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
                    newCase.Origin = 'IVR';
                    newCase.Docket_Number__c = (String)caseInsertData.get('docketNo');
                    newCase.Type = (String)caseInsertData.get('Type');
                    newCase.Sub_Type__c = (String)caseInsertData.get('Sub_Type__c');
                    newCase.Consignee_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_MOBILE_NO');
                    newCase.Risk_Coverage__c = (String)((Map<String,Object>)result[0]).get('DOCKET_TYPE');
                    newCase.Decl_Cargo_value__c = (Decimal)((Map<String,Object>)result[0]).get('DECL_CARGO_VAL');
                    newCase.Consignor_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_NAME');
                    newCase.Booking_OU__c = (String)apiResult.get(booking);
                    newCase.AccountId = (String) apiResult.get(accId);
                    newCase.Docket_Status__c = (String)((Map<String,Object>)result[0]).get('DOCKET_STATUS');
                    newCase.No_of_Packages_Delivered__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS_DELIVERED');
                    if(((Map<String,Object>)result[0]).get('ASSURED_DLY_DT') != null){
                     	newCase.Assured_Delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('ASSURED_DLY_DT'));   
                    }
                    newCase.Consignor_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_MOBILE_NO');
                    newCase.Actual_Weight_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('ACTUAL_WT');
                    newCase.COD_Type__c = (String)((Map<String,Object>)result[0]).get('COD_TYPE');
                    newCase.POD_Type__c = (String)((Map<String,Object>)result[0]).get('POD_TYPE');
                    if(((Map<String,Object>)result[0]).get('BKG_DT') != null){
                     	newCase.Booking_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('BKG_DT'));   
                    }
                    newCase.Delivery_OU__c= (String)apiResult.get(delstn);
                    newCase.Consignor_Pincode__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('CONSIGNOR_PINCODE'));
                    newCase.PROD_SERV_CODE__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('PROD_SERV_CODE'));
                    newCase.Charged_Wt__c = String.valueOf((Decimal)((Map<String,Object>)result[0]).get('CHARGED_WT'));
                    newCase.No_Of_Packages_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS');
                    newCase.Consignee_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_NAME');
                    if(((Map<String,Object>)result[0]).get('APPROVED_DLY_DT') != null){
                        newCase.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('APPROVED_DLY_DT'));
                    }
                    newCase.Docket_Validation__c= 'Valid';
                    newCase.Priority= 'Normal';
                    newCase.Company_of__c  = ((Map<String,Object>)apiResponse[0]).get('companyId') == 'GKE'?'102':'101';
                    
                    If ((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') == 'N') {
                        newCase.PDC_BLOCK__c = '0';
                    }Else If((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') == 'Y'){
                        newCase.PDC_BLOCK__c = '1';
                    }
                    
                    If ((String)((Map<String,Object>)result[0]).get('STOCK_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_OU') != '') {
                        newCase.Stock_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_OU'));
                    }
                    
                    If ((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != '') {
                        newCase.Stock_Receiving_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU'));
                    }
                    insert newCase;
                	Case caseData = [Select CaseNumber,Assured_Delivery_Date__c,CreatedDate From Case Where Id =: newCase.Id limit 1];
                    successResponse.put('Case Number',caseData.CaseNumber);
                    successResponse.put('ADD Date',String.valueOf(caseData.Assured_Delivery_Date__c));
            		successResponse.put('Created Date',String.valueOf(Date.ValueOf(caseData.CreatedDate)));
                    successResponse.put('Status','success');
                    successResponse.put('Status Code','200');
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponse));
                }
                else{
                    RestContext.response.statusCode = 500;
                    successResponse.put('Status','Failed');
                    successResponse.put('Error','For this docket number there is no details.');
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(successResponse));
                }
            }
            else{
                RestContext.response.statusCode = 500;
                Map<String,String> errorMap = new Map<String,String>();
                errorMap.put('Error',(String)apiResult.get('sErrMsg'));
                errorMap.put('Status','Failed');
                if(apiResult.get('response') == null){
                    errorMap.put('Error','For this docket number there is no details.');
                    errorMap.put('Status','Failed');
                }
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorMap));
            }
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;
            Map<String,String> errorMap = new Map<String,String>();
            errorMap.put('Error',ex.getMessage());
            errorMap.put('Status','Failed');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errorMap));
        }
    }
    
}