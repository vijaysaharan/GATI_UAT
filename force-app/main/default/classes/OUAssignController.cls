public class OUAssignController {
    @AuraEnabled 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText ){
                                      
                                      searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                      
                                      String query='';
                                      
                                      query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
                                          ' FROM '+objectName+
                                          ' WHERE '+fld_API_Search+' LIKE '+searchText+' AND RecordType.Name='+System.Label.RecordTypeId+' LIMIT '+lim;
                                      
                                      System.debug('--- debtor query---'+query);
                                      
                                      List<sObject> sobjList = Database.query(query);
                                      List<ResultWrapper> lstRet = new List<ResultWrapper>();
                                      
                                      for(SObject s : sobjList){
                                          ResultWrapper obj = new ResultWrapper();
                                          obj.objName = objectName;
                                          obj.text = String.valueOf(s.get(fld_API_Text)) ;
                                          obj.val = String.valueOf(s.get(fld_API_Val))  ;
                                          lstRet.add(obj);
                                      } 
                                      return JSON.serialize(lstRet) ;
                                  }
    
    @AuraEnabled 
    public static String assignOU(String recordId, String ouId){
        System.debug('---'+recordId+'--'+ouId);
        Lead ld = [SELECT Id,Lead_Assigned_OU__c FROM Lead WHERE Id=:recordId LIMIT 1];
        ld.Lead_Assigned_OU__c = ouId;
        try{
            update ld;
            return ld.Id;
        }Catch(Exception ex){
            return ex.getMessage()+ex.getLineNumber();
        }
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        
    }
    
    
}