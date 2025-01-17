public with sharing class CreateDynamicBigObject {

    public Map<String,String> sTypeToBType = new Map<String,String>();
    public CreateDynamicBigObject() {
       this.sTypeToBType.put('address', 'Text');
       this.sTypeToBType.put('anytype', 'Text');
       this.sTypeToBType.put('base64', 'Text');
       this.sTypeToBType.put('boolean', 'Text');
       this.sTypeToBType.put('combobox', 'Text');
       this.sTypeToBType.put('currency', 'Number');
       this.sTypeToBType.put('long', 'Text');
       this.sTypeToBType.put('location', 'Text');
       this.sTypeToBType.put('integer', 'Number');
       this.sTypeToBType.put('id', 'Text');
       this.sTypeToBType.put('encryptedstring', 'Text');
       this.sTypeToBType.put('email', 'Text');
       this.sTypeToBType.put('double', 'Number');
       this.sTypeToBType.put('datetime', 'DateTime');
       this.sTypeToBType.put('date', 'DateTime');
       this.sTypeToBType.put('datacategorygroupreference', 'Text');
       this.sTypeToBType.put('multipicklist', 'LongTextArea');
       this.sTypeToBType.put('percent', 'Number');
       this.sTypeToBType.put('phone', 'Text');
       this.sTypeToBType.put('picklist', 'Text');
       this.sTypeToBType.put('reference', 'Lookup');
       this.sTypeToBType.put('textarea', 'LongTextArea');
       this.sTypeToBType.put('time', 'DateTime');
       this.sTypeToBType.put('url', 'Url');
       this.sTypeToBType.put('string', 'Text');
    } 

    public String createBigObject(String forObject, String fieldNameWithTypeJSON, String bigObjectName) {
        List<FieldNameWrapper> fieldNamewithtype = (List<FieldNameWrapper>)JSON.deserialize(fieldNameWithTypeJSON, List<FieldNameWrapper>.class);
        ObjectSelected objectData = (ObjectSelected)JSON.deserialize(forObject,ObjectSelected.class);

        //fetching session Id
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();  
        service.SessionHeader = new MetadataService.SessionHeader_element();  
        //service.SessionHeader.sessionId = UserInfo.getSessionId(); 
        service.endpoint_x = 'callout:ApexMDAPI1/services/Soap/m/55.0';
        service.SessionHeader.sessionId = '{!$Credential.OAuthToken}';
        

        service.AllOrNoneHeader = new MetadataService.AllOrNoneHeader_element();  
        service.AllOrNoneHeader.allOrNone = true; //this is required for Big Objects

        if(forObject != '' || forObject !=null){
            MetadataService.CustomObject bigObject = new MetadataService.CustomObject();
             
            // if(forObject.contains('__c')){
            //     forObject = forObject.replaceAll('__c', '__b');
            // }else{
            //     forObject += '__b';
            // }
            // String label = objectData.labelName+' Backup';
            // objectData.labelName = objectData.labelName.replaceAll(' ', '');
            // objectData.labelName = objectData.labelName.replaceAll('[^a-zA-Z0-9]','')+'Backup';
            // objectData.labelName += '__b';

            bigObjectName = bigObjectName.replaceAll( ' ' ,'');
            bigObjectName = bigObjectName.replaceAll('[^a-zA-Z0-9]','');
            bigObjectName = bigObjectName + '__b';
            
            System.debug(bigObjectName);
            bigObject.fullName = bigObjectName;  
            bigObject.label = bigObjectName.removeEnd('__b');  
            bigObject.pluralLabel = bigObjectName.removeEnd('__b')+'s';  
            bigObject.deploymentStatus = 'Deployed'; //Make it Deployed if you need

            if(!fieldNamewithtype.isEmpty()){
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType objectSchema = schemaMap.get(objectData.developerName);
                Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
                Map<String,String> fieldMapping = new Map<String,String>();
                Map<String,String> fieldMappingreverse = new Map<String,String>();


                List<MetadataService.CustomField> lstCustomFields = new List<MetadataService.CustomField>();
                System.debug(fieldNamewithtype);
                for(FieldNameWrapper field : fieldNamewithtype){
                    MetadataService.CustomField fieldObj = new MetadataService.CustomField(); 
                    if(this.sTypeToBType.get(String.valueOf(fieldMap.get(field.apiName).getDescribe().getType()).toLowerCase()) == 'Text'){
                        fieldObj.type_x = 'Text';  
                        fieldObj.label = field.bigLableName;  
                        fieldObj.fullName = field.bigApiName;
                        if(field.indexed){
                            fieldObj.length = field.lengthOfField;
                        }else{
                            fieldObj.length = 255;
                        }  
                        fieldObj.required = field.indexed;  
                        lstCustomFields.add(fieldObj); 
                    }else if(this.sTypeToBType.get(String.valueOf(fieldMap.get(field.apiName).getDescribe().getType()).toLowerCase()) == 'Number'){
                        fieldObj.type_x = 'Number';  
                        fieldObj.label = field.bigLableName;  
                        fieldObj.fullName = field.bigApiName;  
                        fieldObj.precision = 18;  
                        fieldObj.required = field.indexed;  
                        fieldObj.scale = fieldMap.get(field.apiName).getDescribe().getScale();         
                        lstCustomFields.add(fieldObj);  
                    }else if(this.sTypeToBType.get(String.valueOf(fieldMap.get(field.apiName).getDescribe().getType()).toLowerCase()) == 'LongTextArea'){
                        fieldObj.type_x = 'LongTextArea';  
                        fieldObj.label = field.bigLableName;  
                        fieldObj.fullName = field.bigApiName;
                        if(field.indexed){
                            fieldObj.length = field.lengthOfField;
                        }else{
                            fieldObj.length = fieldMap.get(field.apiName).getDescribe().getLength()<300?300:fieldMap.get(field.apiName).getDescribe().getLength();
                        }       
                        fieldObj.visibleLines = 3;           
                        lstCustomFields.add(fieldObj);
                    }
                    else if(this.sTypeToBType.get(String.valueOf(fieldMap.get(field.apiName).getDescribe().getType()).toLowerCase()) == 'Lookup'){ 
                        fieldObj.type_x = 'Text';  
                        fieldObj.label = field.bigLableName;  
                        fieldObj.fullName = field.bigApiName;  
                        fieldObj.length = fieldMap.get(field.apiName).getDescribe().getLength()!=0?fieldMap.get(field.apiName).getDescribe().getLength():6;
                        fieldObj.required = field.indexed;
                        lstCustomFields.add(fieldObj);  
                    }
                    else if(this.sTypeToBType.get(String.valueOf(fieldMap.get(field.apiName).getDescribe().getType()).toLowerCase()) == 'DateTime'){
                        fieldObj.type_x = 'DateTime';  
                        fieldObj.label = field.bigLableName;  
                        fieldObj.fullName = field.bigApiName;  
                        fieldObj.required = field.indexed;
                        lstCustomFields.add(fieldObj);
                        System.debug(fieldMap.get(field.apiName).getDescribe().getLength());
                    }
                    fieldMapping.put(fieldMap.get(field.apiName).getDescribe().getName(),field.labelName.replaceAll('[^a-zA-Z0-9]', '')+'__c');
                    fieldMappingreverse.put(field.labelName.replaceAll('[^a-zA-Z0-9]', '')+'__c',fieldMap.get(field.apiName).getDescribe().getName());
                }
                bigObject.fields = lstCustomFields; 

                List<MetadataService.Index> lstIndex = new List<MetadataService.Index>() ;  
                MetadataService.Index indexObj = new MetadataService.Index(); 
                indexObj.label = 'MyIndex';  
                indexObj.fullName = 'MyIndex';
                bigObject.indexes = lstIndex;
                
                List<MetadataService.IndexField> lstIndexFields = new List<MetadataService.IndexField>();
                String indexIndex = '';
                for(FieldNameWrapper field : fieldNamewithtype){
                    if(field.indexed){
                        MetadataService.IndexField indfl = new MetadataService.IndexField();  
                        indfl.name = field.bigApiName;
                        indexIndex += field.bigApiName+',';
                        indfl.sortDirection = field.sortDirection;  
                        lstIndexFields.add(indfl);
                    }
                }

                indexObj.fields = lstIndexFields;  
                lstIndex.add(indexObj);

               
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:ApexMDAPI1/services/data/v22.0/query/?q=SELECT+id+from+contact');
                    req.setMethod('GET');
                if(!Test.isRunningTest()){
                    HttpResponse res = h.send(req);

                  
                    service.timeout_x = 60000;
                    List<MetadataService.SaveResult> saveResults = service.createMetadata(new List<MetadataService.Metadata>{bigObject}); 
                    MetadataService.SaveResult saveResult = saveResults[0]; 
                    
                    if(saveResult==null || saveResult.success){
                        Backup_Configuration__c bc = new Backup_Configuration__c();
                        bc.Object_Name__c = objectData.developerName;
                        bc.Big_Object_Name__c =  bigObjectName;
                        bc.Big_Object_Index__c = indexIndex.removeEnd(',');
                        bc.Mapping_S2B__c = JSON.serialize(fieldMapping);
                        bc.Mapping_B2S__c = JSON.serialize(fieldMappingreverse);
                        insert bc;
                        ReturnWrapper r = new ReturnWrapper();
                        r.filedMappingToChange = fieldMapping;
                        r.idOfConfig = bc.Id;
                        return JSON.serialize(r);
                    }else{
                        if(saveResult.errors!=null){  
                            for(MetadataService.SaveResult s : saveResults){
                                System.debug(s.errors[0].message);
                            }  
                            List<String> messages = new List<String>();  
                            messages.add(  
                                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +  
                                    'occured processing component ' + saveResult.fullName + '.');  
                            for(MetadataService.Error error : saveResult.errors)  
                                messages.add(  
                                    error.message + ' (' + error.statusCode + ').' +  
                                    ( error.fields!=null && error.fields.size()>0 ?  
                                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );  
                            if(messages.size()>0)  
                                System.debug(String.join(messages, ' '));
                                
                            // CalloutException e = new CalloutException();
                            // e.setMessage(String.join(messages, ' '));
                            // throw e;
                        }  
                        if(!saveResult.success) {
                        System.debug('Request failed with no specified error.');
                        } 
                        return null;
                        }               
                    }

                  }
           return null;
        }
        return null;
    }

    // public void updateB2SMapping(String mappingData, String objectName, String configId) {
    //     Backup_Configuration__c bc = new Backup_Configuration__c();
    //     bc.Id = (Id)configId;
    //     bc.Mapping_B2S__c = mappingData;
    //     update bc;
    // }

    class FieldNameWrapper{
        @AuraEnabled public String labelName{get;set;}
        @AuraEnabled public String apiName{get;set;}
        @AuraEnabled public Boolean indexed{get;set;}
        @AuraEnabled public String sortDirection{get;set;}
        @AuraEnabled public Integer lengthOfField{get;set;}
        @AuraEnabled public String bigApiName{get;set;}
        @AuraEnabled public String bigLableName{get;set;}
    }

    class ReturnWrapper{
        @AuraEnabled public Map<String,String> filedMappingToChange{get;set;}
        @AuraEnabled public String idOfConfig{get;set;}
    }

    class ReturnWrapper2{
        @AuraEnabled public String filedMappingToChange{get;set;}
        @AuraEnabled public String idOfConfig{get;set;}
    }

    public class ObjectSelected {
        @AuraEnabled public String developerName{get;set;}
        @AuraEnabled public String labelName{get;set;}
    }
}