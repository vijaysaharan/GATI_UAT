public with sharing class CaseOwnerBulkChangeController {
    @AuraEnabled
    public static Map<String,String> csvDataHandler(String csvDataList){
        Map<String,String> returnMap = New Map<String,String>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        String lineBreak = '\n';
        String successHeader = 'CaseNumber,UserName,Message\n';
        String successData = '';
        String errorHeader = 'CaseNumber,UserName,Message\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);
        try {
            Set<String> caseNumbers = new Set<String>();
            Set<String> userNames = new Set<String>();
            List<Case> caseToUpdate = new List<Case>();
            Map<String, User> userNameToUser = new Map<String, User>();
            Map<String, String> caseNumberToResult = new Map<String, String>();
            Map<String, csvWrapper> caseNumberToData = new Map<String, csvWrapper>();
            Map<Id, String> caseIdToCaseNumber = new Map<Id, String>();

            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );

            for(csvWrapper csv : dataWrapper){
                caseNumbers.add(csv.CaseNumber);
                caseNumberToData.put(csv.CaseNumber, csv);
                userNames.add(csv.userName);
            }

            Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, CaseNumber,Docket_Number__c,Pickup_Status__c, 
                                Pickup_Date__c, Approver_Remarks_Picklist__c, Actual_Weight__c, Status 
                                FROM Case 
                                WHERE CaseNumber IN :caseNumbers
                                AND Status != 'Closed'
                               ]);

            List<User> userList = [SELECT Id,Username 
                                   FROM User 
                                   WHERE Username IN :userNames 
                                   AND IsActive = true
                                  ];

            if(userList != null && userList.size() > 0){
                for(User usr : userList){
                    userNameToUser.put(usr.Username, usr);
                }
            }

            for(Case cs : casesMap.values()){
                Case csUpdate = new Case();
                csUpdate.Id = cs.Id;
                if(userNameToUser.containsKey(caseNumberToData.get(cs.CaseNumber).UserName)){
                    csUpdate.OwnerId = userNameToUser.get(caseNumberToData.get(cs.CaseNumber).UserName).Id;
                    caseToUpdate.add(csUpdate);
                    caseIdToCaseNumber.put(cs.Id, cs.CaseNumber);
                }
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
                String baseString = csv.CaseNumber+','+csv.UserName+',';
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
                    errorData += baseString+'Error - User Not Active or Not Available\n';
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
        @AuraEnabled public String UserName;
    }
}