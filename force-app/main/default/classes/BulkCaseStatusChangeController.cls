public with sharing class BulkCaseStatusChangeController {
    @AuraEnabled    
    public static Map<String,String> CsvDataHandler(String csvDataList) {
        Map<String,String> returnMap = New Map<String,String>();
        Map<string,Object> results = New Map<string,Object>();
        Map<String,csvWrapper> dataMap = New Map<String,csvWrapper>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        Set<String> caseNumbersClosed = new Set<String>();
        Set<String> alreadyClosedCaseNumbers = new Set<String>();
        String lineBreak = '\n';
        String successHeader = 'CaseNumber,DocketNumber,CaseStatus,Status,Message\n';
        String successData = '';
        String errorHeader = 'CaseNumber,DocketNumber,CaseStatus,Status,Message\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);

        try {
            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );
            List<Case> caseForUpdate = New List<Case>();
            for (csvWrapper csv : dataWrapper) {
                if(csv.CaseNumber != null){
                    dataMap.put(csv.CaseNumber,csv);
                }
            }
            Map<Id,Case> targetCaseMap = new Map<Id,Case>([SELECT Id,Status,CaseNumber,Docket_Number__c 
                                         FROM Case 
                                         WHERE CaseNumber IN: dataMap.keySet() 
                                         AND Type = 'Non Delivery Reasons'
                                        ]);
            for(Case c : targetCaseMap.values()){
                if(c.Status != 'Closed'){
                    c.Status = 'Closed';
                    caseForUpdate.add(c);
                    caseNumbersClosed.add(c.CaseNumber);
                }else{
                    alreadyClosedCaseNumbers.add(c.CaseNumber);
                }
            }
            if(caseForUpdate != null && caseForUpdate.size()>0){
                List<Database.SaveResult> saveResults = Database.update(caseForUpdate,false);
                if(saveResults != null && saveResults.size()>0){
                    for(Integer i=0;i<saveResults.size(); i++){
                        Database.SaveResult sr = saveResults[i];
                        if (sr.isSuccess() && targetCaseMap.containsKey(sr.getId())) {
                            successData += targetCaseMap.get(sr.getId()).CaseNumber+','+targetCaseMap.get(sr.getId()).Docket_Number__c+','+targetCaseMap.get(sr.getId()).Status+',Success,'+sr.getId()+' Updated RecordId'+lineBreak;
						} else {
                            String error = '';
							for(Database.Error err : sr.getErrors()) {
                                error = err.getStatusCode() +' - ' + err.getMessage();
							}
                            errorData += targetCaseMap.get(sr.getId()).CaseNumber+','+targetCaseMap.get(sr.getId()).Docket_Number__c+','+targetCaseMap.get(sr.getId()).Status+',Error,'+error+lineBreak;
						}
                    }
                    for(csvWrapper csv : dataWrapper){
                        if(alreadyClosedCaseNumbers.contains(csv.CaseNumber)){
                            successData += csv.CaseNumber+','+csv.DocketNumber+',Closed,Success,'+'Already Closed!'+lineBreak;
                        }
                        else if(!caseNumbersClosed.contains(csv.CaseNumber) && !alreadyClosedCaseNumbers.contains(csv.CaseNumber)){
                            successData += csv.CaseNumber+','+csv.DocketNumber+',,Success,'+'This is not a type of NDR'+lineBreak;
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
            else if(alreadyClosedCaseNumbers != null && alreadyClosedCaseNumbers.size()>0){
                for(csvWrapper csv : dataWrapper){
                    if(alreadyClosedCaseNumbers.contains(csv.CaseNumber)){
                        successData += csv.CaseNumber+','+csv.DocketNumber+',Closed,Success,'+'Already Closed!'+lineBreak;
                    }
                    else if(!caseNumbersClosed.contains(csv.CaseNumber) && !alreadyClosedCaseNumbers.contains(csv.CaseNumber)){
                        successData += csv.CaseNumber+','+csv.DocketNumber+',,Success,'+'This is not a type of NDR'+lineBreak;
                    }
                }
                if(successData != '' && successData != null){
                    returnMap.put('successData',successData);
                }
            }
            System.debug('returnMap'+returnMap);
            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class csvWrapper{
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String DocketNumber;
    }
}