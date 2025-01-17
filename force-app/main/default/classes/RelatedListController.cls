public with sharing class RelatedListController {


    @AuraEnabled
    public static String getConfigData(String relatedObjectName, String recordId, String relatedLookup){
        try {
            CongifRes c = new CongifRes();
            List<Backup_Configuration__c> bconfig = [select Fields_To_Show__c, Mapping_S2B__c, Child_To_Backup__c, Big_Object_Index__c from Backup_Configuration__c where Big_Object_Name__c = :relatedObjectName];
            c.data = getData(relatedObjectName, bconfig[0].Fields_To_Show__c, relatedLookup, recordId, bconfig[0].Mapping_S2B__c, bconfig[0].Big_Object_Index__c);
            c.relatedfieldList = bconfig[0].Fields_To_Show__c;
            c.childRelation = JSON.serialize(bconfig[0]);
            Map<String,String> fMap = (Map<String,String>)JSON.deserialize(bconfig[0].Mapping_S2B__c, Map<String,String>.class);
            c.idField = fMap.get('Id');
            c.indexField = bconfig[0].Big_Object_Index__c;
            return JSON.serialize(c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getChildConfig(String config){
        try {
            Backup_Configuration__c parentConfig = (Backup_Configuration__c)JSON.deserialize(config, Backup_Configuration__c.class);
            List<String> childData = parentConfig.Child_To_Backup__c.split(',');
            Map<String,String> objToRelatedFieldMap = new Map<String,String>();
            for(String temp : childData){
                List<String> splitData = temp.split(':');
                objToRelatedFieldMap.put(splitData[0], splitData[1]);
            }
            List<Backup_Configuration__c> listToReturn = [select Fields_To_Show__c, Mapping_S2B__c, Child_To_Backup__c, Big_Object_Index__c, Big_Object_Name__c ,Object_Name__c from Backup_Configuration__c where Object_Name__c IN : objToRelatedFieldMap.keySet()];
            ChildConfigResult toReturn = new ChildConfigResult();
            toReturn.configList = JSON.serialize(listToReturn);
            toReturn.objTofidMap = JSON.serialize(objToRelatedFieldMap); 
            return JSON.serialize(toReturn);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   /* @AuraEnabled
    public static void getDataForRelated(String finalConfig){
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    
    
    @AuraEnabled
    public static List<SObject> getData(String relatedObjectName, String relatedFieldList, String relatedLookup, String recordId, String conigMap,String bigIndex){
        try {
            Map<String,String> SToBMap = (Map<String,String>)JSON.deserialize(conigMap, Map<String,String>.class); 
            if(relatedFieldList != null && relatedFieldList != null && relatedLookup != null){
                // if csv is need to be given in related list then we will add the stobmap value to the query
                List<String> filedsList = relatedFieldList.split(',');
                if(!filedsList.contains( SToBMap.get('Id'))){
                    filedsList.add(SToBMap.get('Id'));
                }

                List<String> indexList = bigIndex.split(',');
                for(String index : indexList){
                    if(!filedsList.contains(index)){
                        filedsList.add(index);
                    }
                }


                String query = 'select ';
                Integer lengthFieldList = filedsList.size();
                for(Integer i = 0; i< lengthFieldList; i++){
                    if(i != lengthFieldList-1){
                        query += filedsList[i] + ',';
                    }
                    else{
                        query += filedsList[i];
                    }
                }
                // List<String> indexList = bigIndex.split(',');
                // + indexList[0] + ' <= TODAY AND ' 
                query += ' from ' + relatedObjectName + ' where '+ relatedLookup + ' = \'' + recordId + '\' ';
                return Database.query(query);
                
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static string getColumn(String relatedObjectName, List<String> fieldsApiName){
        try {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(relatedObjectName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            List<Columns> cloumnList = new List<Columns>();
            for (String fieldName: fieldsApiName) {
                Columns c = new Columns();
                c.label = fieldMap.get(fieldName).getDescribe().getLabel();
                c.fieldName = fieldName;
                c.typeOfField = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
                // c.fieldName = fieldMap.get(fieldName).getDescribe().getName();
                c.sortable = true;
                cloumnList.add(c);
            }
            return JSON.serialize(cloumnList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean deleteRecord(String relatedFieldList, Map<String,String> recordTodelete, String relatedObjectName, String bigObjectIndex){
        try {
            if(bigObjectIndex != null){
                // Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                // Schema.SObjectType recordSchema = schemaMap.get(relatedObjectName);
                // SObject record =  recordSchema.newSObject();
                String query = 'Select ';
                List<String> indexList = bigObjectIndex.split(',');
                Integer listSize = indexList.size();
                for(Integer i = 0; i< listSize; i++){
                    if(i != listSize-1){
                        query += indexList[i] + ',';
                    }
                    else{
                        query += indexList[i];
                    }
                }
                query += ' from ' + relatedObjectName + ' where ';
                for(Integer i = 0; i< listSize; i++){
                    if(i != listSize-1){
                        query += indexList[i] + ' = \'' + recordTodelete.get(indexList[i]) + '\' and ';
                    }
                    else{
                        query += indexList[i] + ' = \'' + recordTodelete.get(indexList[i]) + '\'';
                    }
                }
                Database.deleteImmediate(Database.query(query));
                return true;
            }else{
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType recordSchema = schemaMap.get(relatedObjectName);
                SObject record =  recordSchema.newSObject();
                record.put( 'Id' , recordTodelete.get('Id'));
                Database.deleteImmediate(record);
                return true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String viewRecord(String bigObjectIndex,String relatedObjectName, String recordString){
        try {
            Map<String,Object> record = (Map<String,Object>)JSON.deserializeUntyped(recordString);
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(relatedObjectName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            String query = 'Select ';
            Integer listSize = fieldMap.values().size();
            if(bigObjectIndex != null){

                query += String.join( new List<string>(fieldMap.keySet()), ',') + ' from ' + relatedObjectName + ' where ';
                List<String> indexList = bigObjectIndex.split(',');
                Integer listSize2 = indexList.size();
                for(Integer i = 0; i< listSize2; i++){
                        if(i != listSize2-1){
                            if(String.valueOf(fieldMap.get(indexList[i]).getDescribe().getType()) == 'DATETIME'){
                                query += indexList[i] + ' = ' + record.get(indexList[i]) + ' and ';
                            }else{
                                query += indexList[i] + ' = \'' + record.get(indexList[i]) + '\' and ';
                            }
                        }
                        else{
                            if(String.valueOf(fieldMap.get(indexList[i]).getDescribe().getType()) == 'DATETIME'){
                                query += indexList[i] + ' = ' + record.get(indexList[i]);
                            }else{
                                query += indexList[i] + ' = \'' + record.get(indexList[i]) + '\'';
                            }
                        }
                    }

               
                List<SObject> data =  Database.query(query);
                Backup_Configuration__c b = [select Layout_Mapping__c from Backup_Configuration__c where Big_Object_Name__c = :relatedObjectName limit 1];

                Map<String,String> layoutMapping = (Map<String,String>)JSON.deserialize(b.Layout_Mapping__c, Map<String,String>.class);
                


                if(!data.isEmpty()){
                    
                    String recordType;
                    if(fieldMap.keySet().contains('recordtypeid__c')){
                        recordType = (String)data[0].get('RecordTypeID__c');
                    }else{
                        recordType = 'Default';
                    }
                    String layoutString = layoutMapping.get(recordType);
                    List<String> sectionList = layoutString.split('%%');
                    List<ViewResult> toReturn = new List<ViewResult>();
                    for(String sectionDetail: sectionList){
                        List<String> headerAndFields = sectionDetail.split('@');
                        ViewResult vres = new ViewResult();
                        vres.sectionLabel = headerAndFields[0];
                        vres.sectionData = new List<ViewData>();
                        for(String field : headerAndFields[1].split(',')){
                            ViewData v = new ViewData();
                            v.data = data[0].get(field)==null?'':data[0].get(field);
                            v.label = fieldMap.get(field).getDescribe().getLabel();
                            v.apiName = fieldMap.get(field).getDescribe().getName();
                            v.typeOfField = String.valueOf(fieldMap.get(field).getDescribe().getType()).toLowerCase();
                            vres.sectionData.add(v);
                        }
                        toReturn.add(vres);
                    }
                    return JSON.serialize(toReturn);
                }

               return null; 
            }else{
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

               query += ' from '+ relatedObjectName + ' where Id = \'' + record.get('Id') +'\'';
               System.debug(query);
               List<SObject> data =  Database.query(query);

                if(!data.isEmpty()){
                    List<ViewData> toReturn = new List<ViewData>();
                    for(String s : fieldMap.keySet()){
                        ViewData v = new ViewData();
                        v.data = data[0].get(s);
                        v.label = fieldMap.get(s).getDescribe().getLabel();
                        v.typeOfField = String.valueOf(fieldMap.get(s).getDescribe().getType()).toLowerCase();
                        System.debug(v.typeOfField);
                        if(v.data != null){
                            toReturn.add(v);
                        }
                    }
                    System.debug('To return---->' + toReturn);
                    return JSON.serialize(toReturn);
                }

               return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static MappingBigObjToStd__mdt getRestoreMapping(String restoreFrom, String restoreTo){
    //     try {
    //         if(restoreFrom != null && restoreTo != null){
    //             List<MappingBigObjToStd__mdt> mapping = [select  RestoreFrom__c, RestoreTo__c, MappingLabelToApi__c  from MappingBigObjToStd__mdt where RestoreFrom__c = :restoreFrom and RestoreTo__c = :restoreTo ];
    //             if(!mapping.isEmpty()){
    //                 return mapping[0];
    //             }
    //             return null;
    //         }
    //         return null;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    @AuraEnabled
    public static Boolean insertSobject(SObject s){
        try {
            insert s;
            System.debug(s.get('Id'));
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static CsvData createCsv(String parentId,String relatedObjectName){
        try {
            List<Backup_Configuration__c> bc = [Select Object_Name__c,Big_Object_Name__c,Mapping_S2B__c,Big_Object_Index__c from Backup_Configuration__c where Big_Object_Name__c = :relatedObjectName];
            Map<String,String> sToB = (Map<String,String>)JSON.deserialize(bc[0].Mapping_S2B__c, Map<String,String>.class);
            String header = String.join(new List<String>(sToB.keySet()), ',');
            String query = 'Select ';
            query +=  String.join(sToB.values(), ',');
            query += ' from ' + relatedObjectName + ' where ' + bc[0].Big_Object_Index__c.substring(0,bc[0].Big_Object_Index__c.indexOf(',')) + ' = :parentId limit 50000';

            
            CsvData dt = new CsvData();
            dt.data = Database.query(query);
            dt.StoB = sToB;
            return dt;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    

    // @AuraEnabled
    // public static string getSearchedData(String SearchValue){
    //     try {

    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    public class Columns{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String fieldName{get;set;}
        @AuraEnabled public Boolean sortable{get;set;}
        @AuraEnabled public String typeOfField{get;set;}

    }

    public class ViewData {
        @AuraEnabled public Object data{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String typeOfField{get;set;}
        @AuraEnabled public String apiName{get;set;}
    }

    class CongifRes{
        public List<SObject> data;
        public string relatedfieldList;
        public String childRelation;
        public String idField;
        public String indexField;
    }

    class ChildConfigResult{
        public String configList;
        public String objTofidMap;
    }

    public class CsvData {
        @AuraEnabled public List<SObject> data;
        @AuraEnabled public map<String,String> StoB;
    }

    public class ViewResult{
        @AuraEnabled public List<ViewData> sectionData;
        @AuraEnabled public String sectionLabel;
    }

    
}