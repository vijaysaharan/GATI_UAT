public without sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        List<string> lstExcludeitems = new List<string>();
        if(ExcludeitemsList != null && ExcludeitemsList.size()>0){
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }   
        }
        String sQuery =  'SELECT Id, Name, Email, Account.Name FROM ' + ObjectName +' WHERE Name LIKE: searchKey AND Id NOT IN : lstExcludeitems ORDER BY createdDate DESC LIMIT 5';
        List <sObject> lstOfRecords = Database.query(sQuery);        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static Contact ContactDetail(Id conId){ 
        Contact objCon = [SELECT Id, Name, Email FROM Contact WHERE Id=:conId];
        return objCon;
    }
}