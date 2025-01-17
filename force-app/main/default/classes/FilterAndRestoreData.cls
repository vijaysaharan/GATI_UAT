public without sharing class FilterAndRestoreData {
    @AuraEnabled
    public static List<String> getObjectName(){
        try {
            List<Backup_Configuration__c> mdtList = [Select Object_Name__c from Backup_Configuration__c];
            if(!mdtList.isEmpty()){
                List<String> listToReturn = new List<String>();
                for (Backup_Configuration__c mdt : mdtList) {
                    listToReturn.add(mdt.Object_Name__c);
                }
                return listToReturn;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<InputWrapper> getSearchFields(String objectName){
        try {
            List<Backup_Configuration__c> mdtList = [Select Big_Object_Index__c,Big_Object_Name__c from Backup_Configuration__c where Object_Name__c = :objectName];
            if(!mdtList.isEmpty()){
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType objectSchema = schemaMap.get(mdtList[0].Big_Object_Name__c);
                Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
                List<InputWrapper> listToReturn = new List<InputWrapper>();
                List<String> indexFieldList = mdtList[0].Big_Object_Index__c.split(',');
                if(!indexFieldList.isEmpty()){
                    for(String s : indexFieldList){
                        InputWrapper i = new InputWrapper();
                        i.label = fieldMap.get(s).getDescribe().getLabel();
                        i.apiName = fieldMap.get(s).getDescribe().getName();
                        i.typeOfField = String.valueOf(fieldMap.get(s).getDescribe().getType()).toLowerCase();
                        listToReturn.add(i);
                    }
                    return listToReturn;
                }
                return null;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Sobject> getFilteredData(String objectName, String inputString ){
        try {
            System.debug(inputString);
            List<InputWrapper> inputFilter = (List<InputWrapper>)JSON.deserialize(inputString, List<InputWrapper>.class);
            List<Backup_Configuration__c> mdtList = [Select Big_Object_Name__c,Fields_To_Show__c,Object_Name__c from Backup_Configuration__c where Object_Name__c = :objectName];
            if(!mdtList.isEmpty()){
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType objectSchema = schemaMap.get(mdtList[0].Big_Object_Name__c);
                Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
                List<String> filedsToShowList = mdtList[0].Fields_To_Show__c.split(',');
                String query = 'Select ';
                Integer listSize = fieldMap.size();
                Integer j=0;
                for(String s : fieldMap.keySet()){
                    if(j != listSize-1){
                        query += s + ',';
                        j++;
                    }
                    else{
                        query += s;
                        j++;
                    }
                }

                query += ' from '+  mdtList[0].Big_Object_Name__c + ' where ';

                Integer listSize2 = inputFilter.size();
                for(Integer i = 0; i< listSize2; i++){
                    if(i != listSize2-1){
                        query += inputFilter[i].apiName + ' = \'' + inputFilter[i].value + '\' and ';
                    }
                    else{
                        query += inputFilter[i].apiName + ' = \'' + inputFilter[i].value + '\'';
                    }
                }

                System.debug(query);
                List<SObject> data =  Database.query(query);
                return data;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getColumn(String objectName){
        try {
            List<Backup_Configuration__c> mdtList = [Select Big_Object_Name__c,Fields_To_Show__c,Object_Name__c from Backup_Configuration__c where Object_Name__c = :objectName];
            if(!mdtList.isEmpty()){
                List<String> fieldsApiName = mdtList[0].Fields_To_Show__c.split(',');
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get(mdtList[0].Big_Object_Name__c);
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                List<Columns> cloumnList = new List<Columns>();
                for (String fieldName: fieldsApiName) {
                    Columns c = new Columns();
                    c.label = fieldMap.get(fieldName).getDescribe().getLabel();
                    c.fieldName = fieldName;
                    c.sortable = true;
                    cloumnList.add(c);
                }
                return JSON.serialize(cloumnList);
            }
            return null; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Columns> getAllFields(String objectName){
        try {
            List<Backup_Configuration__c> mdtList = [Select Big_Object_Name__c,Fields_To_Show__c,Object_Name__c from Backup_Configuration__c where Object_Name__c = :objectName];
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(mdtList[0].Big_Object_Name__c);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            List<Columns> cloumnList = new List<Columns>();
                for (String fieldName: fieldMap.keySet()) {
                    Columns c = new Columns();
                    c.label = fieldMap.get(fieldName).getDescribe().getLabel();
                    c.fieldName = fieldMap.get(fieldName).getDescribe().getName();
                    c.sortable = true;
                    cloumnList.add(c);
                }
            return cloumnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    public class InputWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String apiName {get;set;}
        @AuraEnabled public String typeOfField {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public Integer index {get;set;}
        @AuraEnabled public Boolean isDisable {get;set;}    
        @AuraEnabled public Boolean isCheck {get;set;}
    }

    public class Columns{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String fieldName{get;set;}
        @AuraEnabled public Boolean sortable{get;set;}
    }
}