global class UtilityLead {
    public static Map<String,Integration_Mapping_Table__mdt> getIntegrationMappingFields(String integrationName){
        Map<String,Integration_Mapping_Table__mdt> cfsmagSfdcMap = new Map<String,Integration_Mapping_Table__mdt>();
        for(Integration_Mapping_Table__mdt eachMapping:[SELECT Id,Integration_Tag_Name__c,SFDC_Field_Api_Name__c,SFDC_Object_Api_Name__c,Field_Validation_Message__c,Tag_Sequence__c
                                                        FROM Integration_Mapping_Table__mdt
                                                        WHERE Callout_Webservice_Name__c =:integrationName
                                                        ORDER BY Tag_Sequence__c 
                                                        DESC]){
                                                            cfsmagSfdcMap.put(eachMapping.Integration_Tag_Name__c,eachMapping);
                                                        }
        return cfsmagSfdcMap ;
        
    }
    public static List<Sobject> getSobjectRecords(String sobjectName ,Set<String> fieldSet,String whereClause){
        String queryString = 'SELECT ' +String.join(fieldSet,',')+ ' FROM '+sobjectName+whereClause;
        System.debug('queryString>>'+queryString);
        return Database.query('SELECT ' +String.join(fieldSet,',')+ ' FROM '+sobjectName+whereClause) ;
    }
    /*
    public static Map<String,String> getFieldWithDataType(String sobjectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType schema = schemaMap.get(sobjectName);
        Map<String, Schema.SObjectField> fieldMap = schema.getDescribe().fields.getMap();
        Map<String,String> fieldWithDataTypeMap = new Map<String,String>();
        for (String fieldName: fieldMap.keySet()) {
            System.debug('String.valueOf(fieldMap.get(fieldName))>>'+String.valueOf(fieldMap.get(fieldName)));
            System.debug('String.valueOf(fieldMap.get(fieldName).getDescribe().getType())>>'+String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
            fieldWithDataTypeMap.put(String.valueOf(fieldMap.get(fieldName)),String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
        }
        System.debug('fieldWithDataTypeMap>>'+fieldWithDataTypeMap);
        return fieldWithDataTypeMap;
        
    }
    public static Boolean dataValidation(String integrationType,String dataType,Object value){
        Boolean isValidFormat = true;
        String strValue = '';
        if(dataType == 'ID'|| dataType =='REFERENCE'){
            strValue= String.valueOf(value);
            System.debug('strValue.isAlphanumeric()>>'+strValue.isAlphanumeric());
            System.debug('strValue.length() != 15>>'+strValue.length());
            if(strValue.length() < 15 || (strValue.length() > 15 && strValue.length()< 18) || !strValue.isAlphanumeric())
            {
                isValidFormat = false; 
            }
        }
        return isValidFormat;
        
    }
    public static Object getParsedValue(String dataType,Object value){
        System.debug('dataType>>'+dataType);
        System.debug('value>>'+value);
        if(value!=null && String.valueOf(value)!='')
        {
        if(dataType == 'DATE'){
            return Date.parse(String.valueOf(value));
        }
        else if(dataType == 'DATETIME'){
            Datetime dateTme;
            List<String> dateTimeParts = String.valueOf(value).split(' ');
            List<String> dateParts = dateTimeParts[0].split('/');
            Integer day = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer year = Integer.valueOf(dateParts[2]);
            
            List<String> timeParts = dateTimeParts[1].split(':');
            Integer hour = Integer.valueOf(timeParts[0]);
            Integer minute = Integer.valueOf(timeParts[1]);
            Integer second = Integer.valueOf(timeParts[2]);
            return Datetime.newInstance(year, month, day, hour, minute, second);
        }
        else if(dataType == 'BOOLEAN'){
            return Boolean.valueOf(value);
            
        }
        else if(datatype == 'DOUBLE'){
            return Double.valueOf(value);
            
        }
        else{
            return value;
        }
        }
        else{
             return null;
        }
    }
    */
    public static String prepareJSONStructure(String integrationName,Map<String,Integration_Mapping_Table__mdt> cfsmagSfdcMap,sObject sObjectRecord){
        Map<String, Object> dataToSerialize = new Map<String, Object>{};
            if(!cfsmagSfdcMap.isEmpty()){
                for(String eachTag : cfsmagSfdcMap.keySet()){
                    if(String.isNotBlank(eachTag)){
                        if(integrationName == Constants.ACCOUNT_PUSH && Constants.EXCEPTION_CASE_TAG_SET.contains(eachTag)){
                            //CFSMAGAccountCalloutService.innerTagMapping(dataToSerialize,eachTag,cfsmagSfdcMap?.get(eachTag).SFDC_Field_Api_Name__c,sObjectRecord);
                        }
                        else if(integrationName == Constants.LEAD_PUSH && Constants.GATI_EXCEPTION_TAG_SET.contains(eachTag)){
                            GATILeadCalloutService.exceptionTagMapping(dataToSerialize,eachTag,cfsmagSfdcMap?.get(eachTag).SFDC_Field_Api_Name__c,sObjectRecord);
                        }
                        else{
                            dataToSerialize.put(eachTag,sObjectRecord?.get(cfsmagSfdcMap?.get(eachTag).SFDC_Field_Api_Name__c));
                        }
                    }

                }
                
            }
        return JSON.serialize(dataToSerialize);
        
    }
    /*
    public static Boolean isNullOrBlank(Object eachTag)
    {  
        return (eachTag==null && eachTag=='') ?  true : false;
        
    }

    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }*/
}