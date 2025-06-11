public without sharing class DocketChangeController {
    @AuraEnabled
    public static String updateDocketNumber(String docketNumber, Id caseId){
        try {
            if(docketNumber != null && docketNumber != ''){
                Case currentCase = [SELECT Id, Type, Sub_Type__c, Docket_Number__c FROM Case WHERE Id = :caseId];
                DocketValidate valid = New DocketValidate();
                Map<String, Organization_Master__c> nameToOrgMaster = new Map<String, Organization_Master__c>();
                Map<String,DocketJson.cls_response> docketResults = New Map<String,DocketJson.cls_response>();

                if(currentCase?.Docket_Number__c == docketNumber){
                    return 'You are typing same docket number as on case.';
                }

                if(docketNumber != null && docketNumber != ''){
                    for(Organization_Master__c om : [SELECT Id,Name, REF_Code__c FROM Organization_Master__c WHERE Operational_Status__c = 'O']){
                        nameToOrgMaster.put(om.Name, om);
                    }
                    docketResults = valid.validate(docketNumber);
                }
                if(docketResults.containsKey(docketNumber)){
                    currentCase.Docket_Number__c = docketNumber;
                    if(docketResults.get(docketNumber).result[0]?.STOCK_OU != null || docketResults.get(docketNumber).result[0]?.STOCK_OU != '' && nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_OU)){
                        currentCase.Stock_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_OU).Id;
                    }
                    if(docketResults.get(docketNumber).result[0]?.STOCK_RECEIVING_OU !=null || docketResults.get(docketNumber).result[0]?.STOCK_RECEIVING_OU != '' && nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU)){
                        currentCase.Stock_Receiving_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU).Id;
                    }
                    currentCase.Delivery_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                    currentCase.Booking_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].BOOKING_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].BOOKING_STN).Id : null;
                    currentCase.Consignee_Mobile_No__c = docketResults.get(docketNumber).result[0].CONSIGNEE_MOBILE_NO;
                    String CompanyCode = docketResults.get(docketNumber).companyId == 'GKE' ? '102' : '101';
                    Account acc = new Account(Customer_Code__c = Decimal.ValueOf(docketResults.get(docketNumber).result[0].CUSTOMER_CODE +'.'+ CompanyCode));
                    currentCase.Account = acc;                    
                    currentCase.Docket_Validation__c = 'Valid';
                    
                    if(docketResults.get(docketNumber).result[0].PDC_BLOCK == 'Y'){
                        currentCase.PDC_BLOCK__c = '1';
                    }                        
                    if(docketResults.get(docketNumber).result[0].PDC_BLOCK == 'N'){
                        currentCase.put('PDC_BLOCK__c','0');
                    }

                    if(currentCase.Type == 'Delayed Connection' && docketResults.get(docketNumber).result[0].PDC_BLOCK !='Y'){
                        if(currentCase.Sub_Type__c == 'STC cooling'){
                            List<String> dayMonYear = docketResults.get(docketNumber).result[0].ASSURED_DLY_DT.split('-');
                            if(!nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_OU)){
                                return 'Either ADD is crossed or Cooling times is less than 12 hours.';
                            }
                            else{
                                Long hourDiff = (Datetime.valueOfGmt( String.valueOf(Datetime.now())).getTime()-DateTime.valueOfGmt(docketResults.get(docketNumber).result[0].STOCK_IN_DATE_TIME).getTime())/(1000*60*60);
                                if( !((hourDiff>12) && ( Date.newInstance( Integer.valueOf(dayMonYear[0]) , Integer.valueOf(dayMonYear[1]), Integer.valueOf(dayMonYear[2])) > Date.today()) ) ){
                                    return 'Either ADD is crossed or Cooling times is less than 12 hours.';
                                }
                            } 
                        }
                        if(nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_OU)){
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_OU).Id;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_OU).Id;
                        }
                        else if(nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU)){
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU).Id;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU).Id;
                        }
                        else{
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        }
                    }                    
                    if(currentCase.Type == 'Undelivered' && docketResults.get(docketNumber).result[0].PDC_BLOCK != 'Y'){
                        List<String> dayMonYear = docketResults.get(docketNumber).result[0].ASSURED_DLY_DT.split('-');
                        if((currentCase.Sub_Type__c == 'NON DELIVERED' || currentCase.Sub_Type__c == 'LATE DELIVERY') && ( Date.newInstance( Integer.valueOf(dayMonYear[0]) , Integer.valueOf(dayMonYear[1]), Integer.valueOf(dayMonYear[2])) > Date.today() )){
                            return 'The Assured Delivery Date is not passed yet.';
                        }
                        if(currentCase.Sub_Type__c == 'NON DELIVERED'){
                            if(nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_OU)){
                                currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                                currentCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_OU).Id;
                            }
                            else if(nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU)){
                                currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                                currentCase.CCEC_Action_OU__c = nameToOrgMaster.get(docketResults.get(docketNumber).result[0].STOCK_RECEIVING_OU).Id;
                            }
                            else{
                                currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                                currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                            }
                        }
                        else{
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        }
                    }
                    if(currentCase.Type == 'Partial Delivery' && docketResults.get(docketNumber).result[0].PDC_BLOCK !='Y'){
                        currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                    }
                    if(currentCase.Type == 'Claims' && docketResults.get(docketNumber).result[0].PDC_BLOCK != 'Y'){
                        currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                    }
                    if(currentCase.Type == 'Invoicing and Others' && docketResults.get(docketNumber).result[0].PDC_BLOCK != 'Y'){
                        if(currentCase.Sub_Type__c == 'EXCESS FREIGHT CHARGES' || currentCase.Sub_Type__c == 'DISCREPANCY IN BILLS'){
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].BOOKING_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].BOOKING_STN).Id : null;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].BOOKING_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].BOOKING_STN).Id : null;
                        }
                        else{
                            currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                            currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        }
                    }
                    if(currentCase.Type == 'Query' && docketResults.get(docketNumber).result[0].PDC_BLOCK != 'Y'){
                        currentCase.Complaint_Actionable_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                        currentCase.CCEC_Action_OU__c = nameToOrgMaster.containsKey(docketResults.get(docketNumber).result[0].DELIVERY_STN) ? nameToOrgMaster.get(docketResults.get(docketNumber).result[0].DELIVERY_STN).Id : null;
                    } 
                    Database.SaveResult updateDetails = Database.Update(currentCase);
                    if(updateDetails.isSuccess()){
                        return 'Docket Number Changed.';
                    }
                    else{
                        String errorMessage = '';
                        for(Database.Error err : updateDetails.getErrors()) {
                            errorMessage += err.getStatusCode() + ': ' + err.getMessage();
                        }
                        return errorMessage;
                    }
                }
                else{
                    return ('There is no result for docket Number - '+docketNumber);
                }
            }
            else{
                return 'Docket Number have no value, Please fill correct docket number.';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}