public class MassTeamMemberController {
    @AuraEnabled(cacheable=true)
    public static List<User> getAllUsers() {
        return [SELECT Id, Name FROM User where Isactive=true];
    }
    
    @AuraEnabled
    public static List<string> MassBatchCallForTransfer(Map<String,Object> ownerData,map<String,Boolean> wrapp){
        List<string> batchJobId = new List<String>();
        system.debug('Size of main maap==>'+ownerData.size());
        if(ownerData.size() > 0){
            Map<String,String> userNameToId = new Map<String,String>();
            List<User> userInkeySet = [SELECT ID,USERNAME,ISACTIVE FROM USER WHERE USERNAME IN : ownerData.keySet()];
            system.debug('Size of user==>'+userInkeySet.size());
            for (User u : userInkeySet) {
                userNameToId.put(u.Username, u.Id);
            }
            //list<Mass_Transfer_Error__c> errorList = new list<Mass_Transfer_Error__c>();
            for (String key : ownerData.keySet() ) {
                if(userNameToId.containsKey(key)){
                    system.debug('List of object size==>'+((List<Object>)ownerData.get(key)).size());
                    //Id temp = Database.executeBatch(new ChangeAccountOwnerBatch((List<Object>)ownerData.get(key),userNameToId.get(key),wrapp),100);
                    //batchJobId.add(temp);
                }
                else {
                    list<object> objList = (list<object>)ownerData.get(key);
                    
                    for(object obj : objList) {
                        
                        string ErrorsMain = 'Not a valid user';
                        ProvideCsv__e event = new ProvideCsv__e();
                        
                        event.csvString__c = '"' + (string)obj + '","' + ErrorsMain + '"';
                        event.ObjectName__c = (string)obj;
                        
                        EventBus.publish(event);
                    }
                }
            }        }
        return batchJobId;
    }
    
    @AuraEnabled
    public Static List<AsyncApexJob>  ApexJobsTableData(List<String> JobId) {
        List<AsyncApexJob> jobs = [select Id, JobType, Status, TotalJobItems, JobItemsProcessed, NumberOfErrors,CreatedDate, CompletedDate from AsyncApexJob where Id in :JobId];
        system.debug('jobs ::'+jobs);
        return jobs;
    }
    
    @AuraEnabled
    public static void abortApexJob(String ApexJobId) {
        try {
            System.abortJob(ApexJobId);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Apex job has been aborted.'));
        } catch (Exception ex) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while aborting the Apex job: ' + ex.getMessage()));
        }
    }
    
    @AuraEnabled
    public static ApexJobStatus getApexJobStatus(String JobId) {
        System.debug(JobId);
        ApexJobStatus jobStatus = new ApexJobStatus();
        AsyncApexJob job = [SELECT Id, Status, TotalJobItems, JobItemsProcessed FROM AsyncApexJob WHERE Id = :JobId];
        
        jobStatus.progress = (job.TotalJobItems == 0) ? 0 : Math.round((job.JobItemsProcessed / job.TotalJobItems) * 100);
        jobStatus.isCompleted = (job.Status == 'Completed' || job.Status == 'Aborted' || job.Status == 'Failed');
        return jobStatus;
    }
    
    public class ApexJobStatus {
        @AuraEnabled public Integer progress;
        @AuraEnabled public Boolean isCompleted;
    }
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        try {
            if(inputWrapper != null){
                String fieldsToQuery = 'SELECT Id, ';
                if(string.isNotBlank(inputWrapper.fieldApiName)){
                    fieldsToQuery = fieldsToQuery + inputWrapper.fieldApiName;
                }
                if(string.isNotBlank(inputWrapper.otherFieldApiName)){
                    fieldsToQuery = fieldsToQuery + ', ' + inputWrapper.otherFieldApiName;
                }
                String query = fieldsToQuery + ' FROM '+ inputWrapper.objectApiName;
                String filterCriteria = inputWrapper.fieldApiName + ' LIKE ' + '\'' + String.escapeSingleQuotes(inputWrapper.searchString.trim()) + '%\' LIMIT 10';
                if(String.isNotBlank(inputWrapper.selectedRecordId)) {
                    query += ' WHERE Id = \''+ inputWrapper.selectedRecordId + '\'';
                }else if(String.isNotBlank(inputWrapper.parentFieldApiName) && String.isNotBlank(inputWrapper.parentRecordId)){
                    query += ' WHERE '+ inputWrapper.parentFieldApiName+ ' = \''+ inputWrapper.parentRecordId + '\'';
                    query += ' AND ' + filterCriteria;
                } 
                else {
                    query += ' WHERE '+ filterCriteria;
                }
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                System.debug(query);
                for(SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(inputWrapper.fieldApiName);
                    if(inputWrapper.otherFieldApiName != '')
                        wrap.subField = (String)s.get(inputWrapper.otherFieldApiName);
                    wrap.Id = (String)s.get('Id');
                    returnWrapperList.add(wrap);
                }
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String Id{get;set;}
    }
    
    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
    }
}