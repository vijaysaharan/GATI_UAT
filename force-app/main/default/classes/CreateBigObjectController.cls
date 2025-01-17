public with sharing class CreateBigObjectController {
    public CreateBigObjectController() {
        
    }

    @AuraEnabled
    public static string listOfSobject(){
        try {
            List<OptionList> listToReturn = new List<OptionList>();
            for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
                OptionList o = new OptionList();
                o.value = objTyp.getDescribe().getName();
                o.label = objTyp.getDescribe().getLabel();
                if(!o.value.endsWith('__b')){
                    listToReturn.add(o);
                }
            }
            return JSON.serialize(listToReturn);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getFields(String objectApiName){
        try {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objectSchema = schemaMap.get(objectApiName);
            Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
            List<OptionList> listToReturn = new List<OptionList>();
            for(Schema.SObjectField fieldTyp : fieldMap.values()){
                OptionList o = new OptionList();
                o.value = fieldTyp.getDescribe().getName();
                o.label = fieldTyp.getDescribe().getLabel();
                o.fieldType = String.valueOf(fieldTyp.getDescribe().getType());
                listToReturn.add(o);
            }

            return JSON.serialize(listToReturn);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createBigObject(String forObject, String fieldNameWithTypeJSON, String bigObjectName){
        try {
            CreateDynamicBigObject c = new CreateDynamicBigObject();
            return c.createBigObject(forObject, fieldNameWithTypeJSON,bigObjectName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static void createB2SMapping(String mappingData, String objectName, String configId){
    //     try {
    //         CreateDynamicBigObject c = new CreateDynamicBigObject();
    //         c.updateB2SMapping(mappingData, objectName, configId);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    public class OptionList {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String fieldType{get;set;}
    }
}