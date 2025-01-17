public without sharing class CsvuploadController {    
    @AuraEnabled
    public static Map<String,String> csvDataHandler(String csvDataList){
        Map<String,String> returnMap = New Map<String,String>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        String lineBreak = '\n';
        String successHeader = 'Message,Type,SubType,DocketNumber,PickupRefNumber,Status\n';
        String successData = '';
        String errorHeader = 'Message,Type,SubType,DocketNumber,PickupRefNumber,Status\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);
        try {
            List<Case> caseToInsert = new List<Case>();
            Map<Id, Case> caseIdToCaseNumber = new Map<Id, Case>();
            Set<Id> caseIds = new Set<Id>();
            List<csvWrapper> wrapperToReturn = new List<csvWrapper>();
            String docketNumbers = '';
            Set<String> pickUpCaseNumbers = new Set<String>();
            DocketValidate valid = New DocketValidate();
            Map<String, Organization_Master__c> nameToOrgMaster = new Map<String, Organization_Master__c>();
            Map<String,DocketJson.cls_response> docketResults = New Map<String,DocketJson.cls_response>();
            Map<String, Case> pickUpNumberToCase = new Map<String, Case>();
            Id complaint = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();

            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );

            for(csvWrapper csv : dataWrapper){
                if(csv.DocketNumber != null && csv.Type != 'Pending Pickup'){
                    docketNumbers += csv.DocketNumber + ',';
                }
                if(csv.PickupRefNumber != null && csv.Type == 'Pending Pickup'){
                    pickUpCaseNumbers.add(csv.PickupRefNumber);
                }
            }

            List<Case> pickUpCases = [SELECT Id,CaseNumber FROM Case WHERE CaseNumber IN: pickUpCaseNumbers];

            if(pickUpCases != null && pickUpCases.size() > 0){
                for(Case cs : pickUpCases){
                    pickUpNumberToCase.put(cs.CaseNumber, cs);
                }
            }

            for(Organization_Master__c om : [SELECT Id,Name FROM Organization_Master__c WHERE Operational_Status__c = 'O']){
                nameToOrgMaster.put(om.Name, om);
            }

            if(docketNumbers != null && docketNumbers != ''){
                if(docketNumbers.substring(docketNumbers.length() - 1, docketNumbers.length()) == ','){
                    docketNumbers = docketNumbers.substring(0, docketNumbers.length()-1);
                }
                docketResults = valid.validate(docketNumbers);
            }

            for(csvWrapper csv : dataWrapper){      
                Boolean eachCheck = false;
                String customError = '';  

                Case newCase = new Case();                
                newCase.Origin = 'Bulk';
                newCase.Status  = 'New';               
                newCase.Type = csv.Type;
                newCase.Sub_Type__c = csv.SubType;
                newCase.RecordTypeId = complaint;
                newCase.Pick_Up_Ref_No__c = csv?.PickupRefNumber;
                if(csv?.PickupRefNumber != null && csv?.PickupRefNumber != '' && csv.Type == 'Pending Pickup' && pickUpNumberToCase.containsKey(csv?.PickupRefNumber)){
                    newCase.Pick_Up_Ref_ID__c = pickUpNumberToCase.get(csv?.PickupRefNumber).Id;
                }
                newCase.Docket_Number__c = csv.DocketNumber;
                newCase.Customer_Name__c = csv.CustomerName;
                newCase.Customer_Email__c = csv.CustomerEmail;
                newCase.Mobile__c = csv.CustomerMobile;
                if(docketResults.containsKey(csv.DocketNumber)){
                    Organization_Master__c book = new Organization_Master__c(REF_Code__c = docketResults.get(csv.DocketNumber).result[0].BOOKING_STN);
                    Organization_Master__c del = new Organization_Master__c(REF_Code__c = docketResults.get(csv.DocketNumber).result[0].DELIVERY_STN);
                    if(docketResults.get(csv.DocketNumber).result[0]?.STOCK_OU != null || docketResults.get(csv.DocketNumber).result[0]?.STOCK_OU != '' && nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_OU)){
                        newCase.Stock_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_OU).Id;
                    }
                    if(docketResults.get(csv.DocketNumber).result[0]?.STOCK_RECEIVING_OU !=null || docketResults.get(csv.DocketNumber).result[0]?.STOCK_RECEIVING_OU != '' && nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU)){
                        newCase.Stock_Receiving_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU).Id;
                    }
                    newCase.Delivery_OU__r = del;
                    newCase.Booking_OU__r = book;
                    newCase.Consignee_Mobile_No__c = docketResults.get(csv.DocketNumber).result[0].CONSIGNEE_MOBILE_NO;
                    String CompanyCode = docketResults.get(csv.DocketNumber).companyId == 'GKE' ? '102' : '101';
                    Account acc = new Account(Customer_Code__c = Decimal.ValueOf(docketResults.get(csv.DocketNumber).result[0].CUSTOMER_CODE +'.'+ CompanyCode));
                    newCase.Account = acc;                    
                    newCase.Docket_Validation__c = 'Valid';
                        
                    //PDC BLOCK CHECK
                    if(docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK == 'Y'){
                        newCase.PDC_BLOCK__c = '1';
                    }                        
                    if(docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK == 'N'){
                        newCase.put('PDC_BLOCK__c','0');
                    }

                    //Assign Complain_OU And CCEC_OU 
                    if(csv.Type == 'Delayed Connection' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK !='Y'){
                        if(csv.SubType == 'STC cooling'){
                            List<String> dayMonYear = docketResults.get(csv.DocketNumber).result[0].ASSURED_DLY_DT.split('-');
                            if(!nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_OU)){
                                customError = 'Either ADD is crossed or Cooling times is less than 12 hours.';
                                eachCheck = true;
                            }
                            else{
                                Long hourDiff = (Datetime.valueOfGmt( String.valueOf(Datetime.now())).getTime()-DateTime.valueOfGmt(docketResults.get(csv.DocketNumber).result[0].STOCK_IN_DATE_TIME).getTime())/(1000*60*60);
                                if( !((hourDiff>12) && ( Date.newInstance( Integer.valueOf(dayMonYear[0]) , Integer.valueOf(dayMonYear[1]), Integer.valueOf(dayMonYear[2])) > Date.today()) ) ){
                                    customError = 'Either ADD is crossed or Cooling times is less than 12 hours.';
                                    eachCheck = true;
                                }
                            } 
                        }
                        if(nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_OU)){
                            newCase.Complaint_Actionable_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_OU).Id;
                            newCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_OU).Id;
                        }
                        else if(nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU)){
                            newCase.Complaint_Actionable_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU).Id;
                            newCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU).Id;
                        }
                        else{
                            newCase.Complaint_Actionable_OU__r = del;
                            newCase.CCEC_Action_OU__r = del;
                        }
                    }
                        
                    if(csv.Type == 'Undelivered' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK != 'Y'){
                        List<String> dayMonYear = docketResults.get(csv.DocketNumber).result[0].ASSURED_DLY_DT.split('-');
                        if((csv.SubType == 'NON DELIVERED' || csv.SubType == 'LATE DELIVERY') && ( Date.newInstance( Integer.valueOf(dayMonYear[0]) , Integer.valueOf(dayMonYear[1]), Integer.valueOf(dayMonYear[2])) > Date.today() )){
                            eachCheck = true;
                            customError = 'The Assured Delivery Date is not passed yet.';
                        }
                        if(csv.SubType == 'NON DELIVERED'){
                            if(nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_OU)){
                                newCase.Complaint_Actionable_OU__r = del;
                                newCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_OU).Id;
                            }
                            else if(nameToOrgMaster.containsKey(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU)){
                                newCase.Complaint_Actionable_OU__r = del;
                                newCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(csv.DocketNumber).result[0].STOCK_RECEIVING_OU).Id;
                            }
                            else{
                                newCase.Complaint_Actionable_OU__r = del;
                                newCase.CCEC_Action_OU__r = del;
                            }
                        }
                        else{
                            newCase.Complaint_Actionable_OU__r = del;
                            newCase.CCEC_Action_OU__r = del;
                        }
                    }
                    if(csv.Type == 'Partial Delivery' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK !='Y'){
                        newCase.Complaint_Actionable_OU__r = del;
                        newCase.CCEC_Action_OU__r = del;
                    }
                    if(csv.Type == 'Claims' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK != 'Y'){
                        newCase.Complaint_Actionable_OU__r = del;
                        newCase.CCEC_Action_OU__r = del;
                    }
                    if(csv.Type == 'Invoicing and Others' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK != 'Y'){
                        if(csv.SubType == 'EXCESS FREIGHT CHARGES' || csv.SubType == 'DISCREPANCY IN BILLS'){
                            newCase.Complaint_Actionable_OU__r = book;
                            newCase.CCEC_Action_OU__r = book;
                        }
                        else{
                            newCase.Complaint_Actionable_OU__r = del;
                            newCase.CCEC_Action_OU__r = del;
                        }
                    }
                    if(csv.Type == 'Query' && docketResults.get(csv.DocketNumber).result[0].PDC_BLOCK != 'Y'){
                        newCase.Complaint_Actionable_OU__r = del;
                        newCase.CCEC_Action_OU__r = del;
                    }  
                }

                if(!eachCheck){
                    wrapperToReturn.add(csv);
                    caseToInsert.add(newCase);
                }
                else{
                    //Custom Errors
                    errorData += csv.Type +','+ csv.SubType +','+ csv.DocketNumber +','+ csv.PickupRefNumber +',Custom error found,'+ customError + lineBreak;
                }             
            }

            if(caseToInsert != null && caseToInsert.size() > 0){
                List<Database.SaveResult> saveResults = Database.insert(caseToInsert,false);
                if(saveResults != null && saveResults.size()>0){
                    for(Database.SaveResult sr : saveResults){
                        if(sr.isSuccess()){
                            caseIds.add(sr.getId());
                        }
                    }
                    if(caseIds.size() > 0){
                        caseIdToCaseNumber = new Map<Id, Case>([SELECT Id,CaseNumber FROM Case WHERE Id IN :caseIds]);
                    }
                    for(Integer i = 0; i < caseToInsert.size(); i++){
                        csvWrapper csv = wrapperToReturn[i];
                        Database.SaveResult sr = saveResults[i];
                        String base = csv.Type +','+ csv.SubType +','+ csv.DocketNumber +','+ csv.PickupRefNumber;
                        if(sr.isSuccess()){
                            successData += 'Complaint Id : '+ (caseIdToCaseNumber.containsKey(sr.getId()) ? caseIdToCaseNumber.get(sr.getId()).CaseNumber : sr.getId()) +','+base+',Successfully Complaint Registered'+ lineBreak;
                        }
                        else{
                            String errorMessage = '';
                            for(Database.Error err : sr.getErrors()){
                                errorMessage += err.getStatusCode() +' - '+ err.getMessage();
                            }
                            errorData += 'Error : '+errorMessage+','+base+',Error Occurred'+ lineBreak;
                        }
                    }
                }
            }

            if(successData != null && successData != ''){
                returnMap.put('successData',successData);
            }
            if(errorData != null && errorData != ''){
                returnMap.put('errorData',errorData);
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    public class CsvWrapper{
        @AuraEnabled public String Type;
        @AuraEnabled public String SubType;
        @AuraEnabled public String CustomerVendor;
        @AuraEnabled public String DocketNumber;
        @AuraEnabled public String PickupRefNumber;
        @AuraEnabled public String CustomerName;
        @AuraEnabled public String CustomerEmail;
        @AuraEnabled public String CustomerMobile;
    } 
}