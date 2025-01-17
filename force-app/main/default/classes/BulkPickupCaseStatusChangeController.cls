public with sharing class BulkPickupCaseStatusChangeController {
    @AuraEnabled
    public static Map<String,String> csvDataHandler(String csvDataList){
        Map<String,String> returnMap = New Map<String,String>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        String lineBreak = '\n';
        String successHeader = 'CaseNumber,DocketNumber,PickupStatus,PickupDate,Status,Message\n';
        String successData = '';
        String errorHeader = 'CaseNumber,DocketNumber,PickupStatus,PickupDate,Status,Message\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);
        try {
            Set<String> caseNumbers = new Set<String>();
            Map<String, csvWrapper> caseNumberToData = new Map<String, csvWrapper>();
            List<Case> caseToUpdate = new List<Case>();
            Map<Id, String> caseIdToCaseNumber = new Map<Id, String>();
            Map<String, String> caseNumberToResult = new Map<String, String>();

            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );

            for(csvWrapper csv : dataWrapper){
                caseNumbers.add(csv.CaseNumber);
                caseNumberToData.put(csv.CaseNumber, csv);
            }
            System.debug('caseNumbers '+caseNumbers);

            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, CaseNumber,Docket_Number__c,Pickup_Status__c, 
                                Pickup_Date__c, Approver_Remarks_Picklist__c, Actual_Weight__c, Status 
                                FROM Case 
                                WHERE CaseNumber IN :caseNumbers
                                AND RecordType.DeveloperName = 'Pick_Up'
                               ]);

            for(Case cs : casesMap.values()){
                Case csUpdate = new Case();
                csUpdate.Id = cs.Id;
                csUpdate.Pickup_Status__c = caseNumberToData.get(cs.CaseNumber).PickupStatus;
                csUpdate.Pickup_Date__c = caseNumberToData.get(cs.CaseNumber).PickupDate;
                csUpdate.Approver_Remarks_Picklist__c = caseNumberToData.get(cs.CaseNumber).ApproverRemarks;
                csUpdate.Actual_Weight__c = caseNumberToData.get(cs.CaseNumber).ActualWeight;
                csUpdate.Status = caseNumberToData.get(cs.CaseNumber).Status;
                caseToUpdate.add(csUpdate);
                caseIdToCaseNumber.put(cs.Id, cs.CaseNumber);
            }

            if(caseToUpdate != null && caseToUpdate.size() > 0){
                List<Database.SaveResult> saveResults = Database.update(caseToUpdate,false);
                if(saveResults != null && saveResults.size()>0){
                    for(Database.SaveResult sr : saveResults){
                        if(sr.isSuccess() && caseIdToCaseNumber.containsKey(sr.getId())){
                            caseNumberToResult.put(caseIdToCaseNumber.get(sr.getId()),'Success');
                        }
                        else if(caseIdToCaseNumber.containsKey(sr.getId())){
                            String errorMsg = '';
                            for(Database.Error err : sr.getErrors()) {                    
                                errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            }
                            errorMsg = errorMsg.remove('\n');
                            errorMsg = errorMsg.remove('\r');
                            caseNumberToResult.put(caseIdToCaseNumber.get(sr.getId()),'Error : '+errorMsg);
                        }
                    }
                }
            }

            for(csvWrapper csv : dataWrapper){
                String baseString = csv.CaseNumber+','+csv.DocketNumber+','+csv.PickupStatus+','+csv.PickupDate+','+csv.Status+',';
                if(caseNumberToResult.containsKey(csv.CaseNumber)){
                    baseString += caseNumberToResult.get(csv.CaseNumber);
                    if(caseNumberToResult.get(csv.CaseNumber) == 'Success'){
                        successData += baseString+'\n';
                    }
                    else{
                        errorData += baseString+'\n';
                    }
                }
                else if(!caseIdToCaseNumber.containsKey(csv.CaseNumber)){
                    errorData += baseString+'Error - Pickup Case Not Exists\n';
                }
                else{
                    errorData += baseString+'Error - Some Other Error\n';
                }
            }

            if(successData != null && successData != ''){
                returnMap.put('successData',successData);
            }
            if(errorData != null && errorData != ''){
                returnMap.put('errorData',errorData);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }

    public class CsvWrapper{
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String DocketNumber;
        @AuraEnabled public String PickupStatus;
        @AuraEnabled public Datetime PickupDate;
        @AuraEnabled public String ApproverRemarks;
        @AuraEnabled public Integer ActualWeight;
        @AuraEnabled public String Status;
    }
}