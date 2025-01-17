public class BulkQueriesUploaderBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    public List<String> csvData;
    
    public BulkQueriesUploaderBatch(List<String> csvData){
        this.csvData=csvData;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
        System.debug(csvData);
        return csvData;
    }
    
    public void execute(Database.BatchableContext BC,List<String> scope){
        List<Case> insertedCaseData = New List<Case>();
        for(String csvString : scope){
            Case caseObj = New Case();
            BulkServiceRequests.csvWrapper csv = (BulkServiceRequests.csvWrapper) JSON.deserialize(
                csvString, BulkServiceRequests.csvWrapper.class
            );
            caseObj =  insertCaseFromDocket(csv);
            insertedCaseData.add(caseObj);
        }
        if(insertedCaseData != null && insertedCaseData.size()>0){
            List<Database.SaveResult> saveResults = Database.insert(insertedCaseData,false);
            List<Mass_Upload_Queries_Status__e> events = New List<Mass_Upload_Queries_Status__e>();
            if(saveResults != null && saveResults.size()>0){
                for(Integer i=0;i<saveResults.size(); i++){
                    Mass_Upload_Queries_Status__e event = New Mass_Upload_Queries_Status__e();
                    Database.SaveResult sr = saveResults[i];
                    BulkServiceRequests.csvWrapper csv = (BulkServiceRequests.csvWrapper) JSON.deserialize(
                        csvData[i], BulkServiceRequests.csvWrapper.class
                    );
                    event.Type__c = csv.Type;
                    event.Docket_Number__c = csv.DocketNumber;
                    event.Description__c = csv.Description;
                    if (sr.isSuccess()) {
                        event.Status__c = 'Success';
                        event.Message__c = 'Inserted Query Id : '+sr.getId();
                    } else {
                        String error = '';
                        for(Database.Error err : sr.getErrors()) {
                            error = err.getStatusCode() +' - ' + err.getMessage();
                        }
                        event.Status__c = 'Failed';
                        event.Message__c = 'Error : '+error;
                    }
                    events.add(event);
                }
            }
            if(events != null && events.size()>0){
                List<Database.SaveResult> results = EventBus.publish(events);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Upload Bulk Queries Batch Finished');
    }

    private static Case insertCaseFromDocket(BulkServiceRequests.csvWrapper basicData){
        try{
            Case newCase = new Case();
            String data = basicData.DocketNumber;
            Map<String,Object> apiResult = caseComponent.docketValidation(data);
            If(apiResult.get('result') == 'successful' && apiResult.get('response') != null){
                List<Object> apiResponse = (List<Object>) apiResult.get('response');
                List<Object> result = (List<Object>) ((Map<String,Object>)apiResponse[0]).get('result');
                String accId= (String)((Map<String,Object>)result[0]).get('CUSTOMER_CODE');
                String delstn = (String)((Map<String,Object>)result[0]).get('DELIVERY_STN');
                String booking = (String)((Map<String,Object>)result[0]).get('BOOKING_STN');
                String stockUO = (String)((Map<String,Object>)result[0]).get('STOCK_OU');
                newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
                newCase.Docket_Number__c = basicData.DocketNumber;
                newCase.Type = basicData.Type;
                newCase.Consignee_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_MOBILE_NO');
                newCase.Risk_Coverage__c = (String)((Map<String,Object>)result[0]).get('DOCKET_TYPE');
                newCase.Decl_Cargo_value__c = (Decimal)((Map<String,Object>)result[0]).get('DECL_CARGO_VAL');
                newCase.Consignor_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_NAME');
                newCase.Booking_OU__c = (String)apiResult.get(booking);
                newCase.AccountId = (String) apiResult.get(accId);
                newCase.Docket_Status__c = (String)((Map<String,Object>)result[0]).get('DOCKET_STATUS');
                newCase.No_of_Packages_Delivered__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS_DELIVERED');
                newCase.Assured_Delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('ASSURED_DLY_DT'));
                newCase.Consignor_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_MOBILE_NO');
                newCase.Actual_Weight_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('ACTUAL_WT');
                newCase.COD_Type__c = (String)((Map<String,Object>)result[0]).get('COD_TYPE');
                newCase.POD_Type__c = (String)((Map<String,Object>)result[0]).get('POD_TYPE');
                newCase.Booking_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('BKG_DT'));
                newCase.Delivery_OU__c= (String)apiResult.get(delstn);
                newCase.Consignor_Pincode__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('CONSIGNOR_PINCODE'));
                newCase.PROD_SERV_CODE__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('PROD_SERV_CODE'));
                newCase.Charged_Wt__c = String.valueOf((Decimal)((Map<String,Object>)result[0]).get('CHARGED_WT'));
                newCase.No_Of_Packages_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS');
                newCase.Consignee_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_NAME');
                newCase.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('APPROVED_DLY_DT'));
                newCase.Docket_Validation__c= 'Valid';
                newCase.Priority= 'Normal';
                newCase.Company_of__c  = ((Map<String,Object>)apiResponse[0]).get('companyId') == 'GKE'?'102':'101';
                newCase.Description = basicData.Description;
                If ((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'N') {
                    newCase.PDC_BLOCK__c = '0';
                }Else If((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'Y'){
                    newCase.PDC_BLOCK__c = '1';
                }
                
                If ((String)((Map<String,Object>)result[0]).get('STOCK_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_OU') != '') {
                    newCase.Stock_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_OU'));
                }
                
                If ((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != '') {
                    newCase.Stock_Receiving_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU'));
                }
            }
            return newCase;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}