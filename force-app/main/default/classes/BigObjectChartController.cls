public with sharing class BigObjectChartController {

    @AuraEnabled
    public static string getDataForChart(String recordId, String relatedObject, String relatedFieldAtObject, String filedName){
        try {
            String query = 'Select '+ filedName + ' from '+ relatedObject + ' where ' + relatedFieldAtObject + ' = \''+ recordId +'\' limit 49999';
            List<SObject> returnList = Database.query(query);
            return JSON.serialize(returnList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}