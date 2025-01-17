public with sharing class ReuseableCsvConvertor {
    @AuraEnabled
    public static String getCsvData(String contentVersionId){
        try {
            List<ContentVersion> cvList = [Select VersionData from ContentVersion where Id = :contentVersionId];
            return  cvList[0].VersionData.toString();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}