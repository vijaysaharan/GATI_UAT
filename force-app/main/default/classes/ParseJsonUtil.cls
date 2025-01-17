public class ParseJsonUtil {
    public static Map<String,List<Sobject>> MetaDataToSobjects = new Map<String,List<Sobject>>();
    public static Map<String,Object> MetaDataToVariable = new Map<String,Object>();
    
    
    public static String parseJson(String metadataToParse, Boolean isList){
        String payload = '';
        JSONTemplate__mdt metaObject; 
        if(!metadataToParse.contains('#')){
         	metaObject = [SELECT Template__c,Query__c,Identifier__c FROM JSONTemplate__mdt WHERE DeveloperName = :metadataToParse];
        }else{
            metaObject = [SELECT Template__c,Query__c,Identifier__c FROM JSONTemplate__mdt WHERE DeveloperName = :metadataToParse.split('#')[0]];
        }
        List<Sobject> operationDataList = ParseJsonUtil.MetaDataToSobjects.get(metadataToParse);
        if(operationDataList == null || operationDataList.size() == 0){
            return '';
        }
        if(metaObject == null){
            return '';
        }

        List<String> jsonObjectList = new List<String>();
        Integer index = 0;
        for(Sobject data : operationDataList){
            String tempPayload = populateTemplateWithObjectData(metaObject.template__c,data);
            tempPayload = populateTemplateWithVariableData(metadataToParse,tempPayload,index++);
            String mergeMetadataregex = '\\(![a-zA-Z0-9_#]+\\)';
            Matcher matcher = Pattern.compile(mergeMetadataregex).matcher(tempPayload);
            while(matcher.find()) {
                String metaDevName = matcher.group();
                metaDevName = metaDevName.substring(2, metaDevName.length() - 1);
                String pattern = '\\(!' + metaDevName + '\\)';
                tempPayload = tempPayload.replaceAll(pattern, ParseJsonUtil.parseJson(metaDevName,String.valueOf(data.get(metaObject.Identifier__c))));
            }
         	jsonObjectList.add(tempPayload);
        }
        payload =  String.join(jsonObjectList, ',');
        if(isList || (operationDataList.size() > 1)){
            payload = '[' + payload + ']';
        }
        return payload;
    }
    
    public static String parseJson(String metadataToParse,String identifier){
        String payload = '';
        JSONTemplate__mdt metaObject; 
        if(!metadataToParse.contains('#')){
         	metaObject = [SELECT Template__c,Query__c,Identifier__c FROM JSONTemplate__mdt WHERE DeveloperName = :metadataToParse]; 
        }else{
            metaObject = [SELECT Template__c,Query__c,Identifier__c FROM JSONTemplate__mdt WHERE DeveloperName = :metadataToParse.split('#')[0]];
        }
        List<Sobject> operationDataList = ParseJsonUtil.MetaDataToSobjects.get(metadataToParse+identifier);
        if(operationDataList == null || operationDataList.size() == 0){
            return '';
        }
        if(metaObject == null){
            return '';
        }
        List<String> jsonObjectList = new List<String>();
        Integer index = 0;
        for(Sobject data : operationDataList){
            String tempPayload = populateTemplateWithObjectData(metaObject.template__c,data);
            tempPayload = populateTemplateWithVariableData(metadataToParse,tempPayload,index++);
            String mergeMetadataregex = '\\(![a-zA-Z0-9_#]+\\)';
            Matcher matcher = Pattern.compile(mergeMetadataregex).matcher(tempPayload);
            while(matcher.find()) {
                String metaDevName = matcher.group();
                metaDevName = metaDevName.substring(2, metaDevName.length() - 1);
                String pattern = '\\(!' + metaDevName + '\\)';
                tempPayload = tempPayload.replaceAll(pattern, ParseJsonUtil.parseJson(metaDevName,String.valueOf(data.get(metaObject.Identifier__c))));
            }
         	jsonObjectList.add(tempPayload);
        }
        payload =  String.join(jsonObjectList, ',');
        return payload;
    }
    
    public static String populateTemplateWithObjectData(String template, SObject record) {
        String regexTest = '\\{![a-zA-Z0-9._]+\\}';
        // String regexTest = '\\{!\\w+\\.?\\w+\\}';
        // String str = template;
        System.debug('template length----->'+template.length());
        Matcher matcher = Pattern.compile(regexTest).matcher(template);
        while(matcher.find()) {
            String field = matcher.group();
            field = field.substring(2, field.length() - 1);
            String pattern = '\\{!' + field + '\\}';
            if(!field.contains('.')) {
                template = template.replaceAll(pattern, String.valueOf(record.get(field) != null?(record.get(field)):('null')));
            }
            else {
                List<String> subFields = field.split('\\.');
                SObject tempSObj = record;
                for(Integer i = 0; i < subFields.size(); i++) {
                    if(i != subFields.size() - 1) {
                        tempSObj = tempSObj.getSObject(subFields[i]);
                        if(tempSObj == null){
                            template = template.replaceAll(pattern, 'null');
                            break;
                        }
                    }
                    else {
                        if(tempSObj.get(subFields[i]) != null)
                        	template = template.replaceAll(pattern, String.valueOf(tempSObj.get(subFields[i])));
                        else
                            template = template.replaceAll(pattern, 'null');
                    }
                }
            }
        }
        System.debug('template after change------>' + template.length());
        return template;
    }

    public static String populateTemplateWithVariableData(String metaDevName, String template, Integer index){
        String regexTest = '\\[![a-zA-Z0-9._]+\\]';
        Matcher matcher = Pattern.compile(regexTest).matcher(template);
        while(matcher.find()) {
            String variable = matcher.group();
            variable = variable.substring(2, variable.length() - 1);
            String pattern = '\\[!' + variable + '\\]';
            String variableKey = metaDevName+ String.valueOf(index) + variable;
            template = template.replaceAll(pattern, String.valueOf(MetaDataToVariable.get(variableKey) != null?(MetaDataToVariable.get(variableKey)):('null')));
        }
        return template;
    }
}